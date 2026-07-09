# nexus-config Specification

## Purpose
TBD - created by archiving change 2026-07-09-nes-bom-patch-2025. Update Purpose after archive.
## Requirements
### Requirement: Nexus 私服发布配置

`bom/pom.xml` MUST 通过 `<distributionManagement>` 配置内网 Nexus 私服作为构件发布目标，URL 使用属性占位以便环境隔离。根 pom 与 bom-client 不发布，无需各自的 distributionManagement。

#### Scenario: distributionManagement 配置

- **WHEN** 检查 `bom/pom.xml`
- **THEN** 存在 `<distributionManagement>`，包含 `releases`（`${nexusReleaseUrl}`）与 `snapshots`（`${nexusSnapshotUrl}`）两个仓库

#### Scenario: 属性由 settings 提供

- **WHEN** 执行发布
- **THEN** `${nexusReleaseUrl}` / `${nexusSnapshotUrl}` 由环境 `~/.m2/settings.xml` 的 `bjca` profile 属性解析
- **AND** server 凭证 id `releases` / `snapshots` 与 settings 中一致
- **AND** 本变更不修改 `settings.xml`（复用环境已激活的 `bjca` profile）

### Requirement: 私服依赖解析

构建 MUST 优先从内网 Nexus 私服（`maven-public` 聚合仓库）解析依赖，隔离外网。

#### Scenario: 依赖从私服拉取

- **WHEN** 执行 `./mvnw -N validate`
- **THEN** 依赖通过 `192.168.131.36:8088/repository/maven-public/` 聚合仓库解析成功
- **AND** 不依赖外网直连

#### Scenario: 快照发布

- **WHEN** 执行 `./mvnw -pl bom -DskipTests deploy`
- **THEN** `2025.0.13-nes.patch.1-SNAPSHOT` 制品发布到 snapshots 仓库

