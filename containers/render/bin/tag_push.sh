#!/bin/bash

docker tag povray_processor/pov_runner:latest us-central1-docker.pkg.dev/terraform-play-2/povray-processor/povray_runner:latest
docker push us-central1-docker.pkg.dev/terraform-play-2/povray-processor/povray_runner:latest