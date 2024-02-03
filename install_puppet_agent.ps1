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

# Download Puppet agent MSI installer
Write-Host "Downloading Puppet agent installer..."
Invoke-WebRequest -Uri $PuppetInstallerUrl -OutFile "puppet-agent.msi"

# Install Puppet agent
Write-Host "Installing Puppet agent..."
$ret = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /norestart /i /l*v install.txt puppet-agent.msi PUPPET_MASTER_SERVER=$puppet_master_server PUPPET_CA_SERVER=$puppet_ca_server PUPPET_AGENT_CERTNAME=$puppet_agent_certname PUPPET_AGENT_ENVIRONMENT=$puppet_agent_environment PUPPET_AGENT_STARTUP_MODE=$puppet_agent_startup_mode" -Wait -Passthru).ExitCode

if ($ret -eq 0) {
  echo "OK"
} else {
  echo "Error: $ret"
}

Write-Host "Puppet agent installation and configuration completed."
