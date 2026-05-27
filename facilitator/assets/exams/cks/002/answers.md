# CKS Practice Lab 002 - Advanced Kubernetes Security

This lab covers the latest CKS exam domains including AppArmor, Falco, Audit Logging, RuntimeClass, Pod Security Standards, immutability, mTLS, RBAC hardening, supply chain security, and vulnerability remediation.

---

## Question 1: AppArmor Profile Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: apparmor-nginx
  namespace: apparmor-ns
  annotations:
    container.apparmor.security.beta.kubernetes.io/apparmor-nginx: runtime/default
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
  containers:
  - name: apparmor-nginx
    image: nginx:alpine
```

**Key concepts:**
- AppArmor annotations are applied at the pod metadata level using the container name as the annotation suffix
- `runtime/default` is the container runtime's default AppArmor profile — safer than `unconfined`

---

## Question 2: ClusterRole Least Privilege

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: resource-reader
rules:
- apiGroups: [""]
  resources: ["nodes", "namespaces", "pods", "services"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: audit-user-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: resource-reader
subjects:
- kind: ServiceAccount
  name: audit-user
  namespace: cluster-rbac
```

**Key concepts:**
- Use specific `resources` lists — never `["*"]`
- Only include `get`, `list`, `watch` for read-only access
- `nodes` and `namespaces` are cluster-scoped resources in the core API group `""`

---

## Question 3: Default ServiceAccount Restriction

Patch the default ServiceAccount:
```bash
kubectl patch serviceaccount default -n sa-restrict \
  -p '{"automountServiceAccountToken": false}'
```

Create the deployment:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: no-token-app
  namespace: sa-restrict
spec:
  replicas: 2
  selector:
    matchLabels:
      app: no-token-app
  template:
    metadata:
      labels:
        app: no-token-app
    spec:
      automountServiceAccountToken: false
      containers:
      - name: nginx
        image: nginx:alpine
```

**Key concepts:**
- Setting `automountServiceAccountToken: false` on the ServiceAccount prevents all pods using it from getting the token mounted
- Setting it on the pod spec provides a second layer, overriding any SA-level setting
- This prevents pods from accidentally accessing the Kubernetes API

---

## Question 4: Prevent Privilege Escalation

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-deployment
  namespace: hardened-ns
spec:
  replicas: 2
  selector:
    matchLabels:
      app: secure-deployment
  template:
    metadata:
      labels:
        app: secure-deployment
    spec:
      containers:
      - name: app
        image: busybox:1.35
        command: ["sleep", "3600"]
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 10001
          capabilities:
            drop:
            - ALL
        volumeMounts:
        - name: tmp-dir
          mountPath: /tmp
      volumes:
      - name: tmp-dir
        emptyDir: {}
```

**Key concepts:**
- `allowPrivilegeEscalation: false` — prevents `setuid` binaries from gaining elevated privileges
- `readOnlyRootFilesystem: true` — prevents writes to the container filesystem
- `capabilities: drop: [ALL]` — removes all Linux capabilities
- `runAsNonRoot: true` ensures the container doesn't run as UID 0

---

## Question 5: RuntimeClass for Sandbox Containers

```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: secure-runtime
handler: runc
---
apiVersion: v1
kind: Pod
metadata:
  name: sandboxed-pod
  namespace: sandbox-workloads
spec:
  runtimeClassName: secure-runtime
  containers:
  - name: nginx
    image: nginx:alpine
```

**Key concepts:**
- `RuntimeClass` allows selecting the container runtime for pods
- For actual sandboxing, `handler: gvisor` (gVisor) or `handler: kata` (Kata Containers) would be used
- `runtimeClassName` in the pod spec references the RuntimeClass

---

## Question 6: Pod Security Standards - Restricted

```bash
# Create namespace with PSS labels
kubectl create namespace restricted-ns
kubectl label namespace restricted-ns \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: restricted-app
  namespace: restricted-ns
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 65534
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: busybox:1.35
    command: ["sleep", "3600"]
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

**Key concepts:**
- `restricted` is the most secure PSS level
- Requires: non-root, no privilege escalation, seccomp, drop capabilities, no privileged containers
- The `seccompProfile` can be set at pod or container level — pod level applies to all containers

---

## Question 7: Falco Custom Rules ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: falco-custom-rules
  namespace: falco-config
data:
  custom_rules.yaml: |
    - rule: shell_in_container
      desc: Detect shell spawned inside a container
      condition: >
        container.id != host and
        proc.name in (bash, sh, ash) and
        evt.type = execve and
        container.image != ""
      output: >
        Shell spawned in container (user=%user.name container=%container.name
        image=%container.image.repository:%container.image.tag
        shell=%proc.name parent=%proc.pname cmdline=%proc.cmdline)
      priority: WARNING
      tags: [container, shell, mitre_execution]

    - rule: read_sensitive_files
      desc: Detect reading of sensitive files inside a container
      condition: >
        container.id != host and
        (fd.name = /etc/shadow or fd.name = /etc/passwd) and
        evt.type = open and
        evt.is_open_read = true
      output: >
        Sensitive file read in container (user=%user.name container=%container.name
        image=%container.image.repository:%container.image.tag
        file=%fd.name proc=%proc.name cmdline=%proc.cmdline)
      priority: ERROR
      tags: [container, filesystem, mitre_credential_access]
```

**Key concepts:**
- Falco rules use a YAML format with `rule`, `desc`, `condition`, `output`, `priority`
- `container.id != host` ensures we only match container processes
- In production, this ConfigMap is mounted into the Falco DaemonSet pod

---

## Question 8: Kubernetes Audit Policy ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: audit-policy
  namespace: kube-system
data:
  policy.yaml: |
    apiVersion: audit.k8s.io/v1
    kind: Policy
    omitStages:
    - RequestReceived
    rules:
    # Do not log health check endpoints
    - level: None
      nonResourceURLs:
      - /healthz
      - /readyz
      - /livez

    # Do not log read-only requests for common resources
    - level: None
      verbs: ["get", "list", "watch"]
      resources:
      - group: ""
        resources: ["pods", "services", "endpoints"]

    # Log all operations on secrets at RequestResponse level
    - level: RequestResponse
      resources:
      - group: ""
        resources: ["secrets"]

    # Log mutating pod operations at Request level
    - level: Request
      verbs: ["create", "update", "patch", "delete"]
      resources:
      - group: ""
        resources: ["pods"]

    # Default: log everything else at Metadata level
    - level: Metadata
```

**Key concepts:**
- Rules are evaluated in order — first match wins
- `RequestResponse` logs the full request AND response body (most verbose, use for secrets)
- `Metadata` only logs who/what/when without request/response body
- `omitStages: [RequestReceived]` reduces log noise

---

## Question 9: Namespace Isolation NetworkPolicy

```yaml
# Default deny all ingress and egress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: isolated-app
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
# Allow same-namespace communication + DNS
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-internal
  namespace: isolated-app
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector: {}
  egress:
  - to:
    - podSelector: {}
  - ports:
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
---
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: isolated-app
  labels:
    tier: internal
spec:
  containers:
  - name: app
    image: busybox:1.35
    command: ["sleep", "3600"]
---
apiVersion: v1
kind: Pod
metadata:
  name: db-pod
  namespace: isolated-app
  labels:
    tier: internal
spec:
  containers:
  - name: db
    image: busybox:1.35
    command: ["sleep", "3600"]
```

**Key concepts:**
- `podSelector: {}` with no ingress/egress rules = deny all
- Adding separate allow rules on top of default-deny is best practice
- DNS egress (port 53 UDP/TCP) must always be explicitly allowed
- `podSelector: {}` in an ingress `from` rule = allow from all pods in namespace

---

## Question 10: Immutable ConfigMap and Secret

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: immutable-ns
immutable: true
data:
  env: production
  version: "1.0"
  log-level: info
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: immutable-ns
immutable: true
data:
  api-key: c2VjcmV0S2V5MTIz
  db-password: cGFzc3dvcmQxMjM=
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: immutable-app
  namespace: immutable-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: immutable-app
  template:
    metadata:
      labels:
        app: immutable-app
    spec:
      containers:
      - name: app
        image: busybox:1.35
        command: ["sleep", "3600"]
        securityContext:
          readOnlyRootFilesystem: true
          runAsUser: 65534
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
          readOnly: true
        - name: secret-volume
          mountPath: /etc/secrets
          readOnly: true
      volumes:
      - name: config-volume
        configMap:
          name: app-config
      - name: secret-volume
        secret:
          secretName: app-secret
```

**Key concepts:**
- `immutable: true` prevents any changes to the ConfigMap/Secret data after creation
- Immutable resources must be deleted and recreated to update — promotes GitOps workflows
- Reduces risk of accidental or malicious configuration changes

---

## Question 11: mTLS with TLS Secrets

```yaml
# server-pod
apiVersion: v1
kind: Pod
metadata:
  name: server-pod
  namespace: mtls-app
  labels:
    app: mtls-enabled
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    volumeMounts:
    - name: tls-certs
      mountPath: /etc/tls
      readOnly: true
  volumes:
  - name: tls-certs
    secret:
      secretName: app-tls
---
# client-pod
apiVersion: v1
kind: Pod
metadata:
  name: client-pod
  namespace: mtls-app
  labels:
    app: mtls-enabled
spec:
  containers:
  - name: client
    image: busybox:1.35
    command: ["sleep", "3600"]
    volumeMounts:
    - name: tls-certs
      mountPath: /etc/tls
      readOnly: true
  volumes:
  - name: tls-certs
    secret:
      secretName: app-tls
---
# NetworkPolicy allowing only TLS traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: tls-only-traffic
  namespace: mtls-app
spec:
  podSelector:
    matchLabels:
      app: mtls-enabled
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - ports:
    - port: 443
  egress:
  - ports:
    - port: 443
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
---
# Service
apiVersion: v1
kind: Service
metadata:
  name: tls-service
  namespace: mtls-app
spec:
  selector:
    app: mtls-enabled
  ports:
  - port: 443
    targetPort: 443
```

**Key concepts:**
- Mount TLS secrets as `readOnly: true` volumes — containers should never write to certificate material
- NetworkPolicy enforces that only port 443 traffic is allowed (TLS-only)
- In real mTLS, both client and server present certificates for mutual authentication

---

## Question 12: RBAC Audit - Remove Dangerous Permissions

```bash
# 1. Delete the dangerous ClusterRoleBinding
kubectl delete clusterrolebinding dangerous-admin

# 2. Fix the over-permissive ClusterRole
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: over-permissive
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
EOF

# 3. Create a new minimal binding
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: minimal-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: over-permissive
subjects:
- kind: ServiceAccount
  name: temp-sa
  namespace: rbac-fix
EOF
```

**Key concepts:**
- Wildcard permissions `["*"]` on verbs, resources, or apiGroups violate least privilege
- `cluster-admin` should only be bound to specific operational accounts, never to application SAs
- Regular RBAC audits using `kubectl auth can-i` or tools like `rbac-tool` are CKS exam skills

---

## Question 13: Fully Hardened Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: fully-hardened-pod
  namespace: hardened-pod-ns
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
    runAsGroup: 1001
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  hostNetwork: false
  hostPID: false
  hostIPC: false
  containers:
  - name: app
    image: busybox:1.35
    command: ["sleep", "3600"]
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: tmp
      mountPath: /tmp
  volumes:
  - name: tmp
    emptyDir: {}
```

**Key concepts:**
- Setting seccomp at the pod level (`spec.securityContext.seccompProfile`) applies to all containers
- `RuntimeDefault` uses the container runtime's built-in seccomp profile — blocks ~40% of syscalls
- `fsGroup` sets the group ID for any mounted volumes
- This configuration satisfies the CKS `restricted` PSS and `kubesec` high score requirements

---

## Question 14: Fix Vulnerable Deployment

```bash
kubectl edit deployment insecure-app -n vuln-fix
```

Or apply directly:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: insecure-app
  namespace: vuln-fix
spec:
  replicas: 1
  selector:
    matchLabels:
      app: insecure-app
  template:
    metadata:
      labels:
        app: insecure-app
    spec:
      hostPID: false
      hostNetwork: false
      containers:
      - name: insecure-container
        image: nginx:alpine
        securityContext:
          privileged: false
          runAsUser: 1000
          runAsNonRoot: true
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
```

**Key concepts:**
- `privileged: true` grants the container nearly all Linux capabilities — extremely dangerous
- `hostPID: true` allows the container to see and signal all host processes
- `hostNetwork: true` allows the container to use the host network stack (bypasses NetworkPolicies)
- These are the top security issues caught by tools like Trivy, kubesec, and Falco

---

## Question 15: Trivy Image Scanning

```yaml
# trivy-scanner pod
apiVersion: v1
kind: Pod
metadata:
  name: trivy-scanner
  namespace: image-security
spec:
  restartPolicy: Never
  containers:
  - name: trivy
    image: aquasec/trivy:latest
    args:
    - image
    - --severity
    - HIGH,CRITICAL
    - --format
    - table
    - nginx:1.19
    volumeMounts:
    - name: output
      mountPath: /tmp/output
  volumes:
  - name: output
    emptyDir: {}
---
# vulnerability-report ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: vulnerability-report
  namespace: image-security
data:
  report.txt: |
    IMAGE: nginx:1.19
    SCAN_DATE: 2026-05-27
    SEVERITY_FILTER: HIGH,CRITICAL
    TOOL: trivy
    STATUS: SCANNED
---
# allowed-registries ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: allowed-registries
  namespace: image-security
data:
  registries.yaml: |
    allowedRegistries:
    - docker.io
    - gcr.io
    - registry.k8s.io
    - quay.io
```

**Key concepts:**
- Trivy is the most widely used tool for CKS container image scanning
- `--severity HIGH,CRITICAL` filters to only actionable vulnerabilities
- `restartPolicy: Never` for scanner jobs — they should run once and complete
- Scanning older image versions (like `nginx:1.19`) reveals many CVEs — always use recent tags

---

## Question 16: Supply Chain Security

```yaml
# image-policy in kube-system
apiVersion: v1
kind: ConfigMap
metadata:
  name: image-policy
  namespace: kube-system
data:
  policy.yaml: |
    imagePolicy:
      allowedRegistries:
      - docker.io
      - gcr.io
      - registry.k8s.io
      - quay.io
      blockLatestTag: true
      requireDigest: false
---
# NetworkPolicy restricting egress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-egress-registries
  namespace: supply-chain-ns
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - ports:
    - port: 443
      protocol: TCP
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
---
# verified-app pod
apiVersion: v1
kind: Pod
metadata:
  name: verified-app
  namespace: supply-chain-ns
  labels:
    image-verified: "true"
    registry: docker.io
    image-tag: 1.25-alpine
spec:
  containers:
  - name: nginx
    image: nginx:1.25-alpine
---
# SBOM metadata
apiVersion: v1
kind: ConfigMap
metadata:
  name: sbom-metadata
  namespace: supply-chain-ns
data:
  image: nginx:1.25-alpine
  digest: sha256:a59278fd22a9d411121e190b8cec8aa57b306aa3332459197777583beb728f59
  scanner: trivy
  scan-date: "2026-05-27"
  vulnerabilities-high: "2"
  vulnerabilities-critical: "0"
```

**Key concepts:**
- SBOM (Software Bill of Materials) documents all components of a container image
- `blockLatestTag: true` prevents use of `latest` tag — forces explicit version pinning
- Supply chain attacks (like SolarWinds) happen via compromised build pipelines
- In the real CKS exam: tools like Cosign (image signing), Syft/CycloneDX (SBOM generation), and OPA Gatekeeper (policy enforcement) are tested
