# Local RELEASE verification evidence

Recorded at: `2026-07-28T03:54:22Z`

## Ownership and repository baseline

- Component: `spring-data-bom-2.7`
- Change: `release-2021-2-18-nes-patch-1`
- Coordinator lease: `coordinator-wave7-bom-27`
- Branch: `2021.2.x-bjca-patch`
- Baseline HEAD before release commit: `46647e3`
- Toolchain: Tencent Kona `8.0.482-kona`

Credentials remain exclusively in user-level Maven configuration and were neither read nor recorded.

## Upstream RELEASE gate

All catalog-declared upstreams are `tagged`: Commons / KeyValue / Redis `2.7.18-nes.patch.1`, Elasticsearch `4.4.18-nes.patch.1`.

## Serialized incremental install

```bash
JAVA_HOME=/Users/anan/.sdkman/candidates/java/8.0.482-kona \
./mvnw -pl bom -am -DskipTests -Dmaven.test.skip=true install
```

- Exit status: success (`0`)
- Maven Total time: `0.720 s`
- Mode: no `clean`; installs flattened BOM POM only
- Log: `/tmp/nes-bom27-install.log`

## Confirmed publication set

One GAV: `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:pom:2021.2.18-nes.patch.1`

- `bjca-footstone-bpring-data-bom-2021.2.18-nes.patch.1.pom` (`9296` bytes)

Root aggregator and `bom-client` were not installed as RELEASE publications.

## Generated POM scan

- `filesScanned`: `1`
- `clean`: `true`
- `findings`: `0`

## Offline local consumer

Consumer: `/tmp/nes-bom27-local-consumer/pom.xml` (imports BOM; depends on Commons/KeyValue/Redis/Elasticsearch without explicit versions)

```bash
mvn -o -f /tmp/nes-bom27-local-consumer/pom.xml dependency:tree
```

- Exit status: success (`0`)
- Resolved NES Data modules: Commons/KeyValue/Redis `2.7.18-nes.patch.1`, Elasticsearch `4.4.18-nes.patch.1`
- Internal SNAPSHOT dependencies: `0`
