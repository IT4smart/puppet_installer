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


# Download Puppet agent MSI installer
Write-Host "Downloading Puppet agent installer..."
Invoke-WebRequest -Uri $PuppetInstallerUrl -OutFile "puppet-agent.msi"

# Install Puppet agent
Write-Host "Installing Puppet agent..."
$ret = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /norestart /log install.txt /i puppet-agent.msi PUPPET_MASTER_SERVER=$puppet_master_server PUPPET_CA_SERVER=$puppet_ca_server PUPPET_AGENT_CERTNAME=$PuppetAgentCertname PUPPET_AGENT_ENVIRONMENT=$PuppetAgentEnvironment PUPPET_AGENT_STARTUP_MODE=$puppet_agent_startup_mode" -Wait -Passthru).ExitCode

if ($ret -eq 0) {
  echo "OK"
} else {
  echo "Error: $ret"
}

Write-Host "Request agent certificate"
$ret = (Start-Process -FilePath "C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat" -ArgumentList "agent --waitforcert 60 -t --verbose --debug" -Wait -Passthru).ExitCode

if ($ret -eq 0) {
  echo "OK"
} else {
  echo "Error: $ret"
}

Write-Host "Puppet agent installation and configuration completed."
