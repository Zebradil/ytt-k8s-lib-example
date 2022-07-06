## Requirements

* [make](https://www.gnu.org/software/make/manual/make.html)
* [carvel tools](https://carvel.dev/) (vendir version >= 0.11.0)
* [sops](https://github.com/mozilla/sops)

## New project setup

### Use example-app

> For existing project, replace `example-app` with your project-name and ensure directory `infrastructure/kubernetes` does not exist inside.

#### Recommended structure

```bash
mkdir example-app
cd example-app

git clone --depth 1 git@github.com:zebradil/ytt-k8s-lib-example.git infrastructure/kubernetes \
 && cd infrastructure/kubernetes \
 && make setup
```

#### Or put it into the same directory

```bash
mkdir example-app
cd example-app

git clone --depth 1 git@github.com:zebradil/ytt-k8s-lib-example.git . \
 && SKIP_DIR_TEST=1 make setup
```


### Manually from scratch

> What this project was setup with

```bash
mkdir -p example-app
cd example-app
```

Create the file [vendir.yml](https://github.com/zebradil/ytt-k8s-lib/-/raw/master/ytt/snippets/vendir.yml)

```bash
vendir sync
mkdir -p bin manifests ytt/{app,common,init,secrets}
find vendor/ytt-k8s-lib/ytt/snippets/bin -type f|xargs -I{} ln -s ../{} bin/
ln -s vendor/ytt-k8s-lib/ytt/snippets/{Makefile,.bootstrap.mk} .
echo APP_NAME=example-app > .env.dist
cp .env.dist .env

git init
git add --all
git commit -m "Initial ytt-k8s-lib-example"
make test
```
