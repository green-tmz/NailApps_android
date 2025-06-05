import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/auth_api.dart';
import '../api/api_client.dart';
// import 'auth/login_screen.dart';
import 'clients/clients_screen.dart';
// import 'masters/masters_screen.dart';
// import 'specializations/specializations_screen.dart';
// import 'services/services_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final authApi = AuthApi(apiClient);
      final userData = await authApi.getMe();
      
      setState(() {
        _userName = '${userData['first_name']} ${userData['last_name']}';
        _isLoading = false;
      });
    } catch (e) {
      // Если не удалось загрузить данные пользователя, перенаправляем на экран входа
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _logout() async {
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final authApi = AuthApi(apiClient);
      await authApi.logout();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выходе: ${e.toString()}')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return ClientsScreen();
      // case 1:
      //   return MastersScreen();
      // case 2:
      //   return SpecializationsScreen();
      // case 3:
      //   return ServicesScreen();
      default:
        return Center(child: Text('Неизвестный раздел'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NailApps'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'NailApps Admin',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Клиенты'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.face),
              title: Text('Мастера'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Специализации'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.spa),
              title: Text('Услуги'),
              selected: _selectedIndex == 3,
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Клиенты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'Мастера',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Специализации',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.spa),
            label: 'Услуги',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}