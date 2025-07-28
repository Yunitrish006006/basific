# Basific Example

這是 Basific 包的示例應用程式，展示了如何使用 Basific 進行用戶認證和管理。

## 功能

- � 自動認證管理（使用 BasificAuthWrapper）
- �📱 內建登入/註冊頁面
- 👤 Supabase Auth 整合
- 👥 用戶管理
- 🎨 可自訂主題

## 專案結構

```
lib/
├── main.dart                    # 應用程式入口點，初始化 Basific
├── app.dart                     # 主應用程式配置（使用 BasificAuthWrapper）
├── pages/
│   ├── home_page.dart          # 主頁面（認證後顯示）
│   └── users_page.dart         # 用戶管理頁面
└── widgets/
    ├── calculator_card.dart    # 計算器顯示卡片
    └── control_buttons.dart    # 控制按鈕
```

## 新的簡化架構

現在使用 `BasificAuthWrapper` 自動處理認證流程：

- 🎯 **零配置認證** - 無需手動處理登入/登出導航
- 🔄 **自動狀態管理** - 認證狀態變化自動更新 UI
- 📱 **內建 UI** - 使用 Basific 提供的登入/註冊頁面
- 🛡️ **Supabase 安全** - 企業級認證安全性

## 運行方式

1. 確保已安裝 Flutter 開發環境
2. 複製專案到本地
3. 安裝依賴項：
   ```bash
   flutter pub get
   ```
4. 運行應用程式：
   ```bash
   flutter run
   ```

## 配置

在 `main.dart` 中，應用程式已配置了 Basific：

```dart
await Basific.initialize(
  BasificConfig(
    supabaseUrl: 'your-supabase-url',
    supabaseAnonKey: 'your-supabase-anon-key',
    theme: BasificTheme(
      primaryColor: Colors.deepPurple,
      borderRadius: 8.0,
    ),
  ),
);
```

## 使用的組件

### 登入頁面
```dart
BasificLoginPage(
  title: 'Basific Calculator Demo',
  onLoginSuccess: (user) {
    // 處理登入成功
  },
)
```

### 註冊頁面
```dart
BasificRegisterPage(
  title: 'Basific 註冊',
  onRegisterSuccess: (user) {
    // 處理註冊成功
  },
)
```

### 用戶管理
```dart
const BasificUserManager(
  title: '用戶管理',
)
```

## 數據庫結構

應用程式需要一個名為 `account` 的 Supabase 表格，包含以下欄位：

- `id` (UUID, 主鍵)
- `account` (文字, 用戶帳號)
- `password` (文字, 密碼)
- `name` (文字, 用戶名稱)
- `level` (文字, 用戶等級)

## 更多資訊

詳細的 API 文檔和配置選項，請參考 [Basific 包文檔](https://pub.dev/packages/basific)。
