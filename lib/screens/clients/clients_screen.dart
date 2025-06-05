import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nail_apps/api/api_client.dart';
import 'package:nail_apps/models/client/client.dart';
import '../../api/api_core.dart';
import 'client_form_screen.dart';

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  late Future<List<Client>> _clientsFuture;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiCore = Provider.of<ApiCore>(context, listen: false);
      final apiClient = ApiClient(apiCore);
      _clientsFuture = apiClient.getClients();
      await _clientsFuture;
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки клиентов: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAndDeleteClient(int clientId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удаление клиента'),
        content: Text('Вы уверены, что хотите удалить этого клиента?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteClient(clientId);
    }
  }

  Future<void> _deleteClient(int clientId) async {
    try {
      final apiCore = Provider.of<ApiCore>(context, listen: false);
      final apiClient = ApiClient(apiCore);

      await apiClient.deleteClient(clientId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Клиент успешно удалён')),
      );
      _loadClients();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления клиента: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Клиенты'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadClients,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClientFormScreen()),
          );
          _loadClients();
        },
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : RefreshIndicator(
        onRefresh: _loadClients,
        child: FutureBuilder<List<Client>>(
          future: _clientsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Ошибка: ${snapshot.error.toString()}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Нет клиентов'));
            }

            final clients = snapshot.data!;
            return ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Dismissible(
                  key: Key(client.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                     await _confirmAndDeleteClient(client.id);
                  },
                  onDismissed: (direction) => _deleteClient(client.id),
                  child: ListTile(
                    title: Text(
                        '${client.firstName} ${client.lastName ?? ''}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (client.phone != null)
                          Text('Телефон: ${client.phone}'),
                        if (client.email != null)
                          Text('Email: ${client.email}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmAndDeleteClient(client.id),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ClientFormScreen(client: client),
                        ),
                      );
                      _loadClients();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}