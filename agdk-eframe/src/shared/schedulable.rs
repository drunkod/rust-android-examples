use actix::prelude::*;
use anyhow::{anyhow, Error};
use auteur_controlling::controller::State;
use chrono::{DateTime, Utc};
use std::time::Duration;

#[derive(Debug, Clone)]
pub struct StateMachine {
    pub state: State,
    pub cue_time: Option<DateTime<Utc>>,
    pub end_time: Option<DateTime<Utc>>,
    schedule_handle: Option<SpawnHandle>,
}

impl Default for StateMachine {
    fn default() -> Self {
        Self {
            state: State::Initial,
            cue_time: None,
            end_time: None,
            schedule_handle: None,
        }
    }
}

pub enum StateChangeResult {
    Success,
    Skip,
}

pub trait Schedulable<A: Actor<Context = Context<A>>>
where
    A: Schedulable<A>,
{
    fn state_machine(&self) -> &StateMachine;
    fn state_machine_mut(&mut self) -> &mut StateMachine;
    fn node_id(&self) -> &str;
    fn next_time(&self) -> Option<DateTime<Utc>>;

    fn transition(
        &mut self,
        ctx: &mut Context<A>,
        target: State,
    ) -> Result<StateChangeResult, Error>;

    fn start_schedule(
        &mut self,
        ctx: &mut Context<A>,
        cue_time: Option<DateTime<Utc>>,
        end_time: Option<DateTime<Utc>>,
    ) -> Result<(), Error> {
        let state_machine = self.state_machine_mut();

        if state_machine.state != State::Initial {
            return Err(anyhow!("Node {} is already scheduled", self.node_id()));
        }

        state_machine.cue_time = cue_time;
        state_machine.end_time = end_time;

        self.schedule_next(ctx)?;
        Ok(())
    }

    fn reschedule(
        &mut self,
        ctx: &mut Context<A>,
        cue_time: Option<DateTime<Utc>>,
        end_time: Option<DateTime<Utc>>,
    ) -> Result<(), Error> {
        let state_machine = self.state_machine_mut();

        if let Some(cue_time) = cue_time {
            if state_machine.state == State::Started {
                return Err(anyhow!("Cannot reschedule start time after node has started"));
            }
            state_machine.cue_time = Some(cue_time);
        }

        if let Some(end_time) = end_time {
            if state_machine.state == State::Stopped {
                return Err(anyhow!("Cannot reschedule end time after node has stopped"));
            }
            state_machine.end_time = Some(end_time);
        }

        // Reset to initial if we're prerolling
        if state_machine.state == State::Starting {
            self.transition(ctx, State::Initial)?;
        }

        self.stop_schedule(ctx);
        self.schedule_next(ctx)?;
        Ok(())
    }

    fn stop_schedule(&mut self, ctx: &mut Context<A>) {
        if let Some(handle) = self.state_machine_mut().schedule_handle.take() {
            ctx.cancel_future(handle);
        }
    }

    fn schedule_next(&mut self, ctx: &mut Context<A>) -> Result<(), Error>
    where
        A: Schedulable<A>,
    {
        if let Some(next_time) = self.next_time() {
            let now = Utc::now();
            if next_time > now {
                let duration = (next_time - now).to_std()?;
                let handle = ctx.run_later(duration, |act, ctx| {
                    act.handle_scheduled_transition(ctx);
                });
                self.state_machine_mut().schedule_handle = Some(handle);
            } else {
                self.handle_scheduled_transition(ctx);
            }
        }
        Ok(())
    }

    fn handle_scheduled_transition(&mut self, ctx: &mut Context<A>)
    where
        A: Schedulable<A>,
    {
        let current_state = self.state_machine().state;
        let next_state = match current_state {
            State::Initial => State::Starting,
            State::Starting => State::Started,
            State::Started => State::Stopping,
            State::Stopping => State::Stopped,
            State::Stopped => return,
        };

        match self.transition(ctx, next_state) {
            Ok(StateChangeResult::Success) => {
                self.state_machine_mut().state = next_state;
                let _ = self.schedule_next(ctx);
            }
            Ok(StateChangeResult::Skip) => {
                // Skip to next state
                self.state_machine_mut().state = next_state;
                self.handle_scheduled_transition(ctx);
            }
            Err(e) => {
                log::error!("Failed to transition to {:?}: {}", next_state, e);
            }
        }
    }
}
