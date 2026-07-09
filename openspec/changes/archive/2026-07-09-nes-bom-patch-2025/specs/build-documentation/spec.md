## ADDED Requirements

### Requirement: 构建快捷命令

项目 MUST 提供 `Makefile` 封装常用 Maven 构建命令，与全家桶其余 fork 仓库（commons-3.5 / keyvalue-3.5）的交付形态一致。因 BOM 为纯 pom、无字节码、无测试，其目标针对 BOM 定制：不含 `test`，改为 `validate`（坐标校验）与 `verify-client`（冒烟校验）。

#### Scenario: Makefile 目标

- **WHEN** 查看 `Makefile`
- **THEN** 至少包含 `clean`、`build`、`validate`、`install`、`deploy`、`verify-client` 目标
- **AND** 各目标使用 `mvnw` 与默认 `~/.m2/settings.xml`（`bjca` profile 默认激活，不显式传 `-s`；可用 `SETTINGS='-s <路径>'` 覆盖）

#### Scenario: make deploy 发布到私服

- **WHEN** 执行 `make deploy`
- **THEN** 对 `bom` 模块执行 `clean deploy`
- **AND** 依 `bom/pom.xml` 的 `<distributionManagement>` 将制品发布到 Nexus（release 版进 `releases`、SNAPSHOT 版进 `snapshots`）

#### Scenario: make build 触发 flatten

- **WHEN** 执行 `make build`
- **THEN** 对 `bom` 模块执行 `-DskipTests clean package`
- **AND** flatten-maven-plugin 生成扁平化发布 POM，坐标为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2025.0.13-nes.patch.1-SNAPSHOT`
