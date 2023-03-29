TF_PLAN_FILE=tf-plan
VERSION=#{TF_VERSION}#
config:
	rm -rf ${HOME}/.tfenv && \
	git clone https://github.com/tfutils/tfenv.git ~/.tfenv
	export PATH="${HOME}/.tfenv/bin:${PATH}" && \
	tfenv install ${VERSION} && \
	tfenv use ${VERSION} && \
	terraform version

init:
	rm -rf ~/.terraform
	export PATH="${HOME}/.tfenv/bin:${PATH}" && \
	terraform --version && \
	terraform init -var "access_key=$(AWS_ACCESS_KEY_ID)" -var "secret_key=$(AWS_SECRET_ACCESS_KEY)" -backend-config=backend.tfvars -reconfigure && \
	terraform fmt -recursive && \
	terraform validate

plan:
	export PATH="${HOME}/.tfenv/bin:${PATH}" && \
	terraform version && \
	terraform plan -out $(TF_PLAN_FILE)

apply:
	export PATH="${HOME}/.tfenv/bin:${PATH}" && \
	terraform version && \
	terraform apply --auto-approve $(TF_PLAN_FILE)

destroy:
	export PATH="${HOME}/.tfenv/bin:${PATH}" && \
	terraform version && \
	terraform destroy --auto-approve
