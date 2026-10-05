# Instruções para agentes

## Projeto

- App Flutter/Dart de educação financeira infantil. O SDK Dart requerido está declarado em `pubspec.yaml`.
- Leia o [README](README.md) para a visão geral, arquitetura e configuração funcional; não duplique aqui detalhes já documentados.
- Código da aplicação em `lib/`: `screens/` contém telas, `widgets/` componentes reutilizáveis, `models/` dados (`Account`, `AppTransaction`), `services/` persistência e autenticação, `theme/` tema e cores.

## Fluxo de trabalho

- Instale dependências com `flutter pub get`; valide Dart com `flutter analyze` e testes com `flutter test`. Execute o app com `flutter run` quando necessário.
- Ao alterar Dart, siga `analysis_options.yaml` e o estilo existente; use `dart format` nos arquivos modificados.
- Preserve os limites entre telas, modelos e serviços. A persistência local passa por `StorageService` (`shared_preferences`); inicialize-a antes de usar e mantenha saldos e transações consistentes.
- Ao alterar juros ou histórico financeiro, confira conjuntamente `StorageService`, `Account` e os testes relacionados. Os testes de juros podem conter expectativas antigas de descrição; não mude a regra nem enfraqueça testes sem confirmar o comportamento pretendido.
- Mantenha a interface e mensagens em português brasileiro, salvo quando a tarefa pedir outro idioma. Preserve nomes de APIs e identificadores existentes.
- Não edite `build/`, arquivos gerados ou configurações nativas de plataforma para mudanças Dart comuns. Altere Android/iOS/outras plataformas apenas quando necessário para a tarefa, especialmente ao configurar plugins nativos.
- Evite incluir segredos de `android/key.properties` ou outros arquivos locais em alterações e saídas.
