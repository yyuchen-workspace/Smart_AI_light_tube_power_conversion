# 📚 智慧AI燈管電力換算 - 文檔中心

> 完整的專案文檔索引，幫助您快速找到所需資訊

---

## 🎯 專案概覽

**智慧AI燈管電力換算計算器** 是一個基於 Flutter 的網頁應用程式，提供精確的燈管電力消耗計算、台電帳單分析和成本效益評估功能。

- 🌐 **在線訪問：** [GitHub Pages](https://yyuchen-workspace.github.io/Smart_AI_light_tube_power_conversion/)
- 📱 **響應式設計：** 支援手機、平板、桌面設備
- ⚡ **即時計算：** 三步驟智慧計算流程
- 🔄 **自動部署：** GitHub Actions CI/CD

---

## 📋 文檔導航

### 🚀 部署與維運
- [🔧 部署指南](./deployment/README.md) - 完整的 GitHub Pages 部署流程
- [🧪 測試流程](./deployment/README.md#測試流程) - 功能測試清單與自動化測試

### 📈 版本歷史
- [📋 版本 5.0](./versions/v5.0.md) - 車道燈/車位燈分離計算系統 **(最新)**
- [📋 版本 4.0](../prd/VERSION_4.0.md) - UI優化與邏輯修復
- [📋 歷史版本](./versions/) - 完整版本演進記錄

### 💻 開發文檔
- [🛠 技術架構](./development/README.md) - Flutter 技術棧與架構設計
- [⚙️ 開發環境](./development/setup.md) - 本地開發環境設置
- [🎨 UI設計規範](./development/ui-guidelines.md) - 界面設計標準

### 📖 使用指南
- [👤 用戶手冊](./user-guide/README.md) - 完整操作說明
- [❓ 常見問題](./user-guide/faq.md) - 疑難排解
- [🔢 計算公式](./user-guide/formulas.md) - 電力計算原理

---

## 🏗 專案架構

```
Smart_AI_light_tube_power_conversion/
├── 📱 lib/main.dart          # Flutter 主應用程式
├── 🌐 web/                   # Web 資源檔案
├── 📋 docs/                  # 文檔中心
│   ├── deployment/           # 部署相關
│   ├── versions/            # 版本歷史  
│   ├── development/         # 開發文檔
│   └── user-guide/          # 使用指南
├── 🔧 .github/workflows/    # GitHub Actions
└── 📄 README.md             # 專案入口
```

---

## ⚡ 快速開始

### 🎯 使用者
1. **直接使用：** 訪問 [在線計算器](https://yyuchen-workspace.github.io/Smart_AI_light_tube_power_conversion/)
2. **了解功能：** 查看 [用戶手冊](./user-guide/README.md)
3. **問題協助：** 參考 [常見問題](./user-guide/faq.md)

### 👨‍💻 開發者  
1. **環境設置：** 參考 [開發環境](./development/setup.md)
2. **本地運行：** `flutter run -d chrome`
3. **部署流程：** 查看 [部署指南](./deployment/README.md)

---

## 🔄 最新更新

### 📅 2025-08-22 - 版本 5.0
- ✨ **新功能：** 車道燈/車位燈分離計算系統
- 🎨 **UI優化：** 紅色高亮計算公式顯示  
- 🔧 **架構重構：** 獨立第三步計算邏輯
- 📱 **體驗提升：** 白色背景輸入欄位

[查看完整更新日誌](./versions/v5.0.md) →

---

## 🛠 技術規格

| 項目 | 規格 |
|------|------|
| **前端框架** | Flutter 3.32.7 |
| **開發語言** | Dart |
| **部署平台** | GitHub Pages |
| **CI/CD** | GitHub Actions |
| **支援瀏覽器** | Chrome, Firefox, Safari, Edge |
| **響應式支援** | Mobile, Tablet, Desktop |

---

## 📊 功能特色

### 🔢 三步驟計算流程
1. **第一步：** AI燈管電力試算（車道燈 + 車位燈）
2. **第二步：** 台電帳單資訊分析（選填）
3. **第三步：** 攤提時間計算（選填）

### ⚙️ 核心功能
- 🎯 **精確計算：** 車道燈 82.12W、車位燈 2.95W 分離計算
- 📊 **電費分析：** 夏季/非夏季電價自動切換
- 💰 **成本評估：** 租賃 vs 買斷方案比較
- ℹ️ **智慧提示：** ？按鈕提供詳細計算說明
- 🔴 **視覺引導：** 重要公式紅色高亮顯示

### 🎨 設計特色
- 📱 **響應式佈局：** 自適應不同設備螢幕
- 🎨 **分色設計：** 三步驟不同顏色卡片區分
- ⚡ **即時驗證：** 輸入錯誤即時提示
- 🔄 **狀態追蹤：** 計算進度視覺化反饋

---

## 📞 支援與協助

### 🐛 問題回報
- **GitHub Issues：** [提交問題](https://github.com/yyuchen-workspace/Smart_AI_light_tube_power_conversion/issues)
- **功能建議：** [提交建議](https://github.com/yyuchen-workspace/Smart_AI_light_tube_power_conversion/issues/new)

### 📖 相關資源
- [Flutter 官方文檔](https://flutter.dev/docs)
- [Dart 語言指南](https://dart.dev/guides)
- [GitHub Actions 文檔](https://docs.github.com/en/actions)

### 👥 貢獻指南
歡迎貢獻代碼、文檔或提出改進建議！請參考 [開發文檔](./development/README.md) 了解如何參與專案開發。

---

## 📄 許可證

本專案採用開放原始碼許可證，詳細資訊請查看 [LICENSE](../LICENSE) 檔案。

---

*文檔版本：1.0*  
*最後更新：2025-08-22*  
*維護者：Claude Code Assistant*