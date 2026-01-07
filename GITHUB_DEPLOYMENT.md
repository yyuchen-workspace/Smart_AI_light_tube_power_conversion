# GitHub 網頁部署流程

本文件說明如何將 Smart AI 燈管電力換算計算器部署到 GitHub Pages。

## 前置準備

1. **確認專案結構**
   ```
   Smart_AI_light_tube_power_conversion/
   ├── lib/
   │   └── main.dart
   ├── web/
   │   ├── index.html
   │   └── manifest.json
   ├── pubspec.yaml
   └── README.md
   ```

2. **確認 pubspec.yaml 設定**
   ```yaml
   name: smart_ai_light_tube_power_conversion
   description: 智慧AI燈管電力換算計算器
   
   publish_to: 'none'
   
   version: 1.0.0+1
   
   environment:
     sdk: '>=2.17.0 <4.0.0'
   
   dependencies:
     flutter:
       sdk: flutter
   
   dev_dependencies:
     flutter_test:
       sdk: flutter
     flutter_lints: ^2.0.0
   
   flutter:
     uses-material-design: true
   ```

## 部署步驟

### 1. 建立 GitHub Repository

1. 前往 [GitHub](https://github.com) 並登入
2. 點擊 "New repository"
3. Repository 名稱：`smart-ai-light-tube-power-conversion`
4. 設定為 Public
5. 勾選 "Add a README file"
6. 點擊 "Create repository"

### 2. 本地專案設定

```bash
# 在專案根目錄初始化 Git
git init

# 添加 GitHub 遠端倉庫
git remote add origin https://github.com/YOUR_USERNAME/smart-ai-light-tube-power-conversion.git

# 添加所有檔案
git add .

# 提交初始版本
git commit -m "Initial commit: Smart AI 燈管電力換算計算器"

# 推送到 GitHub
git push -u origin main
```

### 3. 設定 GitHub Actions 自動部署

在專案根目錄建立 `.github/workflows/deploy.yml`：

```yaml
name: Deploy Flutter Web to GitHub Pages

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
      
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Build web
      run: flutter build web --release --base-href /smart-ai-light-tube-power-conversion/
      
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      if: github.ref == 'refs/heads/main'
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build/web
```

### 4. 啟用 GitHub Pages

1. 前往 GitHub Repository 頁面
2. 點擊 "Settings" 標籤
3. 在左側選單找到 "Pages"
4. 在 "Source" 下拉選單選擇 "GitHub Actions"
5. 點擊 "Save"

### 5. 觸發部署

```bash
# 提交 GitHub Actions 設定
git add .github/workflows/deploy.yml
git commit -m "Add GitHub Actions deployment workflow"
git push origin main
```

## 部署完成後

### 訪問網站

部署完成後，可透過以下網址訪問：
```
https://YOUR_USERNAME.github.io/smart-ai-light-tube-power-conversion/
```

### 檢查部署狀態

1. 前往 GitHub Repository
2. 點擊 "Actions" 標籤
3. 查看最新的 workflow 執行狀態
4. 如果出現錯誤，點擊失敗的 job 查看詳細錯誤訊息

## 更新流程

每次更新程式碼後：

```bash
# 添加變更
git add .

# 提交變更
git commit -m "Update: 描述你的變更"

# 推送到 GitHub
git push origin main
```

GitHub Actions 會自動觸發重新部署。

## 故障排除

### 常見問題

1. **Flutter 版本不相容**
   - 檢查 `.github/workflows/deploy.yml` 中的 Flutter 版本
   - 確認本地 Flutter 版本與 CI 版本一致

2. **Build 失敗**
   - 檢查 `pubspec.yaml` 相依性
   - 確認本地可以成功執行 `flutter build web`

3. **網站無法正常顯示**
   - 檢查 `--base-href` 設定是否正確
   - 確認 Repository 名稱與 base-href 一致

4. **GitHub Pages 無法訪問**
   - 確認 Repository 設定為 Public
   - 檢查 GitHub Pages 設定是否啟用

### 本地測試

部署前建議先本地測試：

```bash
# 建構 Web 版本
flutter build web --release

# 使用本地伺服器測試
cd build/web
python -m http.server 8000
# 或使用 Node.js: npx http-server

# 瀏覽器開啟 http://localhost:8000
```

## 安全注意事項

1. **不要提交敏感資訊**
   - API 金鑰
   - 密碼
   - 個人資料

2. **檢查公開內容**
   - 確認所有提交的程式碼都適合公開
   - 移除測試資料和註解

## 進階設定

### 自定義網域

如果有自己的網域：

1. 在 Repository 根目錄建立 `CNAME` 檔案
2. 內容填入你的網域名稱，例如：`calculator.yourdomain.com`
3. 在你的 DNS 設定中添加 CNAME 記錄指向 `YOUR_USERNAME.github.io`

### 環境變數

如需設定環境變數，在 GitHub Repository 的 Settings > Secrets and variables > Actions 中添加。

---

**注意事項：**
- 首次部署可能需要 5-10 分鐘
- GitHub Pages 有流量限制，適合中小型專案使用
- 所有資料都是靜態的，不包含後端伺服器功能