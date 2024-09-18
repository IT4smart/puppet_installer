param(
    [Parameter(Mandatory=$true)]
    [string]$puppet_master_server,
    
    [Parameter(Mandatory=$true)]
    [string]$puppet_ca_server,
    
    [Parameter(Mandatory=$true)]
    [string]$puppet_agent_certname,
    
    [Parameter(Mandatory=$true)]
    [string]$puppet_agent_environment,
    
    [string]$puppet_agent_startup_mode = "Automatic"
)

# Define variables
$PuppetVersion = "7.14.0"
$PuppetInstallerUrl = "https://downloads.puppet.com/windows/puppet7/puppet-agent-$PuppetVersion-x64.msi"
$PuppetAgentCertname = $puppet_agent_certname.ToLower()
$PuppetAgentEnvironment = $puppet_agent_environment.ToLower()
$localPuppetPath = "$env:TEMP\puppet-agent.msi"


# Download Puppet agent MSI installer
Write-Host "Downloading Puppet agent installer..."
Invoke-WebRequest -Uri $PuppetInstallerUrl -OutFile $localPuppetPath

# Install Puppet agent
Write-Host "Installing Puppet agent..."
$ret = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /norestart /log install.txt /i $localPuppetPath PUPPET_MASTER_SERVER=$puppet_master_server PUPPET_CA_SERVER=$puppet_ca_server PUPPET_AGENT_CERTNAME=$PuppetAgentCertname PUPPET_AGENT_ENVIRONMENT=$PuppetAgentEnvironment PUPPET_AGENT_STARTUP_MODE=$puppet_agent_startup_mode" -Wait -Passthru).ExitCode

if ($ret -eq 0) {
  echo "OK"
} else {
  echo "Error: $ret"
}

# Define the properties for the new firewall rules
$displayNameTCP = "Allow Ruby Inbound TCP"    # Display name for the TCP rule
$displayNameUDP = "Allow Ruby Inbound UDP"    # Display name for the UDP rule
$descriptionTCP = "Allow inbound TCP traffic for ruby.exe"  # Description for the TCP rule
$descriptionUDP = "Allow inbound UDP traffic for ruby.exe"  # Description for the UDP rule
$action = "Allow"                             # Action (Allow/Deny)
$program = "C:\program files\puppet labs\puppet\puppet\bin\ruby.exe"              # Path to the program
$direction = "Inbound"                         # Direction (Inbound/Outbound)
$protocolTCP = "TCP"                           # Protocol (TCP/UDP)
$protocolUDP = "UDP"                           # Protocol (TCP/UDP)
$profile = "Public"                           # Network profile (Domain, Private, Public)

# Create the new firewall rules
New-NetFirewallRule -DisplayName $displayNameTCP `
                    -Description $descriptionTCP `
                    -Action $action `
                    -Program $program `
                    -Direction $direction `
                    -Protocol $protocolTCP `
                    -Profile $profile

New-NetFirewallRule -DisplayName $displayNameUDP `
                    -Description $descriptionUDP `
                    -Action $action `
                    -Program $program `
                    -Direction $direction `
                    -Protocol $protocolUDP `
                    -Profile $profile

Write-Host "Firewall rules for Ruby have been successfully added."



Write-Host "Request agent certificate"
$ret = (Start-Process -FilePath "C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat" -ArgumentList "agent --waitforcert 60 -t --verbose --debug" -Wait -Passthru).ExitCode

if ($ret -eq 0) {
  echo "OK"
} else {
  echo "Error: $ret"
}

Write-Host "Puppet agent installation and configuration completed."
