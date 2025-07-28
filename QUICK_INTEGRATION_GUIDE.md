# Basific 快速整合指南

## 簡化的整合方式

使用新的 `BasificAuthWrapper`，您可以用最少的代碼實現完整的認證功能：

### 1. 基本設置

在 `main.dart` 中：

```dart
import 'package:flutter/material.dart';
import 'package:basific/basific.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Basific
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
  
  runApp(const MyApp());
}
```

### 2. 應用程式結構

在 `app.dart` 中：

```dart
import 'package:flutter/material.dart';
import 'package:basific/basific.dart';
import 'home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BasificAuthWrapper(
        loginTitle: 'My App Login',
        authenticatedBuilder: (user) => HomePage(currentUser: user),
      ),
    );
  }
}
```

### 3. 主頁面

在 `home_page.dart` 中：

```dart
import 'package:flutter/material.dart';
import 'package:basific/basific.dart';

class HomePage extends StatelessWidget {
  final BasificUser currentUser;
  
  const HomePage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
        actions: [
          IconButton(
            onPressed: () => BasificAuthHelper.logoutAndNavigate(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('歡迎，${currentUser.bestDisplayName}!'),
            Text('電子郵件：${currentUser.email}'),
          ],
        ),
      ),
    );
  }
}
```

## 進階功能

### 1. 自訂登入頁面

```dart
BasificAuthWrapper(
  unauthenticatedWidget: CustomLoginPage(),
  authenticatedBuilder: (user) => HomePage(currentUser: user),
)
```

### 2. 認證守衛

對於需要認證的特定頁面：

```dart
BasificAuthGuard(
  child: ProtectedPage(),
  loginTitle: 'Please Login',
)
```

### 3. 登入對話框

在任何地方顯示登入對話框：

```dart
final user = await BasificAuthHelper.showLoginDialog(context);
if (user != null) {
  // 登入成功
}
```

### 4. 註冊對話框

```dart
final user = await BasificAuthHelper.showRegisterDialog(context);
if (user != null) {
  // 註冊成功
}
```

### 5. 直接認證操作

```dart
// 登入
final result = await Basific.login('email@example.com', 'password');

// 註冊
final result = await Basific.register(
  email: 'email@example.com',
  password: 'password',
  displayName: 'User Name',
);

// 登出
await Basific.logout();

// 密碼重設
await Basific.resetPassword('email@example.com');
```

### 6. 監聽認證狀態

```dart
BasificAuth.authStateChanges.listen((authState) {
  if (authState.event == AuthChangeEvent.signedIn) {
    print('用戶已登入');
  } else if (authState.event == AuthChangeEvent.signedOut) {
    print('用戶已登出');
  }
});
```

## 關鍵特色

- **自動狀態管理**：`BasificAuthWrapper` 自動處理認證狀態變化
- **零配置登入頁面**：內建美觀的登入和註冊介面
- **便利方法**：`BasificAuthHelper` 提供常用操作的簡化方法
- **靈活定制**：可以自訂所有 UI 組件
- **Supabase 整合**：完全利用 Supabase Auth 的所有功能

## 最小實現

最少只需要 3 個文件即可實現完整的認證系統：

1. `main.dart` - 初始化配置
2. `app.dart` - 使用 `BasificAuthWrapper`
3. `home_page.dart` - 認證後的主頁面

這就是全部！Basific 會處理其餘的一切。
