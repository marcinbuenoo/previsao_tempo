class Cidade {
  const Cidade({required this.id, required this.nome, required this.uf});
  final String id;
  final String nome;
  final String uf;
  String get rotulo => '$nome/$uf';
}

class DiaPrevisao {
  const DiaPrevisao({required this.data, required this.tempo, required this.minima, required this.maxima, this.iuv});
  final String data;
  final String tempo;
  final int? minima;
  final int? maxima;
  final double? iuv;
}

class Previsao {
  const Previsao({required this.nome, required this.uf, required this.atualizacao, required this.dias});
  final String nome;
  final String uf;
  final String atualizacao;
  final List<DiaPrevisao> dias;
}
