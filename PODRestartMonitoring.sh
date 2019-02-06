#!/bin/bash
n=0
while :
do
  kubectl get pods --all-namespaces -o=jsonpath='{range .items[*]}{.status.containerStatuses[0].restartCount}{"\t"}{.metadata.namespace}{"\t"}{.metadata.name}{"\n"}' | sort -k3 > pod-restart-temp.txt

  echo -e "RestartCount\tNameSpace\tPOD" | cat - pod-restart-temp.txt > pod-restart.txt

  diff pod-restart.txt pod-previous-restart.txt > comparing-result.txt

  LineCount="$(cat comparing-result.txt |wc -l)"

  if [ "$LineCount" == 0 ]
  then
    result=0
    break

  else
    if [ $n == 0 ]
    then
    cat comparing-result.txt
    cp pod-restart.txt pod-previous-restart.txt
    echo "====================pod restart count difference is found, but let's give it a second shot after one minute...============================"
    sleep 60s
    n=$((n+1))
    continue

    else
      if [ $n == 1 ]
      then
      cat comparing-result.txt
      result=1
      break
      fi
    fi
  fi
done


if [ $result == 0 ]
then
exit 0
else
echo "The second shot failed again..."
exit 1
fi

