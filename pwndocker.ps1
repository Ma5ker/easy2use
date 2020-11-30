# ----
# Filename: pwndocker.ps1
# Author  : Ma5ker
# Date    : 11/25/2020
# Comment : This script is used to create pwndocker container 
# Usage   :
#     To stop a container:
#       pwndocker -s containerId
#     Create a container and get its shell
#       pwndocker -n container name -p bind_port -f folder_need_to_mount
#     Easy to use:(name random generated & port ignore)
#       pwndocker -f folder_need_to_mount
# ----

param(
    [string]$name,
    [string]$stop,
    [int]$port,
    [string]$folder
)
# stop container
if($stop -ne '' ){
    $null = docker container stop $stop
    if($?){
        write-host "[>]Stop container success"
        $rm_flag = Read-Host "[?]Remove container?[y/n](default=y)"
        if( $rm_flag -eq 'y' -or $rm_flag -eq '' ){
            $null = docker container rm $stop
        }elseif ($rm_flag -ne 'n') {
            write-host "[-]Unknown options, do nothing."
        }
        exit 0
    }else{
        write-host "[+]Stop container failed"
        exit -1
    }

}

$docker_params = "run","-d"

if ($name -eq ''){
    $name = [System.Guid]::NewGuid().toString('d').substring(0,8)
}
$hostname = $name
$docker_params += "-h",$hostname,"--name",$name

if($port -eq 0 ){
    Write-Host "[*]No port given"
}else{
    $docker_params += "-p", $port,":",$port
}

if ( -not (Test-Path($folder)) ) {
    Write-Host "[*]folder path not exist,will not mounted to the container."
}else {
    $folder = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($folder)

    $docker_params += "-v","${folder}:/ctf/work"

}

$docker_params += "--cap-add=SYS_PTRACE","ma5ker/pwndocker"
$null = docker $docker_params

if ($?){
    Write-Host "[>]Creating container success"
    $exec_params = "exec","-it",$name,"/bin/bash"
    Write-Host "[>]Get container shell: docker $exec_params"
    docker $exec_params
    exit 0
}else{
    Write-Host "[x]FATAL ERROR in Creating container."
    exit -1
}
