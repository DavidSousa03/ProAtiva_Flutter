import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiUrl = 'https://proativa.onrender.com/equipamentos';
const String bearerToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjZmOWRiZTgzZThiNjA1MTJlOTE5MGYiLCJpYXQiOjE3MTg1OTgzNzgsImV4cCI6MTcxODYwMTk3OH0.qvyiw-D5cUqIfZOp86Iu1igwQTEQK0FTLc60WoftD0Y';

class Equipment {
  String nome;
  String modelo;
  String tamanho;
  String patrimonio;
  String marca;
  bool disponivel;
  bool alugado;
  String hostname;
  DateTime? dataDisponivel;
  DateTime? dataAluguel;
  DateTime? dataDevolucao;
  String? alugadoPor;

  Equipment({
    required this.nome,
    required this.modelo,
    required this.tamanho,
    required this.patrimonio,
    required this.marca,
    required this.disponivel,
    required this.alugado,
    required this.hostname,
    this.dataDisponivel,
    this.dataAluguel,
    this.dataDevolucao,
    this.alugadoPor,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      nome: json['nome'],
      modelo: json['modelo'],
      tamanho: json['tamanho'],
      patrimonio: json['patrimonio'],
      marca: json['marca'],
      disponivel: json['disponivel'] ?? false,
      alugado: json['disponivel'] != null ? !json['disponivel'] : false,
      hostname: json['hostname'] ?? '',
      dataDisponivel: json['dataDisponivel'] != null ? DateTime.parse(json['dataDisponivel']) : null,
      dataAluguel: json['dataAluguel'] != null ? DateTime.parse(json['dataAluguel']) : null,
      dataDevolucao: json['dataDevolucao'] != null ? DateTime.parse(json['dataDevolucao']) : null,
      alugadoPor: json['alugadoPor'],
    );
  }
}

Future<List<Equipment>> fetchEquipments() async {
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((equipment) => Equipment.fromJson(equipment)).toList();
  } else {
    throw Exception('Failed to load equipment');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Equipamentos'),
        backgroundColor: Color(0xFF303972),
      ),
      body: FutureBuilder<List<Equipment>>(
        future: futureEquipments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final equipment = snapshot.data![index];
                return ListTile(
                  title: Text(equipment.nome),
                  subtitle: Text(equipment.modelo),
                  trailing: Text(equipment.disponivel ? 'Disponível' : 'Alugado'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EquipamentosScreen(),
  ));
}
