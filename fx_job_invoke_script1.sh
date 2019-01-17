#!/bin/bash
# Begin

FX_USER=$1
FX_PWD=$2
FX_JOBID=$3
REGION=$4
TAGS=$5
SUITES=$6
CATEGORIES=$7
FX_HOST=$8

echo "user=${FX_USER}" 
echo "region=${REGION}"
echo "jobid=${FX_JOBID}"
echo "hostname=${FX_HOST}"

#runId=$(curl -k --header "Content-Type: application/json;charset=UTF-8" -X POST -d '{}' -u "${FX_USER}":"${FX_PWD}" https://cloud.fxlabs.io/api/v1/runs/job/${FX_JOBID}?region=${REGION} | jq -r '.["data"]|.id')
runId=$(curl -k --header "Content-Type: application/json;charset=UTF-8" -X POST -d '{}' -u "${FX_USER}":"${FX_PWD}" "${FX_HOST}"/api/v1/runs/job/${FX_JOBID}?region=${REGION} | jq -r '.["data"]|.id')

echo "runId =" $runId
if [ -z "$runId" ]
then
	  echo "RunId = " "$runId"
          echo "Invalid runid"
#	  echo $(curl -k --header "Content-Type: application/json;charset=UTF-8" -X POST -d '{}' -u "${FX_USER}":"${FX_PWD}" https://cloud.fxlabs.io/api/v1/runs/job/${FX_JOBID}?region=${REGION})
          
          echo $(curl -k --header "Content-Type: application/json;charset=UTF-8" -X POST -d '{}' -u "${FX_USER}":"${FX_PWD}" "${FX_HOST}"/api/v1/runs/job/${FX_JOBID}?region=${REGION})
          exit 1
fi


taskStatus="WAITING"
echo "taskStatus = " $taskStatus



while [ "$taskStatus" == "WAITING" -o "$taskStatus" == "PROCESSING" ]
	 do
		sleep 5
		 echo "Checking Status...."

#		passPercent=$(curl -k --header "Content-Type: application/json;charset=UTF-8" -X GET -u "${FX_USER}":"${FX_PWD}" https://cloud.fxlabs.io/api/v1/runs/${runId} | jq -r '.["data"]|.ciCdStatus')
                passPercent=$(curl -k --header "Content-Type: application/json;charset=UTF-8" -X GET -u "${FX_USER}":"${FX_PWD}" "${FX_HOST}"/api/v1/runs/${runId} | jq -r '.["data"]|.ciCdStatus')
                        
			IFS=':' read -r -a array <<< "$passPercent"
			
			taskStatus="${array[0]}"			

			echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Time Taken =" "${array[4]}" " Run =" "${array[5]}"
			
				

		if [ "$taskStatus" == "COMPLETED" ];then

            echo "------------------------------------------------"
#			echo  "Run detail link https://cloud.fxlabs.io"${array[6]}
			echo  "Run detail link "${FX_HOST}""${array[6]}
			echo "------------------------------------------------"
			echo  "${array[7]}"
			echo "------------------------------------------------"
                        
                	echo "Job run successfully completed"
                        exit 0

                fi
	done

if [ "$taskStatus" == "TIMEOUT" ];then 
echo "Task Status = " $taskStatus
 exit 1
fi

#echo $(curl -k --header "Content-Type: application/json;charset=UTF-8" -X GET -u "${FX_USER}":"${FX_PWD}" https://cloud.fxlabs.io/api/v1/runs/${runId})
echo $(curl -k --header "Content-Type: application/json;charset=UTF-8" -X GET -u "${FX_USER}":"${FX_PWD}" "${FX_HOST}"/api/v1/runs/${runId})
exit1

return 0