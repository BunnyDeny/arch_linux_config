# arch_linux_config —— Arch Linux 常用软件自动化安装与配置

## 思路
- **装软件**：靠 pacman（官方仓库）或 yay（AUR），本仓库用脚本包一层，幂等可重复执行。
- **管配置**：所有"人写的配置文件"集中在本仓库并提交 git；脚本把仓库文件软链到它该在的位置。
  例如 `starship/starship.toml` → `~/.config/starship.toml`。日常编辑的是软链，
  改的就是仓库文件，`git commit` 即可存档；新机器 clone 仓库后逐个跑脚本即恢复。
- **不用 GNU Stow**：文件名/目录无需和目标一致，仓库文件链到哪由脚本里的一行显式声明。

## 目录结构
```
install/lib.sh        共享函数：ensure_pkg(幂等装包)、ensure_symlink(安全建软链)
install/<app>.sh      每个软件一个安装脚本：装包 + 建配置软链
<app>/…               各软件配置文件本体（被软链指向）
```

## 使用方法（假设从刚装好 hyprland 的干净机器开始）
按编号顺序逐个执行，每个脚本幂等、可重复跑：
```
git clone <本仓库> ~/.config/arch_linux_config
./install/starship.sh          # 第 1 步：starship 提示符（含字体依赖，自动在 bash/fish 启用）
./install/waybar.sh            # 第 2 步：waybar 状态栏（含字体依赖）
./install/global.sh            # 第 3 步：全局配置（.bashrc、fish config、hyprland.lua）
./install/kitty.sh             # 第 4 步：kitty 终端（shell fish + 字体大小）
```

## starship 配色预览与套用
- **当前所选预设：Pastel Powerline**（`starship/starship.toml` 即其完整配置，需 Nerd Font，脚本会自动装齐字体）
- 官方预设预览页（可直接看效果挑选）：https://starship.rs/presets/
- 本机内置预设列表：`starship preset --list`
- 换主题：`starship preset <名字> -o ~/.config/starship.toml`
  （该文件是软链，写入即改仓库文件，之后 `git commit` 保存）

## 写新脚本的约定
- 每个 `install/<app>.sh` 必须**显式装齐自身所需依赖（含字体）**，不假设目标机器已装任何东西；
  统一用 `ensure_pkg`（官方仓库）或 `ensure_pkg <包> --aur`（AUR），已装会自动跳过。
- 以 `install/starship.sh` 为范本：开头一行总述，按『装包 → 建配置软链 → 启用』分段，段首一行短注释；
  配置内容一律以仓库文件为准，脚本不生成、不预设任何配置。

## 铁律
- `.ssh/`、token、密码等敏感内容**绝不**提交进仓库。
- 不直接删用户已有的真实配置文件；建软链前如遇真实文件先备份（见 `ensure_symlink`）。
