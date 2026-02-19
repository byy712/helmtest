# Configure snippet code

Snippet code can be used for citm ingress controller, or for citm server

## citm ingress controller

Snippet code is a way to customize nginx.conf when this is not possible by using an [annotation](docker-ingress-annotations.md), ingress controller [argument](docker-ingress-cli-arguments.md)

CITM ingress controller provides two ways for snippet code. You can set it globally, or per ingress (prefered way), using annotation.

See also [access control](#access-control), for controlling code injection

### Global snippet code

Use following when you need to customize configuration for all. This is part of the CITM ingress controller config map.

| Name | Description |
| ---- | ----------- |
| [mainSnippet](docker-ingress-configmap.md#main-snippet)| Adds custom configuration to the main section of the nginx configuration.
| [httpSnippet](docker-ingress-configmap.md#http-snippet)| Adds custom configuration to the http section of the nginx configuration.
| [serverSnippet](docker-ingress-configmap.md#server-snippet)| Adds custom configuration to all the servers in the nginx configuration.
| [locationSnippet](docker-ingress-configmap.md#location-snippet)| Adds custom configuration to all the locations in the nginx configuration.
| [streamSnippet](docker-ingress-configmap.md#stream-snippet)| Adds custom configuration to stream section in the nginx configuration.

#### Example

Hereafter a sample input file using global snippet code

??? "input-snippet.yaml"

    ```
    --8<-- "samples/input-snippet.yaml"
    ```

```
$ helm install --namespace ab --name citm-ab citm-ingress -f input-snippet.yaml
```

The generated nginx.conf will contains following primitives

??? "input-snippet.yamlnginx.conf"

    ```
    --8<-- "samples/nginx-snippet-generated.conf"
    ```

### Per ingress resource

See [snippet](ingress.md#snippet-code) code in ingress resources

### Access control

Since this allow to inject code in nginx.conf (notably [lua code](lua.md)), this can be controlled using [snippet-authorize](helmchart-ingress.md#snippet-authorize)

## citm server

You can activate the same mechanism for [citm server](helmchart-server.md#snippet-code)
