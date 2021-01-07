*** Settings ***
Variables         ../config.yml
Documentation     Ensuring that cfsecurity entitlement is working correctly
Resource          ../resources/common.robot
Library           ../lib/CFCliLibrary.py
Library           ../lib/HelperLibrary.py
Library           RequestsLibrary
Library           OperatingSystem
Test Timeout      15 minutes
Test Setup        Run Keywords
...               I create a simple user for org ${org_name} and ${space_name}
...               AND   cf  create-security-group   ${security_group_name}  ./assets/sec-group-test.json
Test Teardown     Run Keywords
...               I login as admin
...               AND   target  ${org_name}   ${space_name}
...               AND   I delete simple user
...               AND   cf  disable-security-group  ${security_group_name}  ${org_name}
...               AND   cf  delete-security-group  ${security_group_name}   -f

Default Tags      cfsecurity

*** Test Cases ***
Admin can entitle secgroup and org manager can use it after
    When Admin entitles cats security group to org ${org_name}
    Then User can bind cats security group to org ${org_name} and space ${space_name}
    Then User can unbind cats security group from org ${org_name} and space ${space_name}

*** Variables ***
${security_group_name}     security-group-cats


*** Keywords ***
Admin entitles cats security group to org ${org}
    cf  enable-security-group   ${security_group_name}  ${org_name}

User can bind cats security group to org ${my_org} and space ${my_space}
    I login as simple user
    cf  bind-manager-security-group   ${security_group_name}  ${my_org}   ${my_space}
    I login as admin
    ${result}=  cf  security-group  ${security_group_name}
    Should Contain  ${result}   ${my_org}
    Should Contain  ${result}   ${my_space}

User can unbind cats security group from org ${my_org} and space ${my_space}
    I login as simple user
    cf  unbind-manager-security-group   ${security_group_name}  ${my_org}   ${my_space}
    I login as admin
    ${result}=  cf  security-group  ${security_group_name}
    Should Not Contain  ${result}   ${my_org}
    Should Not Contain  ${result}   ${my_space}
