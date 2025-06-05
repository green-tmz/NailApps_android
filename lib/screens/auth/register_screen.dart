import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../api/auth_api.dart';
import '../../api/api_core.dart';
import '../../api/specialization_api.dart';
import '../../models/specialization/specialization.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

final _phoneMask = MaskTextInputFormatter(
  mask: '+7 (###) ###-##-##',
  filter: {"#": RegExp(r'[0-9]')},
);

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  List<int> _selectedSpecializations = [];
  List<Specialization> _allSpecializations = [];
  bool _isLoadingSpecializations = false;

  @override
  void initState() {
    super.initState();
    _loadSpecializations();
  }

  Future<void> _loadSpecializations() async {
    setState(() {
      _isLoadingSpecializations = true;
    });

    try {
      final apiCore = Provider.of<ApiCore>(context, listen: false);
      final specializationApi = SpecializationApi(apiCore);
      _allSpecializations = await specializationApi.getSpecializations();
    } catch (e) {
      setState(() {
        _errorMessage = 'Не удалось загрузить специализации';
      });
    } finally {
      setState(() {
        _isLoadingSpecializations = false;
      });
    }
  }

  void _toggleSpecialization(int id) {
    setState(() {
      if (_selectedSpecializations.contains(id)) {
        _selectedSpecializations.remove(id);
      } else {
        _selectedSpecializations.add(id);
      }
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiCore = Provider.of<ApiCore>(context, listen: false);
      final authApi = AuthApi(apiCore);

      await authApi.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        secondName: _secondNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
        specializationIds: _selectedSpecializations,
      );

      // После успешной регистрации можно перенаправить на экран входа
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка регистрации. Проверьте данные и попробуйте снова.';
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
      appBar: AppBar(title: Text('Регистрация')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Имя',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите имя';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Фамилия',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите фамилию';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _secondNameController,
                  decoration: InputDecoration(
                    labelText: 'Отчество',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Введите корректный email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Телефон',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneMask],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите телефон';
                    }
                    if (value.length < 18) { // +7 (999) 999-99-99 = 18 символов
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
                    if (value.length < 6) {
                      return 'Пароль должен быть не менее 6 символов';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordConfirmController,
                  decoration: InputDecoration(
                    labelText: 'Подтверждение пароля',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Подтвердите пароль';
                    }
                    if (value != _passwordController.text) {
                      return 'Пароли не совпадают';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Выберите специализации:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),

                _isLoadingSpecializations
                    ? CircularProgressIndicator()
                    : _allSpecializations.isEmpty
                    ? Text('Нет доступных специализаций')
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3,
                  ),
                  itemCount: _allSpecializations.length,
                  itemBuilder: (context, index) {
                    final spec = _allSpecializations[index];
                    return FilterChip(
                      label: Text(spec.name),
                      selected: _selectedSpecializations.contains(spec.id),
                      onSelected: (selected) => _toggleSpecialization(spec.id),
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: _selectedSpecializations.contains(spec.id)
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedSpecializations.contains(spec.id)
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                ],

                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Зарегистрироваться'),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Уже есть аккаунт? Войти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _secondNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }
}