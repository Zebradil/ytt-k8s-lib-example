MAKE_MAJOR_VERSION := $(shell echo $(MAKE_VERSION) | cut -f1 -d.)

ifeq "$(shell expr $(MAKE_MAJOR_VERSION) \< 4)" "1"
$(error MAKE_VERSION < 4)
endif

$(shell cp -np .env.dist .env &>/dev/null || true)

# TODO This is due to MAKEFLAGS += --warn-undefined-variables in .bootstrap.mk
1 :=
2 :=

ifndef SKIP_DIR_TEST
	SKIP_DIR_TEST :=
endif


define log =
printf "\033[0;33m$(1)\033[0m"
endef

define test_env =
grep $(1)= .env || echo "$(2)"
endef

define update_env =
read $(1)
if [ -n "$$$(1)" ]; then
  function write_env(){
    if grep -q $(1) $$1; then
      sed -i.bak 's/$(1)=.*/$(1)='$$$(1)'/' $$1 && rm $$1.bak
    else
      echo $(1)=$$$(1) >> $$1
    fi
  }
  write_env .env
  write_env .env.dist
fi
endef


## Setup

setup:: setup-name setup-namespace setup-project update setup-bin setup-done ## All example-app setup

setup-name:: ## Prompt for APP_NAME and write it to .env
	$(call log,Set APP_NAME [$(APP_NAME)]: )
	$(call update_env,APP_NAME)
	$(call test_env,APP_NAME,Error: Please manually investigate .env)

setup-namespace:: ## Prompt for APP_NAMESPACE and write it to .env
	$(call log,Set APP_NAMESPACE [defaults to APP_NAME]: )
	$(call update_env,APP_NAMESPACE)
	$(call test_env,APP_NAMESPACE,Info: APP_NAMESPACE not set. Defaults to APP_NAME)

setup-project:: ## Initial example-app checkout
	[[ "$$SKIP_DIR_TEST" ]] && exit 0
	cd ../../

	if ! test -d infrastructure/kubernetes; then
	  echo Error: Directory infrastructure/kubernetes does not exist. Please investigate manually.
	  exit 1
	fi

	#: Remove unneeded files
	rm -rf infrastructure/kubernetes/{.git*,setup.Makefile,.bootstrap.mk}
	#: Copy Makefile library
	cp -np  infrastructure/kubernetes/vendor/ytt-k8s-lib/ytt/snippets/.bootstrap.mk . &>/dev/null || true
	#: Simplify README
	mv -f infrastructure/kubernetes/README.project.md infrastructure/kubernetes/README.md &>/dev/null || true

	git init &>/dev/null

setup-bin:: ## Sync all binaries
	$(call log,Linking into bin ...\n)
	find vendor/ytt-k8s-lib/ytt/snippets/bin -type f|xargs -I{} ln -sf ../{} bin/

setup-done::
	$(call log,Done\n)
