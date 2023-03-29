# SCHEMAS

<!--toc:start-->
- [SCHEMAS](#schemas)
  - [Overview](#overview)
  - [Openshift](#openshift)
<!--toc:end-->

## Overview

This repo holds all the schemas required to *validate*  or use  *yaml-language-sever* within an openshift context.

Openshift it based on Kubernetes but offers some additional APIs, that are not available with the kubernetes api itself. Also Openshift relies heavily on Operators to manage itself and provide different services.
Because of this Openshift is full of CRDs that enable users to use the various operators by creating different *CustomResources*.

To be able to validate manifests agains an openshift context or use them with yaml-language-sever we need to get openapi schema definition of all these resources and convert it to jsonschema format.

## Openshift

The openapi schema is available from the official Openshift Api repo on [github](https://github.com/openshift/api). The schema is under the *openapi* folder in a file named *openapi.json*.

The script `build.sh` downloads this schema and converts it to jsonschema.

## CRDs

All the CRDs are downloaded from the cluster you are currently connected to and converts them to jsonschema.

The script `crds.sh` is responsible for this.
