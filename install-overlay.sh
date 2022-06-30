#!/usr/bin/env bash
# we need to derive the wildfly version used in the feature pack, e.g. 26.0.0.Final, from the actual wildfly version, e.g. 26.0.1.Final

set -e
set -x

WILDFLY_VERSION=$1
WILDFLY_GRAPHQL_VERSION=$2

# shellcheck disable=SC2001
WILDFLY_GRAPHQL_BASE_VERSION=$(echo "$WILDFLY_VERSION" | sed 's/.[0-9]*.[0-9]*.Final/.0.0.Final/')

URL=https://github.com/wildfly-extras/wildfly-graphql-feature-pack/releases/download/${WILDFLY_GRAPHQL_VERSION}/wildfly-${WILDFLY_GRAPHQL_BASE_VERSION}-mp-graphql-${WILDFLY_GRAPHQL_VERSION}-overlay.zip

curl -L "${URL}" -o overlay.zip

unzip overlay.zip
rm overlay.zip
