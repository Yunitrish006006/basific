# 設定 Profiles 表格以支援 Display Name 登入

## 問題說明

Supabase Auth 的 `auth.users` 表格由於安全限制（Row Level Security），不能直接從客戶端查詢。要實現使用 display_name 登入，我們需要創建一個公開的 `profiles` 表格。

## 解決方案：創建 Profiles 表格

在你的 Supabase SQL 編輯器中執行以下 SQL：

### 1. 創建 profiles 表格

```sql
-- 創建 profiles 表格
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  display_name TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 設定 RLS (Row Level Security)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 允許所有人讀取 profiles（用於 display_name 查詢）
CREATE POLICY "Profiles are viewable by everyone" 
ON public.profiles FOR SELECT 
USING (true);

-- 只允許用戶更新自己的 profile
CREATE POLICY "Users can update own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- 只允許用戶插入自己的 profile
CREATE POLICY "Users can insert own profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);
```

### 2. 創建觸發器自動同步 profiles

```sql
-- 創建函數來處理新用戶註冊
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'display_name',
    NEW.raw_user_meta_data->>'full_name'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 創建觸發器
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

### 3. 為現有用戶創建 profiles

```sql
-- 為現有的 auth.users 創建 profiles 記錄
INSERT INTO public.profiles (id, email, display_name, full_name)
SELECT 
  id,
  email,
  raw_user_meta_data->>'display_name' as display_name,
  raw_user_meta_data->>'full_name' as full_name
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.profiles);
```

## 使用方式

設定完成後，你的應用程式就可以使用 display_name 登入了：

```dart
// 現在可以用 "yun" 登入
final result = await Basific.loginWithUsernameOrEmail('yun', 'your_password');

// 也可以繼續用 email 登入
final result = await Basific.loginWithUsernameOrEmail('yunitrish049@gmail.com', 'your_password');
```

## 確認設定

執行以上 SQL 後，你可以檢查：

```sql
-- 檢查 profiles 表格
SELECT * FROM public.profiles;

-- 確認你的用戶資料
SELECT id, email, display_name FROM public.profiles WHERE display_name = 'yun';
```

應該會看到：
- id: ed7ad75b-8d80-4646-ad27-a93bb0664aa8
- email: yunitrish049@gmail.com  
- display_name: yun

## 注意事項

1. **唯一性**：display_name 設定為 UNIQUE，確保不會有重複的使用者名稱
2. **安全性**：profiles 表格允許所有人讀取（用於 display_name 查詢），但只允許用戶修改自己的資料
3. **同步**：觸發器會自動為新註冊的用戶創建 profile 記錄
4. **現有用戶**：需要手動為現有用戶創建 profile 記錄

完成這些設定後，你就可以用 "yun" 這個 display_name 來登入了！
