use tokio::process::Command;
use std::process::Stdio;

#[tokio::main]
async fn main() {
    println!("Building static_web_server binary locally...");
    let build_status = Command::new("cargo")
        .arg("build")
        .arg("--release")
        .current_dir("./static_web_server")
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .await;

    match build_status {
        Ok(status) if status.success() => println!("Binary built successfully."),
        Ok(status) => {
            eprintln!("Binary build failed with status: {}", status);
            return;
        },
        Err(e) => {
            eprintln!("Failed to run cargo build: {}", e);
            return;
        }
    }

    let copy_status = Command::new("cp")
        .arg("./static_web_server/target/release/static_web_server")
        .arg("./static_web_server/static_web_server")
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .await;

    match copy_status {
        Ok(status) if status.success() => println!("Binary copied for container build."),
        Ok(status) => {
            eprintln!("Binary copy failed with status: {}", status);
            return;
        },
        Err(e) => {
            eprintln!("Failed to copy binary: {}", e);
            return;
        }
    }

    println!("Building static_web_server Podman image (offline)...");
    let podman_status = Command::new("podman")
        .arg("build")
        .arg("-t")
        .arg("static_web_server:latest")
        .arg("-f")
        .arg("Podmanfile")
        .arg("./static_web_server")
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .await;

    match podman_status {
        Ok(status) if status.success() => println!("Image built successfully."),
        Ok(status) => {
            eprintln!("Image build failed with status: {}", status);
            return;
        },
        Err(e) => {
            eprintln!("Failed to run podman build: {}", e);
            return;
        }
    }

    println!("Starting static_web_server container...");
    let run_status = Command::new("podman")
        .arg("run")
        .arg("-d")
        .arg("--name")
        .arg("my-web-container")
        .arg("-p")
        .arg("80:8080")
        .arg("static_web_server:latest")
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .await;

    match run_status {
        Ok(status) if status.success() => println!("Container started successfully. Access your site at http://127.0.0.1"),
        Ok(status) => eprintln!("Container failed to start with status: {}", status),
        Err(e) => eprintln!("Failed to run podman container: {}", e),
    }
}
