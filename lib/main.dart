import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'equipamentos_screen.dart';
import 'pecas_screen.dart';
import 'furos_screen.dart';
import 'funcionarios_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplicativo de Navegação',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder(
          future: _authService.isAuthenticated(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data == true) {
              return HomeScreen();
            } else {
              return LoginPage();
            }
          },
        ),
        '/home': (context) => HomeScreen(),
        '/equipamentos': (context) => EquipamentosScreen(),
        '/pecas': (context) => PecasScreen(),
        '/furos': (context) => FurosScreen(),
        '/funcionarios': (context) => FuncionariosScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF303972),
      appBar: AppBar(
        title: Text('Tela Principal'),
        backgroundColor: Color(0xFF303972),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildExpandedButton(context, 'Equipamentos', 'assets/Images/equipamentos.png', EquipamentosScreen()),
          _buildExpandedButton(context, 'Peças', 'assets/Images/pecas-de-reposicao.png', PecasScreen()),
          _buildExpandedButton(context, 'Furos', 'assets/Images/furar.png', FurosScreen()),
          _buildExpandedButton(context, 'Funcionários', 'assets/Images/funcionarios.png', FuncionariosScreen()),
        ],
      ),
    );
  }

  Widget _buildExpandedButton(BuildContext context, String title, String imagePath, Widget nextScreen) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
          );
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                title,
                style: TextStyle(fontSize: 36, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
