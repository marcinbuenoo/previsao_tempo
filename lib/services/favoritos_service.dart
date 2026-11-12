import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/previsao.dart';

class FavoritosService {
  static const _chave = 'cidades_favoritas';

  static Future<List<Cidade>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chave);
    if (dados == null || dados.isEmpty) return [];
    try {
      final itens = jsonDecode(dados) as List<dynamic>;
      return itens.map((item) => Cidade(
        id: item['id'] as String,
        nome: item['nome'] as String,
        uf: item['uf'] as String,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Cidade>> alternar(Cidade cidade) async {
    final favoritos = await listar();
    final existente = favoritos.indexWhere((item) => item.id == cidade.id);
    if (existente >= 0) {
      favoritos.removeAt(existente);
    } else {
      favoritos.add(cidade);
      favoritos.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, jsonEncode(favoritos.map((item) => {
      'id': item.id,
      'nome': item.nome,
      'uf': item.uf,
    }).toList()));
    return favoritos;
  }
}
