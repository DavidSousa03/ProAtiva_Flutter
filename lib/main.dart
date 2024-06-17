import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'equipamentos_screen.dart';
import 'pecas_screen.dart';
import 'furos_screen.dart';
import 'funcionarios_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicativo de Navegação',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomeScreen(),
        '/equipamentos': (context) => EquipamentosScreen(),
        '/pecas': (context) => PecasScreen(),
        '/furos': (context) => FurosScreen(),
        '/funcionarios': (context) => FuncionariosScreen(),
        '/logout': (context) => LogoutScreen(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Color(0xFF303972),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/Images/logo.png'),
                    TextField(
                      controller: _userController,
                      decoration: InputDecoration(
                        hintText: 'Usuário',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        _userController.value = _userController.value.copyWith(
                          text: text.toLowerCase(),
                          selection: TextSelection.fromPosition(
                            TextPosition(offset: text.length),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: Color(0xFF148CCC),
                        child: const Text(
                          "Acessar",
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          String usuario = _userController.text;
                          String senha = _passwordController.text;
                          if (usuario == 'adm.proativa' && senha == 'HelpDesk') {
                            Navigator.of(context).pushReplacementNamed('/home');
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Erro"),
                                  content: Text("Usuário ou senha incorretos."),
                                  actions: [
                                    TextButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
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
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF303972),
      appBar: AppBar(
        title: Text('Tela Principal'),
        backgroundColor: Color(0xFF303972),
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

class LogoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text('Configurações', style: TextStyle(fontSize: 24)),
            SizedBox(width: 10),
            Icon(Icons.settings, size: 24),
          ],
        ),
        backgroundColor: Color(0xFF303972),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text('Configurações', style: TextStyle(fontSize: 24)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: Text('Sair'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
