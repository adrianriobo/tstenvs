import-module activedirectory
%{ for user_name, user_pass in users }
$userPassword = ConvertTo-SecureString ${user_pass} -AsPlainText -Force
New-ADUser `
    -SamAccountName ${user_name} `
    -Name ${user_name} `
    -AccountPassword $userPassword `
    -ChangePasswordAtLogon $False `
    -Enabled $True
Add-ADGroupMember -Identity "Remote Desktop Users" -Members ${user_name}
%{ endfor ~}