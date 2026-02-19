# csf-common-lib

## Overview

This is a library helm chart, which provides helper functions. It does not provide any Kubernetes objects.
Helper function facilitate the fulfillment of the Helm Best Practices requirements v3.0.0+.

Tests for those helper functions can be found in the `csf-common-lib/unit-tests/tests.yaml` file.

## Example usage

* Add `csf-common-lib` to the `requirements.yaml` of your helm chart.

```
dependencies:
- name: csf-common-lib
  version: 1.0.0
  repository: https://repo.cci.nokia.net/csf-helm-stable/
```

* Use helper functions in Kubernetes object manifests. Example for `deployment.yaml`

```
apiVersion: apps/v1
kind: Deployment
metadata:
[...]
  name: {{ include "csf-common-lib.v1.workloadName" (tuple . .Values.echoserver) }}
  labels:
    {{- include "csf-common-lib.v1.commonLabels" (tuple . .Values.echoserver.name) | indent 4 }}
    {{- include "csf-common-lib.v1.customLabels" (tuple .Values.global.labels .Values.echoserver.labels) | indent 4 }}
  annotations:
    {{- include "csf-common-lib.v1.customAnnotations" (tuple .Values.global.annotations .Values.echoserver.annotations) | indent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "csf-common-lib.v1.selectorLabels" (tuple . .Values.echoserver.name) | indent 6 }}
  template:
    metadata:
      labels:
        {{- include "csf-common-lib.v1.commonLabels" (tuple . .Values.echoserver.name) | indent 8 }}
        {{- include "csf-common-lib.v1.customLabels" (tuple .Values.global.labels .Values.echoserver.labels) | indent 8 }}
    annotations:
      {{- include "csf-common-lib.v1.customAnnotations" (tuple .Values.global.annotations .Values.echoserver.annotations) | indent 4 }}
    spec:
      containers:
[...]
```

* More examples can be found in a sample helm chart in the `csf-common-lib/unit-tests/csf-common-test` directory in CSF-CHARTS/csf-common-lib/unit-tests/csf-common-test git repo.

## Proxy functions

If `csf-common-lib` introduces a new version of some function, then to use this new function, all instances of the old one must be changed to the new one.
Example: to use new `csf-common-lib.v2.workloadName` all `csf-common-lib.v1.workloadName` need to be changed to `csf-common-lib.v2.workloadName`.
This can introduce many changes in the code. To mitigate it you can use proxy functions.

Example:

* File [_helpers_proxy.tpl](unit-tests/csf-common-test/templates/_helpers_proxy.tpl)
```
{{- define "csf-common-test.workloadName" -}}
{{- include "csf-common-lib.v2.workloadName" . -}}
{{- end }}
```
* Use helper functions in `deployment.yaml`

```
apiVersion: apps/v1
kind: Deployment
metadata:
[...]
  name: {{ include "csf-common-test.proxy.workloadName" (tuple . .Values.echoserver) }}
```

To generate proxy functions you can use below code snippet (It should be run inside csf-common-lib dir):
```
CHART_NAME=csf-common-test
for name in $(grep -E "^{{- define" templates/*.tpl | cut -f2 -d'"' | cut -f3- -d. | sort -u); do
  version=$(grep -E "^{{- define" templates/*.tpl | cut -f2 -d'"' | grep -E "\.${name}$" | cut -f2 -d. | sed "s/^v//" | sort -un | tail -1)
  echo "{{- define \"${CHART_NAME}.proxy.${name}\" -}}"
  echo "{{- include \"csf-common-lib.v${version}.${name}\" . -}}"
  echo "{{- end }}"
  echo
done
```

## Helm chart structure and versions

Helper functions are stored in a separate file with a function name e.g. `_labels.tpl`

Function name is prefixed with `<helm chart name>.v<function version>`
* `<helm chart name>` for this chart is `csf-common-lib`. It distinguishes function from any other functions provided by other helm charts.
* `<function version>` in the name, distinguishes function from the same function provided by other version of `csf-common-lib` helm chart. This can happen in the umbrella helm charts. Function version is just a single number e.g. `1`.

For example `labels` function is named `csf-common-lib.v1.customLabels` and it is stored in the `_labels.tpl` file.

When function code changes:
* need to increase function version eg. `1` -> `2`
* need to increase helm chart version
  * bear in mind that helm chart version follows semantic versioning

## csf-common-lib.v1.commonLabels and Helm 2 vs 3

CommonLabels contains `app.kubernetes.io/managed-by` label, which is set to `.Release.Service` value.
`.Release.Service` resolves to `Helm` in Helm v3 and to `Tiller` in Helm v2

csf-common-lib is v2 helm chart, which is supported only by Helm v3, so there is no issue with it.

Template supports overriding this value (just in case) by passing `Tiller` value in the `managedBy` key. It can be passed as a command line parameter or as a value in the `values.yaml` file (preferred way).

.Example
````
helm3 template csf-common-test-1.0.0.tgz --set managedBy=Tiller
````

## Helm unit tests

The static helm unit tests can be run using `helmUnitTests.py` tool.
This tool is available in the `csf-charts-tools` docker image, which contains also helm binaries needed for helm chart templating and all checks used by a CSF-CHARTS-NEW Jenkins job.

* Prepare env using `csf-charts-tools` alias
````
$ alias csf-charts-tools='docker run -it --rm -v ${PWD}:/CSF-CHARTS -w /CSF-CHARTS --net host csf-docker-delivered.repo.cci.nokia.net/csf-charts-tools:latest'
````
* Run bash inside `csf-charts-tools`
````
$ csf-charts-tools
````

* Run helm unit tests
````
# helmUnitTests.py --helmChart csf-common-lib -i csf-common-lib/unit-tests/test*.yaml
````

  * Example output:
````
[INFO]: Tool version: 1.7.1
[TEST]: Tests from test file: csf-common-lib/unit-tests/test-certificate.yaml
** Before Tests:
[PASS]Command: Copy
[PASS]Command: Package helm chart
[1] ** Test[helm3]: Default config
[PASS] Check: Template success
[PASS] Check: Certificate existence
[PASS] └── Kind: Certificate - must exist
[PASS]   └── Name: release-name-csf-common-test
...
````

## Helm versions compatibility

Some functionalities work differently on different version of helm.

Found differences:

### `and` function:
In helm 3.10 and up, if first conditional of `and` is false the second one won't be checked.
In previous versions two conditionals was checked.

#### Example:
````
{{- if and (kindIs "string" $rule.labelSelector) (tpl $rule.labelSelector $root) }}
{{- $labels = tpl $rule.labelSelector $root | fromYaml }}
{{- else }}
{{- $labels = "default" }}
{{- end }}
````
In this case we had 2 conditionals to check. It's works fine at >=3.10 version, because if $rule.labelSelector isn't 
`string` the `tpl` function won't be run. But in older version we will get an error.

#### Solution:
To make our code compatibility with older versions, we can split `and` conditional into two `if` statements.

````
{{- if kindIs "string" $rule.labelSelector }}
    {{- if tpl $rule.labelSelector $root }}
        {{- $labels = tpl $rule.labelSelector $root | fromYaml }}
    {{- end }}
{{- else }}
{{- $labels = "default" }}
{{- end }}
````

### Multiline:
In helm 3.6 and up we can split lines between the `{{` and `}}` markers, like this:
````
{{- $newElement := dict
    "topologyKey" $rule.topologyKey
    "labelSelector" (dict
        "matchLabels" $labels) }}
````
It's make our code more pretty and readability, but in older version of helm this feature don't working.
We should write our code without line splitting 😥:
````
{{- $newElement := dict "topologyKey" $rule.topologyKey "labelSelector" (dict "matchLabels" $labels) }}
````
