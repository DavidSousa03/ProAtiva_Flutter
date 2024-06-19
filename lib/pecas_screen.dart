import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/equipamentos_screen.dart';
import 'package:flutter_application_1/funcionarios_screen.dart';
import 'package:flutter_application_1/furos_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String apiUrl = 'https://proativa.onrender.com/pecas';

class Peca {
  String id;
  String nome;
  String equipamento;
  int quantidade;
  String codigo;
  String marca;
  String observacao;

  Peca({
    required this.id,
    required this.nome,
    required this.equipamento,
    required this.quantidade,
    required this.codigo,
    required this.marca,
    required this.observacao,
  });

  factory Peca.fromJson(Map<String, dynamic> json) {
    return Peca(
      id: json['_id'],
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
      'id': id,
      'nome': nome,
      'equipamento': equipamento,
      'quantidade': quantidade,
      'codigo': codigo,
      'marca': marca,
      'observacao': observacao,
    };
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('authToken');
}

Future<List<Peca>> fetchPecas() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((peca) => Peca.fromJson(peca)).toList();
  } else {
    throw Exception('Failed to load peças');
  }
}

Future<void> addPeca(Peca peca) async {
  final token = await getToken();
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(peca.toJson()),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add peça');
  }
}

Future<void> updatePeca(String id, Peca peca) async {
  final token = await getToken();
  final response = await http.put(
    Uri.parse('$apiUrl/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(peca.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update peça');
  }
}

Future<void> deletePeca(String id) async {
  final token = await getToken();
  final response = await http.delete(
    Uri.parse('$apiUrl/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 204) {
    throw Exception('Failed to delete peça');
  }
}

class PecasScreen extends StatefulWidget {
  @override
  _PecasScreenState createState() => _PecasScreenState();
}

class _PecasScreenState extends State<PecasScreen> {
  late Future<List<Peca>> futurePecas;

  @override
  void initState() {
    super.initState();
    futurePecas = fetchPecas();
  }

  void updatePecaQuantidade(Peca peca, int quantidade) {
    final updatedPeca = Peca(
      id: peca.id,
      nome: peca.nome,
      equipamento: peca.equipamento,
      quantidade: quantidade,
      codigo: peca.codigo,
      marca: peca.marca,
      observacao: peca.observacao,
    );

    updatePeca(peca.id, updatedPeca).then((_) {
      setState(() {
        futurePecas = fetchPecas();
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao atualizar quantidade.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void addAndReload(Peca peca) {
    addPeca(peca).then((_) {
      setState(() {
        futurePecas = fetchPecas();
      });
      Navigator.of(context).pop();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao adicionar peça.'),
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
            Text('Peças'),
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
                  'Peças',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _showAddPecaDialog(),
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
              child: FutureBuilder<List<Peca>>(
                future: futurePecas,
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
                            DataColumn(label: Text('Equipamento')),
                            DataColumn(label: Text('Quantidade')),
                            DataColumn(label: Text('Código')),
                            DataColumn(label: Text('Marca')),
                            DataColumn(label: Text('Observação')),
                            DataColumn(label: Text('Ações')),
                          ],
                          rows: snapshot.data!.map((peca) {
                            return DataRow(cells: [
                              DataCell(
                                Text(peca.nome),
                                onTap: () => _showPecaDetailsDialog(peca),
                              ),
                              DataCell(Text(peca.equipamento)),
                              DataCell(
                                TextField(
                                  controller: TextEditingController(text: peca.quantidade.toString()),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    final updatedQuantidade = int.tryParse(value) ?? peca.quantidade;
                                    updatePecaQuantidade(peca, updatedQuantidade);
                                  },
                                ),
                              ),
                              DataCell(Text(peca.codigo)),
                              DataCell(Text(peca.marca)),
                              DataCell(Text(peca.observacao)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _showEditPecaDialog(peca),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => _showDeleteConfirmationDialog(peca),
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
            FutureBuilder<List<Peca>>(
              future: futurePecas,
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
        currentIndex: 1,
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
                      decoration: InputDecoration(labelText: 'Nome'),
                      onChanged: (value) {
                        nome = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Equipamento'),
                      onChanged: (value) {
                        equipamento = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Quantidade'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        quantidade = int.tryParse(value) ?? 0;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Código'),
                      onChanged: (value) {
                        codigo = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Marca'),
                      onChanged: (value) {
                        marca = value;
                      },
                    ),
                    SizedBox(height: 8),
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
                    if (nome.isEmpty || codigo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nome e Código são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newPeca = Peca(
                      id: '',
                      nome: nome,
                      equipamento: equipamento,
                      quantidade: quantidade,
                      codigo: codigo,
                      marca: marca,
                      observacao: observacao,
                    );

                    addAndReload(newPeca);
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
                        labelText: 'Nome',
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
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        quantidade = int.tryParse(value) ?? 0;
                      },
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
                    if (nome.isEmpty || codigo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nome e Código são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final updatedPeca = Peca(
                      id: peca.id,
                      nome: nome,
                      equipamento: equipamento,
                      quantidade: quantidade,
                      codigo: codigo,
                      marca: marca,
                      observacao: observacao,
                    );

                    updatePeca(peca.id, updatedPeca).then((_) {
                      updatePecaQuantidade(peca, quantidade);
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
                deletePeca(peca.id).then((_) {
                  setState(() {
                    futurePecas = fetchPecas();
                  });
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
