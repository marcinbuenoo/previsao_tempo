import 'package:flutter/material.dart';
import '../models/previsao.dart';
import '../utils/tempo_utils.dart';

class DiaCard extends StatelessWidget {
  const DiaCard({super.key, required this.dia, this.destaque = false});
  final DiaPrevisao dia;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final codigo = dia.tempo.toLowerCase();
    final descricao = condicoesTempo[codigo] ?? (codigo.isEmpty ? 'Condição não informada' : 'Condição: ${dia.tempo}');
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: destaque ? const Color(0xffe7f4f3) : Colors.white, borderRadius: BorderRadius.circular(19),
        border: Border.all(color: destaque ? const Color(0xffd2eae8) : const Color(0xffe8edef))),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .8), borderRadius: BorderRadius.circular(15)),
          child: Icon(iconeTempo(codigo), size: 27, color: const Color(0xff087f8c))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dataLegivel(dia.data), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xff18383d))),
          const SizedBox(height: 3), Text(descricao, style: const TextStyle(fontSize: 12, color: Color(0xff637579))),
          if (dia.iuv != null) Padding(padding: const EdgeInsets.only(top: 7), child: Row(children: [
            const Icon(Icons.wb_sunny_outlined, size: 14, color: Color(0xffc58a22)), const SizedBox(width: 4),
            Text('UV ${dia.iuv!.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11, color: Color(0xff8c641d), fontWeight: FontWeight.w600)),
          ])),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${dia.maxima?.toString() ?? '—'}°', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xff18383d))),
          Text('${dia.minima?.toString() ?? '—'}° mín.', style: const TextStyle(fontSize: 12, color: Color(0xff718185))),
        ]),
      ]));
  }
}
