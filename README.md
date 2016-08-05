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

### How to update the graphite-nozzle release

##### Modify your current release

- Modify jobs and packages to meet your needs (do not forget to update the prepare scripts under `packages/{package}/prepare`)

##### Generate the updated packages and release

- run `./bosh_prepare` from the root of the project
  * the `./src` directory will be populated with the new versions of the packages
- run `add blob <local_path> [<blob_dir>]` for all the packages which need being updated
- run `bosh create release --force`

##### It's now time to test your release...

- run `bosh target {your_bosh_test_ip}` to make sure you're pointing to the right bosh
- run `bosh upload release {path_of_the_generated_Release_manifest}`
- modify your bosh manifest with the updated release version ie:

```
releases:
  - name: graphite-nozzle
    version: 5+dev.1
```

- run `bosh deployment {graphite-nozzle manifest path}`
- run `bosh deploy`
- Wait for compilation, vm updates and so on... 

##### Test your release and if you are happy with it...

- run `bosh upload blobs` 
- Commit your changes
- run `bosh create release --final`
- run `bosh upload release {path_of_the_generated_final_Release_manifest}`
- modify your bosh manifest with the updated release version ie:

```
releases:
  - name: graphite-nozzle
    version: 6
```

- run `bosh deployment {graphite-nozzle manifest path}`
- run `bosh deploy`
- Wait for compilation, vm updates and so on... 

##### Clean-up
- Finally Clean up the dev release from bosh: `bosh delete release {devrelease}`

### Development

As a developer of this release, create new releases and upload them:

```
# Prepare the golang packages resolving their dependencies beforehand
./bosh_prepare
bosh create release --force && bosh -n upload release
```
 
