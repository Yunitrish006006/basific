# Basific 使用範例

這個文件提供了如何使用 Basific 認證功能的詳細範例。

## 雙重登入方式

Basific 支援兩種登入方式：

### 1. 電子郵件登入
用戶可以使用電子郵件地址登入：

```dart
// 程式化登入
final result = await Basific.login('user@example.com', 'password123');

if (result.isSuccess) {
  print('登入成功！歡迎 ${result.user!.bestDisplayName}');
} else {
  print('登入失敗：${result.error}');
}
```

### 2. 帳號名稱登入
用戶也可以使用帳號名稱登入：

```dart
// 程式化登入
final result = await Basific.loginWithUsernameOrEmail('myusername', 'password123');

if (result.isSuccess) {
  print('登入成功！歡迎 ${result.user!.bestDisplayName}');
} else {
  print('登入失敗：${result.error}');
}
```

### 3. 自動檢測登入方式
使用新的登入頁面，系統會自動檢測使用者輸入的是電子郵件還是帳號名稱：

```dart
// UI 登入頁面
BasificLoginPage(
  title: '登入系統',
  onLoginSuccess: (user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(user: user),
      ),
    );
  },
)
```

## 實作細節

### 檢測邏輯
系統會檢查輸入是否包含 `@` 符號：
- 包含 `@`：當作電子郵件處理
- 不包含 `@`：當作帳號名稱處理

### 帳號名稱查詢流程
1. 檢查輸入格式
2. 如果是帳號名稱，查詢 `account` 表格
3. 取得對應的電子郵件地址
4. 使用電子郵件進行 Supabase 認證

## 資料庫設定

### account 表格結構
```sql
CREATE TABLE account (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  account TEXT UNIQUE NOT NULL,      -- 帳號名稱
  email TEXT UNIQUE NOT NULL,        -- 電子郵件
  password TEXT NOT NULL,            -- 保留相容性
  name TEXT NOT NULL,                -- 顯示名稱
  level TEXT DEFAULT 'user'          -- 用戶等級
);
```

### 插入測試資料
```sql
INSERT INTO account (account, email, name) VALUES 
('admin', 'admin@example.com', '系統管理員'),
('user1', 'user1@example.com', '測試用戶1'),
('user2', 'user2@example.com', '測試用戶2');
```

## 完整範例

### 基本應用程式
```dart
import 'package:flutter/material.dart';
import 'package:basific/basific.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Basific.initialize(
    BasificConfig(
      supabaseUrl: 'YOUR_SUPABASE_URL',
      supabaseAnonKey: 'YOUR_SUPABASE_ANON_KEY',
      accountTableName: 'account',
      columnNames: {
        'id': 'id',
        'account': 'account',
        'email': 'email',
        'password': 'password',
        'name': 'name',
        'level': 'level',
      },
    ),
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basific 範例',
      home: BasificAuthWrapper(
        loginTitle: '請登入',
        authenticatedBuilder: (user) => HomePage(user: user),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final BasificUser user;
  
  const HomePage({Key? key, required this.user}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('歡迎 ${user.bestDisplayName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Basific.logout();
              // AuthWrapper 會自動處理導航回登入頁
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('用戶 ID: ${user.id}'),
            Text('電子郵件: ${user.email}'),
            Text('顯示名稱: ${user.bestDisplayName}'),
          ],
        ),
      ),
    );
  }
}
```

## 錯誤處理

### 常見錯誤
1. **帳號名稱不存在**：`Username not found`
2. **密碼錯誤**：`Invalid login credentials`
3. **網路錯誤**：連接 Supabase 失敗

### 錯誤處理範例
```dart
final result = await Basific.loginWithUsernameOrEmail(username, password);

if (!result.isSuccess) {
  switch (result.error) {
    case 'Username not found':
      showSnackBar('找不到此帳號名稱');
      break;
    case 'Invalid login credentials':
      showSnackBar('密碼錯誤');
      break;
    default:
      showSnackBar('登入失敗：${result.error}');
  }
}
```

## 注意事項

1. **帳號表設定**：確保 `account` 表中的 `email` 欄位與 Supabase Auth 的電子郵件同步
2. **唯一性約束**：帳號名稱和電子郵件都應該設定為唯一
3. **安全性**：`account` 表中的密碼欄位不用於實際認證，實際認證由 Supabase Auth 處理
4. **用戶註冊**：註冊新用戶時需要同時在 Auth 和 account 表中創建記錄
