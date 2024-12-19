
# Things we need
# - Build containers
# - Deploy terraform
# - Build the Python library

#SHELL := /bin/bash
ENV_NAME := local_env

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


create_python_env:
	if [ ! -f ${ENV_NAME}/bin/activate ]; then python -m venv ${ENV_NAME}; fi
	. ${ENV_NAME}/bin/activate; pip install -r requirements.txt


build_tag_render_service: create_python_env
	echo "Building the render service container..."
	. ${ENV_NAME}/bin/activate; python -c "from src.utils import tfvars_to_env;tfvars_to_env('./terraform/blobdell-povstorm.tfvars')" > this_env
	. ./this_env && docker build ./containers/render --tag $${TF_VAR_target_gcp_region}-docker.pkg.dev/$${TF_VAR_target_gcp_project_id}/$${TF_VAR_povstorm_namespace}-repository/$${TF_VAR_render_service_docker_tag_postfix}:latest 
	#. ./this_env && docker push $${TF_VAR_target_gcp_region}-docker.pkg.dev/$${TF_VAR_target_gcp_project_id}/$${TF_VAR_povstorm_namespace}/$${TF_VAR_render_service_docker_tag_postfix}:latest 


terraform_plan: build_tag_render_service
	echo "Running Terraform plan..."
	terraform -chdir="./terraform" plan -var-file="blobdell-povstorm.tfvars"


terraform_apply: build_tag_render_service
	echo "Running Terraform apply..."
	terraform -chdir="./terraform" apply -var-file="blobdell-povstorm.tfvars"

terraform_destroy:
	echo "Running Terraform apply..."
	terraform -chdir="./terraform" destroy -var-file="blobdell-povstorm.tfvars"

client:
	echo "Building the Python client..."











