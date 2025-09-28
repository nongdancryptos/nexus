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
```bash
curl https://cli.nexus.xyz/ | sh
source ~/.bashrc
```

Verify:
```bash
nexus-network --help
```

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

## 7. View logs
```bash
tail -f ~/nexus_nodes/<node-id>/nexus.log
```
<!-- Code display (SVG) -->
<p align="center">
  <img src="https://raw.githubusercontent.com/nongdancryptos/nongdancryptos/refs/heads/main/QR-Code/readme.svg" alt="Donation Wallets (SVG code card)" />
</p>
