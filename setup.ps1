#!/usr/sbin/env -S pwsh.exe

if (-Not (Test-Path ".\data\ubuntu-24.04-server-cloudimg-amd64.vhdx")) {
    if (-Not (Test-Path ".\data\ubuntu-24.04-server-cloudimg-amd64.img")) {
        curl -sLO "https://ftp.udx.icscoe.jp/Linux/ubuntu-cloud-images/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
    }
    echo "qemu-img convert -p -f qcow2 -O vhdx ./data/ubuntu-24.04-server-cloudimg-amd64.img ./data/ubuntu-24.04-server-cloudimg-amd64.vhdx" | wsl .
}

echo "cloud-localds ./data/seed.iso ./data/user-data.yml ./data/meta-data.yml" | wsl .
