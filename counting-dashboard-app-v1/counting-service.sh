#!/bin/bash
exec > /var/log/counting-service.log 2>&1
set -x

echo "Starting counting service setup"

sudo apt update -y
sudo apt-get install -y python3 python3-pip python3-psycopg2 postgresql-client net-tools curl

# Write the counting service Python app
sudo cat > /usr/local/bin/counting-service.py << 'PYEOF'
#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import psycopg2
import json
import os

DB_HOST = os.environ["DB_HOST"]
DB_NAME = os.environ["DB_NAME"]
DB_USER = os.environ["DB_USER"]
DB_PASS = os.environ["DB_PASS"]
PORT    = int(os.environ.get("PORT", 9009))

def get_conn():
    return psycopg2.connect(host=DB_HOST, dbname=DB_NAME, user=DB_USER, password=DB_PASS)

def init_db():
    conn = get_conn()
    cur  = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS counter (
            id    SERIAL PRIMARY KEY,
            count INTEGER NOT NULL DEFAULT 0
        )
    """)
    cur.execute(
        "INSERT INTO counter (count) SELECT 0 WHERE NOT EXISTS (SELECT 1 FROM counter LIMIT 1)"
    )
    conn.commit()
    cur.close()
    conn.close()

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        conn  = get_conn()
        cur   = conn.cursor()
        cur.execute("UPDATE counter SET count = count + 1 RETURNING count")
        count = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        body = json.dumps({"count": count}).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        pass

init_db()
print(f"Counting service listening on port {PORT}", flush=True)
HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
PYEOF

sudo chmod 755 /usr/local/bin/counting-service.py

# Create systemd service — DB vars injected by Terraform templatefile at apply time
sudo cat > /usr/lib/systemd/system/counting-api.service << EOF
[Unit]
Description=Counting API service
After=syslog.target network.target

[Service]
Environment=PORT=9009
Environment=DB_HOST=${db_host}
Environment=DB_NAME=${db_name}
Environment=DB_USER=${db_user}
Environment=DB_PASS=${db_pass}
ExecStart=/usr/bin/python3 /usr/local/bin/counting-service.py
User=ubuntu
Group=ubuntu
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sleep 1
sudo systemctl enable counting-api.service
sudo systemctl start counting-api.service
sleep 2
sudo systemctl status counting-api.service
sudo ss -tlnp | grep 9009
