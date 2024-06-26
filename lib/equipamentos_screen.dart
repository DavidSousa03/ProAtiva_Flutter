import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'funcionarios_screen.dart';
import 'furos_screen.dart';
import 'pecas_screen.dart';
import 'login_page.dart';

const String apiUrl = 'https://proativa.onrender.com/equipamentos';

class Equipment {
  String id;
  String nome;
  String modelo;
  String tamanho;
  String patrimonio;
  String marca;
  bool liberado;
  bool alugado;
  String hostname;
  DateTime? dataDisponivel;
  DateTime? dataAluguel;
  DateTime? dataDevolucao;
  String? alugadoPor;

  Equipment({
    required this.id,
    required this.nome,
    required this.modelo,
    required this.tamanho,
    required this.patrimonio,
    required this.marca,
    required this.liberado,
    required this.alugado,
    required this.hostname,
    this.dataDisponivel,
    this.dataAluguel,
    this.dataDevolucao,
    this.alugadoPor,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['_id'],
      nome: json['nome'],
      modelo: json['modelo'],
      tamanho: json['tamanho'],
      patrimonio: json['patrimonio'],
      marca: json['marca'],
      liberado: json['liberado'] ?? false,
      alugado: json['liberado'] != null ? !json['liberado'] : false,
      hostname: json['hostname'] ?? '',
      dataDisponivel: json['dataDisponivel'] != null
          ? DateTime.parse(json['dataDisponivel'])
          : null,
      dataAluguel: json['dataAluguel'] != null
          ? DateTime.parse(json['dataAluguel'])
          : null,
      dataDevolucao: json['dataDevolucao'] != null
          ? DateTime.parse(json['dataDevolucao'])
          : null,
      alugadoPor: json['alugadoPor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'modelo': modelo,
      'tamanho': tamanho,
      'patrimonio': patrimonio,
      'marca': marca,
      'liberado': liberado,
      'hostname': hostname,
      'dataDisponivel': dataDisponivel?.toIso8601String(),
      'dataAluguel': dataAluguel?.toIso8601String(),
      'dataDevolucao': dataDevolucao?.toIso8601String(),
      'alugadoPor': alugadoPor,
    };
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('authToken');
}

Future<List<Equipment>> fetchEquipments() async {
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
    return jsonResponse
        .map((equipment) => Equipment.fromJson(equipment))
        .toList();
  } else {
    throw Exception('Failed to load equipment');
  }
}

Future<void> addEquipment(Equipment equipment) async {
  final token = await getToken();
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(equipment.toJson()),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add equipment');
  }
}

Future<void> updateEquipment(String id, Equipment equipment) async {
  final token = await getToken();
  final response = await http.put(
    Uri.parse('$apiUrl/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(equipment.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update equipment');
  }
}

Future<void> deleteEquipment(String id) async {
  final token = await getToken();
  final response = await http.delete(
    Uri.parse('$apiUrl/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 204) {
    throw Exception('Failed to delete equipment');
  }
}

class EquipamentosScreen extends StatefulWidget {
  @override
  _EquipamentosScreenState createState() => _EquipamentosScreenState();
}

class _EquipamentosScreenState extends State<EquipamentosScreen> {
  late Future<List<Equipment>> futureEquipments;

  @override
  void initState() {
    super.initState();
    futureEquipments = fetchEquipments();
  }

  void _logout() async {
    await AuthService().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void addAndReload(Equipment equipment) {
    addEquipment(equipment).then((_) {
      setState(() {
        futureEquipments = fetchEquipments();
      });
      Navigator.of(context).pop();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao adicionar equipamento.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void deleteAndReload(String id) async {
    try {
      await deleteEquipment(id);
      setState(() {
        futureEquipments = fetchEquipments();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Equipamento deletado com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao deletar equipamento.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void updateAndReload(String id, Equipment equipment) async {
    try {
      await updateEquipment(id, equipment);
      setState(() {
        futureEquipments = fetchEquipments();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Equipamento atualizado com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao atualizar equipamento.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            icon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
            onPressed: _logout,
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
                  'Equipamentos',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _showAddEquipmentDialog(),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xFF303972)),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: Text('Criar'),
                )
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Equipment>>(
                future: futureEquipments,
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Nome')),
                            DataColumn(label: Text('Modelo')),
                            DataColumn(label: Text('Tamanho')),
                            DataColumn(label: Text('Patrimônio')),
                            DataColumn(label: Text('Marca')),
                            DataColumn(label: Text('Disponível')),
                            DataColumn(label: Text('Ações')),
                          ],
                          rows: snapshot.data!.map((equipment) {
                            return DataRow(cells: [
                              DataCell(
                                Text(equipment.nome),
                                onTap: () =>
                                    _showEquipmentDetailsDialog(equipment),
                              ),
                              DataCell(Text(equipment.modelo)),
                              DataCell(Text(equipment.tamanho)),
                              DataCell(Text(equipment.patrimonio)),
                              DataCell(Text(equipment.marca)),
                              DataCell(Icon(
                                equipment.liberado
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: equipment.liberado
                                    ? Colors.green
                                    : Colors.red,
                              )),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () =>
                                          _showEditEquipmentDialog(equipment),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () =>
                                          _showDeleteConfirmationDialog(
                                              equipment),
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
            FutureBuilder<List<Equipment>>(
              future: futureEquipments,
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
        currentIndex: 0,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EquipamentosScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => PecasScreen()));
              break;
            case 2:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => FurosScreen()));
              break;
            case 3:
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FuncionariosScreen()));
              break;
          }
        },
      ),
    );
  }

  void _showAddEquipmentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nomeEquipamento = '';
        String modelo = '';
        String tamanho = '';
        String patrimonio = '';
        String marca = '';
        bool liberado = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Adicionar Equipamento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration:
                          InputDecoration(labelText: 'Nome do Equipamento'),
                      onChanged: (value) {
                        nomeEquipamento = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Modelo'),
                      onChanged: (value) {
                        modelo = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Tamanho'),
                      onChanged: (value) {
                        tamanho = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(labelText: 'Patrimônio'),
                      onChanged: (value) {
                        patrimonio = value;
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
                    if (nomeEquipamento.isEmpty || modelo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Nome e Modelo são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newEquipment = Equipment(
                      id: '',
                      nome: nomeEquipamento,
                      modelo: modelo,
                      tamanho: tamanho,
                      patrimonio: patrimonio,
                      marca: marca,
                      liberado: liberado,
                      alugado: !liberado,
                      hostname: 'HOST0001',
                    );

                    addAndReload(newEquipment);
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

  void _showEditEquipmentDialog(Equipment equipment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nomeEquipamento = equipment.nome;
        String modelo = equipment.modelo;
        String tamanho = equipment.tamanho;
        String patrimonio = equipment.patrimonio;
        String marca = equipment.marca;
        bool liberado = equipment.liberado;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Editar Equipamento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nome do Equipamento',
                        hintText: equipment.nome,
                      ),
                      onChanged: (value) {
                        nomeEquipamento = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Modelo',
                        hintText: equipment.modelo,
                      ),
                      onChanged: (value) {
                        modelo = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Tamanho',
                        hintText: equipment.tamanho,
                      ),
                      onChanged: (value) {
                        tamanho = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Patrimônio',
                        hintText: equipment.patrimonio,
                      ),
                      onChanged: (value) {
                        patrimonio = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Marca',
                        hintText: equipment.marca,
                      ),
                      onChanged: (value) {
                        marca = value;
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
                    if (nomeEquipamento.isEmpty || modelo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Nome e Modelo são campos obrigatórios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final updatedEquipment = Equipment(
                      id: equipment.id,
                      nome: nomeEquipamento,
                      modelo: modelo,
                      tamanho: tamanho,
                      patrimonio: patrimonio,
                      marca: marca,
                      liberado: liberado,
                      alugado: !liberado,
                      hostname: equipment.hostname,
                      dataDisponivel: equipment.dataDisponivel,
                      dataAluguel: equipment.dataAluguel,
                      dataDevolucao: equipment.dataDevolucao,
                      alugadoPor: equipment.alugadoPor,
                    );

                    updateAndReload(equipment.id, updatedEquipment);
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

  void _showDeleteConfirmationDialog(Equipment equipment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja excluir ${equipment.nome}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                deleteAndReload(equipment.id);
                Navigator.of(context).pop();
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _showEquipmentDetailsDialog(Equipment equipment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes do Equipamento'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Nome: ${equipment.nome}'),
                Text('Modelo: ${equipment.modelo}'),
                Text('Tamanho: ${equipment.tamanho}'),
                Text('Patrimônio: ${equipment.patrimonio}'),
                Text('Marca: ${equipment.marca}'),
                Text('Hostname: ${equipment.hostname}'),
                Text('Disponível: ${equipment.liberado ? 'Sim' : 'Não'}'),
                if (equipment.dataAluguel != null)
                  Text('Data de Aluguel: ${equipment.dataAluguel}'),
                if (equipment.dataDevolucao != null)
                  Text('Data de Devolução: ${equipment.dataDevolucao}'),
                if (equipment.alugadoPor != null)
                  Text('Alugado Por: ${equipment.alugadoPor}'),
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
