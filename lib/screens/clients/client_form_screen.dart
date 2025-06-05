import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nail_apps/api/api_core.dart';
import 'package:provider/provider.dart';
import '../../api/api_client.dart';
import '../../models/client/client.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;

  const ClientFormScreen({Key? key, this.client}) : super(key: key);

  @override
  _ClientFormScreenState createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  // Маска для телефона
  final phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.client?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.client?.lastName ?? '');
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');

    // Применяем маску к существующему номеру
    if (widget.client?.phone != null) {
      _phoneController.text = phoneMaskFormatter.maskText(widget.client!.phone!);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiCore = Provider.of<ApiCore>(context, listen: false);
      final apiClient = ApiClient(apiCore);

      // Очищаем номер телефона от маски перед сохранением
      String? phone = _phoneController.text.isNotEmpty
          ? _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '')
          : null;

      final client = Client(
        id: widget.client?.id ?? 0,
        userId: widget.client?.userId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text.isNotEmpty ? _lastNameController.text : null,
        phone: phone,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
      );

      if (widget.client == null) {
        await apiClient.createClient(client);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Клиент успешно создан')),
        );
      } else {
        await apiClient.updateClient(client);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Данные клиента обновлены')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Проверка, что номер телефона заполнен полностью
  bool _isPhoneValid(String? value) {
    if (value == null || value.isEmpty) return widget.client != null;
    return value.replaceAll(RegExp(r'[^0-9]'), '').length == 11;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Новый клиент' : 'Редактировать клиента'),
        actions: [
          if (widget.client != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteClient,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'Имя*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Поле обязательно для заполнения';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Фамилия',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Телефон${widget.client == null ? '*' : ''}',
                  border: OutlineInputBorder(),
                  hintText: '+7 (___) ___-__-__',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [phoneMaskFormatter],
                validator: (value) {
                  if (widget.client == null && (value == null || value.isEmpty)) {
                    return 'Поле обязательно для заполнения';
                  }
                  if (value != null && value.isNotEmpty && !_isPhoneValid(value)) {
                    return 'Введите полный номер телефона';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains('@')) {
                    return 'Введите корректный email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    widget.client == null ? 'СОЗДАТЬ КЛИЕНТА' : 'СОХРАНИТЬ ИЗМЕНЕНИЯ',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteClient() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удаление клиента'),
        content: Text('Вы уверены, что хотите удалить этого клиента?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ОТМЕНА'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('УДАЛИТЬ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiCore = Provider.of<ApiCore>(context, listen: false);
      final clientApi = ApiClient(apiCore);
      await clientApi.deleteClient(widget.client!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Клиент удален')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при удалении: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}