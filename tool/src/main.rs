use std::process::Command;

use axum::extract::Path;
use axum::routing::post;
use axum::Router;

async fn index(Path(name): Path<String>) {
    let _ = Command::new("fish")
        .arg("-c")
        .arg(format!("~/.local/bin/proj_run {name}"))
        .stdout(std::process::Stdio::inherit())
        .spawn()
        .expect("Failed to run project {name}");
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/run/:name", post(index));

    axum::Server::bind(&"0.0.0.0:42069".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}
