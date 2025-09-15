use crate::domain::ports::media_pipeline::{MediaPipeline, PipelineState};
use crate::domain::ports::stream_producer::StreamProducerPort;
use anyhow::Result;
use chrono::{DateTime, Utc};
use std::sync::{Arc, Mutex};

pub struct Node<P: MediaPipeline, S: StreamProducerPort> {
    id: String,
    state: NodeState,
    pipeline: Arc<Mutex<P>>,
    producers: Vec<S>,
}
pub enum NodeState {
    Initial,
    Starting,
    Started,
    Stopping,
    Stopped,
impl<P: MediaPipeline, S: StreamProducerPort> Node<P, S> {
    pub fn new(id: String, pipeline: P) -> Self {
        Self {
            id,
            state: NodeState::Initial,
            pipeline: Arc::new(Mutex::new(pipeline)),
            producers: vec![],
        }
    }
    pub async fn start(&mut self, _cue_time: Option<DateTime<Utc>>) -> Result<()> {
        // Pure business logic
        self.state = NodeState::Starting;
        self.pipeline.lock().unwrap().start().await?;
        self.state = NodeState::Started;
        Ok(())
    pub async fn stop(&mut self) -> Result<()> {
        self.state = NodeState::Stopping;
        self.pipeline.lock().unwrap().stop().await?;
        self.state = NodeState::Stopped;
