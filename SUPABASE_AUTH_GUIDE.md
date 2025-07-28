# Basific - Supabase Auth 整合指南

## 概述

Basific 現在使用 Supabase Auth 提供安全的用戶認證系統。這個更新版本利用了 Supabase 的內建認證功能，包括電子郵件驗證、密碼重設、和豐富的用戶資料管理。

## 主要功能

### 用戶模型

新的 `BasificUser` 模型包含以下欄位：

```dart
class BasificUser {
  final String id;                    // Supabase 用戶 ID
  final String email;                 // 電子郵件地址
  final String? displayName;          // 顯示名稱
  final String? name;                 // 全名
  final String? avatarUrl;            // 頭像 URL
  final String? phone;                // 電話號碼
  final DateTime? emailConfirmedAt;   // 電子郵件確認時間
  final DateTime? lastSignInAt;       // 最後登入時間
  final DateTime createdAt;           // 帳戶建立時間
  final Map<String, dynamic>? metadata; // 額外的用戶資料
}
```

### 認證功能

#### 1. 登入
```dart
final result = await BasificAuth.login(
  email: 'user@example.com',
  password: 'password123',
);

if (result.isSuccess) {
  print('登入成功: ${result.user!.bestDisplayName}');
}
```

#### 2. 註冊
```dart
final result = await BasificAuth.register(
  email: 'user@example.com',
  password: 'password123',
  displayName: '使用者名稱',
  fullName: '完整姓名',
  avatarUrl: 'https://example.com/avatar.jpg', // 可選
);
```

#### 3. 登出
```dart
final result = await BasificAuth.logout();
```

#### 4. 密碼重設
```dart
final result = await BasificAuth.resetPassword(
  email: 'user@example.com',
);
```

#### 5. 更新用戶資料
```dart
final result = await BasificAuth.updateUser(
  email: 'newemail@example.com',      // 可選
  password: 'newpassword',            // 可選
  metadata: {                         // 可選
    'display_name': '新的顯示名稱',
    'avatar_url': 'https://example.com/new-avatar.jpg',
  },
);
```

### 即時認證狀態監聽

```dart
BasificAuth.authStateChanges.listen((authState) {
  if (authState.event == AuthChangeEvent.signedIn) {
    print('用戶已登入: ${BasificAuth.currentUser?.bestDisplayName}');
  } else if (authState.event == AuthChangeEvent.signedOut) {
    print('用戶已登出');
  }
});
```

### 實用方法

#### 檢查認證狀態
```dart
if (BasificAuth.isAuthenticated) {
  print('用戶已登入');
}
```

#### 檢查 Session 有效性
```dart
if (BasificAuth.hasValidSession) {
  print('Session 有效');
} else {
  // 需要重新登入
}
```

#### 刷新 Session
```dart
final result = await BasificAuth.refreshSession();
```

## UI 組件

### 登入頁面
```dart
BasificLoginPage(
  title: '應用程式名稱',
  onLoginSuccess: (user) {
    // 處理登入成功
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(currentUser: user),
      ),
    );
  },
)
```

### 註冊頁面
```dart
BasificRegisterPage(
  title: '建立新帳戶',
  onRegisterSuccess: (user) {
    // 處理註冊成功
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(currentUser: user),
      ),
    );
  },
)
```

## 設定 Supabase

1. 在 `main.dart` 中初始化 Supabase：

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basific/basific.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'your-supabase-url',
    anonKey: 'your-supabase-anon-key',
  );
  
  Basific.initialize(
    config: BasificConfig(
      supabase: Supabase.instance.client,
    ),
  );
  
  runApp(MyApp());
}
```

## 安全特性

- **電子郵件驗證**: 新用戶需要驗證電子郵件才能完全啟用帳戶
- **密碼安全**: 密碼使用 bcrypt 加密儲存
- **JWT Token**: 使用 JWT 進行安全的 session 管理
- **自動過期**: Token 會自動過期，增強安全性
- **密碼重設**: 安全的密碼重設流程

## 遷移指南

如果您從舊版本的 Basific 升級：

1. 用戶資料結構已變更：
   - `account` → `email`
   - `name` → `displayName` 和 `name`
   - 新增了更多用戶資料欄位

2. 認證方法已更新：
   - 所有認證操作現在都是 async
   - 使用 Supabase Auth 而非自定義資料表

3. UI 組件已更新：
   - 登入頁面現在使用電子郵件而非帳號名稱
   - 註冊頁面支援更多用戶資料欄位

## 範例應用

查看 `example/` 目錄中的完整範例應用，了解如何整合和使用所有功能。
