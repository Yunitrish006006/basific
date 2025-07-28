import 'package:flutter/material.dart';
import 'package:basific/basific.dart';

class DatabaseDiagnosticPage extends StatefulWidget {
  const DatabaseDiagnosticPage({super.key});

  @override
  State<DatabaseDiagnosticPage> createState() => _DatabaseDiagnosticPageState();
}

class _DatabaseDiagnosticPageState extends State<DatabaseDiagnosticPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _diagnosticResults = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _diagnosticResults = [];
    });

    try {
      // 檢查連接
      final connectionResult = await _checkConnection();
      _diagnosticResults.add(connectionResult);

      // 檢查 profiles 表格
      final tableResult = await _checkProfilesTable();
      _diagnosticResults.add(tableResult);

      // 檢查用戶數據
      final userCountResult = await _checkUserCount();
      _diagnosticResults.add(userCountResult);

      // 檢查當前用戶
      final currentUserResult = _checkCurrentUser();
      _diagnosticResults.add(currentUserResult);

    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _checkConnection() async {
    try {
      final client = Basific.supabase;
      await client.from('profiles').select('count').limit(1);
      return {
        'check': '資料庫連接',
        'status': 'OK',
        'message': '成功連接到 Supabase',
        'icon': Icons.check_circle,
        'color': Colors.green,
      };
    } catch (e) {
      return {
        'check': '資料庫連接',
        'status': 'ERROR',
        'message': '連接失敗: $e',
        'icon': Icons.error,
        'color': Colors.red,
      };
    }
  }

  Future<Map<String, dynamic>> _checkProfilesTable() async {
    try {
      final client = Basific.supabase;
      await client.from('profiles').select('*').limit(1);
      
      return {
        'check': 'Profiles 表格',
        'status': 'OK',
        'message': 'Profiles 表格存在且可訪問',
        'icon': Icons.table_chart,
        'color': Colors.green,
      };
    } catch (e) {
      return {
        'check': 'Profiles 表格',
        'status': 'ERROR',
        'message': '無法訪問 profiles 表格: $e',
        'icon': Icons.error,
        'color': Colors.red,
      };
    }
  }

  Future<Map<String, dynamic>> _checkUserCount() async {
    try {
      final client = Basific.supabase;
      final response = await client.from('profiles').select('id').count();
      final count = response.count;
      
      return {
        'check': '用戶數量',
        'status': 'INFO',
        'message': '資料庫中共有 $count 個用戶',
        'icon': Icons.people,
        'color': Colors.blue,
      };
    } catch (e) {
      return {
        'check': '用戶數量',
        'status': 'ERROR',
        'message': '無法獲取用戶數量: $e',
        'icon': Icons.error,
        'color': Colors.red,
      };
    }
  }

  Map<String, dynamic> _checkCurrentUser() {
    final user = Basific.currentUser;
    if (user != null) {
      return {
        'check': '當前用戶',
        'status': 'OK',
        'message': '已登入: ${user.email}\\n顯示名稱: ${user.bestDisplayName}',
        'icon': Icons.person,
        'color': Colors.green,
      };
    } else {
      return {
        'check': '當前用戶',
        'status': 'WARNING',
        'message': '未登入用戶',
        'icon': Icons.person_off,
        'color': Colors.orange,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('資料庫診斷'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _runDiagnostics,
            icon: const Icon(Icons.refresh),
            tooltip: '重新檢查',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '系統診斷結果',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在進行診斷檢查...'),
                  ],
                ),
              )
            else if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            '診斷錯誤',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_error!),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _diagnosticResults.length,
                  itemBuilder: (context, index) {
                    final result = _diagnosticResults[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          result['icon'],
                          color: result['color'],
                          size: 32,
                        ),
                        title: Text(
                          result['check'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(result['message']),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: result['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            result['status'],
                            style: TextStyle(
                              color: result['color'],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _runDiagnostics,
                icon: const Icon(Icons.refresh),
                label: const Text('重新檢查'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
