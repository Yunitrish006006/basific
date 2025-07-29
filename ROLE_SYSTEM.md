# Basific 角色系統說明

## 概述
Basific 現在支援用戶角色系統，包含 `admin` 和 `user` 兩種角色。

## 新增功能

### 1. 資料庫結構
- `profiles` 表格新增 `role` 欄位
- 支援 `admin` 和 `user` 兩種角色
- 新用戶默認為 `user` 角色

### 2. User 擴展方法
```dart
final user = Basific.currentUser;

// 獲取用戶角色
print(user?.role);  // 'admin' 或 'user'

// 檢查是否為管理員
if (user?.isAdmin == true) {
  // 管理員專用功能
}

// 檢查是否為一般用戶
if (user?.isUser == true) {
  // 一般用戶功能
}
```

### 3. 註冊時指定角色
```dart
// 註冊管理員
final result = await Basific.register(
  email: 'admin@example.com',
  password: 'password123',
  displayName: 'Administrator',
  role: 'admin',
);

// 註冊一般用戶（默認）
final result = await Basific.register(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'Regular User',
  // role: 'user', // 可省略，默認為 'user'
);
```

### 4. UI 中的角色顯示
- 首頁會顯示用戶角色標籤
- 管理員可以看到特殊的用戶管理功能
- 資料庫診斷頁面會顯示當前用戶角色

## 設定步驟

### 新專案
對於新專案，直接使用 `BasificProfilesHelper.generateCreateTableSQL()` 即可，已包含角色欄位。

### 現有專案遷移
對於已存在的 profiles 表格，需要執行遷移 SQL：

```sql
-- 在 profiles_setup_page.dart 中可以複製此 SQL
-- 或使用 BasificProfilesHelper.generateAddRoleColumnSQL()
```

### 手動設定管理員
如果需要將現有用戶設為管理員：

```sql
UPDATE profiles 
SET role = 'admin' 
WHERE email = 'your-admin@example.com';
```

## 安全考量
- 角色檢查基於 user_metadata，需要確保 RLS 政策適當設定
- 敏感的管理功能應該在後端再次驗證用戶權限
- 建議定期審查管理員權限

## 範例應用
在範例應用中可以看到：
- 角色標籤顯示
- 基於角色的功能顯示/隱藏
- 角色遷移 SQL 生成器
