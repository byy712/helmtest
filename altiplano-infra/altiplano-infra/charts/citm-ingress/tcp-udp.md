# Configure tcp-udp streams

## Overview

Allowing to proxy and load balance traffic for pure tcp/udp backends

Nginx [reference  guide](https://docs.nginx.com/nginx/admin-guide/load-balancer/tcp-udp-load-balancer/)

## nginx.conf

Herafter a simple configuration for udp stream

```
stream {
	upstream test123.com {
		server 192.168.1.1:5060;
		server 192.168.1.2:5060;
    }
	
    server {
        listen 5060 udp;
        proxy_pass test123.com;
        proxy_timeout 1s;
        proxy_responses 1;
    }
}
```

The same for tcp

```
stream {
	upstream test123.com {
		server 192.168.1.1:5060;
		server 192.168.1.2:5060;
    }
	
    server {
        listen 5060 tcp;
        proxy_pass test123.com;
        proxy_timeout 1s;
    }
}
```

## Ingress controller

### Static configuration

By default, nginx ingress controller support one config map for udp service and another one for tcp service. They're specified using [udp-services-configmap and tcp-services-configmap](docker-ingress-cli-arguments.md) argument when starting CITM ingress controller pod. 

They can also be set by specifying a [tcp/udp](helmchart-ingress.md#stream-backend) set value to ingress controller helm chart.

### Dynamic configuration

You may also need to declare dynamic tcp/udp services. In that case, CITM nginx ingress controller has enhanced the mechanism to support a set of config map, instead of only one per protocol.

All config map starting with the pattern given in `udp-services-configmap` or `tcp-services-configmap` will be associated with respectively udp and tcp services.

If you do not provide a `namespace` in `udp-services-configmap` or `tcp-services-configmap`, then check will not be done on namespace, and all config map starting with this name, whatever the namespace will be added.

```
- --tcp-services-configmap=nginx-tcp-server-conf
- --udp-services-configmap=nginx-udp-server-conf
```

See `UdpServiceConfigMapNoNamespace` and `TcpServiceConfigMapNoNamespace` in ingress controller [helm chart](helmchart-ingress.md)

### Sample udp service

Herafter a complete chart of such udp service

??? "upd service sample chart"
     ```
     --8<-- "samples/udp-service.yaml"
     ```
### Ingress controller service

If you're using dynamic configuration, you also need to associate your UDP and TCP ports to CITM ingress controller service. 

This can be achieved thanks to `controller.dynamicUpdateServiceStream`. 

Setting it to true will ensure that all TCP/UDP ports are linked with CITM ingress controller service in kubernetes

```
$ helm3 install nginx citm-ingress --set controller.dynamicUpdateServiceStream=true
```
Now, port `UDP/2018` from previous example, is associated to CITM ingress controller service, and can be reached from edge nodes.
```
$ kubectl get pods,svc -o wide | grep citm
pod/nginx-citm-ingress-controller-tjnff    1/1     Running   0          6m42s   172.16.1.10      ab-cwe-01   <none>
service/nginx-citm-ingress-controller   ClusterIP   None             <none>        80/TCP,443/TCP,2018/UDP   6m42s   app=citm-ingress,component=controller,release=nginx
```

## Supported keywords

| Keyword | Description |
| ------- | ----------- |
| BIND-ADDRESS | Allow to specify on which ip(s) CITM ingress controller will listen for this stream |
| NODE-PORT | If you need to declare your UDP/TCP services as `NodePort` |
| PROXY | Activate Proxy protocol (in or out) |
| TRANSPARENT | Activate transparent proxying |
| PROXY-TRANSPARENT | Activate transparent proxying and Proxy protocol |
| SESSION-AFFINITY | Select session affinity or load balancing policy | 
| STREAM-RESPONSE | Specify number of expected response for UDP protocol | 
| STREAM-SSL | Necessary support for a stream proxy server to work with the SSL/TLS protocol |

## NodePort

If you need to declare your UDP/TCP services as `NodePort` (needed for [Istio](istio.md)), by default, kubernetes peek-up a port in the range (30000-32767). CITM ingress controller allow you to specify this port for UDP/TCP service.

For this, you need to provide it in the config map, using keyword `NODE-PORT`

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-udp-server-conf-2018
data:
  2018: "default/udpserver2018:2018:NODE-PORT=32042"
```

Keep in mind, that CITM ingress controller needs also to be configured for using NodePort

The port provided in this configMap cannot be the same as the one used by your tcp service. 

```
$ helm3 install nginx citm-ingress --set controller.dynamicUpdateServiceStream=true --set controller.service.type=NodePort
```
Now, service `UDP/2018` is associated with NodePort 32042
```
$ kubectl get pods,svc -o wide | grep citm
pod/nginx-citm-ingress-controller-qq5cr    1/1     Running       0          2m5s   172.16.1.10      ab-cwe-01   <none>
service/nginx-citm-ingress-controller   NodePort    10.254.227.10    <none>        80:31372/TCP,443:32115/TCP,2018:32042/UDP   2m5s   app=citm-ingress,component=controller,release=nginx
```

## Bind-address

Allow to specify on which ip(s) CITM ingress controller will listen for this stream

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-udp-server-conf-2018
data:
  2018: "default/udpserver2018:2018:BIND-ADDRESS=192.168.1.42"
```

## Proxy protocol header

The proxy protocol header helps you identify the IP address of a client when you have a load balancer that uses TCP for back-end connections. Because load balancers intercept traffic between clients and your instances, the access logs from your instance contain the IP address of the load balancer instead of the originating client. You can parse the first line of the request to retrieve your client's IP address and the port number.

The address of the proxy in the header for IPv6 is the public IPv6 address of your load balancer. This IPv6 address matches the IP address that is resolved from your load balancer's DNS name, which begins with either ipv6 or dualstack. If the client connects with IPv4, the address of the proxy in the header is the private IPv4 address of the load balancer, which is not resolvable through a DNS lookup outside of the EC2-Classic network.

The proxy protocol line is a single line that ends with a carriage return and line feed ("\r\n"), and has the following form:

```
PROXY_STRING + single space + INET_PROTOCOL + single space + CLIENT_IP + single space + PROXY_IP + single space + CLIENT_PORT + single space + PROXY_PORT + "\r\n"
```

The following is an example of the proxy protocol line for IPv4.

```
PROXY TCP4 198.51.100.22 203.0.113.7 35646 80\r\n
```

Complete story: [enable proxy protocol](https://docs.aws.amazon.com/en_en/elasticloadbalancing/latest/classic/enable-proxy-protocol.html)

This being said, you can activate this feature for incoming request (if CITM ingress controller is behind a load balancer), or for out-going request (request that goes to your backend)

The keywoard is `PROXY`

If after a load balancer

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-udp-server-conf-2020
data:
  2020: "default/udpserver2020:2020:PROXY"
```

To send PROXY packet to your backend (note the double `::`)

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-udp-server-conf-2020
data:
  2020: "default/udpserver2020:2020::PROXY"
```

To activate both

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-udp-server-conf-2020
data:
  2020: "default/udpserver2020:2020:PROXY:PROXY"
```

## Transparent proxy 

Transparent proxy allow to send client ip instead of CITM ingress controller one to backend. 

!!! Warning "IMPORTANT<br>Transparent proxying on IPV6 needs at least glibc 2.28 or upper. This level of glibc is only available within CentOS 8 artificats."

For achieving this, CITM ingress controller provides a new keyword for activating transparent proxying on udp/tcp services. Add `TRANSPARENT` after the port mapping.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-udp-server-conf-2020
data:
  2020: "default/udpserver2020:2020:TRANSPARENT"
```

If you need also to use this service as proxy, keyword becomes `PROXY-TRANSPARENT`

```
  2020: "default/udpserver2020:2020:PROXY-TRANSPARENT"
```

Since CITM ingress controller will modify source ip, You need to activate privilege on citm ingress controller pod. For this, set securityContextPrivileged and workerProcessAsRoot to true at helm install

```
$ helm3 install my-release citm-ingress --set controller.securityContextPrivileged=true,controller.workerProcessAsRoot=true
```

!!! Warning "Network note.<br>Since we're changing ip source of the packet, this is IP spoofing, and this is normally not accepted by your network infrastructure and linux kernel."

You need to tweak some kernel and openstack parameters in order to let the packet reach the destination:

- At the linux level, this is controlled by `net.ipv4.conf.all.rp_filter`

	IP spoofing is disabled by doing `sysctl -w "net.ipv4.conf.all.rp_filter=0"`

	BCMT offer (Sysctl operator in bcmt_oam/operators_sysctl.html) to apply these settings in a persistence way
	
- Openstack neutron also does not like IP spoofing so we have to tell Openstack to let go through the IP src that it does not know. This is done through neutron [port update](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/10/html/networking_guide/sec-allowed-address-pairs) command

- Also, read this [how-to](https://www.nginx.com/blog/ip-transparency-direct-server-return-nginx-plus-transparent-proxy/) if you need to receive packet in response. 

- [Troubleshooting](https://www.nginx.com/blog/ip-transparency-direct-server-return-nginx-plus-transparent-proxy/#troubleshooting)

Example of setup in jira CSFS-28405 on a vmware cluster.

## Number of expected response for udp service

Set number of expected response for udp service. You can specify the number of expected response for an udp incoming request. 0 mean no response expected from the backend.

CITM ingress controller as added a specific keyword, `STREAM-RESPONSE` in the service ConfigMap. Set the value to the number of expected response. This will configure [proxy_responses](http://nginx.org/en/docs/stream/ngx_stream_proxy_module.html#proxy_responses) in nginx.conf. If not specified, the number of datagrams is not limited.
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-udp-server-conf-2020
data:
  2020: "default/udpserver2020:2020:STREAM-RESPONSE=0"
```

If you also need `TRANSPARENT`

```
  2020: "default/udpserver2020:2020:TRANSPARENT:STREAM-RESPONSE=0"
```

## session affinity

Session affinity can be retrieved from kubernetes service description, or set using the config map, with extra argument SESSION-AFFINITY
```
  2020: "default/udpserver2020:2020:SESSION-AFFINITY=least_conn"
```

```
  2020: "default/udpserver2020:2020:SESSION-AFFINITY=hash $remote_addr"
```

## Use service IP

Use the service IP rather than backend pod IPs

```
  2020: "default/tcpserver:2020:NODE-PORT=30042,USE-SVC-IP"
```

## Zone

Use the zone for the upstream which is a shared memory zone that keeps the group’s configuration and run-time state that are shared between worker processes.

```
  2020: "default/tcpserver:2020:NODE-PORT=30042,ZONE=tcpserverzone 5m,STREAM-SSL"
```

Need to mention the NAME and SIZE of the zone, in the above example `tcpserverzone` is the name and `5m` is the size.


## How to combine keywords and its usage with examples

??? - "NodePort"

	`Keyword:` NODE-PORT
	
	`Description:` If you need to declare your UDP/TCP services as NodePort (needed for [Istio](istio.md)), by default, kubernetes peek-up a port in the range (30000-32767). CITM ingress controller allow you to specify this port for UDP/TCP service.
	
	`Configuration:` `2018: "default/udpserver:2018:NODE-PORT=31961"`
	
	```
	[root@nc0904node04 citm-ingress]# kubectl get svc -n citm
	NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        
	tcp-citm-ingress   NodePort    10.254.203.24   <none>        87:32042/TCP,469:32443/TCP,2018:30132/TCP 
	
	[root@nc0904node04 citm-ingress]# nc -vuzw 3 10.91.106.2 31961
	Ncat: Version 7.50 ( https://nmap.org/ncat )
	Ncat: Connected to 10.91.106.2:31961.
	[udpserver-5c8d468bfd-86hwq:2018-1] Message '' receivedNcat: UDP packet sent successfully
	Ncat: 1 bytes sent, 56 bytes received in 2.01 seconds.
	```
	!!! Warning "Keep in mind, that CITM ingress controller needs also to be configured for using NodePort. The port provided in this configMap cannot be the same as the one used by your tcp service.""
    
??? - "Bind-address"

	`Keyword:` BIND-ADDRESS=<IP>
	
	`Description:` Allow to specify on which ip(s) CITM ingress controller will listen for this stream
	
	`Configuration:` `2018: "default/udpserver:2018:BIND-ADDRESS=10.91.106.2"`
	
	`Generated nginx configuration:`
	
	```
    upstream udp-2018-default-udpserver-2018 {
                    server 192.168.24.186:2018 ;
                    server 192.168.99.228:2018 ;
            }
            server {
                    listen  10.91.106.2:2018 reuseport udp;
                    listen [::]:2018 reuseport ipv6only=on udp;
                    proxy_responses 1;
                    proxy_timeout 600s;
                    proxy_next_upstream     on;
                    proxy_next_upstream_timeout 600s;
                    proxy_next_upstream_tries   3;
                    proxy_pass udp-2018-default-udpserver-2018;
            }
    ```

??? - "Proxy protocol header"

    `Keyword:` PROXY
	
	`Description:` The proxy protocol header helps you identify the IP address of a client when you have a load balancer that uses TCP for back-end connections.Because load balancers intercept traffic between clients and your instances, the access logs from your instance contain the IP address of the load balancer instead of the originating client. You can parse the first line of the request to retrieve your client's IP address and the port number.
	
	`Configuration:` `2018: "default/tcpserver:2018:PROXY"`
	
	`Generated nginx configuration:`
	
    ```
    upstream tcp-2018-default-tcpserver-2018 {
                    server 192.168.24.168:2018;
                    server 192.168.99.199:2018;
            }
            server {
                    listen 2018  reuseport  proxy_protocol;
                    listen [::]:2018  reuseport ipv6only=on  proxy_protocol;
                    proxy_pass tcp-2018-default-tcpserver-2018;
                    proxy_timeout 600s;
                    proxy_next_upstream     on;
                    proxy_next_upstream_timeout 600s;
                    proxy_next_upstream_tries   3;
            }
    ```

    To send PROXY packet to your backend (note the double `::`)

    ```
    data:
      2018: "default/tcpserver2018:2018::PROXY"
    ```
    ```
    server {
                    listen 2018  reuseport ;
                    listen [::]:2018  reuseport ipv6only=on ;
                    proxy_pass tcp-2018-default-tcpserver-2018; 
                    proxy_timeout 600s;
                    proxy_next_upstream     on;
                    proxy_next_upstream_timeout 600s;
                    proxy_next_upstream_tries   3;
                    proxy_protocol          on;
            }
    ```
    To activate both

    ```
    data:
      2018: "default/udpserver:2018:PROXY:PROXY"
    ```
    ```
    server {
                    listen 2018  reuseport  proxy_protocol;
                    listen [::]:2018  reuseport ipv6only=on  proxy_protocol;
                    proxy_pass tcp-2018-default-tcpserver-2018;
                    proxy_timeout 600s;
                    proxy_next_upstream     on;
                    proxy_next_upstream_timeout 600s;
                    proxy_next_upstream_tries   3;
                    proxy_protocol          on;
            }
    ```

??? - "Transparent proxy"

	`Keyword:` TRANSPARENT
	
	`Description:` Transparent proxy allow to send client ip instead of CITM ingress controller one to backend.
	
	`Configuration:` `2020: "default/udpserver2020:2020:TRANSPARENT"`
	
	`Generated nginx configuration:`
	
	```
    server {
                    listen    2018 reuseport udp;
                    proxy_bind $remote_addr:$remote_port transparent;
                    proxy_responses 1;
                    proxy_timeout 600s;
                    proxy_next_upstream     on;
                    proxy_next_upstream_timeout 600s;
                    proxy_next_upstream_tries   3;
                    proxy_pass udp-2018-default-udpserver-2018-v4;
            }
    ```

	!!! Warning "IMPORTANT<br>Transparent proxying on IPV6 needs at least glibc 2.28 or upper. This level of glibc is only available within CentOS 8 artificats."
	
    If you need also to use this service as proxy, keyword becomes `PROXY-TRANSPARENT`

    ```
    2020: "default/udpserver2020:2020:PROXY-TRANSPARENT"
    ```

    Since CITM ingress controller will modify source ip, You need to activate privilege on citm ingress controller pod. For this, set securityContextPrivileged and workerProcessAsRoot to true at helm install

    ```
    $ helm3 install my-release citm-ingress --set controller.securityContextPrivileged=true,controller.workerProcessAsRoot=true
    ```

    !!! Warning "Network note.<br>Since we're changing ip source of the packet, this is IP spoofing, and this is normally not accepted by your network infrastructure and linux kernel. Read more in CITM guide tcp-udp.html#transparent-proxy"


??? - "Number of expected response for udp service"

	`Keyword:` STREAM-RESPONSE=<Integer>
	
	`Description:` Set number of expected response for udp service. You can specify the number of expected response for an udp incoming request. 0 mean no response expected from the backend. In the service ConfigMap, set the value to the number of expected response. This will configure [proxy_responses](http://nginx.org/en/docs/stream/ngx_stream_proxy_module.html#proxy_responses) in nginx.conf. If not specified, the number of datagrams is not limited.
	
	`Configuration:` `2020: "default/udpserver2020:2020:STREAM-RESPONSE=0"`
	
	`Generated nginx configuration:` 
	
	```
    server {
                    listen    2020 reuseport udp;
                    proxy_bind $remote_addr:$remote_port transparent;
                    proxy_responses 0;
                    proxy_timeout 600s;
                    proxy_next_upstream     on;
                    proxy_next_upstream_timeout 600s;
                    proxy_next_upstream_tries   3;
                    proxy_pass udp-2020-default-udpserver2020-2020-v4;
            }
    ```
	If you also need `TRANSPARENT`

	```
	2018: "default/udpserver:2018:TRANSPARENT:STREAM-RESPONSE=0"
	```
	```
	upstream udp-2018-default-udpserver-2018 {
                server 192.168.24.158:2018 ;
                server 192.168.99.246:2018 ;
			}
			server {
					listen    2018 reuseport udp;
					listen [::]:2018 reuseport ipv6only=on udp;
					proxy_responses 0;
					proxy_timeout 600s;
					proxy_next_upstream     on;
					proxy_next_upstream_timeout 600s;
					proxy_next_upstream_tries   3;
					proxy_pass udp-2018-default-udpserver-2018;
			}
	```
??? - "Session affinity"

	`Keyword:` SESSION-AFFINITY=<>
	
	`Description:` Select session affinity or load balancing policy. Session affinity can be retrieved from kubernetes service description, or set using the config map, with extra argument SESSION-AFFINITY.
	
	`Configuration:` `2018: "default/udpserver:2018:STREAM-RESPONSE=1:SESSION-AFFINITY=least_conn"`
	
	`Generated nginx configuration:`
	- Least connected load balancing
	With the least-connected load balancing, nginx will try not to overload a busy application server with excessive requests,distributing the new requests to a less busy server instead.
	```
	2018: "default/udpserver:2018:STREAM-RESPONSE=1:SESSION-AFFINITY=least_conn"
	
	upstream udp-2018-default-udpserver-2018 {
					least_conn;
					server 192.168.24.174:2018 ;
					server 192.168.99.216:2018 ;
			}
	```
	- Session persistence
	a hash-function is used to determine what server should be selected for the next request (based on the client's IP address).

	```
	2018: "default/udpserver:2018:SESSION-AFFINITY=hash $remote_addr"
	
	upstream udp-2018-default-udpserver-2018 {
					hash $remote_addr;
					server 192.168.24.159:2018 ;
					server 192.168.99.247:2018 ;
			}

	```

??? -  "Bind Address and Session Affinity"
       - BindAddress and least_conn lb method set in configmap

       ```
        "9000": ingress-nginx/httpecho-go:9000:SESSION-AFFINITY=least_conn,BIND-ADDRESS=10.99.21.250
       ```

       ``` 
        # Below will get generated in nginx.conf
        upstream tcp-9000-ingress_nginx-httpecho_go-9000 {
                least_conn;

                server 192.168.24.156:9000;
                server 192.168.24.168:9000;
        }

        server {

                listen 10.99.21.250:9000  reuseport  ;
				
                listen [::]:9000  reuseport ipv6only=on  ;
                proxy_pass tcp-9000-ingress_nginx-httpecho_go-9000;
                proxy_timeout 600s;
                proxy_next_upstream     on;
                proxy_next_upstream_timeout 600s;
                proxy_next_upstream_tries   3;

        }
       ```

??? -  "Bind address and nodeport"
	
	`Keywords:` NODE-PORT, BIND-ADDRESS
	
	`Description:` Listening to specific IP on a node port.
	
	`Configuration:` `2018: "default/udpserver:2018:NODE-PORT=32042:BIND-ADDRESS=10.91.106.2"`
	
	`Generated nginx configuration:`
	
	```
	server {
                listen 10.91.106.2:2018  reuseport;
                listen [::]:2018  reuseport ipv6only=on;
                proxy_pass tcp-2018-default-tcpserver-2018;
                proxy_timeout 600s;
                proxy_next_upstream     on;
                proxy_next_upstream_timeout 600s;
                proxy_next_upstream_tries   3;
			}

	```
	!!! Warning "Note that any keywords should always be specified before the node-port mapping."

??? - "Nodeport and Proxy"
	
	`Keywords:` NODE-PORT, PROXY
	
	`Description:` If the incoming connection is a non-proxy one, you want to pass a proxy-protocol-supported connection to the backends and at the same time to use nodePorts
	
	`Configuration:` `2018: "default/tcpserver:2018::PROXY:NODE-PORT=30121"`
	
	`Generated nginx configuration:`
	
	```
	[root@nc0904node04 citm-ingress]# kubectl get svc -n citm
	NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        
	tcp-citm-ingress   NodePort    10.254.203.24   <none>        87:32042/TCP,469:32443/TCP,2018:30132/TCP 


	upstream tcp-2018-default-tcpserver-2018 {
                server 192.168.24.154:2018;
                server 192.168.99.215:2018;
        }
        server {
                listen 2018  reuseport ;
                listen [::]:2018  reuseport ipv6only=on ;
                proxy_pass tcp-2018-default-tcpserver-2018;
                proxy_timeout 600s;
                proxy_next_upstream     on;
                proxy_next_upstream_timeout 600s;
                proxy_next_upstream_tries   3;
                proxy_protocol          on;
        }
	```
	for incoming request
	```
	2018: "default/tcpserver:2018:PROXY:NODE-PORT=32042"
	```
	```
	server {
                listen 2018  reuseport  proxy_protocol;
                listen [::]:2018  reuseport ipv6only=on  proxy_protocol;
                proxy_pass tcp-2018-default-tcpserver-2018;
                proxy_timeout 600s;
                proxy_next_upstream     on;
                proxy_next_upstream_timeout 600s;
                proxy_next_upstream_tries   3;
			}
	```

??? - "Proxy, Node-port and Bind-address"

	`Keywords:` NODE-PORT, PROXY, BIND-ADDRESS
	
	`Configuration:` `2018: "default/tcpserver:2018:PROXY:BIND-ADDRESS=10.91.106.2:NODE-PORT=32042"`
	
	`Generated nginx configuration:`
	```
	server {
                listen 10.91.106.2:2018  reuseport  proxy_protocol;
                listen [::]:2018  reuseport ipv6only=on  proxy_protocol;
                proxy_pass tcp-2018-default-tcpserver-2018;
                proxy_timeout 600s;
                proxy_next_upstream     on;
                proxy_next_upstream_timeout 600s;
                proxy_next_upstream_tries   3;
			}

	```

??? - "Transparent, Node-port and Bind-address"

	`Keywords:` NODE-PORT, TRANSPARENT, BIND-ADDRESS
	
	`Configuration:` `2018: "default/tcpserver:2018:TRANSPARENT:BIND-ADDRESS=10.91.106.2:NODE-PORT=32042"`
	
	`Generated nginx configuration:`
	```
	server {
                listen 10.91.106.2:2018  reuseport ;
                proxy_bind $remote_addr:$remote_port transparent;
                proxy_pass tcp-2018-default-tcpserver-2018-v4;
                proxy_timeout 600s;
                proxy_next_upstream     on;
                proxy_next_upstream_timeout 600s;
                proxy_next_upstream_tries   3;
			}
	```
	
??? - "Transparent Proxy and Proxy Protocol header"

	`Keywords:` TRANSPARENT, PROXY
	
	`Configuration:` `2018: "default/tcpserver:2018:TRANSPARENT:PROXY"`
	
	`Generated nginx configuration:`
	```
	server {
                listen 2018  reuseport ;
                proxy_bind $remote_addr:$remote_port transparent;
                proxy_pass tcp-2018-default-tcpserver-2018-v4;
                proxy_timeout 600s;
                proxy_next_upstream     on;
                proxy_next_upstream_timeout 600s;
                proxy_next_upstream_tries   3;
                proxy_protocol          on;
			}
	```
??? - "TLS Termination at Stream"

	`Keywords:` STREAM-SSL
	
	`Description:` SSL termination at the stream level.
	
	`Configuration:` `2018: "default/tcpserver:2018:STREAM-SSL"`
	
	`Generated nginx configuration:`
	```
	server {
                listen 2020  reuseport   ssl;
                listen [::]:2020  reuseport ipv6only=on   ssl;
                proxy_pass tcp-2020-default-tcpserver-2018;
                proxy_timeout 600s;
                proxy_next_upstream     on;
                proxy_next_upstream_timeout 600s;
                proxy_next_upstream_tries   3;
			}
	```
	
	`Keywords:` STREAM-SSL, PROXY
 
	`Description:` With the proxy protocol, NGINX can learn the originating IP address from SSL
	
	`Configuration:` `2018: "default/tcpserver:2018:PROXY:STREAM-SSL"`

	```
	# PEM sha: c464a5ed1aeca859892e8902305c3a6fbd4575d4
			ssl_certificate     /nginx-config/ssl/default-fake-certificate.pem;
			ssl_certificate_key /nginx-config/ssl/default-fake-certificate.pem;
			ssl_session_timeout   4h;
			ssl_handshake_timeout 30s;
			# Stream Snippets
			ssl_protocols         SSLv3 TLSv1 TLSv1.1 TLSv1.2;
			ssl_ciphers           HIGH:!aNULL:!MD5;
			# TCP services
			upstream tcp-2022-default-tcpserver-2018 {
					server 192.168.1.10:2018;
                server 192.168.1.9:2018;
			}
			server {
				listen 2022  reuseport  proxy_protocol  ssl;
				listen [::]:2022  reuseport ipv6only=on  proxy_protocol  ssl;
					.....
			}
	{"type":"log","level":"INFO","facility":"23","time":"2022-02-21T05:00:29Z","timezone":"UTC","process":"citm-ingress-controller","system":"CITM Ingress Controller","systemid":"tcp-citm-ingress-9mszh","host":"vm-wor-175-96","log":{"message":"I0221 05:00:29.163252      40 main.go:241] 'Creating API client' host='https://10.254.0.1:443'"}}
	```
    
	`Keywords:` STREAM-SSL, TRANSPARENT
 
	`Description:` Using transparent proxy with ssl stream 
	
	`Configuration:` `2018: "default/tcpserver:2018:TRANSPARENT:STREAM-SSL"`

	```
	server {
					listen 2022  reuseport   ssl;
					proxy_bind $remote_addr:$remote_port transparent;
					proxy_pass tcp-2022-default-tcpserver-2018-v4;
					proxy_timeout 600s;
					proxy_next_upstream     on;
					proxy_next_upstream_timeout 600s;
					proxy_next_upstream_tries   3;
			}
	```

Supported values are provided in [nginx documentation]( https://docs.nginx.com/nginx/admin-guide/load-balancer/tcp-udp-load-balancer/#configuring-tcp-or-udp-load-balancing)


??? - "Use Service IP"

	`Keywords:` USE-SVC-IP
	
	`Description:` Use of the service IP instead of backend pod IPs 
	
	`Configuration:` `2020: "default/tcpserver:2020:NODE-PORT=30042,USE-SVC-IP,STREAM-SSL"`
	
	`Generated nginx configuration:`

	```
        kubectl exec citm-new-ic-citm-ingress-5ckxv -n preenew -- cat /etc/nginx/nginx.conf | grep -A 200 "# TCP services"

        # TCP services

        upstream tcp-2020-preenew-tcpserver-2020 {

                server 10.254.232.46:2020;

        }

        server {

                listen 2020  reuseport   ssl;

                listen [::]:2020  reuseport ipv6only=on   ssl;

                proxy_pass tcp-2020-preenew-tcpserver-2020;

                proxy_timeout 600s;
                proxy_next_upstream     on;
                proxy_next_upstream_timeout 600s;
                proxy_next_upstream_tries   3;

        }
	```
	
??? - "Zone"

	`Keywords:` ZONE 
	
	`Description:` Specify the shared memory zone that keeps the group’s configuration and run-time state that are shared between worker processes 
	
	`Configuration:` `2020: "default/tcpserver:2020:NODE-PORT=30042,USE-SVC-IP,ZONE=tcpserverzone 5m,STREAM-SSL"`
	
	`Generated nginx configuration:`

	```
        kubectl exec citm-new-ic-citm-ingress-5ckxv -n preenew -- cat /etc/nginx/nginx.conf | grep -A 200 "# TCP services"

        # TCP services

        upstream tcp-2020-preenew-tcpserver-2020 {

                zone tcpserverzone 5m;

                server 10.254.232.46:2020;

        }

        server {

                listen 2020  reuseport   ssl;

                listen [::]:2020  reuseport ipv6only=on   ssl;

                proxy_pass tcp-2020-preenew-tcpserver-2020;

                proxy_timeout 600s;
                proxy_next_upstream     on;
                proxy_next_upstream_timeout 600s;
                proxy_next_upstream_tries   3;

        }
	```
