*** Settings ***
Variables         ../config.yml
Documentation     Ensuring that rolling deployment is working as expected
Resource          ../resources/common.robot
Library           ../lib/CFCliLibrary.py   ${cf_cli_path}
Library           ../lib/HelperLibrary.py
Library           RequestsLibrary
Library           Collections
Test Timeout      5 minutes
Test Teardown     Run Keywords
...               cf  delete  %{CF_APP_NAME}   -f
...               AND  cf  delete-orphaned-routes  -f
Default Tags      rolling
*** Test Cases ***
Rolling an app is useable
    Given I push default binary app named %{CF_APP_NAME}
    Given I store previous instance id for app %{CF_APP_NAME}
    When I push default binary app named %{CF_APP_NAME} with rolling strategy
    Then I expect that instance id change for app %{CF_APP_NAME}

*** Keywords ***
I store previous instance id for app ${name}
    Create Session  get_instance_id_${name}   ${url_protocol}://${name}.%{CF_DOMAIN}   verify=${python_request_verify_cert}
    ${resp}=  Get Request   get_instance_id_${name}   /env   allow_redirects=${False}
    Log   ${resp.text}
    ${instance_guid}=   Get From Dictionary   ${resp.json()}  INSTANCE_GUID
    Set Global Variable   ${previous_instance_id}   ${instance_guid}

I expect that instance id change for app ${name}
    Create Session  get_instance_id_${name}   ${url_protocol}://${name}.%{CF_DOMAIN}   verify=${python_request_verify_cert}
    ${resp}=  Get Request   get_instance_id_${name}   /env   allow_redirects=${False}
    Log   ${resp.text}
    ${instance_guid}=   Get From Dictionary   ${resp.json()}  INSTANCE_GUID
    Should Not Be Equal   ${instance_guid}  ${previous_instance_id}
