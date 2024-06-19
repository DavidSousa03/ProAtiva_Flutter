import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/equipamentos_screen.dart';
import 'package:flutter_application_1/furos_screen.dart';
import 'package:flutter_application_1/pecas_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String apiUrl = 'https://proativa.onrender.com/users';
const String apiUrlTwo = 'https://proativa.onrender.com/user';

class Funcionario {
  String id;
  String nome;
  String telefone;
  String endereco;
  String cargo;
  String email;
  String senha;

  Funcionario({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.endereco,
    required this.cargo,
    required this.email,
    required this.senha,
  });

  factory Funcionario.fromJson(Map<String, dynamic> json) {
    return Funcionario(
      id: json['_id'] ?? 'N/A',
      nome: json['name'] ?? 'N/A',
      telefone: json['phone'] ?? 'N/A',
      endereco: json['address'] ?? 'N/A',
      cargo: json['role'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      senha: json['password'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'phone': telefone,
      'address': endereco,
      'role': cargo,
      'email': email,
      'password': senha,
    };
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('authToken');
}

Future<List<Funcionario>> fetchFuncionarios() async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Token not found');
  }

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((funcionario) => Funcionario.fromJson(funcionario)).toList();
  } else {
    print('Failed to load funcionários: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to load funcionários');
  }
}

Future<void> addFuncionario(Funcionario funcionario) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Token not found');
  }

  final response = await http.post(
    Uri.parse(apiUrlTwo),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'name': funcionario.nome,
      'phone': funcionario.telefone,
      'address': funcionario.endereco,
      'role': funcionario.cargo,
      'email': funcionario.email,
      'password': funcionario.senha
    }),
  );

  if (response.statusCode != 201) {
    print('Failed to add funcionário: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to add funcionário');
  }
}

Future<void> updateFuncionario(String id, Funcionario funcionario) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Token not found');
  }

  final response = await http.put(
    Uri.parse(apiUrlTwo),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'id': id,
      'data': {
        'name': funcionario.nome,
        'phone': funcionario.telefone,
        'address': funcionario.endereco,
        'role': funcionario.cargo,
        'email': funcionario.email,
        'password': funcionario.senha,
      }
    }),
  );

  if (response.statusCode != 200) {
    print('Failed to update funcionário: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to update funcionário');
  }
}

Future<void> deleteFuncionario(String id) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Token not found');
  }

  final response = await http.delete(
    Uri.parse(apiUrlTwo),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'id': id}),
  );

  if (response.statusCode != 200) {
    print('Failed to delete funcionário: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to delete funcionário');
  }
}

class FuncionariosScreen extends StatefulWidget {
  @override
  _FuncionariosScreenState createState() => _FuncionariosScreenState();
}

class _FuncionariosScreenState extends State<FuncionariosScreen> {
  late Future<List<Funcionario>> futureFuncionarios;

  @override
  void initState() {
    super.initState();
    futureFuncionarios = fetchFuncionarios();
  }

  void addAndReload(Funcionario funcionario) {
    addFuncionario(funcionario).then((_) {
      setState(() {
        futureFuncionarios = fetchFuncionarios();
      });
      Navigator.of(context).pop();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao adicionar funcionário.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/Images/logo.png',
              height: 40,
            ),
            SizedBox(width: 10), 
          ],
        ),
        backgroundColor: Color(0xFF303972),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Funcionários',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _showAddFuncionarioDialog(),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xFF303972)),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  ),
                  child: Text('Criar'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Funcionario>>(
                future: futureFuncionarios,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data found'));
                  } else {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Nome')),
                            DataColumn(label: Text('Telefone')),
                            DataColumn(label: Text('Endereço')),
                            DataColumn(label: Text('Cargo')),
                            DataColumn(label: Text('E-mail')),
                            DataColumn(label: Text('Ações')),
                          ],
                          rows: snapshot.data!.map((funcionario) {
                            return DataRow(cells: [
                              DataCell(Text(funcionario.nome)),
                              DataCell(Text(funcionario.telefone)),
                              DataCell(Text(funcionario.endereco)),
                              DataCell(Text(funcionario.cargo)),
                              DataCell(Text(funcionario.email)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _showEditFuncionarioDialog(funcionario),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => _showDeleteConfirmationDialog(funcionario),
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 8),
            FutureBuilder<List<Funcionario>>(
              future: futureFuncionarios,
              builder: (context, snapshot) {
                return Text('Total - ${snapshot.data?.length ?? 0}');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Equipamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Peças',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Furos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Funcionários',
          ),
        ],
        currentIndex: 3,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EquipamentosScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PecasScreen()));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FurosScreen()));
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FuncionariosScreen()));
              break;
          }
        },
      ),
    );
  }

  void _showAddFuncionarioDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nome = '';
        String telefone = '';
        String endereco = '';
        String cargo = '';
        String email = '';
        String senha = '';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Adicionar Funcionário'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(labelText: 'Nome'),
                      onChanged: (value) {
                        nome = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Telefone'),
                      onChanged: (value) {
                        telefone = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Endereço'),
                      onChanged: (value) {
                        endereco = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Cargo'),
                      onChanged: (value) {
                        cargo = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'E-mail'),
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      onChanged: (value) {
                        senha = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nome, E-mail e Senha são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newFuncionario = Funcionario(
                      id: '',
                      nome: nome,
                      telefone: telefone,
                      endereco: endereco,
                      cargo: cargo,
                      email: email,
                      senha: senha,
                    );

                    addAndReload(newFuncionario);
                  },
                  child: Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditFuncionarioDialog(Funcionario funcionario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nome = funcionario.nome;
        String telefone = funcionario.telefone;
        String endereco = funcionario.endereco;
        String cargo = funcionario.cargo;
        String email = funcionario.email;
        String senha = funcionario.senha;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Editar Funcionário'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        hintText: funcionario.nome,
                      ),
                      onChanged: (value) {
                        nome = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                        hintText: funcionario.telefone,
                      ),
                      onChanged: (value) {
                        telefone = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Endereço',
                        hintText: funcionario.endereco,
                      ),
                      onChanged: (value) {
                        endereco = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Cargo',
                        hintText: funcionario.cargo,
                      ),
                      onChanged: (value) {
                        cargo = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        hintText: funcionario.email,
                      ),
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: funcionario.senha,
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        senha = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nome, E-mail e Senha são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final updatedFuncionario = Funcionario(
                      id: funcionario.id,
                      nome: nome,
                      telefone: telefone,
                      endereco: endereco,
                      cargo: cargo,
                      email: email,
                      senha: senha,
                    );

                    updateFuncionario(funcionario.id, updatedFuncionario).then((_) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => FuncionariosScreen()),
                        (Route<dynamic> route) => false,
                      );
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Falha ao atualizar funcionário.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                  },
                  child: Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Funcionario funcionario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja excluir ${funcionario.nome}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                deleteFuncionario(funcionario.id).then((_) {
                  setState(() {
                    futureFuncionarios = fetchFuncionarios();
                  });
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Falha ao deletar funcionário.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _showFuncionarioDetailsDialog(Funcionario funcionario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes do Funcionário'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Nome: ${funcionario.nome}'),
                Text('Telefone: ${funcionario.telefone}'),
                Text('Endereço: ${funcionario.endereco}'),
                Text('Cargo: ${funcionario.cargo}'),
                Text('E-mail: ${funcionario.email}'),
                Text('Senha: ${funcionario.senha}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proativa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    EquipamentosScreen(),
    PecasScreen(),
    FurosScreen(),
    FuncionariosScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Equipamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Peças',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Furos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Funcionários',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
