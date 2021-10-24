#!/bin/bash
set -e

applyfn () {
    local cuekey=$1
    local gmtype=$2
    for item in $(./export.sh $cuekey | jq -c '.[]'); do
        echo $item | greymatter apply -t $gmtype -f -
    done
}

applyfn domains domain
applyfn clusters cluster
applyfn listeners listener
applyfn proxies proxy
# we don't have any sharedrules in this test cluster
#applyfn sharedrules sharedrule
applyfn routes route

