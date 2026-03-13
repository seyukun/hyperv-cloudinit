#!/usr/sbin/env -S pwsh.exe

$VM_NAME        = Read-Host -Prompt "Enter the name of the VM"
$VM_DISK_SIZE   = [UInt64](Read-Host -Prompt "Enter the size of the VM disk in GB (e.g., 20)")
$VM_MEMORY_SIZE = [UInt64](Read-Host -Prompt "Enter the amount of memory in GB (e.g., 4)")
$VM_PROCESSORS  = [UInt32](Read-Host -Prompt "Enter the number of processors (e.g., 2)")

$BASE_DISK_Path = Join-Path (Get-Location).Path ".\data\ubuntu-24.04-server-cloudimg-amd64.vhdx"
$ISO_PATH       = Join-Path (Get-Location).Path ".\data\seed.iso"

$VM_DISK_DIR  = "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks"
$VM_DISK_PATH = Join-Path $VM_DISK_DIR "$VM_NAME.vhdx"

if (-not (Test-Path $BASE_DISK_Path)) {
    throw "Base VHDX not found: $BASE_DISK_Path"
}

if (-not (Test-Path $ISO_PATH)) {
    throw "Seed ISO not found: $ISO_PATH"
}

if (Get-VM -Name $VM_NAME -ErrorAction SilentlyContinue) {
    throw "VM already exists: $VM_NAME"
}

Start-Process -FilePath sudo -ArgumentList @("pwsh.exe", "-Command", @"
    Copy-Item -Path '$BASE_DISK_PATH' -Destination '$VM_DISK_PATH'
    echo 'VHDX: Copied `($VM_DISK_PATH`)'

    Resize-VHD -Path '$VM_DISK_PATH' -SizeBytes ($VM_DISK_SIZE * 1GB)
    echo 'VHDX: Resized $($VM_DISK_SIZE)GB'

    New-VM -Name '$VM_NAME' -MemoryStartupBytes ($VM_MEMORY_SIZE * 1GB) -Generation 2 -VHDPath '$VM_DISK_PATH' | Out-Null
    echo 'VM: Created $VM_NAME'

    Set-VMProcessor -VMName '$VM_NAME' -Count '$VM_PROCESSORS'
    echo 'VM: CPU $VM_PROCESSORS'

    Set-VMMemory -VMName '$VM_NAME' -DynamicMemoryEnabled `$true
    echo 'VM: Dynamic Memory Enabled'

    Add-VMDvdDrive -VMName '$VM_NAME' -Path '$ISO_PATH'
    echo 'Cloud-init: Attached $ISO_PATH'

    Set-VMFirmware -VMName '$VM_NAME' -EnableSecureBoot Off
    echo 'Secure Boot: Disabled'

    Set-VMKeyProtector -VMName '$VM_NAME' -NewLocalKeyProtector
    echo 'TPM: KP Created'

    Enable-VMTPM -VMName '$VM_NAME'
    echo 'TPM: Enabled'

    Set-VM -VMName '$VM_NAME' -CheckpointType disable
    echo 'Checkpoint Disabled'

    Read-Host -Prompt '`n`nPress Enter to exit...'
"@) -Wait
