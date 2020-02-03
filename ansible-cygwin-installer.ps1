#
# This Powershell script will download and install Cygwin and Ansible.
#
# Run from Powershell
#    Set-ExecutionPolicy bypass
#    & ansible-cygwin-installer.ps1
#
# Run from cmd with
#    powershell -ExecutionPolicy bypass "ansible-cygwin-installer.ps1"
#

#
# User variables. These may be changed to suit your environment.
#

$storageDir = $pwd
$cygwinHome = "c:\cygwin"
$cygwinUrlRoot = "http://cygwin.com"
$cygwinMirror = "https://mirrors.tuna.tsinghua.edu.cn/cygwin"

#
# You shouldn't normally need to change anything below here
#

if ($ENV:PROCESSOR_ARCHITECTURE -eq 'AMD64') {
    $cygwinSetupExe = "setup-x86_64.exe"
    $url = "$cygwinUrlRoot/$cygwinSetupExe"
    $file = "$storageDir\$cygwinSetupExe"
} elseif ($ENV:PROCESSOR_ARCHITECTURE -eq 'x86') {
    $cygwinSetupExe = "setup-x86.exe"
    $url = "$cygwinUrlRoot/$cygwinSetupExe"
    $file = "$storageDir\$cygwinSetupExe"
} else {
    echo 'Unknown processor architecture'
    exit
}

# Fully qualified path to Cygwin setup.exe
$cygwinSetupPath = "$storageDir\$cygwinSetupExe"

# Download Cygwin setup.exe, if it doesn't already exist
if ( ! ( Test-Path -Path $cygwinSetupPath -PathType Leaf ) ) {
    $webclient = New-Object System.Net.WebClient
    $webclient.DownloadFile($url,$file)
}

$cygwinSetupArgs = '--no-admin', '-q', '-R', "$cygwinHome", '-s', "$cygwinMirror", '--packages="binutils,wget,dash"'
Start-Process -FilePath $cygwinSetupPath -ArgumentList $cygwinSetupArgs -Wait

# Add cygwin bin dir to path
$ENV:PATH="$cygwinHome\bin;$ENV:PATH"

# Install pip
Start-Process -FilePath $cygwinHome\bin\bash.exe -ArgumentList '-c', """install apt-cyg /bin""" -Wait -NoNewWindow

Start-Process -FilePath $cygwinHome\bin\bash.exe -ArgumentList '-c', """apt-cyg install curl git vim gmp libffi-devel libgmp-devel nano openssh openssl-devel ansible """ -Wait -NoNewWindow


# Install Ansible via pip

# Start-Process -FilePath $cygwinHome\bin\bash.exe -ArgumentList '-c', '"pip2 install -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U"' -Wait -NoNewWindow

# Start-Process -FilePath $cygwinHome\bin\bash.exe -ArgumentList '-c', '"pip2 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple"' -Wait -NoNewWindow

# Run Ansible from outside of Cygwin shell
Start-Process -FilePath $cygwinHome\bin\bash.exe -ArgumentList '-c', '"ansible --version"' -Wait -NoNewWindow
