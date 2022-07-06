## Requirements

* [make](https://www.gnu.org/software/make/manual/make.html)
* [carvel tools](https://carvel.dev/) (vendir version >= 0.11.0)
* [sops](https://github.com/mozilla/sops)


## Render and apply namespace, secrets and templates

```bash
#: Create manifests for namespace and accounts/access-tokens inside manifests folder.
make render-init
#: Initially create this namespace and accounts on current kubectl context selected cluster.
make apply-init

#: Secrets are handled separately without being rendered cleartext/hashed into manifests folder.
make edit-secrets
make diff-secrets
make apply-secrets

#: For the app/project it goes with manifests first again
make render-stack
#: And then deploying them with kapp, respecting diffs before applying
make apply-stack
```

## Update vendors

Get current changes for the main library: [ytt-k8s-lib](https://github.com/zebradil/ytt-k8s-lib)

```bash
make update
```
