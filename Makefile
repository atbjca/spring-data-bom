.PHONY: clean build validate install deploy client help

# =============================================================================
# Spring Data BOM 2021.2.x BJCA/NES 维护分支 — 构建快捷命令（Maven）
# =============================================================================
# 本项目为纯 pom（BOM 物料清单），无字节码、无单元测试，故不提供 test 目标。
# 真正发布的制品只有 bom 模块（cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom）；
# 根 pom 的 install/deploy 已 skip=true，仅作 reactor 聚合根。
#
# 私服依赖解析与发布配置（mirror、nexusReleaseUrl/nexusSnapshotUrl 属性、
# releases/snapshots 凭证）由用户级 ~/.m2/settings.xml 提供（含内网 Nexus
# 镜像 192.168.131.36:8088）。如需显式指定其它 settings，命令行传
# SETTINGS='-s <路径>' 即可覆盖。
# =============================================================================

SHELL := /bin/bash
MVNW  := ./mvnw
# 默认使用用户级 ~/.m2/settings.xml（含内网 Nexus 镜像与凭证）
SETTINGS ?= -s $(HOME)/.m2/settings.xml

help:
	@echo ""
	@echo "可用命令:"
	@echo "  make clean     - 清理构建产物（target）"
	@echo "  make build     - 打包 BOM（flatten 生成发布 pom）"
	@echo "  make validate  - 校验 reactor 与 effective-pom（不发布、不下载）"
	@echo "  make client    - 以 with-bom-client profile 冒烟校验 BOM 可解析"
	@echo "  make install   - 安装 BOM 到本地 Maven 仓库（~/.m2）"
	@echo "  make deploy    - 发布 BOM 到 Nexus 私服 RELEASE"
	@echo ""

# 清理构建产物
clean:
	$(MVNW) $(SETTINGS) clean

# 打包：纯 pom 走 flatten 生成扁平化发布 pom
build:
	$(MVNW) $(SETTINGS) clean package

# 校验根 reactor 与 BOM effective-pom（离线可行，不发布）
validate:
	$(MVNW) $(SETTINGS) -N validate
	$(MVNW) $(SETTINGS) help:effective-pom -pl bom

# 冒烟校验：激活 with-bom-client profile，确认 BOM 及其 managed 依赖可解析
client:
	$(MVNW) $(SETTINGS) -Pwith-bom-client validate

# 安装 BOM 到本地仓库
install:
	$(MVNW) $(SETTINGS) install

# 发布 BOM 到 Nexus 私服 snapshot
deploy:
	$(MVNW) $(SETTINGS) -DskipTests -Dmaven.test.skip=true deploy
