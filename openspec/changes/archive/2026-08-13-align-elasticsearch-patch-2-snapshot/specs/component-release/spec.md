## ADDED Requirements

### Requirement: SNAPSHOT 开发线禁止作为 RELEASE 发布

包含任何内部 `cn.bjca.footstone` SNAPSHOT 依赖的 BOM MUST 仅用于本地或 SNAPSHOT 联调，MUST NOT 发布到 Nexus RELEASE、声明为 RELEASE 或创建 release tag。

#### Scenario: Elasticsearch 仍为 SNAPSHOT

- **WHEN** BOM managed 依赖包含 `bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.2-SNAPSHOT`
- **THEN** BOM version MUST 保持 `2021.2.18-nes.patch.2-SNAPSHOT`
- **AND** RELEASE deploy 和 release tag MUST 被阻断

#### Scenario: 准备正式发布

- **WHEN** Elasticsearch `4.4.18-nes.patch.2` 及全部内部依赖已经形成获准且 Nexus 已验证的 RELEASE
- **THEN** BOM 正式发布 MUST 通过独立 OpenSpec release change 将全部内部版本收敛为 RELEASE
- **AND** 发布前 MUST 验证目标 BOM RELEASE GAV 尚不存在、生成 POM 无内部 SNAPSHOT且独立消费者通过

#### Scenario: 开发态允许的操作

- **WHEN** BOM 仍处于 `2021.2.18-nes.patch.2-SNAPSHOT`
- **THEN** reactor validate、effective POM、本地 install 和消费者联调 MAY 执行
- **AND** 本变更 MUST NOT 执行远程 deploy 或创建发布标签
