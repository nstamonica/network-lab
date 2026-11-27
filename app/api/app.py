import json
import os
import socket
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(os.environ.get("PORT", "8080"))
POD = socket.gethostname()   # in Kubernetes, this is the name of this copy of the app

# Chaos switch for Phase 4: if FAIL_MODE is "crash", quit on purpose
if os.environ.get("FAIL_MODE") == "crash":
    print("FAIL_MODE=crash, exiting", flush=True)
    sys.exit(1)


class Handler(BaseHTTPRequestHandler):
    def send_json(self, code, body):
        data = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == "/health":
            self.send_json(200, {"status": "ok"})
        elif self.path == "/api/status":
            client = self.headers.get("X-Real-IP", self.client_address[0])
            self.send_json(200, {"app": "netmedic-demo", "pod": POD, "client": client})
        else:
            self.send_json(404, {"error": "not found"})


if __name__ == "__main__":
    print(f"api listening on :{PORT}", flush=True)
    ThreadingHTTPServer(("", PORT), Handler).serve_forever()