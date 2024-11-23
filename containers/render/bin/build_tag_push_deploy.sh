#!/bin/bash

./bin/build.sh
./bin/tag_push.sh

gcloud run deploy povray-runner --region=us-central1 --image us-central1-docker.pkg.dev/terraform-play-2/povray-processor/povray_runner:latest 