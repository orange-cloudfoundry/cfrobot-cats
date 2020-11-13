*** Settings ***
Variables         ../config.yml
Documentation     Ensuring that expected feature flags are correctly configured
Resource          ../resources/common.robot
Library           ../lib/CFCliLibrary.py   ${cf_cli_path}
Default Tags      feature-flags
*** Test Cases ***
Validate feature flags expected
    ensure feature flags  ${expected_feature_flags}

