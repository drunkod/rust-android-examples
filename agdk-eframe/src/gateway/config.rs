//! Configuration options for the application

use std::path::PathBuf;
use structopt::StructOpt;

impl Default for Config {
    fn default() -> Self {
        Config {
            port: 8080, // default value for port
            use_tls: false, // default value for use_tls
            certificate_file: None, // default value for certificate_file
            key_file: None, // default value for key_file
            log_path: None, // default value for log_path
        }
    }
}

#[derive(Debug, StructOpt)]
#[structopt(
    name = "auteur",
    about = "Manages GSTreamer processing nodes through a websocket API"
)]
pub struct Config {
    /// Port to use.
    #[structopt(short, long, default_value = "8080")]
    pub port: u16,
    /// Use TLS.
    #[structopt(short = "t", long, requires("certificate-file"), requires("key-file"))]
    pub use_tls: bool,
    /// Certificate public key file.
    #[structopt(short = "c", long)]
    pub certificate_file: Option<PathBuf>,
    /// Certificate private key file.
    #[structopt(short = "k", long)]
    pub key_file: Option<PathBuf>,
    /// Where logs should be stored
    #[structopt(long)]
    pub log_path: Option<PathBuf>,
}
