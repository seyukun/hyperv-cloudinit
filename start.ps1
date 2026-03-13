#!/usr/sbin/env -S pwsh.exe

$VM = Read-Host "VM Name"
$VMPipe = $VM -replace '[^A-Za-z0-9._-]', '_'

Start-Process -FilePath sudo -ArgumentList @("pwsh.exe", "-Command", @"
    Set-VMComPort -VMName '$VM' -Number 1 -Path '\\.\pipe\$VMPipe'
    Start-VM '$VM'
#    convey.exe \\.\pipe\$VMPipe
"@) -Wait

$pipe = [System.IO.Pipes.NamedPipeClientStream]::new(".", $VMPipe, [System.IO.Pipes.PipeDirection]::In)

while ($true) {
    try {
        $pipe.Connect(1000)
        break
    }
    catch {
        Start-Sleep -Milliseconds 200
    }
}

$sr = [System.IO.StreamReader]::new($pipe)

while ($sr.Peek() -eq -1) {
    Start-Sleep -Milliseconds 100
}

while ($true) {
    $n = $sr.Peek()
    if ($n -ge 0) {
        [Console]::Write([char]$sr.Read())
    } else {
        Start-Sleep -Milliseconds 50
    }
}
