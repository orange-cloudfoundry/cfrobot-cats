*** Settings ***
Variables         ../config.yml
Documentation     Ensuring that isolation segments with a shared/public sharding is working
Resource          ../resources/common.robot
Library           ../lib/CFCliLibrary.py
Library           ../lib/HelperLibrary.py
Library           RequestsLibrary
Library           OperatingSystem
Test Timeout      15 minutes
Test Setup        Run Keywords
...               cf  enable-org-isolation  ${org_name}   ${isolation_segments.segment_name}
...               AND  create space and target  ${org_name}   ${isolation_segments.space_name}
...               AND  cf   set-space-isolation-segment   ${isolation_segments.space_name}  ${isolation_segments.segment_name}
Test Teardown     Run Keywords
...               cf  delete  %{CF_APP_NAME}   -f
...               AND  cf  delete-orphaned-routes  -f
...               AND  cf  delete-space  ${isolation_segments.space_name}  -f
...               AND  cf  disable-org-isolation   ${org_name}   ${isolation_segments.segment_name}
...               AND  target   ${org_name}   ${space_name}
Default Tags      isolation-segments
*** Test Cases ***
User auth can be set on an app and unset
    Given I push default binary app named %{CF_APP_NAME}
    When I set public route on my app %{CF_APP_NAME}
    Then I expect answer "Hello from a binary" on public route for app %{CF_APP_NAME}

*** Keywords ***
I set public route on my app ${name}
    cf  map-route  ${name}  %{CF_PUBLIC_DOMAIN}   --hostname  ${name}
    Sleep   ${push_update_wait}

I expect answer "${expected_response}" on public route for app ${name}
    Create Session  get_${name}   ${url_protocol}://${name}.%{CF_PUBLIC_DOMAIN}   verify=${python_request_verify_cert}
    ${resp}=  Get Request   get_${name}   /   allow_redirects=${False}
    Should Contain   ${resp.text}   ${expected_response}