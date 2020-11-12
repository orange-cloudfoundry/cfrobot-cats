*** Settings ***
Variables         config.yml
Documentation     Ensuring that important features for running and managing apps works
Resource          resources/common.robot
Library           lib/CFCliLibrary.py
Library           lib/HelperLibrary.py
Library           RequestsLibrary
Library           OperatingSystem
Test Timeout      5 minutes
Test Teardown     cf  delete  %{CF_BINARY_APP_NAME}   -f
Default Tags      runtime
*** Test Cases ***
App can be pushed scaled and deleted
    When I push default binary app named %{CF_BINARY_APP_NAME} and expect response
    Then I can scale app %{CF_BINARY_APP_NAME} to 2 instances and expect response from all instances
    Then I delete app %{CF_BINARY_APP_NAME}
User can see logs
    When I push default binary app named %{CF_BINARY_APP_NAME}
    Then I can have my logs from app %{CF_BINARY_APP_NAME}
App can be downloaded
    When I push default binary app named %{CF_BINARY_APP_NAME}
    Then I download app %{CF_BINARY_APP_NAME} and match file app with source dir ${app_binary_folder} on both side
User can ssh into app
    When I push default binary app named %{CF_BINARY_APP_NAME}
    Then I run command /usr/bin/env in ssh in app %{CF_BINARY_APP_NAME} and expect to result to VCAP_APPLICATION=.*"application_name":"%{CF_BINARY_APP_NAME}"

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
