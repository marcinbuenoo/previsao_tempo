# Clima por aí — Atividade 2

Aplicativo Flutter para pesquisar cidades brasileiras e consultar a previsão de quatro dias disponibilizada pelo CPTEC/INPE.

## Funcionalidades

- Pesquisa localidades pelo nome e mostra cidade, UF e código retornado pelo serviço.
- Consulta a previsão usando o identificador da cidade fornecido pelo CPTEC/INPE.
- Exibe todos os dias retornados, data, temperaturas mínima e máxima, condição do tempo, ícone e IUV quando disponível.
- Converte as siglas meteorológicas para descrições em português conforme a tabela oficial do serviço.
- Mostra a data de atualização informada pela API, permite atualizar manualmente e puxar a tela para atualizar.
- Apresenta gráfico de linhas com temperaturas mínimas e máximas.
- Trata falhas de conexão, respostas inválidas, campos ausentes e buscas sem resultados.
- Identifica o CPTEC/INPE como fonte dos dados.

## Como executar

Requisitos: Flutter instalado e um dispositivo Android/iOS, emulador ou navegador.

```bash
flutter pub get
flutter run
```

O app consulta os endpoints do CPTEC/INPE por HTTPS. A conexão com a internet é necessária para pesquisar e atualizar previsões.

## Bibliotecas

- `http`: requisições HTTPS ao serviço CPTEC/INPE.
- `xml`: leitura das respostas XML.
- `shared_preferences`: persistência local simples da última cidade selecionada (nome, UF e código).
- `fl_chart`: gráfico de temperaturas.
- `flutter`: interface e navegação entre telas.

## Persistência local

O código e o nome da localidade selecionada, além da UF, são guardados no armazenamento de preferências do dispositivo. Ao iniciar o app, a última cidade é reaberta para mostrar sua previsão. A previsão não é armazenada em cache; os dados meteorológicos são consultados novamente no CPTEC/INPE.

## Capturas de tela

Inclua nesta seção capturas feitas no emulador ou dispositivo após executar o app. Sugestão de arquivos: `screenshots/busca.png`, `screenshots/resultados.png` e `screenshots/previsao-grafico.png`.

## Organização do código

- `lib/main.dart`: inicialização e tema global.
- `lib/pages/`: telas de busca e previsão, com navegação entre elas.
- `lib/models/`: modelos de cidade e previsão.
- `lib/services/`: comunicação HTTP e leitura do XML do CPTEC/INPE.
- `lib/widgets/`: cartão diário e gráfico de temperaturas reutilizáveis.
- `lib/utils/`: descrições das siglas e formatação de datas.

## Serviço de dados

Documentação oficial: [Serviços Web do CPTEC/INPE — XML](https://servicos.cptec.inpe.br/XML/).

- Busca: `https://servicos.cptec.inpe.br/XML/listaCidades?city=<nome>`
- Previsão de quatro dias: `https://servicos.cptec.inpe.br/XML/cidade/<codigo>/previsao.xml`
