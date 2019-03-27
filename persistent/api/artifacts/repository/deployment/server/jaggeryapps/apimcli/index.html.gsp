<html>


<head>
    <meta http-equiv="content-type" content="text/html;charset=utf-8"/>
    <title>wso2 apimcli</title>
</head>
<body>

<h1>apimcli</h1>


A tool to export/import api through command line<br>

Download <a href="https://wso2.com/api-management/tooling/">apimcli</a>

<h3>Setup environment:</h3>

<hr/>
<b>apimcli-add-env.bat (windows):</b>
<pre>
set ENV=dev
set HOST=<%= role.host %>
set PORTM=<%= role.port.mhttps %>
set PORTW=<%= role.port.https %>


SET PARM=add-env -n %ENV%
SET PARM=%PARM% --apim https://%HOST%:%PORTM% 
SET PARM=%PARM% --registration https://%HOST%:%PORTM%/client-registration/v0.13/register
SET PARM=%PARM% --import-export https://%HOST%:%PORTM%/api-import-export-2.6.0-v2
SET PARM=%PARM% --api_list https://%HOST%:%PORTM%/api/am/publisher/v0.13/apis
SET PARM=%PARM% --token https://%HOST%:%PORTM%/oauth2/token

apimcli %PARM%
</pre>
<hr/>


<h3>export api:</h3>
<hr/>
<pre>
apimcli.exe export-api -n APINAME -v APIVERSION -r PUBLISHER -e dev -u admin -p admin --insecure --verbose
</pre>
<hr/>
</body>
</html>
