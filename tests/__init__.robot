*** Settings ***
Variables         ../config.yml
Library           ../lib/CFCliLibrary.py   ${cf_cli_path}
Suite Setup       Run Keywords
...               login  %{CF_API}  %{CF_USER}  %{CF_PASSWORD}  ${skip_ssl_validation}
...               AND  target  system
...               AND  create org with space and target  ${org_name}  ${space_name}
Suite Teardown    Run Keywords
...               cleanup   kill=True
...               AND   delete org  ${org_name}