# GitHub Pages 部署流程

## 自動部署設置

### 1. GitHub Repository 設置

1. **推送代碼到 GitHub**：
   ```bash
   git add .
   git commit -m "Add GitHub Actions deployment workflow"
   git push origin main
   ```

2. **啟用 GitHub Pages**：
   - 進入 GitHub repository
   - 點擊 `Settings` 標籤
   - 在左側菜單找到 `Pages`
   - 在 `Source` 選擇 `GitHub Actions`

### 2. 部署觸發條件

自動部署會在以下情況觸發：
- ✅ 推送到 `main` 或 `master` 分支
- ✅ 創建 Pull Request 到 `main` 或 `master` 分支
- ✅ 手動觸發（在 Actions 頁面點擊 "Run workflow"）

### 3. 部署流程

1. **建構階段 (Build Job)**：
   - 檢出代碼
   - 設置 Flutter 3.32.7 穩定版
   - 安裝依賴 (`flutter pub get`)
   - 代碼分析 (`flutter analyze`)
   - 運行測試（如果有）
   - 建構 Web 應用
   - 上傳建構產物

2. **部署階段 (Deploy Job)**：
   - 部署到 GitHub Pages
   - 只有推送到主分支才會執行

### 4. 訪問網站

部署完成後，可通過以下網址訪問：
```
https://[你的用戶名].github.io/Smart_AI_light_tube_power_conversion/
```

### 5. 監控部署

1. 進入 GitHub repository
2. 點擊 `Actions` 標籤
3. 查看工作流運行狀態
4. 點擊具體的運行查看詳細日誌

## 手動部署步驟

如果需要手動部署：

```bash
# 1. 建構應用
flutter build web --release --web-renderer html --base-href="/Smart_AI_light_tube_power_conversion/"

# 2. 如果你有 gh-pages 分支，可以使用
git subtree push --prefix build/web origin gh-pages

# 或者使用 GitHub CLI
gh workflow run deploy.yml
```

## 故障排除

### 常見問題

1. **部署失敗**：
   - 檢查 `flutter analyze` 是否有錯誤
   - 確認所有依賴都在 `pubspec.yaml` 中

2. **網站無法訪問**：
   - 確認 GitHub Pages 已啟用
   - 檢查 `base-href` 路徑是否正確

3. **樣式或資源載入失敗**：
   - 確認 `base-href` 設置正確
   - 檢查相對路徑是否正確

### 調試步驟

1. 查看 Actions 日誌
2. 檢查建構產物是否正確
3. 本地測試建構結果：
   ```bash
   flutter build web --release
   python3 -m http.server 8000 --directory build/web
   ```

## 配置選項

### 修改部署分支

如果你的主分支不是 `main` 或 `master`，修改 `.github/workflows/deploy.yml`：

```yaml
on:
  push:
    branches: [ your-main-branch ]
```

### 修改網站路徑

如果你的 repository 名稱不同，修改 `base-href`：

```yaml
flutter build web --release --base-href="/你的-repository-名稱/"
```

### Flutter 版本

如需使用不同的 Flutter 版本，修改：

```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '你的版本號'
    channel: 'stable'
```