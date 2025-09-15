use serde::Deserialize;

#[derive(Deserialize)]
pub struct CreateSourceCommand {
    pub id: String,
    pub uri: String,
}
