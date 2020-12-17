*** Settings ***
Variables         ../config.yml
Documentation     Ensuring that uaa-auth service through gobis works
...               If you haven't in your infra just exclude by running with paramater --exclude uaa-auth
Resource          ../resources/common.robot
Library           ../lib/CFCliLibrary.py
Library           ../lib/HelperLibrary.py
Library           RequestsLibrary
Library           OperatingSystem
Test Timeout      5 minutes
Test Setup        Run Keywords
...               cf  enable-service-access  ${gobis_route_service.service_name}  -o  ${org_name}
Test Teardown     Run Keywords
...               cf  delete  %{CF_APP_NAME}   -f
...               AND  cf  unbind-route-service  %{CF_DOMAIN}  --hostname  %{CF_APP_NAME}  ${uaa_auth_instance_name}   -f
...               AND  cf  delete-orphaned-routes  -f
...               AND  cf  delete-service  ${uaa_auth_instance_name}  -f
Default Tags      gobis   uaa-auth
*** Test Cases ***
User auth can be set on an app and unset
    Given I push default binary app named %{CF_APP_NAME} and expect response
    When I set up uaa-auth user route service on app %{CF_APP_NAME}
    Then I expect to be redirected to login page from app %{CF_APP_NAME}

    When I unset uaa-auth user route service on app %{CF_APP_NAME}
    Then I expect app %{CF_APP_NAME} from instance 0 to contains response "Hello from a binary"
*** Variables ***
${uaa_auth_instance_name}     my-uaa-auth-cfrobot-cats

*** Keywords ***
I set up uaa-auth user route service on app ${name}
    cf  create-service  ${gobis_route_service.service_name}   ${gobis_route_service.plan_name}  ${uaa_auth_instance_name}
    cf  bind-route-service  %{CF_DOMAIN}  --hostname  ${name}   ${uaa_auth_instance_name}
    Sleep   ${push_update_wait}
I unset uaa-auth user route service on app ${name}
    cf  unbind-route-service  %{CF_DOMAIN}  --hostname  ${name}  ${uaa_auth_instance_name}   -f
    Sleep   ${push_update_wait}
I expect to be redirected to login page from app ${name}
    I expect app ${name} from instance 0 to have response code "302"
