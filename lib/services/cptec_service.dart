import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/previsao.dart';

class CptecService {
  static const _base = 'https://servicos.cptec.inpe.br/XML';

  static Future<List<Cidade>> buscarCidades(String termo) async {
    // A documentação do CPTEC pede o nome sem acentos. Mantemos os espaços e
    // deixamos Uri codificar o parâmetro com segurança.
    final uri = Uri.parse('$_base/listaCidades').replace(queryParameters: {'city': _semAcentos(termo)});
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) throw Exception('Serviço indisponível (${response.statusCode}).');
    final doc = _parseXml(response.body);
    return doc.findAllElements('cidade').map((e) => Cidade(
      id: _tag(e, 'id'), nome: _tag(e, 'nome'), uf: _tag(e, 'uf'),
    )).where((c) => c.id.isNotEmpty && c.nome.isNotEmpty).toList();
  }

  static Future<Previsao> previsao(Cidade cidade) async {
    final uri = Uri.parse('$_base/cidade/${cidade.id}/previsao.xml');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) throw Exception('Serviço indisponível (${response.statusCode}).');
    final root = _parseXml(response.body).rootElement;
    final dias = root.findElements('previsao').map((e) => DiaPrevisao(
      data: _tag(e, 'dia'), tempo: _tag(e, 'tempo'),
      minima: int.tryParse(_tag(e, 'minima')), maxima: int.tryParse(_tag(e, 'maxima')),
      iuv: double.tryParse(_tag(e, 'iuv').replaceAll(',', '.')),
    )).toList();
    return Previsao(nome: _tag(root, 'nome', fallback: cidade.nome), uf: _tag(root, 'uf', fallback: cidade.uf),
      atualizacao: _tag(root, 'atualizacao'), dias: dias);
  }

  static String _tag(XmlElement e, String name, {String fallback = ''}) {
    final matches = e.findElements(name);
    return matches.isEmpty ? fallback : matches.first.innerText.trim();
  }

  static XmlDocument _parseXml(String body) {
    try {
      return XmlDocument.parse(body);
    } on XmlException {
      throw const FormatException('O CPTEC/INPE retornou uma resposta inválida.');
    }
  }

  static String _semAcentos(String value) => value
      .replaceAll(RegExp('[áàâãä]'), 'a').replaceAll(RegExp('[ÁÀÂÃÄ]'), 'A')
      .replaceAll(RegExp('[éèêë]'), 'e').replaceAll(RegExp('[ÉÈÊË]'), 'E')
      .replaceAll(RegExp('[íìîï]'), 'i').replaceAll(RegExp('[ÍÌÎÏ]'), 'I')
      .replaceAll(RegExp('[óòôõö]'), 'o').replaceAll(RegExp('[ÓÒÔÕÖ]'), 'O')
      .replaceAll(RegExp('[úùûü]'), 'u').replaceAll(RegExp('[ÚÙÛÜ]'), 'U')
      .replaceAll('ç', 'c').replaceAll('Ç', 'C');
}
