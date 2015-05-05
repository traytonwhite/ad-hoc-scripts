Create CSV file containing info about SFDC objects
===================

Script to create individual CSV files containing information about SFDC objects.

Requires API access to the SFDC organization and jq must be installed.

Uses the SOAP API to get around having to use OAuth and Connected Apps in SFDC.

Specify what fields to add by the jq argument processing.

Learn more about what fields are available in SFDC documentation here:
http://www.salesforce.com/us/developer/docs/api/index_Left.htm#CSHID=sforce_api_calls_describesobjects_describesobjectresult.htm|StartTopic=Content%2Fsforce_api_calls_describesobjects_describesobjectresult.htm|SkinName=webhelp


TODO
===================

Add better error handling.

Use getopts to better handle argument passing.
