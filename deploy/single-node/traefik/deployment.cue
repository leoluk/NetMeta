package k8s

import (
	"list"
)

k8s: serviceaccounts: "traefik-ingress-controller": {}

k8s: pvcs: "traefik-data": {}

k8s: deployments: traefik: {
	metadata: labels: app: "traefik"
	spec: {
		replicas: 1
		strategy: type: "Recreate"
		selector: matchLabels: app: "traefik"
		template: {
			metadata: labels: app: "traefik"
			spec: {
				// The poor-man's LoadBalancer implementation in k3s does not support IPv6 and is limited to legacy IPv4.
				// Bypass this inconvenience by running traefik in the host network namespace.
				hostNetwork:        true
				serviceAccountName: "traefik-ingress-controller"
				containers: [{
					name:  "traefik"
					image: "docker.io/traefik:v2.3.6@sha256:03e2149c3a844ca9543edd2a7a8cd0e4a1a9afb543486ad99e737323eb5c25f2"

					let _args = [
						[
							"--accesslog",
							"--entrypoints.web.Address=:\(netmeta.config.ports.http)",
							"--entrypoints.websecure.Address=:\(netmeta.config.ports.https)",
							"--providers.kubernetescrd",
						],

						if netmeta.config.letsencryptMode != "off" {
							[
								"--certificatesresolvers.publicHostnameResolver.acme.tlschallenge",
								"--certificatesresolvers.publicHostnameResolver.acme.email=\(netmeta.config.letsencryptAccountMail)",
								"--certificatesresolvers.publicHostnameResolver.acme.storage=/data/acme.json",
							]
						},

						if netmeta.config.letsencryptMode == "staging" {
							[
								"--certificatesresolvers.publicHostnameResolver.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory",
							]
						},

						if netmeta.config.enableClickhouseIngress {
							[
								"--entrypoints.clickhouse.Address=:\(netmeta.config.ports.clickhouse)",
							]
						},
					]

					args: list.FlattenN(_args, 1)

					ports: [{
						name:          "web"
						containerPort: netmeta.config.ports.http
						protocol:      "TCP"
					}, {
						name:          "websecure"
						containerPort: netmeta.config.ports.https
						protocol:      "TCP"
					}, {
						name:          "clickhouse"
						containerPort: netmeta.config.ports.clickhouse
						protocol:      "TCP"
					}]

					volumeMounts: [{
						mountPath: "/data"
						name:      "traefik-data"
					}]
				}]
				restartPolicy: "Always"
				volumes: [{
					name: "traefik-data"
					persistentVolumeClaim: claimName: "traefik-data"
				}]

			}
		}
	}
}
