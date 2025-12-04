# Carteira Digital Infantil

## Visão Geral do Projeto

Este é um aplicativo móvel desenvolvido em Flutter que funciona como uma conta bancária simulada para crianças. O objetivo é fornecer uma ferramenta educativa e divertida para que as crianças aprendam sobre gestão financeira, permitindo-lhes depositar, sacar e visualizar um histórico de suas transações.

## Tecnologias Utilizadas

*   **Framework:** [Flutter](https://flutter.dev/)
*   **Linguagem:** [Dart](https://dart.dev/)
*   **Armazenamento Local:** [shared_preferences](https://pub.dev/packages/shared_preferences) para persistir o saldo da conta e o histórico de transações no dispositivo.
*   **Autenticação Biométrica:** [local_auth](https://pub.dev/packages/local_auth) para proteger ações como depósitos e saques com a impressão digital ou reconhecimento facial do usuário.
*   **Visualização de Dados:** [fl_chart](https://pub.dev/packages/fl_chart) para exibir o histórico de saldo em um gráfico de linhas.

## Arquitetura

O projeto segue uma estrutura padrão do Flutter, com uma clara separação de responsabilidades:

*   **`lib/models`**: Contém o modelo de dados da aplicação (`AppTransaction`).
*   **`lib/screens`**: Agrupa todas as telas da interface do usuário (UI), como a tela inicial, de depósito, de saque e de histórico.
*   **`lib/services`**: Inclui os serviços que encapsulam a lógica de negócios e a persistência de dados.
    *   `storage_service.dart`: Atua como uma fonte única de verdade para o saldo e as transações, abstraindo o uso do `shared_preferences`.
    *   `biometric_service.dart`: Abstrai a lógica de autenticação biométrica.
*   **`lib/widgets`**: Contém componentes de UI reutilizáveis.

### Gerenciamento de Estado

O estado da aplicação é gerenciado de forma simples, utilizando `StatefulWidget`. A atualização dos dados entre as telas é feita através de um mecanismo de callback. Por exemplo, ao retornar da tela de depósito para a tela inicial, um método `refresh()` é chamado para recarregar os dados do `StorageService` e atualizar a interface.

## TODO List

* Modo multi-filhos! Uma conta para cada com uma seleção de filho na tela inicial

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