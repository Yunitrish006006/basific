# Basific Example App

這是一個展示 `basific` package 功能的 Flutter 應用程式範例。

## 專案結構

```
lib/
├── main.dart                    # 應用程式入口點
├── app.dart                     # 主應用程式配置
├── pages/
│   └── home_page.dart          # 主頁面
└── widgets/
    ├── calculator_card.dart    # 計算器顯示卡片
    └── control_buttons.dart    # 控制按鈕
```

## 功能

這個範例應用程式展示了：
- 如何使用 `Calculator` 類別
- 基本的 Flutter UI 組件
- 狀態管理
- Material Design 3 主題
- 模組化的程式碼結構

## 檔案說明

### `main.dart`
應用程式的入口點，只包含 `main()` 函數，保持簡潔。

### `app.dart`
包含 `MyApp` 類別，負責應用程式的主要配置，如主題和路由。

### `pages/home_page.dart`
包含 `MyHomePage` 類別，是應用程式的主頁面，管理狀態和業務邏輯。

### `widgets/calculator_card.dart`
可重用的 widget，顯示當前數字和計算結果。

### `widgets/control_buttons.dart`
可重用的 widget，包含控制按鈕（加、減、重設）。

## 如何運行

1. 確保您已經安裝了 Flutter SDK
2. 在終端中導航到 `example` 資料夾：
   ```bash
   cd example
   ```
3. 獲取依賴項：
   ```bash
   flutter pub get
   ```
4. 運行應用程式：
   ```bash
   flutter run
   ```

## 應用程式功能

- **數字顯示**：顯示當前數字和加一後的結果
- **加號按鈕**：增加當前數字
- **減號按鈕**：減少當前數字  
- **重設按鈕**：將數字重設為 0
- **浮動操作按鈕**：快速加一

## 模組化優勢

將程式碼分解為多個檔案帶來以下優勢：
- **可維護性**：每個檔案職責單一，更容易維護
- **可重用性**：widgets 可以在其他地方重用
- **可讀性**：程式碼結構更清晰
- **協作性**：多人開發時減少衝突

這個範例展示了如何將 `basific` package 整合到實際的 Flutter 應用程式中，並遵循良好的程式碼組織原則。
