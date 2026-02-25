# Caffeine Tracker

一个基于 macOS SwiftUI 的 Menu Bar App，用于记录和管理每日咖啡因摄入。

## 项目简介

Caffeine Tracker 是一个常驻菜单栏的小工具，目标是让用户可以快速记录饮品摄入，并查看基于半衰期模型的咖啡因残留估算（estimate），帮助控制摄入节奏。

## 项目目标

- 提供极简、快速的菜单栏记录体验
- 聚焦每日咖啡因摄入统计
- 后续可扩展提醒、历史趋势与自定义饮品库

## 当前已实现（MVP 进行中）

- macOS 菜单栏应用（`MenuBarExtra`）
- Add Intake 三种添加方式
- `Quick Presets`（通用预设）
- `Brand Products`（品牌 -> 产品/容量 两级选择）
- `Manual Input`（手动输入 mg）
- 选择预设/品牌产品后自动填充咖啡因 mg（仍可手动修改）
- 输入摄入时间并添加记录
- 当前估算残留咖啡因（mg，half-life = 5 小时）
- Today's Intakes 列表（时间 + mg）
- 删除记录（Delete）
- `UserDefaults` 本地存储（当前开发阶段在 `DEBUG` 启动时会清空记录，便于测试）

## Brand Products（US 本地静态数据）

当前内置（本地 seed 数据，无网络请求）：

- Red Bull
- Coca-Cola（含 Coke / Zero Sugar / Diet Coke / Barq's / Sprite / Fresca）
- Pepsi（含 Pepsi / Diet Pepsi / Pepsi Zero Sugar，不同包装）
- Mountain Dew（含 Zero Sugar / Code Red / Baja Blast，多包装）
- CELSIUS（产品线级别）

## 技术栈（当前）

- Swift
- SwiftUI
- macOS `MenuBarExtra`
- `UserDefaults`（MVP 持久化）

## 安装与运行

1. 使用 Xcode 打开项目：
   - `/Users/kevinzhou/Desktop/Caffeine_Tracker/Caffeine_Tracker/Caffeine_Tracker.xcodeproj`
2. 选择 macOS 运行目标
3. 点击 Run
4. 在 macOS 顶部菜单栏点击杯子图标打开面板

提示：
- 这是菜单栏应用，不会弹出传统主窗口
- 当前 `DEBUG` 运行会清空本地记录数据（用于开发测试）

## 开发计划（当前阶段）

- [x] 仓库初始化（`.gitignore` / `README` / `LICENSE`）
- [x] 创建 Xcode macOS SwiftUI 工程
- [x] 搭建 MenuBarExtra 基础结构
- [x] 实现 IntakeRecord / ViewModel / `UserDefaults` MVP 持久化
- [x] 实现 Add Intake + 残留估算 + Today 列表 + 删除
- [x] 实现 Brand Products 两级选择（Brand -> Product）与本地 US seed 数据
- [ ] 增加品牌产品搜索（可选）
- [ ] 优化 mg 输入体验（仅数字/格式化）
- [ ] 评估升级到 SwiftData（可选）
