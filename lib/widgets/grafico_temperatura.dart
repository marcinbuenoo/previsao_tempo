import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/previsao.dart';
import '../utils/tempo_utils.dart';

class GraficoTemperatura extends StatelessWidget {
  const GraficoTemperatura({super.key, required this.dias});
  final List<DiaPrevisao> dias;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
    decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(21), border: Border.all(color: scheme.outlineVariant)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Temperaturas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: scheme.onSurface)),
      const SizedBox(height: 3), Text('Mínima e máxima previstas · °C', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
      const SizedBox(height: 18),
      SizedBox(height: 185, child: LineChart(LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10,
          getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant.withValues(alpha: .6), strokeWidth: 1)),
        borderData: FlBorderData(show: false), minX: 0, maxX: (dias.length - 1).toDouble(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34,
            getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)))),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (v, _) {
            final i = v.toInt();
            return i >= 0 && i < dias.length ? Padding(padding: const EdgeInsets.only(top: 8), child: Text(diaCurto(dias[i].data), style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant))) : const SizedBox.shrink();
          })),
        ),
        lineBarsData: [_linha(dias, (d) => d.maxima, const Color(0xffe78b58)), _linha(dias, (d) => d.minima, const Color(0xff168f94))],
      ))),
      const SizedBox(height: 13),
      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Legenda(cor: Color(0xffe78b58), texto: 'Máxima'), SizedBox(width: 22), _Legenda(cor: Color(0xff168f94), texto: 'Mínima'),
      ]),
    ]));
  }
}

LineChartBarData _linha(List<DiaPrevisao> dias, int? Function(DiaPrevisao) valor, Color cor) => LineChartBarData(
  spots: [for (var i = 0; i < dias.length; i++) if (valor(dias[i]) != null) FlSpot(i.toDouble(), valor(dias[i])!.toDouble())],
  isCurved: true, color: cor, barWidth: 3, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: false));

class _Legenda extends StatelessWidget {
  const _Legenda({required this.cor, required this.texto});
  final Color cor;
  final String texto;
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)), const SizedBox(width: 6), Text(texto, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))]);
}
