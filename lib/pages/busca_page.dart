import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/previsao.dart';
import '../services/cptec_service.dart';
import 'previsao_page.dart';

class BuscaPage extends StatefulWidget {
  const BuscaPage({super.key});
  @override
  State<BuscaPage> createState() => _BuscaPageState();
}

class _BuscaPageState extends State<BuscaPage> {
  final _controller = TextEditingController();
  List<Cidade> _cidades = [];
  bool _buscando = false;
  String? _erro;

  Future<void> _buscar() async {
    final termo = _controller.text.trim();
    if (termo.isEmpty) { setState(() => _erro = 'Digite o nome de uma cidade.'); return; }
    setState(() { _buscando = true; _erro = null; _cidades = []; });
    try {
      final encontrados = await CptecService.buscarCidades(termo);
      if (mounted) setState(() { _cidades = encontrados; if (encontrados.isEmpty) _erro = 'Nenhuma cidade encontrada. Tente outro nome.'; });
    } catch (_) {
      if (mounted) setState(() => _erro = 'Não foi possível consultar o serviço. Verifique sua conexão e tente novamente.');
    } finally { if (mounted) setState(() => _buscando = false); }
  }

  Future<void> _abrirPrevisao(Cidade cidade) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cidade_id', cidade.id);
    await prefs.setString('cidade_nome', cidade.nome);
    await prefs.setString('cidade_uf', cidade.uf);
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => PrevisaoPage(cidade: cidade)));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: CustomScrollView(slivers: [
      SliverPadding(padding: const EdgeInsets.fromLTRB(22, 34, 22, 22), sliver: SliverList(delegate: SliverChildListDelegate([
        Container(height: 112, decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xff087f8c), Color(0xff36a6a2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(26)),
          child: Stack(children: [
            const Positioned(right: 20, top: 18, child: Icon(Icons.wb_cloudy_rounded, size: 78, color: Color(0x66ffffff))),
            Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('CLIMA POR AÍ', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.bold)),
              const SizedBox(height: 7), Text('Encontre sua cidade', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ])),
          ])),
        const SizedBox(height: 27),
        Text('Previsão do tempo', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xff18383d))),
        const SizedBox(height: 7), const Text('Pesquise uma cidade brasileira para ver os próximos dias.', style: TextStyle(color: Color(0xff637579))),
        const SizedBox(height: 22),
        TextField(controller: _controller, textInputAction: TextInputAction.search, onSubmitted: (_) => _buscar(),
          decoration: const InputDecoration(hintText: 'Nome da cidade', prefixIcon: Icon(Icons.search_rounded))),
        const SizedBox(height: 12),
        SizedBox(height: 52, child: FilledButton.icon(onPressed: _buscando ? null : _buscar,
          icon: const Icon(Icons.travel_explore_rounded), label: const Text('Buscar cidade', style: TextStyle(fontWeight: FontWeight.w700)))),
        if (_buscando) const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
        if (_erro != null && !_buscando) _MensagemBusca(texto: _erro!, erro: _cidades.isEmpty),
        if (_cidades.isNotEmpty) ...[
          const SizedBox(height: 27),
          Text('RESULTADOS  ·  ${_cidades.length}', style: const TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: Color(0xff637579))),
          const SizedBox(height: 10),
        ],
      ]))),
      if (!_buscando && _cidades.isNotEmpty) SliverPadding(padding: const EdgeInsets.fromLTRB(22, 0, 22, 20), sliver: SliverList.builder(
        itemCount: _cidades.length, itemBuilder: (context, index) {
          final cidade = _cidades[index];
          return Card(margin: const EdgeInsets.only(bottom: 9), elevation: 0, color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17), side: const BorderSide(color: Color(0xffe7edef))),
            child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xffe6f4f3), borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.location_on_outlined, color: Color(0xff087f8c))),
              title: Text(cidade.nome, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(' ${cidade.uf}  ·  Código ${cidade.id}', style: const TextStyle(color: Color(0xff718185))),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xff087f8c)), onTap: () => _abrirPrevisao(cidade)));
        })),
      SliverFillRemaining(hasScrollBody: false, child: Padding(padding: const EdgeInsets.only(bottom: 18), child: Align(alignment: Alignment.bottomCenter,
        child: Text('DADOS METEOROLÓGICOS  ·  CPTEC/INPE', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w600))))),
    ])),
  );
}

class _MensagemBusca extends StatelessWidget {
  const _MensagemBusca({required this.texto, required this.erro});
  final String texto;
  final bool erro;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(top: 20), padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: erro ? const Color(0xfffff3ed) : const Color(0xffeaf5f4), borderRadius: BorderRadius.circular(18)),
    child: Row(children: [Icon(erro ? Icons.info_outline_rounded : Icons.check_circle_outline, color: const Color(0xff087f8c)), const SizedBox(width: 12), Expanded(child: Text(texto))]));
}
