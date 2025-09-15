use crate::domain::ports::stream_producer::StreamProducerPort;
use anyhow::Result;
use async_trait::async_trait;

#[derive(Clone)]
pub struct GStreamerStreamProducer;

#[async_trait]
impl StreamProducerPort for GStreamerStreamProducer {
    fn add_consumer(&self, _consumer_id: &str) -> Result<()> {
        unimplemented!()
    }

    fn remove_consumer(&self, _consumer_id: &str) {
        unimplemented!()
    }

    fn forward(&self) {
        unimplemented!()
    }

    fn get_consumer_ids(&self) -> Vec<String> {
        unimplemented!()
    }
}
