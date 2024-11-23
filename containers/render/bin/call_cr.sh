#!/bin/bash

TOKEN=`gcloud auth print-identity-token`


curl -X POST -H "Authorization: Bearer ${TOKEN}" https://povray-runner-829986676083.us-central1.run.app \
	-d "{}" -H "Content-Type: application/json"


# curl -H \
# "Authorization: Bearer $(gcloud auth print-identity-token)" \
# https://povray-runner-829986676083.us-central1.run.app