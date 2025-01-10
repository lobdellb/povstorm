
# Things we need
# - Build containers
# - Deploy terraform
# - Build the Python library

#SHELL := /bin/bash
ENV_NAME := local_env
EXAMPLE_ENV := example_env

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

package_client:
	. ${ENV_NAME}/bin/activate; cd src/povstorm_client; poetry build


build_tag_render_service: create_python_env package_client
	echo "Building the render service container..."
	. ${ENV_NAME}/bin/activate; python -c "from src.utils import tfvars_to_env;tfvars_to_env('./terraform/blobdell-povstorm.tfvars')" > this_env
	cp src/povstorm_client/dist/povstorm_client-0.1.0-py3-none-any.whl ./containers/render/
	. ./this_env && docker build ./containers/render --tag $${TF_VAR_target_gcp_region}-docker.pkg.dev/$${TF_VAR_target_gcp_project_id}/$${TF_VAR_povstorm_namespace}-repository/$${TF_VAR_render_service_docker_tag_postfix}
	#. ./this_env && docker inspect --format='{{index .RepoDigests 0}}' $${TF_VAR_target_gcp_region}-docker.pkg.dev/$${TF_VAR_target_gcp_project_id}/$${TF_VAR_povstorm_namespace}-repository/$${TF_VAR_render_service_docker_tag_postfix} > latest_render_container_hash
	#. ./this_env && docker push $${TF_VAR_target_gcp_region}-docker.pkg.dev/$${TF_VAR_target_gcp_project_id}/$${TF_VAR_povstorm_namespace}/$${TF_VAR_render_service_docker_tag_postfix}:latest 

push_render_service: build_tag_render_service
	echo "Push the render service container to GCP artifact registery..."
	. ${ENV_NAME}/bin/activate; python -c "from src.utils import tfvars_to_env;tfvars_to_env('./terraform/blobdell-povstorm.tfvars')" > this_env
	. ./this_env && docker push $${TF_VAR_target_gcp_region}-docker.pkg.dev/$${TF_VAR_target_gcp_project_id}/$${TF_VAR_povstorm_namespace}-repository/$${TF_VAR_render_service_docker_tag_postfix}
	. ./this_env && gcloud container images list-tags $${TF_VAR_target_gcp_region}-docker.pkg.dev/$${TF_VAR_target_gcp_project_id}/$${TF_VAR_povstorm_namespace}-repository/$${TF_VAR_render_service_docker_tag_postfix} --limit=1 --format="get(digest)" > latest_render_container_hash


terraform_plan: push_render_service
	echo "Running Terraform plan..."
	terraform -chdir="./terraform" plan -var-file="blobdell-povstorm.tfvars" -out=plan.tfplan


terraform_apply: push_render_service
	echo "Running Terraform apply (to stand up infra) ..."
	terraform -chdir="./terraform" apply -json -var-file="blobdell-povstorm.tfvars" plan.tfplan  | tee tf_outputs.json | jq .
	#terraform apply ./terraform/plan.tfplan # | tee tf_outputs.json | jq .

terraform_destroy:
	echo "Running Terraform destory (to take down infra) ..."
	terraform -chdir="./terraform" destroy -var-file="blobdell-povstorm.tfvars"


clean:
	find -name \*.whl -not -path "./${ENV_NAME}/*" -exec rm {} \;
	find -name \*.tgz -not -path "./${ENV_NAME}/*" -exec rm {} \;
	find -name \*.tar.gz -not -path "./${ENV_NAME}/*" -exec rm {} \;

create_example_python_env:
	if [ ! -f ${EXAMPLE_ENV}/bin/activate ]; then python -m venv ${EXAMPLE_ENV}; fi
	. ${EXAMPLE_ENV}/bin/activate; pip install -r ./example_client/requirements.txt

run_example: terraform_apply package_client create_example_python_env
	echo "Running example..."





# I should possibly create files name ?.o as a way of clocking which work has been already done, and then delete those in the clean step.

# Todo:
# - Figure out how to deal with the python package name issue, ie., we don't want a mega-long package name.
# - Deal with the pip version issues
# - Remove string "blobdell" from everything
# - use .o files or something to deal with the re-running things issue
# - Rename the create venv steps

