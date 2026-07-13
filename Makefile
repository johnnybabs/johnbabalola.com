.PHONY: dev-setup init plan apply deploy destroy lint fmt validate test

TERRAFORM_DIR := infra

# Install pre-commit and wire it into the local git hooks so lint runs
# before every commit. Run this once after cloning.
dev-setup:
	pip install --user pre-commit || pipx install pre-commit
	pre-commit install
	@echo "pre-commit installed. Hooks will run on every commit."

init:
	cd $(TERRAFORM_DIR) && terraform init

plan:
	cd $(TERRAFORM_DIR) && terraform plan

apply:
	cd $(TERRAFORM_DIR) && terraform apply

fmt:
	cd $(TERRAFORM_DIR) && terraform fmt -recursive

validate:
	cd $(TERRAFORM_DIR) && terraform init -backend=false && terraform validate

lint:
	pre-commit run --all-files

test:
	bash tests/smoke.sh

deploy:
	@echo "Automated deploy runs via GitHub Actions on push to main."
	@echo "For a manual upload, see docs/runbooks/manual-deploy.md"

destroy:
	@echo "This stack is tagged Teardown=false. See teardown.sh for the --force path."
	@exit 1
