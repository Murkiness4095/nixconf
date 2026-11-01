# Agent Git & Commit Rules

本仓库所有提交必须遵循 [Conventional Commits v1.0.0](https://www.conventionalcommits.org/zh-hans/v1.0.0/) 规范。

## 工作流

1. 改动完成后，仅 `git add` 与当前任务直接相关的文件。
2. 提交前必须运行相关验证（优先 `nix flake check`，或至少执行一次 dry-build / `just` 任务）。
3. 提交信息必须严格符合下方格式；禁止临时提交、空提交或描述含糊的提交。
4. 不要主动 `git push`；除非用户明确要求。
5. 每次提交完成后，向用户报告提交 hash 与提交信息。

## 暂存与提交禁忌

- 不要将 `.env`、密钥明文、大体积二进制、`flake.lock` 之外自动生成的文件加入暂存区。
- 不要使用 `git add .` 全量暂存；逐文件确认。
- 不要执行 `--amend`、`reset`、`rebase -i`、`push -f`、`clean -f`、`checkout -f` 等危险操作。
- 不要创建普通提交前询问确认；但遇到可能破坏仓库的破坏性操作（如删除 secrets、回滚 flake.lock）必须告知用户。

## 提交信息格式

```text
<type>(<scope>): <description>

[可选的 body，说明改动动机与行为变更]

[可选的 footer，BREAKING CHANGE: 或 Closes/Fixes/Refs]
```

### 规则

- `type` 与 `scope` 全部小写。
- `description` 使用祈使句、小写开头、末尾不加句号，长度 ≤ 72 字符。
- 需要额外说明时写 body；body 每行 ≤ 100 字符。
- 破坏性变更在 `type(scope)!:` 加 `!`，或在 footer 中写 `BREAKING CHANGE: 说明`。
- 一次提交只做一件事；多件事拆分提交。

## Type 定义

| type       | 用途                                                         |
| ---------- | ------------------------------------------------------------ |
| `feat`     | 新增功能、模块、host 配置、home 配置、包封装等               |
| `fix`      | 修复 bug、错误配置、构建失败、运行时问题等                   |
| `refactor` | 重构：既不新增功能也不修复 bug 的结构/命名/整理              |
| `perf`     | 性能优化、启动时间优化、资源占用降低等                       |
| `style`    | 仅格式调整、空行、注释、拼写修正（不影响行为）               |
| `docs`     | 文档、README、注释、AGENTS.md、help 文本                     |
| `test`     | 测试、验证脚本、测试数据                                     |
| `build`    | 构建系统、derivation、overlay、lock 更新、依赖版本调整       |
| `ci`       | CI/CD、GitHub Actions、自动化脚本                            |
| `chore`    | 仓库维护、git 配置、不影响主代码的杂项                       |

## Scope 定义

| scope            | 对应路径/内容                                              |
| ---------------- | ---------------------------------------------------------- |
| `repo`           | 仓库级配置、git、AGENTS.md、Justfile 等                    |
| `flakes`         | `flake.nix`、`flake.lock`、inputs、outputs 结构            |
| `nixos`          | NixOS 系统级模块与配置                                     |
| `home`           | home-manager 配置                                          |
| `hosts/<name>`   | 单台主机配置，如 `hosts/asus`、`hosts/sheng` 等            |
| `modules`        | `modules/` 下的功能/服务/额外模块                          |
| `packages`       | 自定义包、封装脚本、`wrappedPrograms/` 等                  |
| `secrets`        | `secrets/`、`.sops.yaml`、加密/密钥相关                    |
| `assets`         | 图片、壁纸、logo 等静态资源                                |
| `docs`           | 文档、README、说明文件                                     |

使用最具体的 scope；若改动跨多个 scope，可省略 scope 或用 `*`（不推荐，应拆分提交）。

## 提交示例

```text
feat(hosts/asus): add nvidia prime offload support

fix(home/terminal): correct wezterm font fallback order

refactor(modules): split desktop features into separate files

build(flake): update nixpkgs to 24.11

chore(repo): add initial .gitignore

feat(packages): wrap onekey-wallet with firejail

docs(readme): update install instructions for nixos-unstable
```

## 提交报告

每次提交后向用户简要说明：

```text
已提交：<hash> <type>(<scope>): <description>
```
