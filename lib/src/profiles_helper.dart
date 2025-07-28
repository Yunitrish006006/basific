import 'config.dart';

/// Helper class for setting up and managing the profiles table
class BasificProfilesHelper {
  /// Generate SQL script to create the profiles table
  static String generateCreateTableSQL({
    String? tableName,
    String? usernameColumn,
    String? emailColumn,
  }) {
    final config = Basific.config;
    final table = tableName ?? config.profilesTableName;
    final username = usernameColumn ?? config.usernameColumn;
    final email = emailColumn ?? config.emailColumn;
    
    return '''
-- 創建 $table 表格以支援使用者名稱登入
CREATE TABLE public.$table (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  $email TEXT UNIQUE NOT NULL,
  $username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 設定 RLS (Row Level Security)
ALTER TABLE public.$table ENABLE ROW LEVEL SECURITY;

-- 允許所有人讀取 profiles（用於 $username 查詢）
CREATE POLICY "Profiles are viewable by everyone" 
ON public.$table FOR SELECT 
USING (true);

-- 只允許用戶更新自己的 profile
CREATE POLICY "Users can update own profile" 
ON public.$table FOR UPDATE 
USING (auth.uid() = id);

-- 只允許用戶插入自己的 profile
CREATE POLICY "Users can insert own profile" 
ON public.$table FOR INSERT 
WITH CHECK (auth.uid() = id);

-- 創建函數來處理新用戶註冊
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS \$\$
BEGIN
  INSERT INTO public.$table (id, $email, $username, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'$username',
    NEW.raw_user_meta_data->>'full_name'
  );
  RETURN NEW;
END;
\$\$ LANGUAGE plpgsql SECURITY DEFINER;

-- 創建觸發器
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 為現有的 auth.users 創建 profiles 記錄
INSERT INTO public.$table (id, $email, $username, full_name)
SELECT 
  id,
  email,
  raw_user_meta_data->>'$username' as $username,
  raw_user_meta_data->>'full_name' as full_name
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.$table);
''';
  }

  /// Generate SQL script to check if the table is set up correctly
  static String generateCheckTableSQL({
    String? tableName,
    String? usernameColumn,
    String? emailColumn,
  }) {
    final config = Basific.config;
    final table = tableName ?? config.profilesTableName;
    final username = usernameColumn ?? config.usernameColumn;
    final email = emailColumn ?? config.emailColumn;
    
    return '''
-- 檢查 $table 表格設定
SELECT 
  'Table exists' as check_type,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = '$table'
  ) THEN 'OK' ELSE 'MISSING' END as status

UNION ALL

SELECT 
  'Required columns' as check_type,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = '$table'
    AND column_name IN ('id', '$email', '$username')
  ) THEN 'OK' ELSE 'MISSING' END as status

UNION ALL

SELECT 
  'RLS enabled' as check_type,
  CASE WHEN EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relname = '$table' AND c.relrowsecurity = true
  ) THEN 'OK' ELSE 'DISABLED' END as status;

-- 檢查現有 profiles 資料
SELECT COUNT(*) as total_profiles FROM public.$table;

-- 顯示範例資料
SELECT id, $email, $username, full_name 
FROM public.$table 
LIMIT 5;
''';
  }

  /// Get setup instructions as markdown
  static String getSetupInstructions() {
    final config = Basific.config;
    return '''
# 設定 ${config.profilesTableName} 表格以支援使用者名稱登入

## 步驟 1: 建立資料表

在您的 Supabase SQL 編輯器中執行以下 SQL 指令：

```sql
${generateCreateTableSQL()}
```

## 步驟 2: 驗證設定

執行以下 SQL 來檢查設定是否正確：

```sql
${generateCheckTableSQL()}
```

## 步驟 3: 測試登入

設定完成後，您可以使用使用者名稱登入：

```dart
// 使用使用者名稱登入
final result = await BasificAuth.loginWithUsernameOrEmail(
  usernameOrEmail: 'your_username',
  password: 'your_password',
);

// 也可以繼續使用 email 登入
final result = await BasificAuth.loginWithUsernameOrEmail(
  usernameOrEmail: 'your_email@example.com',
  password: 'your_password',
);
```

## 故障排除

如果遇到問題，可以使用以下方法檢查：

```dart
// 檢查 profiles 表格是否正確設定
final isSetup = await BasificAuth.checkProfilesTableSetup();
if (!isSetup) {
  print(BasificAuth.getProfilesSetupInstructions());
}
```

## 配置選項

您可以在 BasificConfig 中自訂表格和欄位名稱：

```dart
await Basific.initialize(
  BasificConfig(
    supabaseUrl: 'your_url',
    supabaseAnonKey: 'your_key',
    profilesTableName: 'user_profiles',  // 自訂表格名稱
    usernameColumn: 'username',          // 自訂使用者名稱欄位
    emailColumn: 'email_address',        // 自訂 email 欄位
    enableUsernameLogin: true,           // 啟用使用者名稱登入
  ),
);
```
''';
  }
}
