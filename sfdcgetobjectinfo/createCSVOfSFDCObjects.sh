#!/usr/bin/env bash

prefix="${1}"
loginfile="${2}"

# ping the SFDC instance using the SOAP API to learn what the session ID is for the REST API calls
xmlresponse="$(curl -s https://login.salesforce.com/services/Soap/u/33.0 -H "Content-Type: text/xml; charset=UTF-8" -H "SOAPAction: login" -d @"${loginfile}")"
# session ID is whatever is between the <sessionId> XML tag
sessionid="$(echo "${xmlresponse}" | sed 's/.*<sessionId>\(.*\)<\/sessionId>.*/\1/')"
# to determine the SFDC instance, we'll grab the instance of the server URL
sfdcinstance="$(echo "${xmlresponse}" | sed 's/.*<serverUrl>https:\/\/\(.*\)\.salesforce\.com.*<\/serverUrl>.*/\1/')"

objectlisturl="https://${sfdcinstance}.salesforce.com/services/data/v33.0/sobjects/"
objectlist="${prefix}_sobjectlist.txt"
curl -s "${objectlisturl}" -H "Authorization: Bearer ${sessionid}" -H "X-PrettyPrint:1" | jq -r '.sobjects[].name' > "${objectlist}"

csvOutput="${prefix}_allobjectsdescribe.csv"

while read object
do
	echo "$(date) -- Starting processing of ${object}"
	jsonResponse="${prefix}_${object}_describe.json"
	sfdcurl="https://${sfdcinstance}.salesforce.com/services/data/v33.0/sobjects/${object}/describe/"
	curl -s "${sfdcurl}" -H "Authorization: Bearer ${sessionid}" -H "X-PrettyPrint:1" > "${jsonResponse}"
	jq -r '.name as $objectname | .fields[] | [ $objectname, .name, .label, .unique, .nillable, .externalId, .type, .relationshipName, ([.referenceTo[]] | join(";")), .cascadeDelete, .calculated, .calculatedFormula, ([.picklistValues[].value] | join(";")) ] | @csv' < "${jsonResponse}" >> "${csvOutput}"
	echo "$(date) -- Completed processing of ${object}"
done < "${objectlist}"
