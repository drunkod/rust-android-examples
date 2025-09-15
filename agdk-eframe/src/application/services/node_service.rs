use crate::domain::nodes::node::Node;
use crate::infrastructure::gstreamer::pipeline_adapter::GStreamerPipeline;
use crate::infrastructure::gstreamer::stream_producer_adapter::GStreamerStreamProducer;
use anyhow::Result;
use std::collections::HashMap;

pub struct NodeService {
    nodes: HashMap<String, Node<GStreamerPipeline, GStreamerStreamProducer>>,
}

impl NodeService {
    pub fn new() -> Self {
        Self {
            nodes: HashMap::new(),
        }
    }

    pub async fn create_source(&mut self, id: String, uri: String) -> Result<()> {
        // Use case implementation
        let pipeline = GStreamerPipeline::new(&uri)?;
        let node = Node::new(id.clone(), pipeline);
        self.nodes.insert(id, node);
        Ok(())
    }
}
