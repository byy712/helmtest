# Changelog

All notable changes to chart **cpro-common-lib** are documented in this file,
## [Unreleased] 

## [2.0.0] - 2023-11-30
### Added
- CSFOAM-17710: Added templating function to mount sensitivedata credentials
- CSFOAM-17672: Added character length restriction for the podNamePrefix in cpro-common-lib
- CSFOAM-17672: Added character length restriction for the podNamePrefix in cpro-common-lib
- CSFOAM-17656: CentOS7 Deprecation - Charts Git
- CSFOAM-17910: Added common template for HBP security encryption
- CSFOAM-17942: Added network policy apiversion to use for all the charts
- CSFOAM-17710: Added templating function to mount sensitivedata credentials
- CSFOAM-17700: Made changes in template for HBP security encryption
- CSFOAM-17679: Added code to fetch certificate issuerRef details with precedence[HBP_Security_cert_7] - Addressed review comments
- CSFOAM-17700: Made changes for common template for security encryption
- CSFOAM-18164: Added dnsNames condition for security encryption
- CSFOAM-18135: Added podnameprefix seperate template for vmalert and vmcluster as their fullnameoverride and nameoverride are taking from workloadlevel
### Changed
- CSFOAM-17676: Image Flavor Mapper logic now renders selected Image Flavor using csf-common-lib
- CSFOAM-17905: Changed _fluentd logic to now select image flavor from csf-common-lib
- CSFOAM-17905: Hard coded supported Flavors for _fluentd
- CSFOAM-17909: modify the code to add character length restriction for the podNamePrefix in cpro-common-lib
- CSFOAM-17675: Renamed fluentd and imageFlavorMapper template temporarily for non-blocking purpose
- CSFOAM-17675: Corrected Indentation error in fluentd chart
- CSFOAM-18160: updated chart version
### Fixed
- CSFOAM-18135: Fixed fullname-v2 template to truncate release name and chart name when whole deployment name crosses req length



## [1.3.1] - 2023-10-04
### Fixed
- CSFOAM-17749: Fix to take the correct centos image for fluentd
- CSFOAM-17909: Fix for the podNamePrefix in cpro-common-lib
- CSFOAM-17675: fluentd-v2 uses correct imageFlavorMapper-v2 
## [1.3.0] - 2023-07-24
### Fixed
- CSFOAM-15494: Fixed the common template issue
### Added
- CSFOAM-16678: Added character length restriction for the containername and containerNamePrefix in cpro-common-lib
- CSFOAM-16685: common template to take the imageflavour in the tag
- CSFOAM-16661: Added Charts to take Single Registry and Flat Registry as per HBP 3.5.0
- CSFOAM-16661: Modified the fluentd and logrotate image to take the single registry and flat registry as per HBP 3.5.0 [ HBP_Helm_reloc_1, HBP_Helm_reloc_2, HBP_Helm_reloc_3 ]
- CSFOAM-16941: [HBP v3.6.0] HBP_Istio_sidecar_1 (Added changes to have configurable istio admin stopPort and healthCheckPort)
- CSFOAM-15494: Added function to take the cpu limits based on enableDefaultCpuLimits parameter as per HBP 3.4.0 [HBP_Kubernetes_Pod_res_3, HBP_Kubernetes_Pod_res_5]
- CSFOAM-15494: Enabled cpu limits for logrotate & fluentd container as per HBP 3.4.0 [HBP_Kubernetes_Pod_res_3, HBP_Kubernetes_Pod_res_5]
- CSFOAM-17468: updated chart version
## [1.2.0] - 2023-06-30
### Fixed
- CSFOAM-16509: removed special char from chart


## [1.1.0] - 2023-06-30

### Added
- CSFOAM-15287: Added topologySpreadConstraints in cpro-common-lib
- CSFOAM-15655: Code changes for imagePullSecrets in cpro-common-lib
- CSFOAM-15935: Dummy push for the cpro-common-lib as chart is deleted from the incubator, due to which builds are failing
- CSFOAM-15860: added tls template as per HBP 
### Changed
- CSFOAM-15992: Changed the name of isEmpty to isEmptyValue in _syslogvalues.tpl as IsEmpty is deprecated
- CSFOAM-16113: changed the securitycontext template to use across in all vms and cpro charts for the fluentd and logrotate container
- CSFOAM-16014: Update all templates from csf-commons-lib to latest csf-common-lib-1.8.0 - remove deprecated content
- CSFOAM-16256: fluentd container command update
- CSFOAM-16509: move chart to stable

### Security

### Fixed
- CSFOAM-15716: Code correction for imagePullSecrets in cpro-common-lib
- CSFOAM-16163: cpro-common-lib centos template is wrong due to which fluentd container imagepullpolicy is being shown empty when it renders

### Added
## [1.0.0] - 2023-04-06
- CSFOAM-14634: syslog fluentd template is added
- CSFOAM-14667: changes for syslog values function
- CSFOAM-14951: Addition of logrotate template 
- CSFOAM-14800: Added configmap name template
- CSFOAM-14800: changes for the configmap template 
- CSFOAM-15290: added template to get the values of syslog from global or workload
- CSFOAM-15235: Added centos implementation for the fluentd template

### fixed
- CSFOAM-15223: template change as there is issue with volumemounts for the grafana
- CSFOAM-15240: logs as an argument not needed in the fluentd.tpl and logrotatetpl
- CSFOAM-15300: Fix for timezone is not reflecting properly for alertmanager and fluentd containers
- CSFOAM-15425: Hostname changes for Node-exporter container
