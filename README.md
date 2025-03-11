# 飲食控制 App

這是一個使用 Flutter 開發的飲食控制應用程式，提供使用者記錄和追蹤他們的飲食習慣。

## 功能特點

- 使用者認證系統（登入/註冊）
- 美觀的使用者介面
- 響應式設計，支援各種螢幕尺寸
- RESTful API 整合

## 系統需求

- Flutter SDK: 3.x.x
- Dart SDK: 3.x.x
- Android Studio / VS Code
- Android SDK: API 21+ (Android 5.0 或更高)
- iOS 11.0 或更高


## 專案結構

```
lib/
  ├── config/         # 配置文件
  ├── models/         # 資料模型
  ├── pages/          # 頁面
  ├── services/       # API 服務
  ├── utils/          # 工具類
  └── main.dart       # 入口文件
```

## API 整合

應用程式使用以下 API 端點：

- 登入: `POST /auth/login`
- 註冊: `POST /auth/register`

## 開發環境

- 開發環境 API URL: `https://health-care.zeabur.app`
- 生產環境 API URL: `https://health-care.zeabur.app`

## 支援平台

- Android 5.0 (API 21) 或更高
- iOS 11.0 或更高