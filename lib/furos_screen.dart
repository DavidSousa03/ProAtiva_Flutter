import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/equipamentos_screen.dart';
import 'package:flutter_application_1/funcionarios_screen.dart';
import 'package:flutter_application_1/pecas_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String apiUrl = 'https://proativa.onrender.com/furos';

class Furo {
  String id;
  String obra;
  String cliente;
  String responsavel;
  String assistente;
  String observacao;
  bool liberado;

  Furo({
    required this.id,
    required this.obra,
    required this.cliente,
    required this.responsavel,
    required this.assistente,
    required this.observacao,
    required this.liberado,
  });

  factory Furo.fromJson(Map<String, dynamic> json) {
    return Furo(
      id: json['_id'],
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
      'id': id,
      'obra': obra,
      'cliente': cliente,
      'responsavel': responsavel,
      'assistente': assistente,
      'observacao': observacao,
      'liberado': liberado,
    };
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('authToken');
}

Future<List<Furo>> fetchFuros() async {
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
    return jsonResponse.map((furo) => Furo.fromJson(furo)).toList();
  } else {
    throw Exception('Failed to load furos');
  }
}

Future<void> addFuro(Furo furo) async {
  final token = await getToken();
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(furo.toJson()),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add furo');
  }
}

Future<void> updateFuro(String id, Furo furo) async {
  final token = await getToken();
  final response = await http.put(
    Uri.parse('$apiUrl/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(furo.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update furo');
  }
}

Future<void> deleteFuro(String id) async {
  final token = await getToken();
  final response = await http.delete(
    Uri.parse('$apiUrl/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 204) {
    throw Exception('Failed to delete furo');
  }
}

class FurosScreen extends StatefulWidget {
  @override
  _FurosScreenState createState() => _FurosScreenState();
}

class _FurosScreenState extends State<FurosScreen> {
  late Future<List<Furo>> futureFuros;

  @override
  void initState() {
    super.initState();
    futureFuros = fetchFuros();
  }

  void updateFuroLiberado(Furo furo, bool liberado) {
    final updatedFuro = Furo(
      id: furo.id,
      obra: furo.obra,
      cliente: furo.cliente,
      responsavel: furo.responsavel,
      assistente: furo.assistente,
      observacao: furo.observacao,
      liberado: liberado,
    );

    updateFuro(furo.id, updatedFuro).then((_) {
      setState(() {
        futureFuros = fetchFuros();
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao atualizar liberado.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void addAndReload(Furo furo) {
    addFuro(furo).then((_) {
      setState(() {
        futureFuros = fetchFuros();
      });
      Navigator.of(context).pop();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao adicionar furo.'),
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
            Text('Furos'),
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
                  'Furos',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _showAddFuroDialog(),
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
              child: FutureBuilder<List<Furo>>(
                future: futureFuros,
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
                            DataColumn(label: Text('Obra')),
                            DataColumn(label: Text('Cliente')),
                            DataColumn(label: Text('Responsável')),
                            DataColumn(label: Text('Assistente')),
                            DataColumn(label: Text('Observação')),
                            DataColumn(label: Text('Liberado')),
                            DataColumn(label: Text('Ações')),
                          ],
                          rows: snapshot.data!.map((furo) {
                            return DataRow(cells: [
                              DataCell(
                                Text(furo.obra),
                                onTap: () => _showFuroDetailsDialog(furo),
                              ),
                              DataCell(Text(furo.cliente)),
                              DataCell(Text(furo.responsavel)),
                              DataCell(Text(furo.assistente)),
                              DataCell(Text(furo.observacao)),
                              DataCell(Checkbox(
                                value: furo.liberado,
                                onChanged: (value) {
                                  updateFuroLiberado(furo, value ?? furo.liberado);
                                },
                              )),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _showEditFuroDialog(furo),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => _showDeleteConfirmationDialog(furo),
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
            FutureBuilder<List<Furo>>(
              future: futureFuros,
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
        currentIndex: 2,
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
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Cliente'),
                      onChanged: (value) {
                        cliente = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Responsável'),
                      onChanged: (value) {
                        responsavel = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Assistente'),
                      onChanged: (value) {
                        assistente = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Observação'),
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
                    if (obra.isEmpty || cliente.isEmpty || responsavel.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Obra, Cliente e Responsável são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newFuro = Furo(
                      id: '',
                      obra: obra,
                      cliente: cliente,
                      responsavel: responsavel,
                      assistente: assistente,
                      observacao: observacao,
                      liberado: liberado,
                    );

                    addAndReload(newFuro);
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
                    if (obra.isEmpty || cliente.isEmpty || responsavel.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Obra, Cliente e Responsável são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final updatedFuro = Furo(
                      id: furo.id,
                      obra: obra,
                      cliente: cliente,
                      responsavel: responsavel,
                      assistente: assistente,
                      observacao: observacao,
                      liberado: liberado,
                    );

                    updateFuro(furo.id, updatedFuro).then((_) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => FurosScreen()),
                        (Route<dynamic> route) => false,
                      );
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
                deleteFuro(furo.id).then((_) {
                  setState(() {
                    futureFuros = fetchFuros();
                  });
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
