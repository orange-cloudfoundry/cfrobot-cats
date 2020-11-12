*** Settings ***
Variables         ../config.yml
Library           ../lib/CFCliLibrary.py
Library           ../lib/HelperLibrary.py
Library           RequestsLibrary
Library           OperatingSystem


*** Variables ***
${DEFAULT_MEMORY_LIMIT}       256M
${DEFAULT_DISK_LIMIT}         512M
${app_binary_folder}          ./assets/binary
*** Keywords ***
I push an app named ${name:[^ ]*} with buildpack ${buildpack:[^ ]*} from folder ${dir}
    ${buildpack_final}=   get first buildpack   ${buildpack}
    ${result}=  cf  push  -d  %{CF_DOMAIN}   -b  ${buildpack}  -m  ${DEFAULT_MEMORY_LIMIT}   -k  ${DEFAULT_DISK_LIMIT}  -p  ${dir}  ${name}
    Log   ${result}

I push an app named ${name:[^ ]*} with buildpack ${buildpack:[^ ]*} from folder ${dir} with manifest path ${path}
    ${buildpack_final}=   get first buildpack   ${buildpack}
    ${result}=  cf  push  -d  %{CF_DOMAIN}   -b  ${buildpack}  -m  ${DEFAULT_MEMORY_LIMIT}   -k  ${DEFAULT_DISK_LIMIT}  -p  ${dir}  -f  ${path}  ${name}
    Log   ${result}

I push an app named ${name:[^ ]*} with buildpack ${buildpack:[^ ]*} from asset ${asset:[^ ]*} with manifest
    I push an app named ${name} with buildpack ${buildpack} from folder ./assets/${asset} with manifest path ./assets/${asset}/manifest.yml

I push an app named ${name:[^ ]*} with buildpack ${buildpack:[^ ]*} from asset ${asset:[^ ]*}
    I push an app named ${name} with buildpack ${buildpack} from folder ./assets/${asset}

I delete app ${name}
    cf  delete  ${name}   -f

I push default binary app named ${name:[^ ]*}
    ${buildpack}=   get first buildpack   binary_buildpack
    ${result}=  cf  push  -d  %{CF_DOMAIN}   -b  ${buildpack}  -m  30M   -k  16M  -p  ${app_binary_folder}  ${name}
    Log   ${result}

I expect app ${name} from instance ${instance} to contains response "${expected_response}"
    ${app_guid}=  cf  app   ${name}   --guid
    ${sess_headers}=     Create Dictionary  X-Cf-App-Instance=${app_guid}:${instance}
    Create Session  get_${name}   ${url_protocol}://${name}.%{CF_DOMAIN}   verify=${python_request_verify_cert}   headers=${sess_headers}
    ${resp}=  Get Request   get_${name}   /   allow_redirects=${False}
    Should Contain   ${resp.text}   ${expected_response}

I expect app ${name} from instance ${instance} to have response code "${expected_response}"
    ${app_guid}=  cf  app   ${name}   --guid
    ${sess_headers}=     Create Dictionary  X-Cf-App-Instance=${app_guid}:${instance}
    Create Session  get_${name}   ${url_protocol}://${name}.%{CF_DOMAIN}   verify=${python_request_verify_cert}   headers=${sess_headers}
    ${resp}=  Get Request   get_${name}   /   allow_redirects=${False}
    Log   ${resp.text}
    Should Be Equal As Integers   ${resp.status_code}   ${expected_response}


I push default binary app named ${name:[^ ]*} and expect response
    I push default binary app named ${name}
    I expect app ${name} from instance 0 to contains response "Hello from a binary"