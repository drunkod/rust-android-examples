use async_trait::async_trait;
use anyhow::Result;

#[async_trait]
pub trait MediaPipeline: Send + Sync {
    async fn start(&mut self) -> Result<()>;
    async fn stop(&mut self) -> Result<()>;
    async fn set_state(&mut self, state: PipelineState) -> Result<()>;
}
pub enum PipelineState {
    Null,
    Ready,
    Playing,
    Paused,
