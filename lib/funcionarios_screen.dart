import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiUrl = 'https://proativa.onrender.com/funcionarios';
const String bearerToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjZmOWRiZTgzZThiNjA1MTJlOTE5MGYiLCJpYXQiOjE3MTg1OTM1NTEsImV4cCI6MTcxODU5NzE1MX0.zYpTP6wJ7xOoDr-BUEpS2Af7hATQOzjuqHQIngIY8qg';

class Funcionario {
  String nome;
  String telefone;
  String endereco;
  String cargo;
  String acesso;
  String senha;

  Funcionario({
    required this.nome,
    required this.telefone,
    required this.endereco,
    required this.cargo,
    required this.acesso,
    required this.senha,
  });

  factory Funcionario.fromJson(Map<String, dynamic> json) {
    return Funcionario(
      nome: json['nome'],
      telefone: json['telefone'],
      endereco: json['endereco'],
      cargo: json['cargo'],
      acesso: json['acesso'],
      senha: json['senha'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'telefone': telefone,
      'endereco': endereco,
      'cargo': cargo,
      'acesso': acesso,
      'senha': senha,
    };
  }
}

Future<List<Funcionario>> fetchFuncionarios() async {
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((funcionario) => Funcionario.fromJson(funcionario)).toList();
  } else {
    throw Exception('Falha ao carregar funcionários');
  }
}

Future<void> createFuncionario(Funcionario funcionario) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
    body: jsonEncode(funcionario.toJson()),
  );

  if (response.statusCode != 201) {
    throw Exception('Falha ao adicionar funcionário');
  }
}

Future<void> updateFuncionario(String acesso, Funcionario funcionario) async {
  final response = await http.put(
    Uri.parse('$apiUrl/$acesso'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
    body: jsonEncode(funcionario.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Falha ao atualizar funcionário');
  }
}

Future<void> deleteFuncionario(String acesso) async {
  final response = await http.delete(
    Uri.parse('$apiUrl/$acesso'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
  );

  if (response.statusCode != 204) {
    throw Exception('Falha ao deletar funcionário');
  }
}

class FuncionariosScreen extends StatefulWidget {
  @override
  _FuncionariosScreenState createState() => _FuncionariosScreenState();
}

class _FuncionariosScreenState extends State<FuncionariosScreen> {
  List<Funcionario> _funcionariosList = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchFuncionarios();
  }

  Future<void> _fetchFuncionarios() async {
    try {
      final funcionarios = await fetchFuncionarios();
      setState(() {
        _funcionariosList = funcionarios;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Image.asset(
              'assets/Images/logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10),
            Text('Funcionários'),
          ],
        ),
        backgroundColor: Color(0xFF303972),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddFuncionarioDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar Funcionário',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFuncionariosList().length,
              itemBuilder: (context, index) {
                final funcionario = _filteredFuncionariosList()[index];
                return ListTile(
                  title: Text(funcionario.nome),
                  subtitle: Text('Cargo: ${funcionario.cargo}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditFuncionarioDialog(funcionario);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(funcionario);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showFuncionarioDetailsDialog(funcionario);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Funcionario> _filteredFuncionariosList() {
    return _funcionariosList.where((funcionario) {
      final nomeLower = funcionario.nome.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();

      if (_searchQuery.isNotEmpty && !nomeLower.contains(queryLower)) {
        return false;
      }

      return true;
    }).toList();
  }

  void _showAddFuncionarioDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nome = '';
        String telefone = '';
        String endereco = '';
        String cargo = '';
        String acesso = '';
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
                    TextField(
                      decoration: InputDecoration(labelText: 'Telefone'),
                      onChanged: (value) {
                        telefone = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Endereço'),
                      onChanged: (value) {
                        endereco = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Cargo'),
                      onChanged: (value) {
                        cargo = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Acesso (e-mail)'),
                      onChanged: (value) {
                        acesso = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Senha'),
                      onChanged: (value) {
                        senha = value;
                      },
                      obscureText: true,
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
                    if (nome.isEmpty || acesso.isEmpty || senha.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nome, Acesso e Senha são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newFuncionario = Funcionario(
                      nome: nome,
                      telefone: telefone,
                      endereco: endereco,
                      cargo: cargo,
                      acesso: acesso,
                      senha: senha,
                    );

                    createFuncionario(newFuncionario).then((_) {
                      _fetchFuncionarios();
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Falha ao adicionar funcionário.'),
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

  void _showEditFuncionarioDialog(Funcionario funcionario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nome = funcionario.nome;
        String telefone = funcionario.telefone;
        String endereco = funcionario.endereco;
        String cargo = funcionario.cargo;
        String acesso = funcionario.acesso;
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
                        labelText: 'Acesso (e-mail)',
                        hintText: funcionario.acesso,
                      ),
                      onChanged: (value) {
                        acesso = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: funcionario.senha,
                      ),
                      onChanged: (value) {
                        senha = value;
                      },
                      obscureText: true,
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
                    if (nome.isEmpty || acesso.isEmpty || senha.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nome, Acesso e Senha são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final updatedFuncionario = Funcionario(
                      nome: nome,
                      telefone: telefone,
                      endereco: endereco,
                      cargo: cargo,
                      acesso: acesso,
                      senha: senha,
                    );

                    updateFuncionario(funcionario.acesso, updatedFuncionario).then((_) {
                      _fetchFuncionarios();
                      Navigator.of(context).pop();
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
                deleteFuncionario(funcionario.acesso).then((_) {
                  _fetchFuncionarios();
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
                Text('Acesso (e-mail): ${funcionario.acesso}'),
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
