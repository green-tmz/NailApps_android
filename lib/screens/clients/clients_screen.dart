import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/api_client.dart';
import '../../models/client/client.dart';
import 'client_form_screen.dart';

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  late Future<List<Client>> _clientsFuture;
  late final ApiClient _clientApi;

  @override
  void initState() {
    super.initState();
    _clientApi = Provider.of<ApiClient>(context, listen: false);
    _clientsFuture = _clientApi.getClients();
  }

  Future<void> _refreshClients() async {
    setState(() {
      _clientsFuture = _clientApi.getClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClientFormScreen()),
          );
          _refreshClients();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshClients,
        child: FutureBuilder<List<Client>>(
          future: _clientsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Ошибка загрузки клиентов'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Нет клиентов'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final client = snapshot.data![index];
                return ListTile(
                  title: Text('${client.firstName} ${client.lastName ?? ''}'),
                  subtitle: Text(client.phone ?? client.email ?? ''),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientFormScreen(client: client),
                      ),
                    );
                    _refreshClients();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}