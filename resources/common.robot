*** Settings ***
Variables         ../config.yml
Library           ../lib/CFCliLibrary.py  ${cf_cli_path}
Library           ../lib/HelperLibrary.py
Library           RequestsLibrary
Library           OperatingSystem
Library           String


*** Variables ***
${DEFAULT_MEMORY_LIMIT}       256M
${DEFAULT_DISK_LIMIT}         512M
${app_binary_folder}          ./assets/binary

*** Keywords ***
I push an app named ${name:[^ ]*} with buildpack ${buildpack:[^ ]*} from folder ${dir} without manifest
    ${buildpack_final}=   get first buildpack   ${buildpack}
    ${result}=  cf  push  --no-route   -b  ${buildpack_final}  -m  ${DEFAULT_MEMORY_LIMIT}   -k  ${DEFAULT_DISK_LIMIT}  -p  ${dir}  ${name}
    Log   ${result}
    cf  map-route   ${name}  %{CF_DOMAIN}  --hostname   ${name}
    Sleep  5s

I push an app named ${name:[^ ]*} with buildpack ${buildpack:[^ ]*} from folder ${dir} with manifest path ${path}
    ${buildpack_final}=   get first buildpack   ${buildpack}
    ${result}=  cf  push  --no-route   -b  ${buildpack_final}  -m  ${DEFAULT_MEMORY_LIMIT}   -k  ${DEFAULT_DISK_LIMIT}  -p  ${dir}  -f  ${path}  ${name}
    Log   ${result}
    cf  map-route   ${name}  %{CF_DOMAIN}  --hostname   ${name}
    Sleep  5s

I push an app named ${name:[^ ]*} with buildpack ${buildpack:[^ ]*} from asset ${asset:[^ ]*} with manifest
    I push an app named ${name} with buildpack ${buildpack} from folder ./assets/${asset} with manifest path ./assets/${asset}/manifest.yml

I push an app named ${name:[^ ]*} with buildpack ${buildpack:[^ ]*} from asset ${asset:[^ ]*} without manifest
    I push an app named ${name} with buildpack ${buildpack} from folder ./assets/${asset} without manifest

I delete app ${name}
    cf  delete  ${name}   -f

I push default binary app named ${name:[^ ]*}
    ${buildpack}=   get first buildpack   binary_buildpack
    ${result}=  cf  push  --no-route   -b  ${buildpack}  -m  30M   -k  16M  -p  ${app_binary_folder}  ${name}
    Log   ${result}
    cf  map-route   ${name}  %{CF_DOMAIN}  --hostname   ${name}
    Sleep  5s

I push default binary app named ${name:[^ ]*} with rolling strategy
    ${buildpack}=   get first buildpack   binary_buildpack
    ${result}=  cf  push   -b  ${buildpack}  -m  30M   -k  16M  -p  ${app_binary_folder}  --strategy  rolling  ${name}
    Log   ${result}
    Sleep  5s

I expect app ${name:[^ ]*} from instance ${instance} to contains response "${expected_response}"
    ${app_guid}=  cf  app   ${name}   --guid
    ${sess_headers}=     Create Dictionary  X-Cf-App-Instance=${app_guid}:${instance}
    Create Session  get_${name}   ${url_protocol}://${name}.%{CF_DOMAIN}   verify=${python_request_verify_cert}   headers=${sess_headers}
    ${resp}=  Get Request   get_${name}   /   allow_redirects=${False}
    Should Contain   ${resp.text}   ${expected_response}

I expect app ${name:[^ ]*} to contains response "${expected_response}"
    Create Session  get_${name}   ${url_protocol}://${name}.%{CF_DOMAIN}   verify=${python_request_verify_cert}
    ${resp}=  Get Request   get_${name}   /   allow_redirects=${False}
    Should Contain   ${resp.text}   ${expected_response}

I expect app ${name:[^ ]*} from instance ${instance:[0-9]+} to have response code "${expected_response}"
    ${app_guid}=  cf  app   ${name}   --guid
    ${sess_headers}=     Create Dictionary  X-Cf-App-Instance=${app_guid}:${instance}
    Create Session  get_${name}   ${url_protocol}://${name}.%{CF_DOMAIN}   verify=${python_request_verify_cert}   headers=${sess_headers}
    ${resp}=  Get Request   get_${name}   /   allow_redirects=${False}
    Log   ${resp.text}
    Should Be Equal As Integers   ${resp.status_code}   ${expected_response}


I push default binary app named ${name:[^ ]*} and expect response
    I push default binary app named ${name}
    I expect app ${name} from instance 0 to contains response "Hello from a binary"

I create a simple user for org ${my_org} and ${my_space}
    ${password}=  Generate Random String  12
    cf  create-user       ${simple_user.username}   ${password}
    cf  set-org-role      ${simple_user.username}   ${my_org}      OrgManager
    cf  set-space-role    ${simple_user.username}   ${my_org}      ${my_space}    SpaceManager
    cf  set-space-role    ${simple_user.username}   ${my_org}      ${my_space}    SpaceDeveloper
    Set Global Variable   ${simple_user_password}   ${password}

I delete simple user
    cf  delete-user   ${simple_user.username}   -f

I login as simple user
    I login as ${simple_user.username} with password ${simple_user_password}
I login as admin
    I login as %{CF_USER} with password %{CF_PASSWORD}
I login as ${user:[^ ]*} with password ${password}
    cf  auth  ${user}   ${password}
