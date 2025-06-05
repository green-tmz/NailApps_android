import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/auth_api.dart';
import '../../api/api_core.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

final _phoneMask = MaskTextInputFormatter(
  mask: '+7 (###) ###-##-##',
  filter: {"#": RegExp(r'[0-9]')},
);
final _emailMask = MaskTextInputFormatter(
  filter: {"@": RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')},
);

bool _isEmailField = true;

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final apiCore = Provider.of<ApiCore>(context, listen: false);
      final authApi = AuthApi(apiCore);

      await authApi.login(
        login: _loginController.text,
        password: _passwordController.text,
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка входа. Проверьте данные и попробуйте снова.';
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Вход в систему',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _loginController,
                      decoration: InputDecoration(
                        labelText: _isEmailField ? 'Email' : 'Телефон',
                        prefixIcon: Icon(_isEmailField ? Icons.email : Icons.phone),
                        suffixIcon: IconButton(
                          icon: Icon(_isEmailField ? Icons.phone : Icons.email),
                          onPressed: () {
                            setState(() {
                              _isEmailField = !_isEmailField;
                              _loginController.clear();
                            });
                          },
                        ),
                      ),
                      keyboardType: _isEmailField ? TextInputType.emailAddress : TextInputType.phone,
                      inputFormatters: [
                        _isEmailField ? _emailMask : _phoneMask,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _isEmailField ? 'Введите email' : 'Введите телефон';
                        }
                        if (_isEmailField && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Введите корректный email';
                        }
                        if (!_isEmailField && value.length < 18) { // +7 (999) 999-99-99 = 18 символов
                          return 'Введите полный номер телефона';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                    SizedBox(height: 24),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Войти'),
                    ),
                    SizedBox(height: 16), // Добавлен отступ
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'Нет аккаунта? Зарегистрироваться',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}