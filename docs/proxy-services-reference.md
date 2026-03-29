# Airgap Proxy Services — Developer Reference

## Proxy VM: 10.0.0.100
All services terminate TLS via self-signed certs (CA: `certs/ca-chain.pem`).

---

## Reverse Proxies (nginx on :443)

### Package Repositories

| Service | URL | Upstream | Usage |
|---------|-----|----------|-------|
| **YUM/RPM** | `https://yum.example.com` | Rocky 9, EPEL 9, RKE2 | `baseurl=https://yum.example.com/rocky/9/BaseOS/x86_64/os/` |
| **APT** | `https://apt.example.com` | Debian, Ubuntu | `deb https://apt.example.com/debian/ bookworm main` |
| **APK** | `https://apk.example.com` | Alpine v3.20, v3.21, edge | `https://apk.example.com/alpine/v3.21/main` |

### Language Package Managers

| Service | URL | Upstream | Usage |
|---------|-----|----------|-------|
| **Go** | `https://go.example.com` | proxy.golang.org, sum.golang.org | `GOPROXY=https://go.example.com,direct` |
| **NPM** | `https://npm.example.com` | registry.npmjs.org | `npm config set registry https://npm.example.com/` |
| **PyPI** | `https://pypi.example.com` | pypi.org, files.pythonhosted.org | `pip install --index-url https://pypi.example.com/simple/` |
| **Maven** | `https://maven.example.com` | repo1.maven.org, maven.google.com, plugins.gradle.org | `<url>https://maven.example.com/maven2/</url>` |
| **Crates** | `https://crates.example.com` | index.crates.io, static.crates.io | `[source.internal] registry = "sparse+https://crates.example.com/api/v1/crates/"` |

### Helm Charts

| Service | URL | Upstream | Usage |
|---------|-----|----------|-------|
| **Helm** | `https://charts.example.com` | 11 chart repos | `helm repo add jetstack https://charts.example.com/jetstack/` |

Available chart prefixes: `/jetstack/`, `/cnpg/`, `/hashicorp/`, `/goharbor/`, `/prometheus-community/`, `/external-secrets/`, `/autoscaler/`, `/ot-helm/`, `/kasmtech/`, `/gitlab/`, `/mariadb-operator/`

### Cloud Images & Downloads

| Service | URL | Upstream | Usage |
|---------|-----|----------|-------|
| **Downloads** | `https://dl.example.com` | Rocky, Debian, Ubuntu cloud images | See paths below |

| Path | Content |
|------|---------|
| `/rocky/9/images/x86_64/` | Rocky 9 qcow2, ISOs |
| `/debian/bookworm/latest/` | Debian 12 qcow2 + SHA512SUMS |
| `/ubuntu/noble/current/` | Ubuntu 24.04 img + SHA256SUMS |

---

## Forward Proxy (Squid on :3128)

For generic internet access from CI pipelines, pods, or VMs:

```yaml
env:
  - name: http_proxy
    value: "http://proxy.example.com:3128"
  - name: https_proxy
    value: "http://proxy.example.com:3128"
  - name: no_proxy
    value: "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.svc,.cluster.local,.example.com"
```

Shell usage:
```bash
export http_proxy=http://proxy.example.com:3128
export https_proxy=http://proxy.example.com:3128
export no_proxy="10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.svc,.cluster.local,.example.com"
```

---

## Harbor Registry

| Service | URL | Purpose |
|---------|-----|---------|
| **Harbor UI** | `https://harbor.example.com` | Web UI |
| **Harbor v2 API** | `https://harbor.example.com/v2/` | Docker registry API |
| **Bootstrap Registry** | `10.0.0.100:5000` | Standalone Docker registry |

### Proxy-Cache Projects (pull-through cache for container images)

Pull images through Harbor instead of going direct to public registries:

```bash
# Instead of:                         Use:
docker pull nginx:latest             # harbor.example.com/docker.io/library/nginx:latest
docker pull ghcr.io/org/img:tag      # harbor.example.com/ghcr.io/org/img:tag
docker pull quay.io/org/img:tag      # harbor.example.com/quay.io/org/img:tag
docker pull registry.k8s.io/img:tag  # harbor.example.com/registry.k8s.io/img:tag
```

Available proxy-cache registries: `docker.io`, `ghcr.io`, `quay.io`, `registry.k8s.io`, `gcr.io`, `public.ecr.aws`, `docker.elastic.co`, `registry.gitlab.com`

### Helm OCI Charts

helm-sync automatically pushes HTTP Helm charts to Harbor as OCI artifacts when pulled through `charts.example.com`. Charts are stored at:

```
harbor.example.com/<source-fqdn>/<chart-name>:<version>
```

Example: `harbor.example.com/charts.jetstack.io/cert-manager:v1.19.3`

---

## DNS Requirements

All proxy hostnames must resolve to `10.0.0.100`:

```
yum.example.com      → 10.0.0.100
apt.example.com      → 10.0.0.100
apk.example.com      → 10.0.0.100
dl.example.com       → 10.0.0.100
charts.example.com   → 10.0.0.100
go.example.com       → 10.0.0.100
npm.example.com      → 10.0.0.100
pypi.example.com     → 10.0.0.100
maven.example.com    → 10.0.0.100
crates.example.com   → 10.0.0.100
harbor.example.com   → 10.0.0.100
proxy.example.com    → 10.0.0.100
bin.example.com      → 10.0.0.100
```

Or add to `/etc/hosts`:
```
10.0.0.100  yum.example.com apt.example.com apk.example.com dl.example.com charts.example.com bin.example.com go.example.com npm.example.com pypi.example.com maven.example.com crates.example.com harbor.example.com proxy.example.com
```

## CA Trust

Clients must trust the private CA. Install `certs/ca-chain.pem`:

```bash
# Rocky/RHEL
sudo cp ca-chain.pem /etc/pki/ca-trust/source/anchors/airgap-proxy-ca.pem
sudo update-ca-trust

# Debian/Ubuntu
sudo cp ca-chain.pem /usr/local/share/ca-certificates/airgap-proxy-ca.crt
sudo update-ca-certificates

# Alpine
sudo cp ca-chain.pem /usr/local/share/ca-certificates/airgap-proxy-ca.crt
sudo update-ca-certificates
```
