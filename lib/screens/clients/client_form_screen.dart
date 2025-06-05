import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.client?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.client?.lastName ?? '');
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
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
      final apiCore = Provider.of<ApiClient>(context, listen: false);
      final clientApi = ApiClient(apiCore as ApiCore);

      final client = Client(
        id: widget.client?.id ?? 0,
        userId: widget.client?.userId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text.isNotEmpty ? _lastNameController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
      );

      if (widget.client == null) {
        await clientApi.createClient(client);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Клиент успешно создан')),
        );
      } else {
        await clientApi.updateClient(client);
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
                  labelText: 'Телефон',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
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
      final apiCore = Provider.of<ApiClient>(context, listen: false);
      final clientApi = ApiClient(apiCore as ApiCore);
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