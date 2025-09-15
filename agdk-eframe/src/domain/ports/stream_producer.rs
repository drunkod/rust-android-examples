use anyhow::Result;
use async_trait::async_trait;

#[async_trait]
pub trait StreamProducerPort: Send + Sync + Clone {
    fn add_consumer(&self, consumer_id: &str) -> Result<()>;
    fn remove_consumer(&self, consumer_id: &str);
    fn forward(&self);
    fn get_consumer_ids(&self) -> Vec<String>;
}
