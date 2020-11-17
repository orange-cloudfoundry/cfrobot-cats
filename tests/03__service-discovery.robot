*** Settings ***
Variables         ../config.yml
Documentation     Ensuring that service discovery and policies is working
Resource          ../resources/common.robot
Library           ../lib/CFCliLibrary.py   ${cf_cli_path}
Library           ../lib/HelperLibrary.py
Library           RequestsLibrary
Test Timeout      5 minutes
Test Teardown     Run Keywords
...               cf  delete  %{CF_APP_NAME}   -f
...               AND  cf  delete  ${app_proxy_name}  -f
...               AND  cf  delete-orphaned-routes  -f
Default Tags      service-discovery
*** Test Cases ***
Service discovery access is working between 2 apps
    Given I push default binary app named %{CF_APP_NAME}
    Given I create a proxy app
    When I set up internal route on app %{CF_APP_NAME} and set access policy to proxy app
    I expect to reach app %{CF_APP_NAME} through proxy app

*** Keywords ***
I create a proxy app
    I push an app named ${app_proxy_name} with buildpack go_buildpack from asset proxy with manifest

I set up internal route on app ${name} and set access policy to proxy app
    cf  map-route   ${name}   ${default_internal_domain}   --hostname  ${name}
    Sleep  ${push_update_wait}
    cf  add-network-policy  ${app_proxy_name}  ${name}  --protocol  tcp  --port  8080

I expect to reach app ${name} through proxy app
    Create Session  get_proxy_app   ${url_protocol}://${app_proxy_name}.%{CF_DOMAIN}   verify=${python_request_verify_cert}
    ${resp}=  Get Request   get_proxy_app   /proxy/${name}.${default_internal_domain}:8080   allow_redirects=${False}

*** Variables ***
${app_proxy_name}       %{CF_APP_NAME}-proxy