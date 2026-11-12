import 'package:flutter/material.dart';
import '../models/previsao.dart';
import '../services/cptec_service.dart';
import '../widgets/dia_card.dart';
import '../widgets/grafico_temperatura.dart';
import '../utils/tempo_utils.dart';

class PrevisaoPage extends StatefulWidget {
  const PrevisaoPage({super.key, required this.cidade});
  final Cidade cidade;
  @override
  State<PrevisaoPage> createState() => _PrevisaoPageState();
}

class _PrevisaoPageState extends State<PrevisaoPage> {
  Previsao? _previsao;
  String? _erro;
  bool _carregando = true;

  @override
  void initState() { super.initState(); _atualizar(); }

  Future<void> _atualizar() async {
    setState(() { _carregando = true; _erro = null; });
    try {
      final previsao = await CptecService.previsao(widget.cidade);
      if (mounted) setState(() { _previsao = previsao; if (previsao.dias.isEmpty) _erro = 'Não há previsão disponível para esta cidade.'; });
    } catch (_) {
      if (mounted) setState(() => _erro = 'Não foi possível carregar a previsão. Verifique sua conexão e tente novamente.');
    } finally { if (mounted) setState(() => _carregando = false); }
  }

  @override
  Widget build(BuildContext context) {
    final previsao = _previsao;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Voltar à busca', icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Previsão', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [IconButton(tooltip: 'Atualizar previsão', onPressed: _carregando ? null : _atualizar, icon: const Icon(Icons.refresh_rounded)), const SizedBox(width: 6)],
      ),
      body: _carregando && previsao == null
        ? const Center(child: CircularProgressIndicator())
        : previsao == null || previsao.dias.isEmpty
          ? _EstadoErro(texto: _erro ?? 'Previsão indisponível', aoTentar: _atualizar)
          : RefreshIndicator(onRefresh: _atualizar, child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 28), children: [
              _CabecalhoCidade(previsao: previsao, carregando: _carregando),
              const SizedBox(height: 22),
              Row(children: [
                const Expanded(child: Text('PRÓXIMOS DIAS', style: TextStyle(fontSize: 12, letterSpacing: 1.3, fontWeight: FontWeight.w800, color: Color(0xff637579)))),
                if (_carregando) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
              ]),
              const SizedBox(height: 11),
              ...previsao.dias.asMap().entries.map((entry) => DiaCard(dia: entry.value, destaque: entry.key == 0)),
              if (previsao.dias.any((d) => d.minima != null || d.maxima != null)) ...[
                const SizedBox(height: 10), GraficoTemperatura(dias: previsao.dias),
              ],
              const SizedBox(height: 22),
              const Text('Fonte: CPTEC/INPE', textAlign: TextAlign.center, style: TextStyle(color: Color(0xff718185), fontSize: 12)),
            ])),
    );
  }
}

class _CabecalhoCidade extends StatelessWidget {
  const _CabecalhoCidade({required this.previsao, required this.carregando});
  final Previsao previsao;
  final bool carregando;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff087f8c), Color(0xff36a6a2)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(25)),
    child: Stack(children: [
      const Positioned(right: 0, top: 0, child: Icon(Icons.wb_cloudy_rounded, color: Color(0x44ffffff), size: 88)),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CIDADE SELECIONADA', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 7),
        Text('${previsao.nome}/${previsao.uf}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
        const SizedBox(height: 13),
        Row(children: [const Icon(Icons.update_rounded, size: 16, color: Colors.white70), const SizedBox(width: 6),
          Text('Atualizado em ${dataLegivel(previsao.atualizacao)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
          if (carregando) ...[const SizedBox(width: 10), const SizedBox(width: 13, height: 13, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))],
        ]),
      ]),
    ]));
}

class _EstadoErro extends StatelessWidget {
  const _EstadoErro({required this.texto, required this.aoTentar});
  final String texto;
  final VoidCallback aoTentar;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.cloud_off_rounded, size: 52, color: Color(0xff829397)), const SizedBox(height: 16), Text(texto, textAlign: TextAlign.center),
    const SizedBox(height: 18), OutlinedButton.icon(onPressed: aoTentar, icon: const Icon(Icons.refresh_rounded), label: const Text('Tentar novamente')),
  ])));
}
