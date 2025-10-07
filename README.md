# How to run `Nexus.sh` on Ubuntu

## 1. Install Git, screen, and curl
```bash
sudo apt update
sudo apt install -y git screen curl
```

## 2. Clone the repo
```bash
git clone https://github.com/nongdancryptos/Nexus.git
cd Nexus
```

## 3. Make the script executable
```bash
chmod +x nexus.sh
```

## 4. Prepare the `id.txt` file (one NODE-ID per line)
Create the `id.txt` file in the `Nexus` directory:
```bash
nano id.txt
```

Example contents of `id.txt`:
```
36063968
36063969
36063970
```

## 5. Install the `nexus-network` CLI

### Option 1 — Auto install (recommended)
```bash
curl https://cli.nexus.xyz/ | sh
source ~/.bashrc
```

### Option 2 — Manual install (for v0.10.15)
```bash
wget https://github.com/nexus-xyz/nexus-cli/releases/download/v0.10.15/nexus-cli-0.10.15-linux-amd64.tar.gz
tar -xzf nexus-cli-0.10.15-linux-amd64.tar.gz
sudo install -m 755 nexus-cli-0.10.15/nexus-network /usr/local/bin/nexus-network
```

Verify installation:
```bash
nexus-network --version
```
Expected output:
```
nexus-network 0.10.15 (build 1758914182067)
```

---

## 6. Run the script
- Start all nodes listed in `id.txt`:
```bash
./nexus.sh start
```
- Check screen session status:
```bash
./nexus.sh status
```
- Stop all nodes:
```bash
./nexus.sh stop
```
- Start a single node:
```bash
./nexus.sh start-one <node-id>
```
- Stop a single node:
```bash
./nexus.sh stop-one <node-id>
```

---

## 7. View logs
```bash
tail -f ~/nexus_nodes/<node-id>/nexus.log
```

---

<p align="center">
  <img src="https://raw.githubusercontent.com/nongdancryptos/nongdancryptos/refs/heads/main/QR-Code/readme.svg" alt="Donation Wallets (SVG code card)" />
</p>
