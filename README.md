# Linux Survivalist

![](static/linux-survivalist-mr-robot.png)

Survive in Linux/Docker environments by installing essential tools.

## Prerequisites
### On Alpine Linux like environment
Install *bash* and *curl*:
```bash
apk add bash curl
```
### On Debian like environment
Install *curl*:
```bash
apt update && apt install curl -y
```
### On RHEL like environment
Install *curl*:
```bash
$(command -v dnf || command -v microdnf) install curl -y
```

## Usage
Pipe the online `survive.sh` script to bash. Available at: 
- Full URL: https://raw.githubusercontent.com/mtovmassian/linux-survivalist/main/src/survive.sh 
- Shorten URL: https://bit.ly/srvv

### Survive by installing tools for all purpose
```bash
curl -s -L https://raw.githubusercontent.com/mtovmassian/linux-survivalist/main/src/survive.sh | bash
```
### Survive by installing tools for specific purpose
For example *process* and *text*
```bash
curl -s -L https://raw.githubusercontent.com/mtovmassian/linux-survivalist/main/src/survive.sh | bash -s -- --process --text
```
### Survive in silence
```bash
curl -s -L https://raw.githubusercontent.com/mtovmassian/linux-survivalist/main/src/survive.sh | bash -s -- --quiet
```