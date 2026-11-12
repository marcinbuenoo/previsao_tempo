import 'package:flutter/material.dart';

const condicoesTempo = <String, String>{
  'ec':'Encoberto com chuvas isoladas','ci':'Chuvas isoladas','c':'Chuva','in':'Instável','pp':'Possibilidade de pancadas de chuva',
  'cm':'Chuva pela manhã','cn':'Chuva à noite','pt':'Pancadas de chuva à tarde','pm':'Pancadas de chuva pela manhã','np':'Nublado e pancadas de chuva',
  'pc':'Pancadas de chuva','pn':'Parcialmente nublado','cv':'Chuvisco','ch':'Chuvoso','t':'Tempestade','ps':'Predomínio de sol',
  'e':'Encoberto','n':'Nublado','cl':'Céu claro','nv':'Nevoeiro','g':'Geada','ne':'Neve','nd':'Não definido','pnt':'Pancadas de chuva à noite',
  'psc':'Possibilidade de chuva','pcm':'Possibilidade de chuva pela manhã','pct':'Possibilidade de chuva à tarde','pcn':'Possibilidade de chuva à noite',
  'npt':'Nublado com pancadas à tarde','npn':'Nublado com pancadas à noite','ncn':'Nublado com possibilidade de chuva à noite',
  'nct':'Nublado com possibilidade de chuva à tarde','ncm':'Nublado com possibilidade de chuva pela manhã','npm':'Nublado com pancadas pela manhã',
  'npp':'Nublado com possibilidade de chuva','vn':'Variação de nebulosidade',
};

IconData iconeTempo(String codigo) {
  if (['c','ci','ec','in','pp','cm','cn','pt','pm','np','pc','cv','ch','t','pnt','psc','pcm','pct','pcn','npt','npn','ncn','nct','ncm','npm','npp'].contains(codigo)) return Icons.thunderstorm_rounded;
  if (['ps','cl'].contains(codigo)) return Icons.wb_sunny_rounded;
  if (['n','e','pn','vn'].contains(codigo)) return Icons.cloud_rounded;
  if (codigo == 'nv') return Icons.foggy;
  if (codigo == 'ne') return Icons.ac_unit;
  return Icons.cloud_queue_rounded;
}

String dataLegivel(String value) {
  final d = DateTime.tryParse(value);
  if (d == null) return value.isEmpty ? 'Data não informada' : value;
  const meses = ['jan','fev','mar','abr','mai','jun','jul','ago','set','out','nov','dez'];
  return '${d.day} ${meses[d.month - 1]} ${d.year}';
}

String diaCurto(String value) {
  final d = DateTime.tryParse(value);
  return d == null ? '' : '${d.day}/${d.month}';
}
