
# Things we need
# - Build containers
# - Deploy terraform
# - Build the Python library

#SHELL := /bin/bash

nothing:
	$(warning no default target)

all: client terraform_apply
	echo "Making all"

build_tag_stitch_service:
	echo "Building the stitch service container..."


	# This loads the tfvars into environment variables.
	#eval $(python -c \"from src.utils import tfvars_to_env;tfvars_to_env('./terraform/blobdell-povstorm.tfvars')\")
	#python -c 'from src.utils import tfvars_to_env;tfvars_to_env("./terraform/blobdell-povstorm.tfvars")' > ./env
	#pwd
	#source ./env
	#echo "******"
	#source ./env set | grep TF_VAR
	#echo "******" 
	#echo ${SHELL}
	#eval $(echo "BRYCE=9")
	#echo docker build ./containers/render -t ${TF_VAR_render_service_docker_tag}
	#echo docker tag ${TF_VAR_render_service_docker_tag}:latest us-central1-docker.pkg.dev/${TF_VAR_target_gcp_project_id}/${TF_VAR_render_service_docker_tag}:latest

# export BLAH=`echo "Trent"` && echo $$BLAH

build_tag_render_service:
	echo "Building the render service container..."
	python -c "from src.utils import tfvars_to_env;tfvars_to_env('./terraform/blobdell-povstorm.tfvars')" > this_env
	. ./this_env && echo docker build ./containers/render --tag $$target_gcp_region-docker.pkg.dev/$$TF_VAR_target_gcp_project_id/$$TF_VAR_render_service_docker_tag:latest 
	#. ./this_env && echo docker tag $$TF_VAR_render_service_docker_tag:latest $$target_gcp_region-docker.pkg.dev/$$TF_VAR_target_gcp_project_id/$$TF_VAR_render_service_docker_tag:latest 
	. ./this_env && echo docker push us-central1-docker.pkg.dev/$$TF_VAR_target_gcp_project_id/$$TF_VAR_render_service_docker_tag:latest

terraform_plan: build_tag_render_service
	echo "Running Terraform plan..."
	terraform plan -chdir="./terraform" -var-file="blobdell-povstorm.tfvars"


terraform_apply: build_tag_render_service
	echo "Running Terraform apply..."
	terraform apply -chdir="./terraform" -var-file="blobdell-povstorm.tfvars"

terraform_destroy:
	echo "Running Terraform apply..."
	terraform destory -chdir="./terraform" -var-file="blobdell-povstorm.tfvars"

client:
	echo "Building the Python client..."











