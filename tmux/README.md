Put tmuxp projevct description here

- core.yml - Consul, Nomad, Vault servers + root top -d1 to kill bad systemd-resolver
- distributor.yml - Traefik, Fabio, Superfly, Gloo, Qloo
- worker.yml - Actual workloads here; by type: Java, Golang, .net
- db.yml - Persistent DBs: Redis, cockroachDB, rqlite
- store.yml - Storage: OpenEBS, MooseFS