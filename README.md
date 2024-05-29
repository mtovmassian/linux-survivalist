# linux-survival-kit

![](static/linux-survival-kit-mr-robot.png)

Survive in Linux/Docker environments by installing essential tools.

## Prerequisites
### Install curl
- On Alpine Linux like environment
```bash
apk add curl
```
- On Debian like environment
```bash
apt update && apt install curl -y
```
- On RHEL like environment
```bash
$(command -v dnf || command -v microdnf) install curl -y
```

## Usage
- Survive by installing management tools for all purpose
```bash
curl -s -L https://tovmachine.com/survive.sh | bash
```
- Survive by installing management tools for specific purpose (e.g. *process* and *text*)
```bash
curl -s -L https://tovmachine.com/survive.sh | bash -s -- --process --text
```
- Survive in silence
```bash
curl -s -L https://tovmachine.com/survive.sh | bash -s -- --quiet
```