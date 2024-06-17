import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiUrl = 'https://proativa.onrender.com/pecas';
const String bearerToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjZmOWRiZTgzZThiNjA1MTJlOTE5MGYiLCJpYXQiOjE3MTg1OTM1NTEsImV4cCI6MTcxODU5NzE1MX0.zYpTP6wJ7xOoDr-BUEpS2Af7hATQOzjuqHQIngIY8qg';

class Peca {
  String nome;
  String equipamento;
  int quantidade;
  String codigo;
  String marca;
  String observacao;

  Peca({
    required this.nome,
    required this.equipamento,
    required this.quantidade,
    required this.codigo,
    required this.marca,
    required this.observacao,
  });

  factory Peca.fromJson(Map<String, dynamic> json) {
    return Peca(
      nome: json['nome'],
      equipamento: json['equipamento'],
      quantidade: json['quantidade'],
      codigo: json['codigo'],
      marca: json['marca'],
      observacao: json['observacao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'equipamento': equipamento,
      'quantidade': quantidade,
      'codigo': codigo,
      'marca': marca,
      'observacao': observacao,
    };
  }
}

Future<List<Peca>> fetchPecas() async {
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((peca) => Peca.fromJson(peca)).toList();
  } else {
    throw Exception('Falha ao carregar peças');
  }
}

Future<void> createPeca(Peca peca) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
    body: jsonEncode(peca.toJson()),
  );

  if (response.statusCode != 201) {
    throw Exception('Falha ao adicionar peça');
  }
}

Future<void> updatePeca(String codigo, Peca peca) async {
  final response = await http.put(
    Uri.parse('$apiUrl/$codigo'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
    body: jsonEncode(peca.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Falha ao atualizar peça');
  }
}

Future<void> deletePeca(String codigo) async {
  final response = await http.delete(
    Uri.parse('$apiUrl/$codigo'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
  );

  if (response.statusCode != 204) {
    throw Exception('Falha ao deletar peça');
  }
}

class PecasScreen extends StatefulWidget {
  @override
  _PecasScreenState createState() => _PecasScreenState();
}

class _PecasScreenState extends State<PecasScreen> {
  List<Peca> _pecasList = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPecas();
  }

  Future<void> _fetchPecas() async {
    try {
      final pecas = await fetchPecas();
      setState(() {
        _pecasList = pecas;
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
            Text('Peças'),
          ],
        ),
        backgroundColor: Color(0xFF303972),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddPecaDialog();
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
                labelText: 'Buscar Peça',
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
              itemCount: _filteredPecasList().length,
              itemBuilder: (context, index) {
                final peca = _filteredPecasList()[index];
                return ListTile(
                  title: Text(peca.nome),
                  subtitle: Text('Equipamento: ${peca.equipamento}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditPecaDialog(peca);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(peca);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showPecaDetailsDialog(peca);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Peca> _filteredPecasList() {
    return _pecasList.where((peca) {
      final nomeLower = peca.nome.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();

      if (_searchQuery.isNotEmpty && !nomeLower.contains(queryLower)) {
        return false;
      }

      return true;
    }).toList();
  }

  void _showAddPecaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nome = '';
        String equipamento = '';
        int quantidade = 0;
        String codigo = '';
        String marca = '';
        String observacao = '';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Adicionar Peça'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(labelText: 'Nome da Peça'),
                      onChanged: (value) {
                        nome = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Equipamento'),
                      onChanged: (value) {
                        equipamento = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Quantidade'),
                      onChanged: (value) {
                        quantidade = int.tryParse(value) ?? 0;
                      },
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Código'),
                      onChanged: (value) {
                        codigo = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Marca'),
                      onChanged: (value) {
                        marca = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Observação'),
                      onChanged: (value) {
                        observacao = value;
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
                    if (nome.isEmpty || equipamento.isEmpty || codigo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nome, Equipamento e Código são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newPeca = Peca(
                      nome: nome,
                      equipamento: equipamento,
                      quantidade: quantidade,
                      codigo: codigo,
                      marca: marca,
                      observacao: observacao,
                    );

                    createPeca(newPeca).then((_) {
                      _fetchPecas();
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Falha ao adicionar peça.'),
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

  void _showEditPecaDialog(Peca peca) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nome = peca.nome;
        String equipamento = peca.equipamento;
        int quantidade = peca.quantidade;
        String codigo = peca.codigo;
        String marca = peca.marca;
        String observacao = peca.observacao;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Editar Peça'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nome da Peça',
                        hintText: peca.nome,
                      ),
                      onChanged: (value) {
                        nome = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Equipamento',
                        hintText: peca.equipamento,
                      ),
                      onChanged: (value) {
                        equipamento = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Quantidade',
                        hintText: peca.quantidade.toString(),
                      ),
                      onChanged: (value) {
                        quantidade = int.tryParse(value) ?? 0;
                      },
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Código',
                        hintText: peca.codigo,
                      ),
                      onChanged: (value) {
                        codigo = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Marca',
                        hintText: peca.marca,
                      ),
                      onChanged: (value) {
                        marca = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Observação',
                        hintText: peca.observacao,
                      ),
                      onChanged: (value) {
                        observacao = value;
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
                    if (nome.isEmpty || equipamento.isEmpty || codigo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nome, Equipamento e Código são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final updatedPeca = Peca(
                      nome: nome,
                      equipamento: equipamento,
                      quantidade: quantidade,
                      codigo: codigo,
                      marca: marca,
                      observacao: observacao,
                    );

                    updatePeca(peca.codigo, updatedPeca).then((_) {
                      _fetchPecas();
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Falha ao atualizar peça.'),
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

  void _showDeleteConfirmationDialog(Peca peca) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja excluir ${peca.nome}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                deletePeca(peca.codigo).then((_) {
                  _fetchPecas();
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Falha ao deletar peça.'),
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

  void _showPecaDetailsDialog(Peca peca) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes da Peça'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Nome: ${peca.nome}'),
                Text('Equipamento: ${peca.equipamento}'),
                Text('Quantidade: ${peca.quantidade}'),
                Text('Código: ${peca.codigo}'),
                Text('Marca: ${peca.marca}'),
                Text('Observação: ${peca.observacao}'),
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
