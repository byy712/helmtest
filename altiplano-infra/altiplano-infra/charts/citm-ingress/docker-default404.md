# Install from docker

Default citm-default-backend docker listen on http/8080

```
docker run -dit --name df404 -p 8080:8080 citm-default-backend
```

It serves two urls, with a Nokia rendering

| Url path | HTTP Response|
|--|--|
|/|HTTP/404 Not Found|
|/healthz|HTTP/200 OK|

## Available variables

|name|type|default|description
|:-----|:-----|:-----|:----------------------------------------------------------------|
|DEFAULT_BACKEND_TITLE|string|404 - Not found|html title page
|DEFAULT_BACKEND_BODY|string|The requested page was not found|message displayed in the html body
|DEFAULT_BACKEND_COPYRIGHT|string|Nokia. All rights reserved|Copyright notice
|DEFAULT_BACKEND_PRODUCT_FAMILY_NAME|string|CITM|Product family name
|DEFAULT_BACKEND_PRODUCT_NAME|string|Default backend|Product name
|DEFAULT_BACKEND_RELEASE|string|4.0.4-5|Product release
|DEFAULT_BACKEND_TOOLBAR_TITLE|string|View more ...|Helper message for detailed information on product
|DEFAULT_BACKEND_IMAGE_BANNER|string|Nokia_logo_white.svg|Logo to be used. Format must be svg
|DEFAULT_BACKEND_PORT|int|8080|listening http port
|debug|boolean|false|set this to true for activating debug message

## Customize banner/logo
You can provide you own logo using following parameters to docker

``` 
# docker run -dit --name df404 -p 8080:8080 -v ~/my_logo.svg:/images/my_logo.svg -e DEFAULT_BACKEND_IMAGE_BANNER=my_logo.svg citm-default-backend
```

## Rendering

Get on /

![get on /](../img/default-404-slash.png)

About version

![About version](../img/default-404-about.png)

