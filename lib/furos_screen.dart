import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiUrl = 'https://proativa.onrender.com/furos';
const String bearerToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjZmOWRiZTgzZThiNjA1MTJlOTE5MGYiLCJpYXQiOjE3MTg1OTM1NTEsImV4cCI6MTcxODU5NzE1MX0.zYpTP6wJ7xOoDr-BUEpS2Af7hATQOzjuqHQIngIY8qg';

class Furo {
  String obra;
  String cliente;
  String responsavel;
  String assistente;
  String observacao;
  bool liberado;

  Furo({
    required this.obra,
    required this.cliente,
    required this.responsavel,
    required this.assistente,
    required this.observacao,
    required this.liberado,
  });

  factory Furo.fromJson(Map<String, dynamic> json) {
    return Furo(
      obra: json['obra'],
      cliente: json['cliente'],
      responsavel: json['responsavel'],
      assistente: json['assistente'],
      observacao: json['observacao'],
      liberado: json['liberado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'obra': obra,
      'cliente': cliente,
      'responsavel': responsavel,
      'assistente': assistente,
      'observacao': observacao,
      'liberado': liberado,
    };
  }
}

Future<List<Furo>> fetchFuros() async {
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((furo) => Furo.fromJson(furo)).toList();
  } else {
    throw Exception('Falha ao carregar furos');
  }
}

Future<void> createFuro(Furo furo) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
    body: jsonEncode(furo.toJson()),
  );

  if (response.statusCode != 201) {
    throw Exception('Falha ao adicionar furo');
  }
}

Future<void> updateFuro(String obra, Furo furo) async {
  final response = await http.put(
    Uri.parse('$apiUrl/$obra'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
    body: jsonEncode(furo.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Falha ao atualizar furo');
  }
}

Future<void> deleteFuro(String obra) async {
  final response = await http.delete(
    Uri.parse('$apiUrl/$obra'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
  );

  if (response.statusCode != 204) {
    throw Exception('Falha ao deletar furo');
  }
}

class FurosScreen extends StatefulWidget {
  @override
  _FurosScreenState createState() => _FurosScreenState();
}

class _FurosScreenState extends State<FurosScreen> {
  List<Furo> _furosList = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchFuros();
  }

  Future<void> _fetchFuros() async {
    try {
      final furos = await fetchFuros();
      setState(() {
        _furosList = furos;
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
            Text('Furos'),
          ],
        ),
        backgroundColor: Color(0xFF303972),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddFuroDialog();
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
                labelText: 'Buscar Furo',
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
              itemCount: _filteredFurosList().length,
              itemBuilder: (context, index) {
                final furo = _filteredFurosList()[index];
                return ListTile(
                  title: Text(furo.obra),
                  subtitle: Text('Cliente: ${furo.cliente}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditFuroDialog(furo);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(furo);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showFuroDetailsDialog(furo);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Furo> _filteredFurosList() {
    return _furosList.where((furo) {
      final obraLower = furo.obra.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();

      if (_searchQuery.isNotEmpty && !obraLower.contains(queryLower)) {
        return false;
      }

      return true;
    }).toList();
  }

  void _showAddFuroDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String obra = '';
        String cliente = '';
        String responsavel = '';
        String assistente = '';
        String observacao = '';
        bool liberado = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Adicionar Furo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(labelText: 'Obra'),
                      onChanged: (value) {
                        obra = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Cliente'),
                      onChanged: (value) {
                        cliente = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Responsável'),
                      onChanged: (value) {
                        responsavel = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Assistente'),
                      onChanged: (value) {
                        assistente = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Observação'),
                      onChanged: (value) {
                        observacao = value;
                      },
                    ),
                    Row(
                      children: <Widget>[
                        Text('Liberado: '),
                        Checkbox(
                          value: liberado,
                          onChanged: (value) {
                            setState(() {
                              liberado = value!;
                            });
                          },
                        ),
                      ],
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
                    if (obra.isEmpty || cliente.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Obra e Cliente são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newFuro = Furo(
                      obra: obra,
                      cliente: cliente,
                      responsavel: responsavel,
                      assistente: assistente,
                      observacao: observacao,
                      liberado: liberado,
                    );

                    createFuro(newFuro).then((_) {
                      _fetchFuros();
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Falha ao adicionar furo.'),
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

  void _showEditFuroDialog(Furo furo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String obra = furo.obra;
        String cliente = furo.cliente;
        String responsavel = furo.responsavel;
        String assistente = furo.assistente;
        String observacao = furo.observacao;
        bool liberado = furo.liberado;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Editar Furo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Obra',
                        hintText: furo.obra,
                      ),
                      onChanged: (value) {
                        obra = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Cliente',
                        hintText: furo.cliente,
                      ),
                      onChanged: (value) {
                        cliente = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Responsável',
                        hintText: furo.responsavel,
                      ),
                      onChanged: (value) {
                        responsavel = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Assistente',
                        hintText: furo.assistente,
                      ),
                      onChanged: (value) {
                        assistente = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Observação',
                        hintText: furo.observacao,
                      ),
                      onChanged: (value) {
                        observacao = value;
                      },
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Text('Liberado: '),
                        Checkbox(
                          value: liberado,
                          onChanged: (value) {
                            setState(() {
                              liberado = value!;
                            });
                          },
                        ),
                      ],
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
                    if (obra.isEmpty || cliente.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Obra e Cliente são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final updatedFuro = Furo(
                      obra: obra,
                      cliente: cliente,
                      responsavel: responsavel,
                      assistente: assistente,
                      observacao: observacao,
                      liberado: liberado,
                    );

                    updateFuro(furo.obra, updatedFuro).then((_) {
                      _fetchFuros();
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Falha ao atualizar furo.'),
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

  void _showDeleteConfirmationDialog(Furo furo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja excluir ${furo.obra}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                deleteFuro(furo.obra).then((_) {
                  _fetchFuros();
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Falha ao deletar furo.'),
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

  void _showFuroDetailsDialog(Furo furo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes do Furo'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Obra: ${furo.obra}'),
                Text('Cliente: ${furo.cliente}'),
                Text('Responsável: ${furo.responsavel}'),
                Text('Assistente: ${furo.assistente}'),
                Text('Observação: ${furo.observacao}'),
                Text('Liberado: ${furo.liberado ? 'Sim' : 'Não'}'),
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
