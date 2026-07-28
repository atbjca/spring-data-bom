# Local RELEASE verification evidence

Recorded at: `2026-07-28T03:56:12Z`

## Ownership and repository baseline

- Component: `spring-data-bom-3.5`
- Change: `release-2025-0-13-nes-patch-1`
- Coordinator lease: `coordinator-wave7-bom-35`
- Branch: `2025.0.x-bjca-patch`
- Baseline HEAD before release commit: `7698531`
- Toolchain: Amazon Corretto `17.0.17-amzn`

Credentials remain exclusively in user-level Maven configuration and were neither read nor recorded.

## Upstream RELEASE gate

Commons / KeyValue / Redis `3.5.13-nes.patch.1`, Elasticsearch `5.5.13-nes.patch.1` are `tagged`.

## Serialized incremental install

```bash
JAVA_HOME=/Users/anan/.sdkman/candidates/java/17.0.17-amzn \
./mvnw -pl bom -am -DskipTests -Dmaven.test.skip=true install
```

- Exit status: success (`0`)
- Maven Total time: `2.393 s`
- Log: `/tmp/nes-bom35-install.log`

## Confirmed publication set

One GAV: `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:pom:2025.0.13-nes.patch.1`

- `bjca-footstone-bpring-data-bom-2025.0.13-nes.patch.1.pom` (`6094` bytes)

## Generated POM scan

- `filesScanned`: `1`
- `clean`: `true`
- `findings`: `0`

## Offline local consumer

Consumer: `/tmp/nes-bom35-local-consumer/pom.xml`

- Exit status: success (`0`)
- Resolved NES Data modules at `3.5.13-nes.patch.1` / ES `5.5.13-nes.patch.1`
- Internal SNAPSHOT dependencies: `0`
