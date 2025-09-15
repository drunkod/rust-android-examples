#[cfg(test)]
pub use test_utilities::*;

#[cfg(test)]
mod test_utilities {
    use anyhow::Result;
    use auteur_controlling::controller::{Command, CommandResult, NodeInfo};

    pub fn asset_uri(file: &str) -> String {
        format!("file:///tmp/test_assets/{}", file)
    }

    pub async fn create_source(id: &str, uri: &str, audio: bool, video: bool) -> Result<()> {
        // Test implementation
        Ok(())
    }

    pub async fn create_local_destination(id: &str, name: &str, _config: Option<()>) -> Result<()> {
        // Test implementation
        Ok(())
    }

    pub async fn connect(
        link_id: &str,
        src: &str,
        dest: &str,
        audio: bool,
        video: bool,
        config: Option<()>,
    ) -> Result<()> {
        // Test implementation
        Ok(())
    }

    pub async fn node_info_unchecked(id: &str) -> NodeInfo {
        // Test implementation
        unimplemented!("Test utility")
    }

    // Add other test utilities as needed
}
