$FX_USER=$args[0]
$FX_PWD=$args[1]
$FX_JOBID=$args[2]
$REGION=$args[3]
$TAGS=$args[4]
$SUITES=$args[5]
$CATEGORIES=$args[6]
#$FX_HOST=$args[7]

Write-Host "user = ${FX_USER}"
Write-Host "region = ${REGION}"
Write-Host "jobid = ${FX_JOBID}"
#Write-Host "hostname = ${FX_HOST}" 


############################## Token Generation #######################################################################################
$pair = "${FX_USER}:${FX_PWD}"
#Write-Host "$pair"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
#Write-Host "$base64"
$basicAuthValue = "Basic $base64"
#Write-Host "$basicAuthValue"
$headers = @{ Authorization = $basicAuthValue }
#Write-Host "$headers"
######################################################################################################################################

#######################################################################################################################################
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy



############################################################################################################################################



$runId=$((Invoke-WebRequest  -Uri "https://cloud.fxlabs.io/api/v1/runs/job/${FX_JOBID}?region=${REGION}" -UseBasicParsing   -Headers $headers -Method POST  -ContentType "application/json;charset=UTF-8" ) | ConvertFrom-Json  | select -expand data | select -expand id)

Write-Host "runId = $runId"
Write-Host " "


if (  !$runId )
{

	  Write-Host "RunId =  "$runId""
          Write-Host "Invalid runid"
      
          Write-Host $(Invoke-WebRequest  -Uri "https://cloud.fxlabs.io/api/v1/runs/job/${FX_JOBID}?region=${REGION}" -UseBasicParsing  -Headers $headers -Method POST  -ContentType "application/json;charset=UTF-8")

          exit 1
}

$taskStatus="WAITING"
Write-Host "taskStatus = " $taskStatus

While ( ("$taskStatus" -eq "WAITING") -or ("$taskStatus" -eq "PROCESSING") )
{ 
               	 sleep 5
                 
	       	 Write-Host "Checking Status...."
                 Write-Host "----------------------------------------------------------------------------------------------------------------------------------------------"

                  $passPercent=$((Invoke-WebRequest  -Uri "https://cloud.fxlabs.io/api/v1/runs/${runId}"  -UseBasicParsing -Headers $headers -Method GET  -ContentType "application/json;charset=UTF-8" )| ConvertFrom-Json  | select -expand data | select -expand ciCdStatus)


                
                  $array = $passPercent.Split(':')			
                  $taskStatus= $array[0]
			
                  Write-Host "Status =" , $array[0], " Success Percent =" , $array[1], " Total Tests =", $array[2], " Time Taken =", $array[4], " Run =" $array[5]

                  if ("$taskstatus" -eq "COMPLETED"){
                  
                       Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------"
                       Write-Host "Run detail link "${FX_HOST}"", $array[6]
                       Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------"
                       Write-Host  $array[7] 
                       Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------"
                       Write-Host "Job run successfully completed"
                       exit 0       
                                                   }
} 

if ("$taskstatus" -eq "TIMEOUT")
{
Write-Host "Task Status = $taskstatus" 
exit 1
}


Write-Host $(Invoke-WebRequest  -Uri "https://cloud.fxlabs.io/api/v1/runs/${runId}" -UseBasicParsing -Headers $headers -Method GET  -ContentType "application/json;charset=UTF-8" )
exit 1

return 0
