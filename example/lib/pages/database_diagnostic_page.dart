import 'package:flutter/material.dart';
import 'package:basific/basific.dart';

/// 診斷工具：檢查 account 表格結構
class DatabaseDiagnosticPage extends StatefulWidget {
  const DatabaseDiagnosticPage({super.key});

  @override
  State<DatabaseDiagnosticPage> createState() => _DatabaseDiagnosticPageState();
}

class _DatabaseDiagnosticPageState extends State<DatabaseDiagnosticPage> {
  String _result = '';
  bool _isLoading = false;

  Future<void> _checkTableStructure() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final config = Basific.config;
      StringBuffer result = StringBuffer();
      
      // 檢查 profiles 表格
      try {
        final profilesResponse = await Basific.supabase
            .from('profiles')
            .select('*')
            .limit(1);

        if (profilesResponse.isNotEmpty) {
          final firstRow = profilesResponse.first;
          final columns = firstRow.keys.toList();
          
          result.writeln('✅ profiles 表格存在');
          result.writeln('可用欄位: ${columns.join(', ')}');
          result.writeln('');
          result.writeln('檢查結果:');
          result.writeln('${columns.contains('email') ? '✅' : '❌'} email 欄位');
          result.writeln('${columns.contains('display_name') ? '✅' : '❌'} display_name 欄位');
          result.writeln('');
          
          // 檢查是否有 yun 這個用戶
          try {
            final yunResponse = await Basific.supabase
                .from('profiles')
                .select('email, display_name')
                .eq('display_name', 'yun')
                .maybeSingle();
            
            if (yunResponse != null) {
              result.writeln('✅ 找到 display_name="yun" 的用戶');
              result.writeln('Email: ${yunResponse['email']}');
            } else {
              result.writeln('❌ 找不到 display_name="yun" 的用戶');
            }
          } catch (e) {
            result.writeln('⚠️  查詢用戶時出錯: $e');
          }
        } else {
          result.writeln('⚠️  profiles 表格是空的');
        }
      } catch (e) {
        result.writeln('❌ profiles 表格不存在或無法訪問');
        result.writeln('錯誤: $e');
        result.writeln('');
        result.writeln('請參考 PROFILES_SETUP.md 來設定 profiles 表格');
      }
      
      result.writeln('');
      result.writeln('--- 嘗試檢查原始 account 表格 ---');
      
      // 檢查原始的 account 表格
      try {
        final accountResponse = await Basific.supabase
            .from(config.accountTableName)
            .select('*')
            .limit(1);

        if (accountResponse.isNotEmpty) {
          final firstRow = accountResponse.first;
          final columns = firstRow.keys.toList();
          
          result.writeln('✅ ${config.accountTableName} 表格存在');
          result.writeln('可用欄位: ${columns.join(', ')}');
          result.writeln('');
          result.writeln('配置的欄位映射:');
          config.columnNames.entries.forEach((e) {
            result.writeln('${e.key}: ${e.value}');
          });
        } else {
          result.writeln('⚠️  ${config.accountTableName} 表格是空的');
        }
      } catch (e) {
        result.writeln('❌ ${config.accountTableName} 表格不存在或無法訪問');
        result.writeln('錯誤: $e');
      }

      setState(() {
        _result = result.toString();
      });
    } catch (error) {
      setState(() {
        _result = '診斷過程中發生錯誤: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('資料庫診斷'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _checkTableStructure,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('檢查表格結構'),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
