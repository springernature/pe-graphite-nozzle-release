#!/bin/bash

set -e

template_prefix="graphite-nozzle"
STEMCELL_OS=${STEMCELL_OS:-ubuntu}

infrastructure=$1

fail() {
  echo >&2 $*
}

if [[ "$infrastructure" != "warden" ]] ; then
  fail "usage: ./make_manifest <warden>"
  exit 1
fi

case "${infrastructure}/${STEMCELL_OS}" in
  (warden/*)       STEMCELL_URL="https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent" ;;
  (*)
    fail "Invalid infrastructure or OS specified."
    exit 1
    ;;
esac

shift

BOSH_STATUS=$(bosh status)
DIRECTOR_UUID=$(echo "$BOSH_STATUS" | grep UUID | awk '{print $2}')
DIRECTOR_CPI=$(echo "$BOSH_STATUS" | grep CPI | awk '{print $2}' | sed -e 's/_cpi//')
DIRECTOR_NAME=$(echo "$BOSH_STATUS" | grep Name | awk '{print $2}')
NAME=$template_prefix-$infrastructure

if [[ $DIRECTOR_NAME = "warden" && ${infrastructure} != "warden" ]]; then
  fail "Not targeting bosh-lite with warden CPI. Please make sure you have run 'bosh target' and are targeting a BOSH lite before running this script."
  exit 1
fi

function latest_uploaded_stemcell {
  echo $(bosh stemcells | grep bosh | grep $STEMCELL_OS | awk -F'|' '{ print $2, $3 }' | sort -nr -k2 | head -n1 | awk '{ print $1 }')
}

STEMCELL=${STEMCELL:-$(latest_uploaded_stemcell)}
if [[ -z ${STEMCELL} ]]; then
  echo
  echo "Uploading latest $DIRECTOR_CPI/$STEMCELL_OS stemcell..."
  STEMCELL_URL=$(bosh public stemcells --full | grep $DIRECTOR_CPI | grep $STEMCELL_OS | sort -nr | head -n1 | awk '{ print $4 }')
  bosh upload stemcell $STEMCELL_URL
fi
STEMCELL=${STEMCELL:-$(latest_uploaded_stemcell)}

templates=$(dirname $0)
release=$templates/..
tmpdir=$release/tmp

mkdir -p $tmpdir
cp $templates/stub.yml $tmpdir/stub-with-uuid.yml
echo $DIRECTOR_NAME $DIRECTOR_CPI $DIRECTOR_UUID $STEMCELL
perl -pi -e "s/PLACEHOLDER-DIRECTOR-UUID/$DIRECTOR_UUID/g" $tmpdir/stub-with-uuid.yml
perl -pi -e "s/NAME/$NAME/g" $tmpdir/stub-with-uuid.yml
perl -pi -e "s/STEMCELL/$STEMCELL/g" $tmpdir/stub-with-uuid.yml

if ! [ -x "$(command -v spruce)" ]; then
  echo 'spruce is not installed. Please download at https://github.com/geofffranks/spruce/releases' >&2
fi

spruce merge --prune meta \
  $templates/deployment.yml \
  $templates/jobs.yml \
  $templates/infrastructure-${infrastructure}.yml \
  $tmpdir/stub-with-uuid.yml \
  $* > $tmpdir/$NAME-manifest.yml

bosh deployment $tmpdir/$NAME-manifest.yml
bosh status