# Supabase Auth 遷移指南

## 變更概述

Basific 套件已更新為使用 Supabase 的官方 Auth 服務，而不是自定義的資料表認證系統。

## 主要變更

### 1. 用戶模型更新

**舊的 BasificUser 模型：**
```dart
class BasificUser {
  final String id;
  final String account;
  final String name;
  final String level;
}
```

**新的 BasificUser 模型：**
```dart
class BasificUser {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final Map<String, dynamic>? metadata;
}
```

### 2. 認證方法更新

**登入：**
```dart
// 舊方式
BasificAuth.login(
  account: 'username',
  password: 'password',
);

// 新方式
BasificAuth.login(
  email: 'user@example.com',
  password: 'password',
);
```

**註冊：**
```dart
// 舊方式
BasificAuth.register(
  account: 'username',
  password: 'password',
  name: 'Display Name',
  level: 'user',
);

// 新方式
BasificAuth.register(
  email: 'user@example.com',
  password: 'password',
  name: 'Display Name',
);
```

**登出：**
```dart
// 舊方式
BasificAuth.logout(); // 同步

// 新方式
await BasificAuth.logout(); // 異步
```

### 3. 新功能

- **密碼重設：**
```dart
await BasificAuth.resetPassword(email: 'user@example.com');
```

- **用戶信息更新：**
```dart
await BasificAuth.updateUser(
  email: 'newemail@example.com',
  password: 'newpassword',
  metadata: {'name': 'New Name'},
);
```

- **認證狀態監聽：**
```dart
BasificAuth.authStateChanges.listen((authState) {
  // 處理認證狀態變更
});
```

- **會話管理：**
```dart
bool isValid = BasificAuth.hasValidSession;
await BasificAuth.refreshSession();
```

## Supabase 配置

確保您的 Supabase 項目已啟用 Auth 服務：

1. 在 Supabase 儀表板中，前往 "Authentication" → "Settings"
2. 確保已啟用電子郵件認證
3. 配置適當的安全策略

## 遷移步驟

1. **更新代碼：** 將所有 `account` 參數改為 `email`
2. **處理可選名稱：** 用戶名稱現在是可選的，使用 `user.name ?? user.email` 作為顯示名稱
3. **更新登出調用：** 確保 `logout()` 調用使用 `await`
4. **移除自定義用戶表：** 不再需要自定義的 `account` 資料表
5. **利用新功能：** 考慮使用密碼重設和認證狀態監聽等新功能

## 暫時禁用的功能

- **BasificUserManager：** 由於 Supabase Auth 的用戶管理模式不同，此組件已暫時禁用，正在重新設計中

## 範例

查看 `example/` 目錄中的更新範例，了解如何使用新的 Supabase Auth 系統。
