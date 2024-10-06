//! Implementation of the HTTP service

use super::config::Config;
use std::sync::Arc;

use crate::nodes::node::{CommandMessage, NodeManager, StopMessage};

use actix::{Actor, Addr, SystemService};
use actix_web::{error, web, App, HttpRequest, HttpResponse, HttpServer, Responder};
use actix_web_actors::ws;

use auteur_controlling::controller::Command;
use tracing::error;

use log::{debug};
// Function to create a command
async fn create_command(
    node_manager: web::Data<Addr<NodeManager>>,
    json: web::Json<Command>,
) -> HttpResponse {
    println!("#21 Create_command with json: {:?}", json.0);
    let message = CommandMessage { command: json.0 };
    let response = node_manager.send(message).await;

    // Return a JSON response with the result of the operation
    HttpResponse::Ok()
        .content_type::<_>("application/json")
        .body(format!("{:?}", response))
}

// Function to start the server based on the passed `Config`.
pub async fn run(cfg: Config) -> Result<(), anyhow::Error> {
    log::debug!("Running server with config: {:?}", cfg);
    println!("#33 Running server with config: {:?}", cfg);
    // Initialize NodeManager
    let node_manager = NodeManager::from_registry();
    // Setup HTTP server
    let server = HttpServer::new(move || {
        App::new()
        .app_data(web::Data::new(node_manager.clone())) // Share NodeManager across routes
        .wrap(actix_web::middleware::Logger::default()) // Use Logger middleware
        .wrap(tracing_actix_web::TracingLogger::default()) // Use TracingLogger middleware
        .route("/command", web::post().to(create_command)) // Setup route to create_command
    });
    // Setup server to use TLS if configured
    let server = if cfg.use_tls {
        use openssl::ssl::{SslAcceptor, SslFiletype, SslMethod};

        let mut builder = SslAcceptor::mozilla_intermediate(SslMethod::tls())?;
        builder.set_private_key_file(
            cfg.key_file.as_ref().expect("No key file given"),
            SslFiletype::PEM,
        )?;
        builder.set_certificate_chain_file(
            cfg.certificate_file
                .as_ref()
                .expect("No certificate file given"),
        )?;
        // Bind server with openssl if TLS is used    
        server.bind_openssl(format!("0.0.0.0:{}", cfg.port), builder)?
    } else {
        // Bind server without using openssl if TLS is not used
        server.bind(format!("0.0.0.0:{}", cfg.port))?
    };
    // Start the server
    server.run().await?;

    // let result = server.run().await;
    // println!("server returned: {:?}", result);
    // match result {
    //     Ok(_) => {
    //         println!("Server started successfully");
    //         log::info!("Server started successfully");
    //     },
    //     Err(e) => {
    //         println!("Failed to start server: {:?}", e);
    //         log::error!("Failed to start server: {:?}", e);
    //         return Err(anyhow::anyhow!(e));
    //     }
    // }       
    // When the server stops running, a StopMessage is sent to the NodeManager actor.
    let _ = NodeManager::from_registry().send(StopMessage).await;
    println!(" server running successfully");
    Ok(())
}
