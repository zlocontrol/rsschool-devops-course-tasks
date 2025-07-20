# SonarQube Deployment

## Install

```bash
helm repo add oteemo https://oteemo.github.io/charts
helm repo update

kubectl create namespace sonarqube

helm install sonarqube oteemo/sonarqube \
  --namespace sonarqube \
  -f sonarqube/values.yaml
