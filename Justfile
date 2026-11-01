# NixOS 声明式配置 —— 快捷命令
#
# 用法：
#   just default      # 列出全部命令
#   just os           # 构建并激活系统（最常用）
#   just os --show-trace
#
# 所有 recipe 都以仓库根目录为工作目录（just 默认行为）。

# ────────────────────────────── 系统 ──────────────────────────────

# 构建并激活系统配置（默认主机，等价于 nixos-rebuild switch）
os *args:
    nh os switch . {{ if args == "" { "" } else { "-- " + args } }}

# 仅构建，不激活、不改动启动项
build *args:
    nh os build . {{ if args == "" { "" } else { "-- " + args } }}

# 构建并设为下次开机默认配置
boot *args:
    nh os boot . {{ if args == "" { "" } else { "-- " + args } }}

# 临时激活新配置，重启后自动回滚（适合验证有风险的改动）
test *args:
    nh os test . {{ if args == "" { "" } else { "-- " + args } }}

# 空跑：打印将要执行的动作，不做任何改动
dry:
    nh os switch . --dry

# 回滚到上一个 generation
rollback:
    nh os rollback

# 列出系统的 generation 历史
gens:
    nh os info

# 对比当前 generation 与上一次的闭包差异
diff:
    #!/usr/bin/env bash
    set -euo pipefail

    mapfile -t gens < <(ls -1dv /nix/var/nix/profiles/system-*-link 2>/dev/null || true)

    if [ "${#gens[@]}" -lt 2 ]; then
        echo "只有一个 generation，无可对比对象"
        exit 0
    fi

    nvd diff "${gens[-2]}" /run/current-system

# ────────────────────────────── flake ──────────────────────────────

# 只更新某个 input：just up nixpkgs
# 更新全部 flake input（不自动 rebuild）：just up
up *args:
    nix flake update {{ args }}

# 校验 flake 的全部输出与模块求值
check *args:
    nix flake check {{ if args == "" { "" } else { "-- " + args } }}

# 打印 flake 的输出（packages / nixosConfigurations 等）
show:
    nix flake show

# 格式化仓库内全部 .nix 文件（nixfmt，RFC 风格）
fmt:
    #!/usr/bin/env bash
    set -euo pipefail

    mapfile -t files < <(git ls-files -co --exclude-standard '*.nix')

    if [ "${#files[@]}" -eq 0 ]; then
        echo "没有找到 .nix 文件"
        exit 0
    fi

    nixfmt "${files[@]}"
    echo "已格式化 ${#files[@]} 个文件"

# 仅检查格式是否合规，不修改文件
fmt-check:
    #!/usr/bin/env bash
    set -euo pipefail

    mapfile -t files < <(git ls-files -co --exclude-standard '*.nix')
    nixfmt --check "${files[@]}"

# ────────────────────────────── 维护 ──────────────────────────────

# 清理 30 天前的旧 generation 与无引用 store 路径
gc:
    sudo nix-collect-garbage --delete-older-than 30d

# 列出全部快捷命令
default:
    @just --list
