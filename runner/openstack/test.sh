#!/bin/bash
ready=1
state="Stopped"
# ready=0
# state="Running"
while [[ $ready -gt 0 && $state != "Running" ]]
do
    echo "$ready and $state"
    echo "Checking adws service on 10.0.111.43"
    sshpass -p redhat20.21 \
      ssh -q -o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null \
          Admin@10.0.111.43 exit
    ready=$?
    echo $ready
    if [[ $ready -eq 0 ]]; then
      state=$(sshpass -p redhat20.21 \
        ssh -q -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            Admin@10.0.111.43 \
            'powershell.exe -command "Get-Service -Name adws | Select-Object Status -ExpandProperty Status"') 
      echo $state
    fi
done
echo "ssh connection is ok"