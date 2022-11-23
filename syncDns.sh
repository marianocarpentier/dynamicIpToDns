#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# Next 3 lines just in case the carriage return is not Unix like
file="$SCRIPT_DIR/settings.properties"
tmpFile=$file".tmp"
cat $file | tr -d '\r' >$tmpFile

while IFS='=' read -r key value; do

  key=$(echo $key | tr '.' '_')
  eval ${key}=\${value}

done <$tmpFile

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

CURRENT_IP_ADDRESS=$(aws route53 list-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --output json | jq -c '.ResourceRecordSets | .[]' | grep ${DNS_RECORD_NAME} | jq -c '.ResourceRecords | .[] | .Value' | tr -d '"')
NEW_IP_ADDRESS=$(curl ifconfig.me)

rm $tmpFile

if [ $CURRENT_IP_ADDRESS == $NEW_IP_ADDRESS ]; then

  echo "Current IP Address in DNS Record: $CURRENT_IP_ADDRESS - Current IP Address locally: $NEW_IP_ADDRESS"
  echo "IP address unchanged, do nothing."

else

  updateRecordJson="$SCRIPT_DIR/updateRecord.json"

  cp "$updateRecordJson.template" "$updateRecordJson"

  sed -i $(echo "s/{{DNS_RECORD_NAME}}/"${DNS_RECORD_NAME}"/") $updateRecordJson
  sed -i $(echo "s/{{IP_ADDRESS}}/"${NEW_IP_ADDRESS}"/") $updateRecordJson

  cat $updateRecordJson

  aws route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch file://$updateRecordJson

  if [ $? -ne 0 ]; then
    echo "There was an error updating the IP address in the record ${DNS_RECORD_NAME}"
    exit 1
  else
    echo "IP Address ${NEW_IP_ADDRESS} in ${DNS_RECORD_NAME}"
  fi

fi

exit 0
