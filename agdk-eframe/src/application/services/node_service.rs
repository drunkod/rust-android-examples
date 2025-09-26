use actix::Actor;
use crate::domain::nodes::node::Node;
use anyhow::Result;
use std::collections::HashMap;

pub struct NodeService {
    nodes: HashMap<String, Node>,
}

impl NodeService {
    pub fn new() -> Self {
        Self {
            nodes: HashMap::new(),
        }
    }

    pub async fn create_source(&mut self, id: String, uri: String) -> Result<()> {
        // Since Node is an enum, you'll need to use it differently
        // For example, if you're creating a Source:
        use crate::domain::nodes::source::Source;

        let source = Source::new(&id, &uri, true, true);
        let source_addr = source.start();

        self.nodes.insert(id, Node::Source(source_addr));
        Ok(())
    }
}
