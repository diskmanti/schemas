#! /bin/bash

OCP_VERSIONS=$(git ls-remote --heads https://github.com/openshift/api | cut -d/ -f3 | grep release-4)
OPENAPI2JSONSCHEMABIN="podman run -i -v ${PWD}:/out/schemas ghcr.io/yannh/openapi2jsonschema:latest"

for OCP_VERSION in $OCP_VERSIONS master; do
	SCHEMA=https://raw.githubusercontent.com/openshift/api/${OCP_VERSION}/openapi/openapi.json
	PREFIX=https://raw.githubusercontent.com/diskmanti/schemas/main/openshift/${OCP_VERSION}/_definitions.json

	if [ ! -d "${OCP_VERSION}-standalone-strict" ]; then
		$OPENAPI2JSONSCHEMABIN -o "schemas/openshift/${OCP_VERSION}-standalone-strict" --expanded --kubernetes --stand-alone --strict "${SCHEMA}"
		$OPENAPI2JSONSCHEMABIN -o "schemas/openshift/${OCP_VERSION}-standalone-strict" --kubernetes --stand-alone --strict "$SCHEMA"
	fi

	if [ ! -d "${OCP_VERSION}-standalone" ]; then
		$OPENAPI2JSONSCHEMABIN -o "schemas/openshift/${OCP_VERSION}-standalone" --expanded --kubernetes --stand-alone "${SCHEMA}"
		$OPENAPI2JSONSCHEMABIN -o "schemas/openshift/${OCP_VERSION}-standalone" --kubernetes --stand-alone "${SCHEMA}"
	fi

	if [ ! -d "${OCP_VERSION}-local" ]; then
		$OPENAPI2JSONSCHEMABIN -o "schemas/openshift/${OCP_VERSION}-local" --expanded --kubernetes "${SCHEMA}"
		$OPENAPI2JSONSCHEMABIN -o "schemas/openshift/${OCP_VERSION}-local" --kubernetes "${SCHEMA}"
	fi

	if [ ! -d "${OCP_VERSION}" ]; then
		$OPENAPI2JSONSCHEMABIN -o "schemas/openshift/${OCP_VERSION}" --expanded --kubernetes --prefix "${PREFIX}" "${SCHEMA}"
		$OPENAPI2JSONSCHEMABIN -o "schemas/openshift/${OCP_VERSION}" --kubernetes --prefix "${PREFIX}" "${SCHEMA}"
	fi
done
