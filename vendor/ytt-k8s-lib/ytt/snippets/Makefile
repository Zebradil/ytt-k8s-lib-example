# This Makefile is intended to be used in ytt-based projects.
#
# It reads `.env` from the current directory and requires `.bootstrap.mk` in the repository root.
# - https://github.com/zebradil/ytt-k8s-lib/blob/master/.bootstrap.mk
#
# It works with the following project structure:
# .
# ├── bin
# │  └── decrypt_for_ytt
# ├── Makefile
# ├── manifests
# │  └── ...
# ├── vendir.yml
# └── ytt
#    ├── app
#    │  └── <ytt templates>
#    ├── common
#    │  ├── <common ytt stuff, like:>
#    │  ├── overlays.yaml
#    │  └── values.yaml
#    ├── init
#    │  └── <ytt templates for administrative resources (SA, namespace, etc.)>
#    ├── secrets
#    │  └── <ytt templates for secrets>
#    └── secrets.sops.yaml
#
# Take a look at infrastructure configuration of de/youtube-scraper repo
# and snippets from devops/ytt-k8s-lib repo:
#   - vendir.yml
#   - decrypt_for_ytt


ifneq (,$(wildcard *.Makefile))
  include *.Makefile
endif

include $(shell git rev-parse --show-toplevel)/.bootstrap.mk

ifneq (,$(wildcard .env))
  include .env
  export $(shell sed 's/=.*//' .env)
endif

# This is the apps name, which is needed for kapp and should be unique per namespace.
# It is required for kapp to maintain state, especially when multiple apps are deployed into the same namespace.
ifndef APP_NAME
  $(error APP_NAME is not set)
endif

# This is the k8s namespace in which the app is deployed.
# It defaults to APP_NAME
APP_NAMESPACE ?= $(APP_NAME)

# This is the k8s namespace kapp will use for storing it's data in configmaps
KAPP_NAMESPACE ?= $(APP_NAMESPACE)

# Name of the service account which is used for CI of the app
SERVICE_ACCOUNT ?= 'namespace-admin'

# Optionally set this to application name, this app is a part of
PART_OF ?= $(APP_NAMESPACE)

# This is the path to ytt binary plus default flags
YTT = ytt --data-value namespace=$(APP_NAMESPACE) --data-value part_of=$(PART_OF)

## General

install:: ## Installs vendir dependencies
	vendir sync --locked

update:: ## Updates vendir dependencies
	vendir sync
	export bootstrap=vendor/ytt-k8s-lib/ytt/snippets/.bootstrap.mk
	test -f $$bootstrap && cp -p $$bootstrap $$(git rev-parse --show-toplevel)/.bootstrap.mk || true
	$(MAKE) test

## Initial setup

apply-init:: render-init ## Creates base resources
	kubectl apply -f manifests/init.yaml

render-init:: ## Renders manifests for initial setup
	$(YTT) -f ytt/init \
	    -f ytt/common \
	    > manifests/init.yaml

## Configure CI

get-kube-sa-token:: ## Prints access token of service account
	kubectl -n $(APP_NAMESPACE) get secret -o jsonpath='{.data.token}' \
	    $$(kubectl -n $(APP_NAMESPACE) get sa $(SERVICE_ACCOUNT) -o jsonpath='{.secrets[0].name}') \
	    | base64 --decode

get-kube-server-ca:: ## Prints server CA
	kubectl config view --minify --raw --output 'jsonpath={..cluster.certificate-authority-data}'

get-kube-server-url:: ## Prints cluster URL
	kubectl config view --minify --raw --output 'jsonpath={..cluster.server}'

get-ci-variables:: ## Prints evironment variables for CI
	printf "KUBE_NAMESPACE=$(APP_NAMESPACE)"
	printf "\n\nKUBE_SERVER="
	$(MAKE) get-kube-server-url
	printf "\n\nKUBE_SERVER_CA="
	$(MAKE) get-kube-server-ca
	printf "\n\nKUBE_SA_TOKEN="
	$(MAKE) get-kube-sa-token
	echo

## Secrets

edit-secrets:: ## Decrypts secrets file and opens it in $EDITOR
	sops ytt/secrets.sops.yaml

apply-secrets:: ## Decripts secret values with sops, renders and applies secrets
	./bin/decrypt_for_ytt ytt/secrets.sops.yaml \
	| $(YTT) -f ytt/common \
	      -f ytt/secrets \
	      -f - \
	| kubectl apply -f -
	# TODO Find a way to request pods using the secrets (popeye does a similar thing)
	echo -e "\033[0;33mNow recreate pods which are referencing the secrets\033[0m"

show-secrets:: ## Decripts secret values with sops, renders and stdouts secrets
	./bin/decrypt_for_ytt ytt/secrets.sops.yaml \
	| $(YTT) -f ytt/common \
	      -f ytt/secrets \
	      -f - \

diff-secrets:: ## Decripts secret values with sops, renders and applies secrets
	./bin/decrypt_for_ytt ytt/secrets.sops.yaml \
	| $(YTT) -f ytt/common \
	      -f ytt/secrets \
	      -f - \
	| kubectl diff -f -

## Main stack

render-stack:: ## Renders templates into manifests
	$(YTT) -f ytt/common \
	    -f ytt/app \
	| kbld -f- > manifests/stack.yaml

apply-stack:: ## Applies manifests to Kubernetes
	kapp deploy -c -a $(APP_NAME) -f <(kbld -f manifests/stack.yaml)

## Tests

test:: test-init test-secrets test-stack ## Tests that templates are rendered successfully

test-init:: ## Tests init templates rendering
	printf "\033[0;33mInit rendering: \033[0m"
	error=$$( \
	  $(YTT) -f ytt/common \
	      -f ytt/init \
	    2>&1 > /dev/null \
	) \
	&& echo -e "\033[0;32mOK\033[0m" || (echo -e "\033[0;31mFAIL\033[0m"; echo -e "$$error")

test-secrets:: ## tests secrets templates rendering
	printf "\033[0;33mSecrets rendering: \033[0m"
	error=$$( \
	  ./bin/decrypt_for_ytt ytt/secrets.sops.yaml \
	  | $(YTT) -f ytt/common \
	      	-f ytt/secrets \
	      	-f - \
	    2>&1 > /dev/null \
	) \
	&& echo -e "\033[0;32mOK\033[0m" || (echo -e "\033[0;31mFAIL\033[0m"; echo -e "$$error")

test-stack:: ## Tests stack templates rendering
	printf "\033[0;33mStack rendering: \033[0m"
	error=$$( \
	  $(YTT) -f ytt/common \
	      -f ytt/app \
	    2>&1 > /dev/null \
	) \
	&& echo -e "\033[0;32mOK\033[0m" || (echo -e "\033[0;31mFAIL\033[0m"; echo -e "$$error")
