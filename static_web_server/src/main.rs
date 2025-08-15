use hyper::{Body, Request, Response, Server};
use hyper::service::{make_service_fn, service_fn};
use std::fs;
use std::net::SocketAddr;
use std::path::Path;

async fn serve_index(_req: Request<Body>) -> Result<Response<Body>, hyper::Error> {
    let path = Path::new("./index.html");
    match fs::read(path) {
        Ok(contents) => Ok(Response::new(Body::from(contents))),
        Err(_) => Ok(Response::builder()
            .status(404)
            .body(Body::from("404 Not Found"))
            .unwrap()),
    }
}

#[tokio::main]
async fn main() {
    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    let make_svc = make_service_fn(|_conn| async {
        Ok::<_, hyper::Error>(service_fn(serve_index))
    });
    println!("Static web server running on http://127.0.0.1:8080");
    let server = Server::bind(&addr).serve(make_svc);
    if let Err(e) = server.await {
        eprintln!("Server error: {}", e);
    }
}
