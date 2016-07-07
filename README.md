# BOSH Release for graphite-nozzle

The aim of this bosh release is to deploy a graphite-nozzle in order to filter loggregator metrics and send them to a statsd deployment

* graphite-nozzle

#Prerequisites

- BOSH CLI
- A working Cloud Foundry environment. This release is setup to work with a CF BOSH lite environment, but you should be able to deploy it to any environment.
- Add graphite-nozzle UAA client in Cloud Foundry deployment manifest
```
properties:
  uaa:
    clients:
      graphite-nozzle:
        access-token-validity: 1209600
        authorized-grant-types: authorization_code,client_credentials,refresh_token
        override: true
        secret: example-nozzle
        scope: openid,oauth.approvals,doppler.firehose
        authorities: oauth.login,doppler.firehose
```
- bosh deploy your Cloud Foundry environment again with the above changes present

## Usage

To use this bosh release, first upload it to your bosh:

```
bosh target BOSH_HOST
git clone https://github.com/SpringerPE/go-graphite-boshrelease.git
cd go-graphite-boshrelease
bosh create release && bosh upload release
```

For [bosh-lite](https://github.com/cloudfoundry/bosh-lite), you can quickly create a deployment manifest & deploy a cluster:

```
templates/make_manifest warden
bosh -n deploy
```

### Development

As a developer of this release, create new releases and upload them:

```
# Prepare the golang packages resolving their dependencies beforehand
./bosh_prepare
bosh create release --force && bosh -n upload release
```


