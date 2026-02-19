# CITM ingress controller - kubernetes internal

How it works internally in a kubernetest cluster

## Terminology

An Ingress Resource is a kubernetes API object that defines rules which allow external access to services in a cluster. An Ingress controller fulfills the rules set in the Ingress.

Ingress may provide load balancing, SSL termination and name-based virtual hosting.

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

An Ingress may be configured to give Services externally-reachable URLs, load balance traffic, terminate SSL / TLS, and offer name based virtual hosting. An Ingress controller is responsible for fulfilling the Ingress, usually with a load balancer, though it may also configure your edge router or additional frontends to help handle the traffic.

An Ingress does not expose arbitrary ports or protocols. Exposing services other than HTTP and HTTPS to the internet typically uses a service of type Service.Type=NodePort or Service.Type=LoadBalancer.

A minimal Ingress resource example:

```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: tomcat-webapp
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /
        backend:
          serviceName: tomcat
          servicePort: 80
```

## Ingress rules

Each HTTP rule contains the following information:

- An optional host. In this example, no host is specified, so the rule applies to all inbound HTTP traffic through the IP address specified. If a host is provided (for example, foo.bar.com), the rules apply to that host.
- A list of paths (for example, /testpath), each of which has an associated backend defined with a serviceName and servicePort. Both the host and path must match the content of an incoming request before the load balancer directs traffic to the referenced Service.
- A backend is a combination of Service and port names as described in the Service doc. HTTP (and HTTPS) requests to the Ingress that matches the host and path of the rule are sent to the listed backend.

Ingress can be configured using a set of [annotations](docker-ingress-annotations.md)

## Default Backend

An Ingress with no rules sends all traffic to a single default backend. The default backend is typically a configuration option of the Ingress controller and is not specified in your Ingress resources.

CITM ingress controller [default backend](helmchart-default404.md)

If none of the hosts or paths match the HTTP request in the Ingress objects, the traffic is routed to your default backend.

## Call flow

An `ingress controller` is a kubernetes service which is able to manage ingress resources. 

It's defined like any other kubernetes component, with a service and pod deployement. 

For providing external access, it's typically deployed on edge nodes, allowing external access.

![citm ingress controller inside](ic-pod.png)

Roughly,

- listen using kubernetes API on event for specific kubernetes objects. This concern

	- ingress resource
	- kubernetes services
	- kubernetes pods
	- certificates
	- config map (for tcp/udp) [configuration](tcp-udp.md#ingress-controller)
  
- Generate the associated nginx.conf, reflecting the ingress configuration

- Ask nginx load balancer to reload its configuration

![citm ingress controller inside](ic-call-flow.png)

## References

- [https://kubernetes.io/docs/concepts/services-networking/ingress/](https://kubernetes.io/docs/concepts/services-networking/ingress/)

- [TCP/UDP](tcp-udp.md#ingress-controller) (level 4 service) and ingress controller
