// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class Equipment {
//   String nome;
//   String modelo;
//   String tamanho;
//   String patrimonio;
//   String marca;
//   bool disponivel;
//   bool alugado;
//   String hostname;
//   DateTime? dataDisponivel;
//   DateTime? dataAluguel;
//   DateTime? dataDevolucao;
//   String? alugadoPor;

//   Equipment({
//     required this.nome,
//     required this.modelo,
//     required this.tamanho,
//     required this.patrimonio,
//     required this.marca,
//     required this.disponivel,
//     required this.alugado,
//     required this.hostname,
//     this.dataDisponivel,
//     this.dataAluguel,
//     this.dataDevolucao,
//     this.alugadoPor,
//   });

//   factory Equipment.fromJson(Map<String, dynamic> json) {
//     return Equipment(
//       nome: json['nome'],
//       modelo: json['modelo'],
//       tamanho: json['tamanho'],
//       patrimonio: json['patrimonio'],
//       marca: json['marca'],
//       disponivel: json['disponivel'],
//       alugado: !json['disponivel'],
//       hostname: json['hostname'],
//       dataDisponivel: json['dataDisponivel'] != null ? DateTime.parse(json['dataDisponivel']) : null,
//       dataAluguel: json['dataAluguel'] != null ? DateTime.parse(json['dataAluguel']) : null,
//       dataDevolucao: json['dataDevolucao'] != null ? DateTime.parse(json['dataDevolucao']) : null,
//       alugadoPor: json['alugadoPor'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'nome': nome,
//       'modelo': modelo,
//       'tamanho': tamanho,
//       'patrimonio': patrimonio,
//       'marca': marca,
//       'disponivel': disponivel,
//       'hostname': hostname,
//       'dataDisponivel': dataDisponivel?.toIso8601String(),
//       'dataAluguel': dataAluguel?.toIso8601String(),
//       'dataDevolucao': dataDevolucao?.toIso8601String(),
//       'alugadoPor': alugadoPor,
//     };
//   }
// }

// Future<List<Equipment>> fetchEquipments() async {
//   final response = await http.get(Uri.parse('https://proativa.onrender.com/equipamentos'));

//   if (response.statusCode == 200) {
//     List jsonResponse = json.decode(response.body);
//     return jsonResponse.map((equipment) => Equipment.fromJson(equipment)).toList();
//   } else {
//     throw Exception('Falha ao carregar equipamentos');
//   }
// }

// Future<void> addEquipment(Equipment equipment) async {
//   final response = await http.post(
//     Uri.parse('https://proativa.onrender.com/equipamentos'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(equipment.toJson()),
//   );

//   if (response.statusCode != 201) {
//     throw Exception('Falha ao adicionar equipamento');
//   }
// }

// Future<void> updateEquipment(String id, Equipment equipment) async {
//   final response = await http.put(
//     Uri.parse('https://proativa.onrender.com/equipamentos/$id'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(equipment.toJson()),
//   );

//   if (response.statusCode != 200) {
//     throw Exception('Falha ao atualizar equipamento');
//   }
// }

// Future<void> deleteEquipment(String id) async {
//   final response = await http.delete(
//     Uri.parse('https://proativa.onrender.com/equipamentos/$id'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//   );

//   if (response.statusCode != 204) {
//     throw Exception('Falha ao deletar equipamento');
//   }
// }
