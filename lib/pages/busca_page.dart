import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/previsao.dart';
import '../services/cptec_service.dart';
import '../services/favoritos_service.dart';
import '../widgets/theme_actions.dart';
import 'previsao_page.dart';

class BuscaPage extends StatefulWidget {
  const BuscaPage({super.key});
  @override
  State<BuscaPage> createState() => _BuscaPageState();
}

class _BuscaPageState extends State<BuscaPage> {
  final _controller = TextEditingController();
  List<Cidade> _cidades = [];
  List<Cidade> _favoritos = [];
  bool _buscando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    final favoritos = await FavoritosService.listar();
    if (mounted) setState(() => _favoritos = favoritos);
  }

  Future<void> _alternarFavorito(Cidade cidade) async {
    final favoritos = await FavoritosService.alternar(cidade);
    if (mounted) setState(() => _favoritos = favoritos);
  }

  Future<void> _buscar() async {
    final termo = _controller.text.trim();
    if (termo.isEmpty) {
      setState(() => _erro = 'Digite o nome de uma cidade.');
      return;
    }
    setState(() { _buscando = true; _erro = null; _cidades = []; });
    try {
      final encontrados = await CptecService.buscarCidades(termo);
      if (mounted) setState(() {
        _cidades = encontrados;
        if (encontrados.isEmpty) _erro = 'Nenhuma cidade encontrada. Tente outro nome.';
      });
    } catch (_) {
      if (mounted) setState(() => _erro = 'Não foi possível consultar o serviço. Verifique sua conexão e tente novamente.');
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          tooltip: dark ? 'Ativar modo claro' : 'Ativar modo escuro',
          icon: Icon(dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          onPressed: ThemeActions.of(context).onToggle,
        ),
        const SizedBox(width: 8),
      ]),
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverPadding(padding: const EdgeInsets.fromLTRB(22, 18, 22, 22), sliver: SliverList(delegate: SliverChildListDelegate([
          Container(height: 112, decoration: BoxDecoration(
            gradient: LinearGradient(colors: dark ? const [Color(0xff29292c), Color(0xff171719)] : const [Color(0xff087f8c), Color(0xff36a6a2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(26)),
            child: Stack(children: [
              const Positioned(right: 20, top: 18, child: Icon(Icons.wb_cloudy_rounded, size: 78, color: Color(0x66ffffff))),
              Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('CLIMA POR AÍ', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.bold)),
                const SizedBox(height: 7), Text('Encontre sua cidade', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ])),
            ])),
          const SizedBox(height: 27),
          Text('Previsão do tempo', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface)),
          const SizedBox(height: 7), Text('Pesquise uma cidade brasileira para ver os próximos dias.', style: TextStyle(color: scheme.onSurfaceVariant)),
          if (_favoritos.isNotEmpty) ...[
            const SizedBox(height: 23),
            Text('CIDADES FAVORITAS  ·  ${_favoritos.length}', style: TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            ..._favoritos.map((cidade) => Card(
              margin: const EdgeInsets.only(bottom: 8), elevation: 0, color: scheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17), side: BorderSide(color: scheme.outlineVariant)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Icon(Icons.star_rounded, color: scheme.tertiary),
                title: Text(cidade.nome, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${cidade.uf}  ·  Código ${cidade.id}', style: TextStyle(color: scheme.onSurfaceVariant)),
                trailing: IconButton(tooltip: 'Remover dos favoritos', icon: const Icon(Icons.close_rounded), onPressed: () => _alternarFavorito(cidade)),
                onTap: () => _abrirPrevisao(cidade),
              ),
            )),
          ],
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
            Text('RESULTADOS  ·  ${_cidades.length}', style: TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 10),
          ],
        ]))),
        if (!_buscando && _cidades.isNotEmpty) SliverPadding(padding: const EdgeInsets.fromLTRB(22, 0, 22, 20), sliver: SliverList.builder(
          itemCount: _cidades.length, itemBuilder: (context, index) {
            final cidade = _cidades[index];
            return Card(margin: const EdgeInsets.only(bottom: 9), elevation: 0, color: scheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17), side: BorderSide(color: scheme.outlineVariant)),
              child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(13)),
                  child: Icon(Icons.location_on_outlined, color: scheme.onPrimaryContainer)),
                title: Text(cidade.nome, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${cidade.uf}  ·  Código ${cidade.id}', style: TextStyle(color: scheme.onSurfaceVariant)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    tooltip: _favoritos.any((item) => item.id == cidade.id) ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
                    icon: Icon(_favoritos.any((item) => item.id == cidade.id) ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: _favoritos.any((item) => item.id == cidade.id) ? scheme.tertiary : scheme.onSurfaceVariant),
                    onPressed: () => _alternarFavorito(cidade),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: scheme.primary),
                ]), onTap: () => _abrirPrevisao(cidade)));
          })),
        SliverFillRemaining(hasScrollBody: false, child: Padding(padding: const EdgeInsets.only(bottom: 18), child: Align(alignment: Alignment.bottomCenter,
          child: Text('DADOS METEOROLÓGICOS  ·  CPTEC/INPE', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w600))))),
      ])),
    );
  }
}

class _MensagemBusca extends StatelessWidget {
  const _MensagemBusca({required this.texto, required this.erro});
  final String texto;
  final bool erro;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = erro ? scheme.errorContainer : scheme.secondaryContainer;
    final foreground = erro ? scheme.onErrorContainer : scheme.onSecondaryContainer;
    return Container(margin: const EdgeInsets.only(top: 20), padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [Icon(erro ? Icons.info_outline_rounded : Icons.check_circle_outline, color: foreground), const SizedBox(width: 12), Expanded(child: Text(texto, style: TextStyle(color: foreground)))]));
  }
}
