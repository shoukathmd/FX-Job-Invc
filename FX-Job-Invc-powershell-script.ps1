#! /usr/bin/pwsh

$FX_USER=$args[0]
$FX_PWD=$args[1]
$FX_JOBID=$args[2]
$REGION=$args[3]
$TAGS=$args[4]
$SUITES=$args[5]
$CATEGORIES=$args[6]
$FX_HOST=$args[7]

Write-Host "user = ${FX_USER}"
Write-Host "region = ${REGION}"
Write-Host "jobid = ${FX_JOBID}"
Write-Host "hostname = ${FX_HOST}" 

$runId=$(curl -k --header  "Content-Type: application/json;charset=UTF-8" -X POST -d '{}' -u ""${FX_USER}":"${FX_PWD}"" ""${FX_HOST}"/api/v1/runs/job/${FX_JOBID}?region=${REGION}" | jq -r '."data"|."id"')



Write-Host "runId = $runId"

if (  !$runId )
{

	  Write-Host "RunId =  "$runId""
          Write-Host "Invalid runid"
      
          Write-Host $(curl -k --header "Content-Type: application/json;charset=UTF-8" -X POST -d '{}' -u ""${FX_USER}":"${FX_PWD}"" ""${FX_HOST}"/api/v1/runs/job/${FX_JOBID}?region=${REGION}")

          exit 1
}


$taskStatus="WAITING"
Write-Host "taskStatus = " $taskStatus

While ( ("$taskStatus" -eq "WAITING") -or ("$taskStatus" -eq "PROCESSING") )
{ 
               	 sleep 5
	       	 Write-Host "Checking Status...."
                  
                  $passPercent=$(curl -k --header "Content-Type: application/json;charset=UTF-8" -X GET -u ""${FX_USER}":"${FX_PWD}"" ""${FX_HOST}"/api/v1/runs/${runId}" | jq -r '."data"|."ciCdStatus"')

                
                  $array = $passPercent.Split(':')			
                  $taskStatus= $array[0]
			
                  Write-Host "Status =" , $array[0], " Success Percent =" , $array[1], " Total Tests =", $array[2], " Time Taken =", $array[4], " Run =" $array[5]

                  if ("$taskstatus" -eq "COMPLETED"){
                  
                       Write-Host "---------------------------------------------------------------------------------"
                       Write-Host "Run detail link "${FX_HOST}"", $array[6]
                       Write-Host "---------------------------------------------------------------------------------"
                       Write-Host  $array[7] 
                       Write-Host "---------------------------------------------------------------------------------"
                       Write-Host "Job run successfully completed"
                       exit 0       
                                                   }
} 

if ("$taskstatus" -eq "TIMEOUT")
{
Write-Host "Task Status = $taskstatus" 
exit 1
}

Write-Host $(curl -k --header "Content-Type: application/json;charset=UTF-8" -X GET -u ""${FX_USER}":"${FX_PWD}"" ""${FX_HOST}"/api/v1/runs/${runId}")
exit 1

return 0
          
