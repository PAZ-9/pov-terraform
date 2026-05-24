# counting-app — Terraform Infrastructure

Three-tier infrastructure with a dashboard app, counting service, and PostgreSQL RDS in **eu-west-2**.

## Architecture

```
Internet
    │
    ▼
Internet Gateway
    │
    ▼
Tier 1 — Public Subnet (10.0.1.0/24)
    ├── Dashboard EC2  ◄── port 9009 (public)
    └── NAT Gateway
            │
            ▼
Tier 2 — Private Subnet (10.0.2.0/24)
    └── Counting EC2  ◄── port 9009 (from dashboard SG only)
            │
            ▼
Tier 3 — DB Subnets (10.0.3.0/24, 10.0.4.0/24)
    └── RDS PostgreSQL  ◄── port 5432 (from counting SG only)
```

- **Tier 1 — Dashboard** — public EC2, internet-facing on port 9009. Calls the counting service via private IP.
- **Tier 2 — Counting** — private EC2, no public IP. Accepts traffic from dashboard SG only. Queries RDS on every request to increment and return the counter.
- **Tier 3 — Database** — RDS PostgreSQL across 2 AZs (eu-west-2a, eu-west-2b). Accepts connections from counting SG only. Persists the counter in a `counter` table.
- **Private key** — generated locally as `counting-app-ssh-key.pem` (0400) and copied to the dashboard instance at `~/.ssh/counting-app-ssh-key.pem`.

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with profile `master-console-admin`

## Usage

```bash
# Initialise providers and modules
terraform init

# Preview changes
terraform plan

# Deploy
terraform apply
```

## Outputs

| Output | Description |
|--------|-------------|
| `dashboard_app_url` | Public URL to access the dashboard app |
| `dashboard_instance_ip` | Public IP of the dashboard instance |
| `counting_instance_ip` | Private IP of the counting instance |
| `ssh_dashboard` | SSH command to connect to the dashboard instance |
| `ssh_counting` | SSH command to connect to the counting instance via jump host |
| `db_endpoint` | RDS PostgreSQL endpoint |
| `db_password` | RDS master password (sensitive — use `terraform output db_password`) |

```bash
# Print all outputs after apply
terraform output

# Get DB password (sensitive — must be requested explicitly)
terraform output db_password

# Alternatively, read it from the counting instance
sudo grep DB_PASS /usr/lib/systemd/system/counting-api.service
```

## SSH Access

```bash
# Dashboard (direct)
ssh -i counting-app-ssh-key.pem ubuntu@<dashboard_public_ip>

# Counting (via dashboard jump host)
ssh -i counting-app-ssh-key.pem -J ubuntu@<dashboard_public_ip> ubuntu@<counting_private_ip>
```

## Verify Services

**On the counting instance:**
```bash
sudo systemctl status counting-api.service
sudo systemctl status counting-api.service | grep -E "Active|since"
sudo cat /var/log/counting-service.log
sudo ss -tlnp | grep 9009
curl http://localhost:9009

# Get DB password
sudo grep DB_PASS /usr/lib/systemd/system/counting-api.service

# Connect to DB interactively (will prompt for password)
psql -h counting-app-postgres.cduyesa4gx4j.eu-west-2.rds.amazonaws.com -p 5432 -U dbadmin -d countingdb

# Once inside psql shell
# \dt                        -- list all tables
# \d counter                 -- describe counter table
# SELECT * FROM counter;     -- show full row (id + count)
# SELECT count FROM counter;       -- show count value only
# UPDATE counter SET count = 0;    -- reset counter to 0
# \q                               -- quit

# Or run a one-liner query
psql -h <db_endpoint> -p 5432 -U dbadmin -d countingdb -c "SELECT count FROM counter;"
psql -h counting-app-postgres.cduyesa4gx4j.eu-west-2.rds.amazonaws.com:5432 -U dbadmin -d countingdb -c "SELECT count FROM counter;"

```

**On the dashboard instance:**
```bash
sudo systemctl status dashboard-api.service
sudo cat /var/log/dashboard-service.log
sudo ss -tlnp | grep 9009
curl http://localhost:9009
curl http://<counting_private_ip>:9009
```

**From local:**
```bash
curl http://<dashboard_public_ip>:9009
```

## Files

| File | Purpose |
|------|---------|
| `provider.tf` | AWS, TLS, local, null provider configuration |
| `variables.tf` | Input variable definitions |
| `terraform.tfvars` | Variable values |
| `main.tf` | VPC, subnets, IGW, NAT Gateway, route tables |
| `keypair.tf` | EC2 key pair — generates and saves private key locally |
| `data.tf` | Latest Ubuntu 24.04 AMI lookup |
| `sg.tf` | Security groups for dashboard and counting instances |
| `ec2.tf` | EC2 instances and private key copy to dashboard |
| `outputs.tf` | URLs, IPs, and SSH commands |
| `dashboard-service.sh` | Dashboard app userdata script |
| `counting-service.sh` | Counting app userdata — Python HTTP server backed by PostgreSQL |
| `rds.tf` | RDS PostgreSQL instance, subnet group, random password |

## Verify DB Persistence After Counting Instance Restart

This test proves the dashboard is getting the counter from the database, not from memory.
If the count continues from where it left off after a restart, data is persisted in RDS.

**Step 1 — Note the current count from the dashboard (local machine):**
```bash
curl http://<dashboard_public_ip>:9009
# Note the count value, e.g. {"count": 42}
```

**Step 2 — Check the count in the database (on counting instance):**
```bash
# SSH into counting instance
ssh -i counting-app-ssh-key.pem -J ubuntu@<dashboard_public_ip> ubuntu@<counting_private_ip>

# Query the DB directly
psql -h <db_endpoint> -U dbadmin -d countingdb -c "SELECT count FROM counter;"
# Should match the value from Step 1
```

**Step 3 — Restart the counting service:**
```bash
# On the counting instance
sudo systemctl restart counting-api.service

# Confirm it restarted cleanly
sudo systemctl status counting-api.service
```

**Step 4 — Hit the dashboard again immediately after restart (local machine):**
```bash
curl http://<dashboard_public_ip>:9009
# Count must continue from where it left off, e.g. {"count": 43}
# NOT reset to 0 — this confirms data comes from RDS, not memory
```

**Step 5 — Confirm count incremented in DB (on counting instance):**
```bash
psql -h <db_endpoint> -U dbadmin -d countingdb -c "SELECT count FROM counter;"
# Should now show 43
```

**Expected result:**

| Scenario | In-memory only | Backed by RDS |
|----------|---------------|---------------|
| Before restart | 42 | 42 |
| After restart + 1 request | 1 ← reset | 43 ← continues |

> If the count resets to 1 after restart, the service is not connecting to the DB.
> Check `sudo journalctl -u counting-api.service` for connection errors.

## Teardown

```bash
terraform destroy
```

> **Note:** The private key file `counting-app-ssh-key.pem` is written to this directory and stored in Terraform state. Do not commit it to version control. Add it to `.gitignore`:
> ```
> *.pem
> .terraform/
> terraform.tfstate*
> ```
