# Caffeine Tracker

一个基于 macOS SwiftUI 的 Menu Bar App，用于记录和管理每日咖啡因摄入。

## 项目简介

Caffeine Tracker 是一个常驻菜单栏的小工具，目标是让用户可以快速记录饮品摄入，并直观看到当天咖啡因总量，帮助控制摄入节奏。

## 项目目标

- 提供极简、快速的菜单栏记录体验
- 聚焦每日咖啡因摄入统计
- 后续可扩展提醒、历史趋势与自定义饮品库

## MVP 功能清单

- 菜单栏图标入口（Menu Bar App）
- 快速添加常见饮品（如美式、拿铁、茶、能量饮料）
- 自定义输入咖啡因毫克数（mg）
- 显示今日累计摄入量
- 本地持久化保存（重启后数据不丢失）
- 一键清空当日记录（或跨天自动重置）

## 技术栈（规划）

- Swift
- SwiftUI
- macOS MenuBarExtra（后续接入）
- 本地存储（待定：UserDefaults / SwiftData）

## 安装与运行（占位）

> 待 Xcode 工程初始化后补充具体步骤

## 开发计划（当前阶段）

- [x] 仓库初始化（`.gitignore` / `README` / `LICENSE`）
- [ ] 创建 Xcode macOS SwiftUI 工程
- [ ] 搭建 MenuBarExtra 基础结构
- [ ] 实现数据模型与本地存储
- [ ] 实现 MVP 交互流程
