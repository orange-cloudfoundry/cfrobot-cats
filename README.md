# Cfrobot-cats

This is acceptance test for cloud foundry made with [robot framework](http://robotframework.org/) for easy extensibility and writing.

This was made to suits our cloud foundry in production to ensure features we have added or accessible feature inside cloud foundry has been working.

As far we:
- don't cover docker feature as this is deactivated in our cloud foundry
- don't cover tcp feature as this is not activated in our cloud foundry
- don't cover volume service as this is not proposed in our cloud foundry

## Run tests

1. run `pip install -r requirements.txt`
2. copy file [config.sample.yml](/config.sample.yml) to `config.yml` and fill the gaps.
3. export env var as follows:

```bash
export CF_API=https://api.to.your.cloudfoundry
export CF_USER='admin-user'
export CF_PASSWORD='admin-password'
export CF_ORG='cfrobot-cats-org'
export CF_SPACE='cfrobot-cats-space'
export CF_BINARY_APP_NAME='binary-app'
export CF_DOMAIN='app.domain.of.your.cloudfoundry'

# this next env var is optionnal, this is necessary if you run `isolation-segments` tests
export CF_PUBLIC_DOMAIN='pub.app.cf.bgl.hbx.geo.francetelecom.fr'
```

4. run `run-tests.sh [tests] [to] [include]` (e.g.: `run-tests.sh uaa-auth`)

**Note**: args after run-tests.sh are tests to include in addition of [runtime.robot](/runtime.robot).

## Tests availables

- `runtime`: **Default tests always ran**, test that ensure important features for running and managing apps works (deploy, scale, delete, logs, ssh) 
- `uaa-auth`: Tests to ensure that uaa-auth service through [gobis](https://github.com/orange-cloudfoundry/gobis-server) works
- `isolation-segments`: Tests to ensure that isolation segments works (with a shared/public separation architecture)

