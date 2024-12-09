1- install minikube
2- install conntrack crictl cri-dockerd
3- run minikube: minikube start --driver=none

https://github.com/kubernetes/minikube/issues/9399 >> --driver=docker

4- backend pod is in CrashLoopBackOff