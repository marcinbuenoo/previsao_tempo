import 'package:flutter/material.dart';
import '../models/previsao.dart';
import '../utils/tempo_utils.dart';

class DiaCard extends StatelessWidget {
  const DiaCard({super.key, required this.dia, this.destaque = false});
  final DiaPrevisao dia;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final codigo = dia.tempo.toLowerCase();
    final descricao = condicoesTempo[codigo] ?? (codigo.isEmpty ? 'Condição não informada' : 'Condição: ${dia.tempo}');
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: destaque ? scheme.primaryContainer : scheme.surface, borderRadius: BorderRadius.circular(19),
        border: Border.all(color: destaque ? scheme.primary.withValues(alpha: .25) : scheme.outlineVariant)),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: scheme.surface.withValues(alpha: .85), borderRadius: BorderRadius.circular(15)),
          child: Icon(iconeTempo(codigo), size: 27, color: scheme.primary)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dataLegivel(dia.data), style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
          const SizedBox(height: 3), Text(descricao, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          if (dia.iuv != null) Padding(padding: const EdgeInsets.only(top: 7), child: Row(children: [
            Icon(Icons.wb_sunny_outlined, size: 14, color: scheme.tertiary), const SizedBox(width: 4),
            Text('UV ${dia.iuv!.toStringAsFixed(1)}', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ])),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${dia.maxima?.toString() ?? '—'}°', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: scheme.onSurface)),
          Text('${dia.minima?.toString() ?? '—'}° mín.', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ]),
      ]));
  }
}
