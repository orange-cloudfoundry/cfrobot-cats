*** Settings ***
Variables         ../config.yml
Documentation     Ensuring that important features for running and managing apps works
Resource          ../resources/common.robot
Library           ../lib/CFCliLibrary.py   ${cf_cli_path}
Library           ../lib/HelperLibrary.py
Library           RequestsLibrary
Library           OperatingSystem
Test Timeout      5 minutes
Test Teardown     Run Keywords
...               cf  delete  %{CF_APP_NAME}   -f
...               AND  cf  delete-orphaned-routes  -f
Default Tags      runtime
*** Test Cases ***
App can be pushed scaled and deleted
    When I push default binary app named %{CF_APP_NAME} and expect response
    Then I can scale app %{CF_APP_NAME} to 2 instances and expect response from all instances
    Then I delete app %{CF_APP_NAME}
User can see logs
    When I push default binary app named %{CF_APP_NAME}
    Then I can have my logs from app %{CF_APP_NAME}
User can ssh into app
    When I push default binary app named %{CF_APP_NAME}
    Then I run command /usr/bin/env in ssh in app %{CF_APP_NAME} and expect to result to VCAP_APPLICATION=.*"application_name":"%{CF_APP_NAME}"

*** Keywords ***
I run command ${cmd} in ssh in app ${name} and expect to result to ${expect_result_regex}
    ${result}=  cf  ssh   ${name}   -c  ${cmd}
    Should Match Regexp   ${result}   ${expect_result_regex}
I download app ${name} and match file ${filepath} with source dir ${dir} on both side
    ${dl_dir}=  download and extract app  ${name}
    ${dl_content}=  Get File  ${dl_dir}/${filepath}
    ${expect_content}=  Get File  ${dir}/${filepath}
    Remove Directory  ${dl_dir}   True
    Should Be Equal   ${expect_content}  ${dl_content}

I can have my logs from app ${name}
    ${result}=  cf  logs  --recent  ${name}
    Should Match Regexp   ${result}   \[(App|APP).*/0\]

I can scale app ${name} to ${n} instances and expect response from all instances
    cf  scale   ${name}   -i  ${n}
    FOR    ${instance}    IN RANGE    ${n}
      I expect app ${name} from instance ${instance} to contains response "Hello from a binary"
    END
