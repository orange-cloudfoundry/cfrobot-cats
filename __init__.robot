*** Settings ***
Variables         config.yml
Library           lib/CFCliLibrary.py
Suite Setup       Run Keywords
...               login  %{CF_API}  %{CF_USER}  %{CF_PASSWORD}  ${skip_ssl_validation}
...               AND  target  system
...               AND  create org with space and target  %{CF_ORG}   %{CF_SPACE}
Suite Teardown    Run Keywords
...               cleanup   kill=True
...               AND   delete org  %{CF_ORG}