use crate::domain::ports::media_pipeline::{MediaPipeline, PipelineState};
use anyhow::{anyhow, Result};
use async_trait::async_trait;
use gst::prelude::*;

pub struct GStreamerPipeline {
    pipeline: gst::Pipeline,
}

impl GStreamerPipeline {
    pub fn new(uri: &str) -> Result<Self> {
        gst::init()?;
        let pipeline = gst::parse_launch(&format!("uridecodebin uri={} ! videoconvert ! autovideosink", uri))?
            .downcast::<gst::Pipeline>()
            .map_err(|_| anyhow!("Failed to downcast to gst::Pipeline"))?;

        Ok(Self { pipeline })
    }
}

#[async_trait]
impl MediaPipeline for GStreamerPipeline {
    async fn start(&mut self) -> Result<()> {
        self.pipeline.set_state(gst::State::Playing)?;
        Ok(())
    }

    async fn stop(&mut self) -> Result<()> {
        self.pipeline.set_state(gst::State::Null)?;
        Ok(())
    }

    async fn set_state(&mut self, state: PipelineState) -> Result<()> {
        let gst_state = match state {
            PipelineState::Null => gst::State::Null,
            PipelineState::Ready => gst::State::Ready,
            PipelineState::Playing => gst::State::Playing,
            PipelineState::Paused => gst::State::Paused,
        };
        self.pipeline.set_state(gst_state)?;
        Ok(())
    }
}
