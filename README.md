# Carteira Digital Infantil - Meu Cofrinho

## Visão Geral do Projeto

Este é um aplicativo móvel desenvolvido em Flutter que funciona como uma conta bancária simulada para crianças. O objetivo é fornecer uma ferramenta educativa e divertida para que as crianças aprendam sobre gestão financeira, permitindo-lhes depositar, sacar e visualizar um histórico de suas transações.

## Tecnologias Utilizadas

- **Framework:** [Flutter](https://flutter.dev/)
- **Linguagem:** [Dart](https://dart.dev/)
- **Persistência e autenticação:** Firebase Authentication e Cloud Firestore. As contas e transações são isoladas por usuário.
- **Visualização de Dados:** [fl_chart](https://pub.dev/packages/fl_chart) para exibir o histórico de saldo em um gráfico de linhas.

## Arquitetura

O projeto segue uma estrutura padrão do Flutter, com uma clara separação de responsabilidades:

- **`lib/models`**: Contém o modelo de dados da aplicação (`AppTransaction`).
- **`lib/screens`**: Agrupa todas as telas da interface do usuário (UI), como a tela inicial, de depósito, de saque e de histórico.
- **`lib/services`**: Inclui os serviços que encapsulam a lógica de negócios e a persistência de dados.
  - `storage_service.dart`: Atua como uma fonte única de verdade para o saldo e as transações, abstraindo o uso do `shared_preferences`.
- **`lib/widgets`**: Contém componentes de UI reutilizáveis.

### Gerenciamento de Estado

O estado da aplicação é gerenciado de forma simples, utilizando `StatefulWidget`. A atualização dos dados entre as telas é feita através de um mecanismo de callback. Por exemplo, ao retornar da tela de depósito para a tela inicial, um método `refresh()` é chamado para recarregar os dados do `StorageService` e atualizar a interface.

## TODO List

- Modo multi-filhos! Uma conta para cada com uma seleção de filho na tela inicial

## Configuração Firebase

O app usa Firebase Authentication com e-mail e senha e salva os dados no Cloud Firestore em `users/{uid}/accounts`, com transações em uma subcoleção de cada conta. A configuração de plataforma fica em `lib/firebase_options.dart` e `android/app/google-services.json`.

Ative o provedor **E-mail/senha** no Firebase Authentication e crie o banco Cloud Firestore no projeto. Para instalar as regras de acesso definidas em `firestore.rules`, execute:

```bash
firebase deploy --only firestore:rules --project my-kid-money
```

As regras permitem que cada usuário autenticado acesse somente os próprios documentos. Os dados que já estavam no SharedPreferences não são importados; ao entrar pela primeira vez, o app cria a conta padrão no Firestore.

## Como Executar o Projeto

### 1. Instalar Dependências

Antes de executar, instale as dependências necessárias com o seguinte comando:

```bash
flutter pub get
```

### 2. Executar o Aplicativo

Você pode rodar o aplicativo em um dispositivo conectado ou em um emulador:

```bash
flutter run
```
