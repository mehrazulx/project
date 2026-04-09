SHELL := /bin/bash

TF := terraform

.PHONY: fmt init validate plan apply plan-ingestion apply-ingestion plan-s3-only apply-s3-only

fmt:
	$(TF) fmt -recursive

init:
	$(TF) init -reconfigure

validate:
	$(TF) validate

plan:
	$(TF) plan

apply:
	$(TF) apply

plan-ingestion:
	$(TF) plan \
		-var='enable_regaffairs_ingestion=true' \
		-var='enable_regaffairs_datasync=true' \
		-var='enable_bedrock_kb_sync=true'

apply-ingestion:
	$(TF) apply \
		-var='enable_regaffairs_ingestion=true' \
		-var='enable_regaffairs_datasync=true' \
		-var='enable_bedrock_kb_sync=true'

plan-s3-only:
	$(TF) plan \
		-var='enable_regaffairs_ingestion=true' \
		-var='enable_regaffairs_datasync=false' \
		-var='enable_bedrock_kb_sync=false'

apply-s3-only:
	$(TF) apply \
		-var='enable_regaffairs_ingestion=true' \
		-var='enable_regaffairs_datasync=false' \
		-var='enable_bedrock_kb_sync=false'
