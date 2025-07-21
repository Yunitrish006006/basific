# Basific

一個簡單的 Flutter package，提供基本的計算功能。

## 功能

- 簡單的數字加一計算器
- 輕量級且易於使用
- 完整的測試覆蓋

## 開始使用

在您的 `pubspec.yaml` 中新增依賴：

```yaml
dependencies:
  basific: ^0.0.1
```

然後運行：

```bash
flutter pub get
```

## 使用方法

```dart
import 'package:basific/basific.dart';

void main() {
  final calculator = Calculator();
  
  print(calculator.addOne(5)); // 輸出: 6
  print(calculator.addOne(-3)); // 輸出: -2
  print(calculator.addOne(0)); // 輸出: 1
}
```

## 範例應用程式

查看 `/example` 資料夾中的完整 Flutter 應用程式範例，展示如何在實際應用中使用此 package。

要運行範例：

```bash
cd example
flutter pub get
flutter run
```

## 測試

運行測試：

```bash
flutter test
```

## 額外資訊

這個 package 是一個簡單的範例，展示如何創建和發布 Flutter packages。
