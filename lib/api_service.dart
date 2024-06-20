import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://suaapi.com";

  Future<List<String>> getEquipamentos() async {
    final response = await http.get(Uri.parse('$baseUrl/equipamentos'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((equipamento) => equipamento.toString()).toList();
    } else {
      throw Exception('Failed to load equipamentos');
    }
  }

  Future<void> deleteEquipamento(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/equipamentos/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete equipamento');
    }
  }

  Future<void> addEquipamento(String equipamento) async {
    final response = await http.post(
      Uri.parse('$baseUrl/equipamentos'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'equipamento': equipamento}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add equipamento');
    }
  }

  Future<void> editEquipamento(int id, String novoEquipamento) async {
    final response = await http.put(
      Uri.parse('$baseUrl/equipamentos/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'equipamento': novoEquipamento}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to edit equipamento');
    }
  }

  Future<List<String>> getPecas() async {
    final response = await http.get(Uri.parse('$baseUrl/pecas'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((peca) => peca.toString()).toList();
    } else {
      throw Exception('Failed to load pecas');
    }
  }

  Future<void> deletePeca(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/pecas/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete peca');
    }
  }

  Future<void> addPeca(String peca) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pecas'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'peca': peca}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add peca');
    }
  }

  Future<void> editPeca(int id, String novaPeca) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pecas/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'peca': novaPeca}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to edit peca');
    }
  }

  Future<List<String>> getFuros() async {
    final response = await http.get(Uri.parse('$baseUrl/furos'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((furo) => furo.toString()).toList();
    } else {
      throw Exception('Failed to load furos');
    }
  }

  Future<void> deleteFuro(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/furos/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete furo');
    }
  }

  Future<void> addFuro(String furo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/furos'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'furo': furo}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add furo');
    }
  }

  Future<void> editFuro(int id, String novoFuro) async {
    final response = await http.put(
      Uri.parse('$baseUrl/furos/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'furo': novoFuro}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to edit furo');
    }
  }

  Future<List<String>> getFuncionarios() async {
    final response = await http.get(Uri.parse('$baseUrl/funcionarios'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((funcionario) => funcionario.toString()).toList();
    } else {
      throw Exception('Failed to load funcionarios');
    }
  }

  Future<void> deleteFuncionario(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/funcionarios/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete funcionario');
    }
  }

  Future<void> addFuncionario(String funcionario) async {
    final response = await http.post(
      Uri.parse('$baseUrl/funcionarios'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'funcionario': funcionario}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add funcionario');
    }
  }

  Future<void> editFuncionario(int id, String novoFuncionario) async {
    final response = await http.put(
      Uri.parse('$baseUrl/funcionarios/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'funcionario': novoFuncionario}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to edit funcionario');
    }
  }
}
