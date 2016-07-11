# BOSH Release for graphite-nozzle

The aim of this bosh release is to deploy a [graphite-nozzle](https://github.com/pivotal-cf/graphite-nozzle) in order to filter [loggregator](https://github.com/cloudfoundry/loggregator) metrics and send them to a statsd server

### jobs

- graphite-nozzle

### packages

* autoconf
* python
* git
* golang1.6
* python

# Prerequisites

- BOSH CLI
- A working Cloud Foundry environment. This release is setup to work with a CF BOSH lite environment, but you should be able to deploy it to any environment by first uploading the final release provided

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
git clone https://github.com/SpringerPE/graphite-nozzle-boshrelease.git
cd graphite-nozzle-boshrelease
bosh deployment `path_to_your_manifest`
bosh upload release && bosh deploy
```

For [bosh-lite](https://github.com/cloudfoundry/bosh-lite), you can quickly create a deployment manifest & deploy a cluster:

```
./bosh_prepare
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
 