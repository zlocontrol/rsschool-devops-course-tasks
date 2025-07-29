# `monitoring/` Directory – Monitoring Stack Configuration

This directory contains all necessary files for deploying and configuring a monitoring stack using **Prometheus**, **Grafana**, and **Alertmanager** on **Kubernetes**, along with related configurations used in the **Jenkins CI/CD pipeline**.

---

## 📂 Contents

- **`Jenkinsfile`**  
  The main Jenkins Pipeline script for the `monitoring/` directory.  
  Responsible for deploying and updating all monitoring components in Kubernetes. Automates the creation of namespaces, secrets, ConfigMaps, and Helm releases.

- **`prometheus-values.yaml`**  
  Configuration for the Bitnami Prometheus Helm chart. Defines:
  - Prometheus server settings
  - Alertmanager configuration (with SMTP via `grafana-smtp-secret`)
  - `scrape_configs` for metric collection
  - Toggle options for components (e.g., `nodeExporter`, `kube-state-metrics`)

- **`grafana-values.yaml`**  
  Configuration for the Bitnami Grafana Helm chart. Specifies:
  - Dashboard and data source provisioning
  - `emptyDir` or `readOnlyRootFilesystem` settings
  - SMTP notification settings
  - Persistent volume claim for dashboard/data persistence

- **`grafana-all-dashboards-configmap.yaml`**  
  Kubernetes ConfigMap for provisioning **all Grafana dashboards**.  
  Contains links to dashboard JSON files.

- **`dashboards/`**  
  Directory with Grafana dashboards in JSON format:
  - `flask_app_dashboard.json`: Dashboard for monitoring a Flask app
  - `kube.json`: Cluster health monitoring dashboard

- **`alert-rules.yaml`**  
  Prometheus alert rule definitions.

- **`current-prometheus-server-configmap.yaml`**  
  Injects alert rules (`alert-rules.yaml`) into the Prometheus server via ConfigMap.

- **`grafana-admin-secret.yaml`**  
  Kubernetes Secret applied by Jenkins.  
  Includes:
  - Grafana admin credentials (`GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD`)
  - Built-in data source configuration (`datasources.yaml`)

- **`grafana-smtp-secret.yaml`**  
  Kubernetes Secret with SMTP credentials for Grafana alert notifications.

- ~~`datasources.yaml`~~ *(Deprecated)*  
  Contents are now included in `grafana-admin-secret.yaml`.

- **`prometheus-scrape-secret.yaml`** *(Optional)*  
  Secret for Prometheus to authorize metric scraping.

- **`stress-pod.yaml`**  
  For stress testing the cluster or monitoring stack.

---

## ⚙️ Pipeline Workflow (`monitoring/Jenkinsfile`)

1. **Environment Setup**  
   Adds/updates Helm repos and ensures `helm-diff` plugin is installed.

2. **Apply Secrets**  
   Applies:
   - `grafana-admin-secret.yaml` (admin credentials + data sources)
   - `grafana-smtp-secret.yaml` (SMTP credentials)

3. **Apply ConfigMaps**  
   Deploys:
   - Grafana dashboards (`grafana-all-dashboards-configmap.yaml`)
   - Prometheus alert rules (`current-prometheus-server-configmap.yaml`)

4. **Prometheus Deployment**  
   Uses Helm + `prometheus-values.yaml` to install/update Prometheus.  
   Includes `helm diff` step for previewing changes.

5. **Grafana Deployment**  
   Uses Helm + `grafana-values.yaml` to install/update Grafana.  
   Includes `helm diff` step.

6. **Wait for Pod Readiness**  
   Waits for Prometheus and Grafana pods to become ready.

7. **Output Access Info**  
   Displays access links to:
   - Grafana
   - Prometheus
   - Alertmanager

---

## 🧱 Dependencies & Prerequisites

- **Kubernetes Cluster**  
  Access to a running cluster (e.g., Minikube)

- **Jenkins**  
  Must be installed and configured to run pod agents in Kubernetes  
  (`jenkins-pods/helm-pod.yaml`)

- **RBAC**  
  Jenkins agents must have RBAC permissions (`get`, `create`, `patch`, `apply`, `delete`)  
  for Secrets, ConfigMaps, Deployments, Pods, and Namespaces  
  in the `jenkins` and `monitoring` namespaces

- **Bitnami Helm Charts**  
  Used for Prometheus and Grafana  
  Ensure chart versions match `values.yaml` configs  
  > For Grafana v10+, configure `emptyDir` or set `readOnlyRootFilesystem: false`

- **Grafana Values Config (`grafana-values.yaml`)**  
  Ensure proper provisioning of:
  - Data sources
  - Admin user credentials from `grafana-admin-secret.yaml`  
  May require special Helm chart config to mount the secret

---


