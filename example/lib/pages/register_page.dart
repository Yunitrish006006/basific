import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _selectedLevel = 'user';

  final List<String> _levels = ['user', 'admin'];

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 檢查帳號是否已存在
      final existingUser = await Supabase.instance.client
          .from('account')
          .select()
          .eq('account', _accountController.text)
          .maybeSingle();

      if (existingUser != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('此帳號已存在'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 創建新帳號
      await Supabase.instance.client.from('account').insert({
        'account': _accountController.text,
        'password': _passwordController.text,
        'name': _nameController.text,
        'level': _selectedLevel,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('註冊成功！請返回登入')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('註冊失敗：$error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('註冊'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.person_add,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '創建新帳號',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // 帳號輸入框
                  TextFormField(
                    controller: _accountController,
                    decoration: const InputDecoration(
                      labelText: '帳號',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      helperText: '用於登入的帳號名稱',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入帳號';
                      }
                      if (value.length < 3) {
                        return '帳號至少需要3個字元';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 姓名輸入框
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '姓名',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                      helperText: '顯示用的姓名',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入姓名';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 權限等級選擇
                  DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    decoration: const InputDecoration(
                      labelText: '權限等級',
                      prefixIcon: Icon(Icons.security),
                      border: OutlineInputBorder(),
                    ),
                    items: _levels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(level == 'user' ? '一般使用者' : '管理員'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLevel = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 密碼輸入框
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: '密碼',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      helperText: '至少6個字元',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入密碼';
                      }
                      if (value.length < 6) {
                        return '密碼至少需要6個字元';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 確認密碼輸入框
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: '確認密碼',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請確認密碼';
                      }
                      if (value != _passwordController.text) {
                        return '密碼不一致';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // 註冊按鈕
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              '註冊',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
