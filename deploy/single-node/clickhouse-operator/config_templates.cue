package k8s

import (
	"encoding/yaml"
	"encoding/json"
)

k8s: configmaps: "etc-clickhouse-operator-templatesd-files": {
	metadata: labels: app: "clickhouse-operator"
	data: {
		"001-templates.json.example": json.Marshal(_installation_template)
		let _installation_template = {
			apiVersion: "clickhouse.altinity.com/v1"
			kind:       "ClickHouseInstallationTemplate"
			metadata: name: "01-default-volumeclaimtemplate"
			spec: templates: {
				volumeClaimTemplates: [
					{
						name: "chi-default-volume-claim-template"
						spec: {
							accessModes: [
								"ReadWriteOnce",
							]
							resources: requests: storage: "2Gi"
						}
					},
				]
				podTemplates: [
					{
						name:         "chi-default-oneperhost-pod-template"
						distribution: "OnePerHost"
						spec: containers: [
							{
								name:  "clickhouse"
								image: "yandex/clickhouse-server:19.3.7"
								ports: [
									{
										name:          "http"
										protocol:      "TCP"
										containerPort: 8123
									},
									{
										name:          "client"
										protocol:      "TCP"
										containerPort: 9000
									},
									{
										name:          "interserver"
										protocol:      "TCP"
										containerPort: 9009
									},
								]
							},
						]
					},
				]
			}
		}

		"default-pod-template.yaml.example": yaml.Marshal(_pod_template)
		let _pod_template = {
			apiVersion: "clickhouse.altinity.com/v1"
			kind:       "ClickHouseInstallationTemplate"
			metadata: name: "default-oneperhost-pod-template"
			spec: templates: podTemplates: [{
				name:         "default-oneperhost-pod-template"
				distribution: "OnePerHost"
			}]
		}

		"default-storage-template.yaml.example": yaml.Marshal(_storage_template)
		let _storage_template = {
			apiVersion: "clickhouse.altinity.com/v1"
			kind:       "ClickHouseInstallationTemplate"
			metadata: name: "default-storage-template-2Gi"
			spec: templates: volumeClaimTemplates: [{
				name: "default-storage-template-2Gi"
				spec: {
					accessModes: [
						"ReadWriteOnce",
					]
					resources: requests: storage: "2Gi"
				}
			}]
		}
	}
}
