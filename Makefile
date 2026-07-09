.PHONY: clean build validate install deploy verify-client help

# =============================================================================
# Spring Data BOM 2025.0.x BJCA/NES 维护分支 — 构建快捷命令（Maven）
# =============================================================================
# 本项目为 Maven 聚合工程，基线 2025.0.13，唯一发布制品为 bom 模块
# （cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom）。BOM 为纯 pom、
# 无字节码、无测试。私服依赖解析与发布配置（mirror、bjca profile 属性、
# releases/snapshots 凭证）全部由 Maven 默认用户级配置 ~/.m2/settings.xml 提供，
# 且 bjca profile 默认激活，因此不显式传 -s。如需覆盖，命令行传
# SETTINGS='-s <路径>' 即可。

SHELL := /bin/bash
MVNW  := ./mvnw
SETTINGS ?=

help:
	@echo ""
	@echo "可用命令:"
	@echo "  make clean         - 清理构建产物（target）"
	@echo "  make build         - 编译打包 bom（触发 flatten，跳过测试）"
	@echo "  make validate      - 校验根 reactor 并打印 bom 的 effective-pom（确认 fork 坐标生效）"
	@echo "  make install       - 安装 bom 到本地 Maven 仓库（~/.m2）"
	@echo "  make deploy        - 发布 bom 到 Nexus 私服"
	@echo "  make verify-client - 激活 with-bom-client profile 做依赖解析冒烟校验"
	@echo ""

# 清理构建产物
clean:
	$(MVNW) $(SETTINGS) clean

# 编译打包 bom：触发 flatten-maven-plugin 生成扁平化发布 pom
build:
	$(MVNW) $(SETTINGS) -DskipTests -pl bom clean package

# 校验根 reactor，并打印 bom 的 effective-pom 以确认 GAV 与 managed 依赖 fork 坐标生效
validate:
	$(MVNW) $(SETTINGS) -N validate
	$(MVNW) $(SETTINGS) help:effective-pom -pl bom

# 安装 bom 到本地仓库
install:
	$(MVNW) $(SETTINGS) -pl bom clean install

# 发布 bom 到 Nexus 私服（依据 bom/pom.xml 的 distributionManagement，
# release 版进 releases 仓库，SNAPSHOT 版进 snapshots 仓库）
deploy:
	$(MVNW) $(SETTINGS) -pl bom clean deploy

# 冒烟校验：激活 with-bom-client profile，验证 bom-client 通过本 BOM 解析依赖版本
# 注：validate 阶段仅做模型/parent 解析；私服无法代理外网官方 jar 时勿升级到 verify
verify-client:
	$(MVNW) $(SETTINGS) -Pwith-bom-client validate
