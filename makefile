cluster-name ?= "visma-demo"
region ?= "europe-west4-a"
zone ?= "europe-west4-a"
zonee ?= "europe-west4-a"
project ?= "summer2021-319316"
port ?= 8080

start: create-with-ingress argo-setup flux-setup
stop: delete-kind

# Cluster 

context:
	kubectl config delete-context $(cluster-name) || true
	gcloud container clusters get-credentials $(cluster-name) --zone $(zone) --project $(project) 
	kubectl config rename-context $$(kubectl config current-context) $(cluster-name)
	@echo

# Terraform ------------------------------------

terraform-cluster-create:
	cd terraform && terraform apply
	make context

terraform-cluster-delete:
	cd terraform && terraform destroy

# Kind -------

cluster-exists-kind:
	@kind get clusters | grep $(cluster-name) > /dev/null && echo cluster $(cluster-name) already exists || (echo cluster $(cluster-name) does not exist && false)

create-with-ingress:
	@echo "Setting up cluster with ingress..."
	@kind create cluster --name $(cluster-name) --wait 5m --config ./kind-cluster.yml
	@kubectl config delete-context $(cluster-name) || true
	@kubectl config rename-context $$(kubectl config current-context) $(cluster-name)
	@gum spin -- kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	@gum spin --title "Sleeping" -- sleep 5
	@gum spin --title "waiting for ingress" -- kubectl wait -n ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=150s
	@gum spin -- kubectl apply -f test-setup.yml
	@gum spin sleep 10
	@echo "Testing if ingress is working..."
	curl localhost/test
	@echo

delete-kind:
	@kind delete cluster --name $(cluster-name)
	@kubectl config delete-context $(cluster-name) && gum spin sleep 3 || true

apply-argo-ingress:
	kubectl apply -f argo-ingress.yml --context $(cluster-name)


# ArgoCD ------------------------------------

argo-setup:
	make argo-check-if-credentials-exist
	make argo-install
	make argo-bootstrap-creds
	make argo-bootstrap-apps
	make argo-login
	make argo-ui-localhost-port-forward

argo-check-if-credentials-exist:
	@[ -f ./repo-creds.yml ] || (echo "repo-creds.yml does not exist. Create it from template: repo-creds-template.yml" && false)

argo-install:
	@echo "ArgoCD Install..."
	@kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	@kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "Waiting for ArgoCD to get ready..."
	@while ! kubectl wait -A --for=condition=ready pod -l "app.kubernetes.io/name=argocd-server" --timeout=300s; do echo "Waiting for ArgoCD to get ready..." && sleep 10; done
	@sleep 2
	@echo

argo-port-forward: argo-login
	kubectl port-forward svc/argocd-server --pod-running-timeout=60m0s -n argocd $(port):443 &>/dev/null &
	@echo

argo-login:
	@echo "ArgoCD Login..."
	@argocd login --port-forward --insecure --port-forward-namespace argocd --username=admin --password=$$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo)
	@export ARGOCD_OPTS='--port-forward-namespace argocd' 
	@echo

argo-ui-localhost-port-forward: argo-login-credentials
	kubectl get nodes &>/dev/null
	@echo "killing all port-forwarding" && pkill -f "port-forward" || true
	kubectl port-forward svc/argocd-server --pod-running-timeout=60m0s -n argocd $(port):443 &>/dev/null &
	@open http://localhost:$(port)
	@echo

argo-login-credentials:
	@echo "username: admin, password: $$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo) \n"

argo-bootstrap-creds:
	@echo "Bootstrapping credentials..."
	@kubectl apply -f ./repo-creds.yml

argo-bootstrap-apps:
	@echo "Bootstrapping apps..."
	@kubectl apply -f ./k8s/bootstrap/bootstrap.yml

# Flux ------------------------------------

flux-setup:
	flux bootstrap github \
		--components=source-controller,kustomize-controller,image-reflector-controller,image-automation-controller \
		--owner=dag-andersen \
		--branch=master \
		--repository=visma-e-conomic-hiring \
		--path=clusters/core \
		--token-auth \
		--personal
	gitops create dashboard ww-gitops --password=root
	kubectl apply -f ./flux-ingress.yml
	kubectl create secret docker-registry docker-secret --from-file=.dockerconfigjson=../../.docker/config.json || true
	echo "\Flux - username: admin, password: root\n"
	open http://flux.localhost

# other ------------------------------------

prometheus-login-creds:
	@printf "prometheus - username: admin, password: $$(kubectl get secret --namespace prometheus prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)\n"

fix-ingress-issues:
	kubectl delete -A ValidatingWebhookConfiguration helm-ingress-ingress-nginx-admission \
		|| kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission \
		|| kubectl delete -A ValidatingWebhookConfiguration nginx-ingress-nginx-admission \
		|| true