# CKS 003 – Exam Answers and Solutions

## Q1: Trivy Image Scan – Remediate Vulnerable Deployment (6 marks)

**Concept:** Image scanning and supply chain security

### Solution

```bash
# Update deployment to use safe image
kubectl -n image-audit set image deployment/legacy-web \
  legacy-web=nginx:1.25-alpine

# Add security label to pod template
kubectl -n image-audit patch deployment legacy-web \
  --type=json \
  -p='[{"op":"add","path":"/spec/template/metadata/labels/scanned","value":"true"}]'

# Verify
kubectl -n image-audit get deployment legacy-web \
  -o jsonpath='{.spec.template.spec.containers[0].image}'
kubectl -n image-audit get deployment legacy-web \
  -o jsonpath='{.spec.template.metadata.labels.scanned}'
```

**Key Points:**
- `nginx:1.25-alpine` has significantly fewer CVEs than `nginx:1.14` (which has 100+ HIGH/CRITICAL)
- Alpine-based images have a minimal footprint, reducing attack surface
- Labeling deployments with scan status is a supply chain security practice

---

## Q2: Falco Runtime Rules – Modify Rule Priority and Output (7 marks)

**Concept:** Runtime threat detection with Falco

### Solution

```bash
# Get current ConfigMap
kubectl -n monitoring get configmap falco-custom-rules -o yaml

# Edit the ConfigMap
kubectl -n monitoring edit configmap falco-custom-rules
```

The updated `falco_rules.yaml` content in the ConfigMap should be:

```yaml
- list: monitored_shells
  items: [bash, sh, ash, zsh, fish]

- rule: detect_shell_exec
  desc: Detect shell execution in containers
  condition: spawned_process and container and proc.name in (monitored_shells)
  output: "Shell executed in container (user=%user.name container_id=%container.id image=%container.image.repository shell=%proc.name parent=%proc.pname)"
  priority: WARNING
  tags: [container, shell, mitre_execution]
```

**Key Points:**
- Priority `WARNING` is more visible than `NOTICE` in alerting systems
- Including `%container.id` and `%user.name` in output aids incident response
- Lists in Falco allow reuse of common values across rules

---

## Q3: 3-Tier Application Network Policy Micro-Segmentation (7 marks)

**Concept:** Network segmentation and zero-trust networking

### Solution

```yaml
# backend-isolation: allow ingress only from frontend, egress only to db + DNS
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-isolation
  namespace: three-tier
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: db
    ports:
    - protocol: TCP
      port: 5432
  - ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
```

```yaml
# db-isolation: allow ingress only from backend, deny all egress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-isolation
  namespace: three-tier
spec:
  podSelector:
    matchLabels:
      app: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
  egress: []
```

**Key Points:**
- Micro-segmentation limits blast radius of a compromised component
- Always include DNS egress (UDP/TCP port 53) or DNS resolution will break
- Empty `egress: []` with `Egress` in policyTypes = deny all egress

---

## Q4: RBAC Cleanup – Remove cluster-admin Binding, Create Least Privilege Role (7 marks)

**Concept:** Principle of least privilege in Kubernetes RBAC

### Solution

```bash
# Step 1: Delete the overly permissive ClusterRoleBinding
kubectl delete clusterrolebinding dev-cluster-admin

# Step 2: Create minimal Role in dev-team namespace
kubectl create role dev-role \
  --verb=get,list,watch \
  --resource=pods,services,deployments \
  -n dev-team

# Step 3: Create RoleBinding
kubectl create rolebinding dev-role-binding \
  --role=dev-role \
  --serviceaccount=dev-team:dev-sa \
  -n dev-team

# Verify
kubectl auth can-i list pods --as=system:serviceaccount:dev-team:dev-sa -n dev-team
kubectl auth can-i delete pods --as=system:serviceaccount:dev-team:dev-sa -n dev-team
kubectl auth can-i list secrets --as=system:serviceaccount:dev-team:dev-sa -n dev-team
```

**Key Points:**
- ClusterRoleBindings are cluster-wide; always prefer namespace-scoped RoleBindings
- `cluster-admin` should only be used for break-glass emergency access
- Least privilege: only grant what the workload absolutely needs

---

## Q5: Apply Seccomp RuntimeDefault Profile to Existing Deployment (5 marks)

**Concept:** System call restriction with seccomp

### Solution

```bash
kubectl -n prod-apps patch deployment api-backend --type=json \
  -p='[{
    "op": "add",
    "path": "/spec/template/spec/securityContext",
    "value": {
      "seccompProfile": {
        "type": "RuntimeDefault"
      }
    }
  }]'

# Verify
kubectl -n prod-apps get deployment api-backend \
  -o jsonpath='{.spec.template.spec.securityContext.seccompProfile}'
```

Or via YAML edit:

```yaml
spec:
  template:
    spec:
      securityContext:
        seccompProfile:
          type: RuntimeDefault
```

**Key Points:**
- `RuntimeDefault` uses the container runtime's default seccomp profile
- Pod-level seccompProfile applies to ALL containers in the pod
- This restricts the set of available system calls, reducing kernel attack surface

---

## Q6: AppArmor Profile – Create Annotated Pod (6 marks)

**Concept:** Mandatory Access Control with AppArmor

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-apparmor
  namespace: apparmor-workloads
  labels:
    app: nginx-apparmor
  annotations:
    container.apparmor.security.beta.kubernetes.io/nginx: runtime/default
spec:
  containers:
  - name: nginx
    image: nginx:1.25-alpine
    ports:
    - containerPort: 80
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
  namespace: apparmor-workloads
spec:
  selector:
    app: nginx-apparmor
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

**Key Points:**
- AppArmor annotation format: `container.apparmor.security.beta.kubernetes.io/<container-name>: <profile>`
- `runtime/default` is the container runtime's built-in AppArmor profile
- The profile restricts filesystem access, network, and capabilities
- In Kubernetes 1.30+, AppArmor can also be set via `securityContext.appArmorProfile`

---

## Q7: Binary Integrity Verification (6 marks)

**Concept:** Supply chain security – binary verification

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hash-checker
  namespace: binary-verification
  labels:
    app: hash-checker
spec:
  restartPolicy: OnFailure
  containers:
  - name: checker
    image: busybox:1.35
    command:
    - sh
    - -c
    - "sha256sum /host-bin/kubectl | tee /tmp/hash.txt; sleep 3600"
    volumeMounts:
    - name: host-bin
      mountPath: /host-bin
      readOnly: true
    - name: tmp-dir
      mountPath: /tmp
  volumes:
  - name: host-bin
    hostPath:
      path: /usr/local/bin
      type: Directory
  - name: tmp-dir
    emptyDir: {}
```

```bash
kubectl create configmap verification-info \
  --from-literal=binary_path=/usr/local/bin/kubectl \
  --from-literal=verification_method=sha256sum \
  --from-literal=status=verified \
  -n binary-verification
```

**Key Points:**
- Compare the computed SHA256 against the official checksum from dl.k8s.io
- Read-only hostPath prevents accidental modification of host binaries
- Binary verification detects supply chain tampering

---

## Q8: Encryption Configuration for Secrets at Rest (7 marks)

**Concept:** Data encryption at rest using EncryptionConfiguration

### Solution

First, generate a 32-byte base64 key:
```bash
head -c 32 /dev/urandom | base64
# Example: 5Pl3m2QBjVJeXlGjLWzHBhPIWDqaH1YbdXXxxP5NHkI=
```

Create the ConfigMap:
```bash
kubectl create configmap encryption-config \
  --from-file=encryption.yaml=/dev/stdin \
  -n kube-system << 'EOF'
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- resources:
  - secrets
  providers:
  - aescbc:
      keys:
      - name: key1
        secret: 5Pl3m2QBjVJeXlGjLWzHBhPIWDqaH1YbdXXxxP5NHkI=
  - identity: {}
EOF
```

```bash
kubectl create secret generic encryption-test \
  --from-literal=test-key=test \
  -n kube-system
```

**Key Points:**
- `aescbc` uses AES-CBC encryption with PKCS#7 padding
- The key MUST be exactly 16, 24, or 32 bytes, base64-encoded (32-byte = AES-256)
- `identity: {}` as fallback allows reading unencrypted secrets during migration
- To activate: pass `--encryption-provider-config` to kube-apiserver
- After enabling, run `kubectl get secrets -A | xargs kubectl get secret` to re-encrypt existing secrets

---

## Q9: Kyverno Policy – Require Security Labels (6 marks)

**Concept:** Policy-as-code with Kyverno

### Solution

```yaml
# security-policy ConfigMap (key: policy.yaml)
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-security-label
spec:
  validationFailureAction: Audit
  rules:
  - name: check-security-scan-label
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Pods must have label security-scan: completed"
      pattern:
        metadata:
          labels:
            security-scan: completed
```

```bash
kubectl create configmap security-policy \
  --from-file=policy.yaml=<above file> \
  -n policy-config

kubectl create configmap policy-exceptions \
  --from-literal=exempt_namespaces="kube-system,monitoring,cert-manager" \
  --from-literal=policy_name=require-security-label \
  -n policy-config
```

**Key Points:**
- `Audit` mode logs violations without blocking (vs `Enforce` which blocks)
- Kyverno ClusterPolicies apply cluster-wide; Policies are namespace-scoped
- Security labeling ensures only scanned workloads run in production

---

## Q10: Pod Security Standards – Fix Non-Compliant Workloads (7 marks)

**Concept:** Pod Security Standards enforcement

### Solution

```bash
# Step 1: Label namespace with baseline PSS enforcement
kubectl label namespace legacy-workloads \
  pod-security.kubernetes.io/enforce=baseline \
  pod-security.kubernetes.io/enforce-version=latest

# Step 2: Fix privileged-app deployment
kubectl -n legacy-workloads patch deployment privileged-app \
  --type=json \
  -p='[
    {"op":"remove","path":"/spec/template/spec/hostPID"},
    {"op":"add","path":"/spec/template/spec/containers/0/securityContext","value":{"privileged":false,"runAsNonRoot":true}}
  ]'

# Step 3: Create compliant pod
kubectl -n legacy-workloads run baseline-compliant \
  --image=nginx:1.25-alpine \
  --labels="app=baseline-compliant"
```

**PSS Baseline prohibits:**
- Privileged containers (`privileged: true`)
- HostPID, HostIPC, HostNetwork
- Unrestricted volume types
- Adding dangerous capabilities (NET_RAW, etc.)

**Key Points:**
- Baseline PSS is appropriate for most workloads; Restricted is for high-security
- Label `enforce` blocks non-compliant pods; `warn` and `audit` are less strict
- Always test with `warn` mode before `enforce` to avoid breaking existing workloads

---

## Q11: ImagePolicyWebhook Admission Configuration (5 marks)

**Concept:** Admission control for supply chain security

### Solution

```yaml
# admission_config.yaml content:
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: ImagePolicyWebhook
  configuration:
    imagePolicy:
      kubeConfigFile: /etc/kubernetes/image-policy-webhook.kubeconfig
      allowTTL: 50
      denyTTL: 50
      retryBackoff: 500
      defaultAllow: false
```

```bash
kubectl create configmap image-webhook-config \
  --from-file=admission_config.yaml=<above file> \
  -n kube-system

kubectl create configmap allowed-registries \
  --from-literal=registries="registry.k8s.io,docker.io/library,gcr.io" \
  -n kube-system
```

**Key Points:**
- `defaultAllow: false` means images from unknown registries are REJECTED
- The webhook must respond within `allowTTL`/`denyTTL` seconds
- Requires passing `--admission-control-config-file` to kube-apiserver
- Common alternative: OPA Gatekeeper or Kyverno for registry restrictions

---

## Q12: TLS Ingress with Custom Certificate (7 marks)

**Concept:** Secure ingress with TLS termination

### Solution

```bash
# Step 1: Get cert data from ConfigMap
TLS_CRT=$(kubectl -n web-tls get configmap raw-certs \
  -o jsonpath='{.data.tls\.crt}')
TLS_KEY=$(kubectl -n web-tls get configmap raw-certs \
  -o jsonpath='{.data.tls\.key}')

# Write to temp files
echo "$TLS_CRT" > /tmp/tls.crt
echo "$TLS_KEY" > /tmp/tls.key

# Step 2: Create TLS Secret
kubectl create secret tls web-tls-secret \
  --cert=/tmp/tls.crt \
  --key=/tmp/tls.key \
  -n web-tls

# Clean up
rm /tmp/tls.crt /tmp/tls.key
```

```yaml
# Ingress manifest
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: web-tls
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - app.cks-exam.io
    secretName: web-tls-secret
  rules:
  - host: app.cks-exam.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

**Key Points:**
- TLS Secrets must be in the SAME namespace as the Ingress
- The certificate's CN/SAN must match the host in the Ingress rules
- `ssl-redirect: true` ensures HTTP traffic is redirected to HTTPS

---

## Q13: Container Immutability Remediation (6 marks)

**Concept:** Container immutability and security hardening

### Solution

```bash
kubectl -n mutable-apps patch deployment data-processor \
  --type=json \
  -p='[
    {"op":"add","path":"/spec/template/spec/containers/0/securityContext/readOnlyRootFilesystem","value":true},
    {"op":"add","path":"/spec/template/spec/containers/0/securityContext/runAsUser","value":1000},
    {"op":"add","path":"/spec/template/spec/containers/0/securityContext/runAsNonRoot","value":true},
    {"op":"add","path":"/spec/template/spec/containers/0/securityContext/allowPrivilegeEscalation","value":false},
    {"op":"add","path":"/spec/template/spec/volumes","value":[{"name":"tmp-dir","emptyDir":{}}]},
    {"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[{"name":"tmp-dir","mountPath":"/tmp"}]}
  ]'
```

Or edit the deployment YAML:
```yaml
containers:
- name: data-processor
  securityContext:
    readOnlyRootFilesystem: true
    runAsUser: 1000
    runAsNonRoot: true
    allowPrivilegeEscalation: false
  volumeMounts:
  - name: tmp-dir
    mountPath: /tmp
volumes:
- name: tmp-dir
  emptyDir: {}
```

**Key Points:**
- `readOnlyRootFilesystem: true` prevents runtime code injection (immutable containers)
- Running as non-root limits privilege escalation potential
- `emptyDir` provides writable scratch space without persisting sensitive data
- These settings align with CIS Docker Benchmark and NIST SP 800-190

---

## Q14: Block Cloud Metadata Server Access via NetworkPolicy (5 marks)

**Concept:** Preventing SSRF attacks against cloud metadata endpoints

### Solution

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: block-metadata
  namespace: cloud-workloads
spec:
  podSelector: {}  # applies to all pods
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 169.254.169.254/32
```

```bash
kubectl -n cloud-workloads run cloud-app \
  --image=busybox:1.35 \
  --command -- sleep 3600 \
  --labels=app=cloud-app
```

**Key Points:**
- `169.254.169.254` is the standard cloud IMDS (Instance Metadata Service) address
- Attackers exploiting SSRF in a pod can steal cloud credentials from IMDS
- The `except` clause in `ipBlock` allows all traffic EXCEPT the metadata IP
- This is a CKS exam favourite – appears in real exams frequently

---

## Q15: Minimal ServiceAccount with RBAC Least Privilege (7 marks)

**Concept:** Service account hardening and RBAC least privilege

### Solution

```bash
# Step 1: Create minimal SA
kubectl -n workload-ns create serviceaccount minimal-sa
kubectl -n workload-ns patch serviceaccount minimal-sa \
  --type=merge \
  -p='{"automountServiceAccountToken": false}'

# Step 2: Create minimal Role
kubectl -n workload-ns create role minimal-role \
  --verb=get,list \
  --resource=pods

# Step 3: Create RoleBinding
kubectl -n workload-ns create rolebinding minimal-binding \
  --role=minimal-role \
  --serviceaccount=workload-ns:minimal-sa

# Step 4: Update deployment
kubectl -n workload-ns patch deployment legacy-app \
  --type=json \
  -p='[
    {"op":"replace","path":"/spec/template/spec/serviceAccountName","value":"minimal-sa"},
    {"op":"add","path":"/spec/template/spec/automountServiceAccountToken","value":false}
  ]'
```

**Key Points:**
- `automountServiceAccountToken: false` prevents the SA token from being mounted
- Compromised pods cannot use the SA token to call the Kubernetes API
- Always use dedicated SAs per workload, never the `default` SA
- The `default` SA in a namespace has no permissions by default but mounting is enabled

---

## Q16: Certificate Expiry Monitoring Pod (6 marks)

**Concept:** Certificate lifecycle management and security monitoring

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cert-validator
  namespace: cert-monitoring
  labels:
    app: cert-validator
spec:
  containers:
  - name: validator
    image: alpine:3.18
    command:
    - sh
    - -c
    - "apk add --no-cache openssl && openssl x509 -in /etc/tls/tls.crt -noout -enddate > /tmp/expiry.txt && sleep 3600"
    volumeMounts:
    - name: cert-volume
      mountPath: /etc/tls
      readOnly: true
    - name: tmp-dir
      mountPath: /tmp
  volumes:
  - name: cert-volume
    secret:
      secretName: monitor-cert
  - name: tmp-dir
    emptyDir: {}
```

```bash
kubectl create configmap cert-info \
  --from-literal=certName=monitor-cert \
  --from-literal=namespace=cert-monitoring \
  --from-literal=checkType=expiry \
  -n cert-monitoring
```

**Key Points:**
- TLS certificates expire – unmonitored expiry causes outages and security gaps
- `openssl x509 -enddate` extracts the `notAfter` field from the certificate
- Mount secrets as read-only volumes, never inject as environment variables
- For production: use cert-manager with automated renewal and Prometheus alerting
