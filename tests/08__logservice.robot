*** Settings ***
*** Settings ***
Variables         ../config.yml
Documentation     Ensuring that logservice is taking logs from an app
Resource          ../resources/common.robot
Library           ../lib/CFCliLibrary.py
Library           ../lib/HelperLibrary.py
Library           ../lib/PrometheusLibrary.py
Library           RequestsLibrary
Library           OperatingSystem
Test Timeout      15 minutes
Test Teardown     Run Keywords
...               cf  delete  %{CF_APP_NAME}   -f
...               AND  cf  delete-orphaned-routes  -f
...               AND  cf  delete-service  ${logservice_instance_name}  -f
Default Tags      logservice

*** Test Cases ***
Logservice receive logs for app when it's bound to the app
    Given I push default binary app named %{CF_APP_NAME}
    When I set up logservice on app %{CF_APP_NAME}
    Then I expect to have logs received on logservice from app %{CF_APP_NAME}

*** Variables ***
${logservice_instance_name}     logs-cfrobot-cats

*** Keywords ***
I set up logservice on app ${name}
    cf  create-service  ${logservice.service_name}   ${logservice.plan_name}  ${logservice_instance_name}
    cf  bind-service  ${name}  ${logservice_instance_name}
    cf  restart   ${name}

I expect to have logs received on logservice from app ${name}
    Wait Until Keyword Succeeds   70x  50ms  expect to have logs received on logservice from app ${name}

expect to have logs received on logservice from app ${name}
    I expect app ${name} to contains response "Hello from a binary"
    ${instance_guid}=   cf  service   ${logservice_instance_name}   --guid
    Create Session  get_logservice   %{LOGSERVICE_URI}   verify=${python_request_verify_cert}
    ${resp}=  Get Request   get_logservice   /metrics   allow_redirects=${False}
    ${sent_total}=  prom search metric by labels  ${resp.text}  logs_sent_total   instance_id=${instance_guid}
    Should Be True   ${sent_total} > 1.0

