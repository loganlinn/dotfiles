#!/usr/bin/env zsh

kpod-secrets() {
	# List all Secrets currently in use by a pod
	kubectl get pods -o json "$@" | jq -c '.items[].spec.containers[].env[]?.valueFrom.secretKeyRef.name' | grep -v null | sort | uniq
}

kpod-initContainers() {
	# List all containerIDs of initContainer of all pods
	# Helpful when cleaning up stopped containers, while avoiding removal of initContainers.
	kubectl get pods "$@" -o jsonpath='{range .items[*].status.initContainerStatuses[*]}{.containerID}{"\n"}{end}' | cut -d/ -f3
}

kpod-jsonpaths() {
	# Produce a period-delimited tree of all keys returned for pods, etc
	kubectl get pods -o json | jq -c 'path(..)|[.[]|tostring]|join(".")'
}
