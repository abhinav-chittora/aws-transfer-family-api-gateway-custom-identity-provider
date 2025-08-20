.PHONY: deploy login setup destroy destroy-setup

PROFILE ?= glbl-infra-ops-dev
COLOUR_GREEN=\033[0;32m
COLOUR_RED=\033[0;31m
COLOUR_BLUE=\033[0;34m
COLOUR_END=\033[0m

StackName ?= "transfer-family-solution-custom-idp-entra-id"

# Login to AWS SSO	
login:
	@echo "$(COLOUR_GREEN)Logging in to AWS...$(COLOUR_END)"
	@aws sts get-caller-identity --profile $(PROFILE) > /dev/null 2>&1 || aws sso login --profile $(PROFILE)

# Setup the AWS network environment
setup: login
	@echo "$(COLOUR_GREEN)Setting up AWS environment...$(COLOUR_END)"
	@if aws cloudformation describe-stacks --stack-name sftp-networksetup --profile $(PROFILE) > /dev/null 2>&1; then \
		echo "${COLOUR_BLUE}Stack exists, updating...$(COLOUR_END)"; \
		aws cloudformation update-stack --stack-name sftp-networksetup --template-body file://setup-aws-networking.yaml --parameters file://parameters.json --capabilities CAPABILITY_NAMED_IAM --profile $(PROFILE); \
	else \
		echo "$(COLOUR_RED)Stack does not exist, creating...$(COLOUR_END)"; \
		aws cloudformation create-stack --stack-name sftp-networksetup --template-body file://setup-aws-networking.yaml --parameters file://parameters.json --capabilities CAPABILITY_NAMED_IAM --profile $(PROFILE); \
	fi
	@echo "$(COLOUR_GREEN)Setup complete.$(COLOUR_END)"

destroy-setup: login
	@echo "$(COLOUR_GREEN)Destroying CloudFormation stack...$(COLOUR_END)"
	@aws cloudformation delete-stack --stack-name sftp-networksetup --profile $(PROFILE)	> /dev/null 2>&1
	@echo "$(COLOUR_RED)Stack deletion initiated.$(COLOUR_END)"

destroy: login
	@echo "$(COLOUR_GREEN)Destroying CloudFormation stack...$(COLOUR_END)"
	@aws cloudformation delete-stack --stack-name ${StackName} --profile $(PROFILE)	> /dev/null 2>&1
	@echo "$(COLOUR_RED)Stack deletion initiated.$(COLOUR_END)"

# Deploy the CloudFormation stack
deploy: login
	@echo "$(COLOUR_GREEN)Deploying CloudFormation stack...$(COLOUR_END)"
	@if aws cloudformation describe-stacks --stack-name ${StackName} --profile $(PROFILE) > /dev/null 2>&1; then \
		echo "$(COLOUR_BLUE)Stack exists, updating...$(COLOUR_END)"; \
		output=$$(aws cloudformation update-stack --template-body file://transfer-family-solution.yaml --stack-name ${StackName} --parameters file://sftp-parameters.json --capabilities CAPABILITY_NAMED_IAM --profile $(PROFILE) 2>&1); \
		if echo "$$output" | grep -q '"StackId":'; then \
			echo "$(COLOUR_BLUE)Deployment is underway.$(COLOUR_END)"; \
		else \
			echo "$(COLOUR_RED)Deployment failed.$(COLOUR_END)"; \
			echo "$$output"; \
		fi; \
	else \
		echo "$(COLOUR_RED)Stack does not exist, creating...$(COLOUR_END)"; \
		output=$$(aws cloudformation create-stack --template-body file://transfer-family-solution.yaml --stack-name ${StackName} --parameters file://sftp-parameters.json --capabilities CAPABILITY_NAMED_IAM --profile $(PROFILE) 2>&1); \
		if echo "$$output" | grep -q '"StackId":'; then \
			echo "$(COLOUR_BLUE)Deployment is underway.$(COLOUR_END)"; \
		else \
			echo "$(COLOUR_RED)Deployment failed.$(COLOUR_END)"; \
			echo "$$output"; \
		fi; \
	fi
