use axum::{extract::Path, routing::post, Router};
use std::{
    process::{Command, ExitStatus},
    time::Duration,
};

fn compile(proj: String) -> bool {
    println!("Compiling {proj}");

    let exit_code = Command::new("g++")
        .args(&[
            "-std=c++14",
            "-Wall",
            "-Wextra",
            "-o",
            &proj,
            &format!("{}.cpp", &proj),
        ])
        .current_dir(std::fs::canonicalize(format!("./{}", &proj)).unwrap())
        .stdout(std::process::Stdio::inherit())
        .spawn()
        .expect("Failed to spawn g++")
        .wait()
        .expect("Failed to run g++");

    exit_code.success()
}

fn run(proj: String) -> Result<Duration, ExitStatus> {
    println!("Running {proj}");

    let mut cmd = Command::new(format!("./{proj}"));
    cmd.current_dir(std::fs::canonicalize(format!("./{}", &proj)).unwrap());
    cmd.stdout(std::process::Stdio::inherit());

    let start = std::time::Instant::now();
    let exit_code = cmd
        .spawn()
        .expect(&format!("Failed to spawn {proj}"))
        .wait()
        .expect(&format!("Failed to run {proj}"));

    if exit_code.success() {
        Ok(start.elapsed())
    } else {
        Err(exit_code)
    }
}

async fn run_handle(Path(name): Path<String>) {
    if !compile(name.clone()) {
        println!("Project {name} failed to compile");
        return;
    }
    match run(name.clone()) {
        Ok(duration) => println!("\nDone in {} ms", duration.as_millis()),
        Err(code) => println!("\nExited with {code}"),
    }
}

fn create_iproj(name: String) {
    use std::fs;

    fs::create_dir(&name).expect("Failed to create project directory");
    fs::File::create(format!("{}/{}.cpp", &name, &name)).expect("Failed to create project file");
}

fn create_fproj(name: String) {
    use std::fs;

    fs::create_dir(&name).expect("Failed to create project directory");
    fs::File::create(format!("{}/{}.cpp", &name, &name)).expect("Failed to create project file");
    fs::File::create(format!("{}/{}.in", &name, &name)).expect("Failed to create project file");
    fs::File::create(format!("{}/{}.out", &name, &name)).expect("Failed to create project file");
}

#[derive(serde::Deserialize)]
struct Create {
    name: String,
    t: String,
}
async fn create_handle(Path(Create { name, t }): Path<Create>) {
    match t.as_str() {
        "i" => create_iproj(name),
        "f" => create_fproj(name),
        _ => println!("Unknown project type {t}"),
    }
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/run/:name", post(run_handle))
        .route("/clr", post(|| async { clearscreen::clear().unwrap() }))
        .route("/create/:t/:name", post(create_handle));

    axum::Server::bind(&"0.0.0.0:42069".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap()
}
