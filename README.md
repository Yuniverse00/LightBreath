本项目是一个由Flutter制作而成的应用程序。

This project is a starting point for a Flutter application.

如果这是你的第一个Flutter项目，可以参考一些资源：

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

有关Flutter开发入门的帮助，请查看在线文档，它提供教程，示例、移动开发指南和完整的API参考资料。

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/), which offers tutorials, samples, guidance on mobile development, and a full API reference.

# LightBreath

LightBreath 是一个基于 Flutter 的移动端戒烟干预应用。本项目**强依赖指定版本的 Flutter SDK**，并通过 **FVM (Flutter Version Management)** 进行版本管理。如果未按说明配置环境，项目将无法正常编译或运行。

LightBreath is a Flutter-based mobile smoking cessation intervention app. This project **strictly depends on a specific Flutter SDK version** and uses **FVM (Flutter Version Management)** for version control. If the environment is not configured as instructed, the project will not build or run correctly.

本文档将从零开始，完整说明在 **Windows** 环境下如何配置、运行和构建本项目。

This document provides a complete, step-by-step guide for configuring, running, and building the project on **Windows**.

## 一、环境要求概览 | Environment Requirements

在开始之前，请确保你的开发环境满足以下条件：

Before you begin, make sure your environment meets the following requirements:

- 操作系统 | OS: Windows 10 or Windows 11
- Java JDK: **JDK 17 (required)**
- Flutter SDK:
  - 全局 Flutter | Global Flutter: 3.41.7 (or another latest version)
  - 项目指定 Flutter | Project Flutter: **3.19.6 (required)**
- Flutter 版本管理工具 | Flutter version manager: FVM
- Android Studio (for IDE run and Android builds)

## 二、Java JDK 配置 | Java JDK Setup

请确认你已安装 **JDK 17**。

Make sure **JDK 17** is installed.

```bash
java -version
```

输出应类似 | Output should look like:

```
java version "17.x.x"
```

如果不是 17，请卸载其他版本并重新安装 JDK 17。

If the version is not 17, uninstall other versions and install JDK 17.

## 三、安装并配置 FVM | Install and Configure FVM

### 1. 安装 FVM | Install FVM

在 PowerShell 中执行 | Run in PowerShell:

```powershell
dart pub global activate fvm
```

验证安装 | Verify installation:

```powershell
fvm --version
```

---

### 2. 配置 FVM 缓存目录（推荐） | Configure FVM Cache Path (Recommended)

建议统一放在 `C:\Flutter\Fvm`：

It is recommended to place all Flutter SDKs under `C:\Flutter\Fvm`:

```powershell
fvm config --cache-path C:\Flutter\Fvm
```

---

### 3.（国内网络推荐）配置 Flutter 镜像源 | Configure Flutter Mirrors (in China)

```powershell
fvm config --flutter-url https://gitee.com/mirrors/Flutter.git
setx FLUTTER_STORAGE_BASE_URL https://storage.flutter-io.cn
setx PUB_HOSTED_URL https://pub.flutter-io.cn
```

执行后请**重新打开 PowerShell**。

Restart PowerShell after setting environment variables.

## 四、安装指定 Flutter 版本 | Install Required Flutter Version

```powershell
fvm install 3.19.6
```

安装完成后，你应看到 Flutter 3.19.6。

After installation, Flutter 3.19.6 should be available.

目录结构示例 | Directory structure example:

```
C:\Flutter\Fvm\versions\
├─ 3.19.6
├─ 3.41.7
```

说明 | Notes:

- 3.41.7: 全局 Flutter（`flutter`） | Global Flutter
- 3.19.6: 项目使用版本 | Project Flutter

## 五、全局 Flutter 与项目 Flutter 的区别 | Global vs Project Flutter

- 全局 Flutter | Global:
  ```bash
  flutter
  ```
  → 3.41.7

- 项目 Flutter | Project:
  ```bash
  fvm flutter
  ```
  → 3.19.6

**所有项目相关命令必须使用** | **All project commands must use**:

```bash
fvm flutter <command>
```

## 六、Android Studio 配置 | Android Studio Setup

如需通过 Android Studio 运行项目，必须手动指定 Flutter SDK 路径。

To run the project via Android Studio, you must manually set the Flutter SDK path.

路径 | Path:

```
C:\Flutter\Fvm\versions\3.19.6
```

位置 | Location:

`Settings → Languages & Frameworks → Flutter`

## 七、运行与构建 | Run and Build

### 命令行运行 | Run via CLI

```bash
fvm flutter pub get
fvm flutter run
```

### 构建 APK | Build APK

```bash
fvm flutter build apk
```

输出位置 | Output:

```
build\app\outputs\flutter-apk\
```

## 八、常见问题 | Common Issues

### Flutter 版本错误 | Wrong Flutter Version

- 是否使用 `fvm flutter`
- Android Studio Flutter 路径是否正确

Check `fvm flutter` usage and IDE Flutter path.

### 构建失败或依赖异常 | Build Failure or Dependency Issues

当出现编译失败、依赖解析异常或不明错误时，建议按以下顺序执行：

If you encounter build failures, dependency resolution errors, or unclear issues, run the following commands in order:

```bash
fvm flutter clean
fvm flutter pub get
```

这一步可以清理旧的构建缓存并重新拉取依赖，是最常见且有效的排查方式。

This clears stale build artifacts and re-fetches dependencies, which resolves most common issues.
