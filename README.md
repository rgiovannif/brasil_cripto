# Brasil_cripto - Seu Rastreador de Criptomoedas

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=Dart&logoColor=white)
![MVVM](https://img.shields.io/badge/Architecture-MVVM-blue.svg?style=flat-square)
![GetIt](https://img.shields.io/badge/Dependency%20Injection-GetIt-brightgreen.svg?style=flat-square)
![Provider](https://img.shields.io/badge/State%20Management-Provider-blueviolet.svg?style=flat-square)
![Hive](https://img.shields.io/badge/Local%20Persistence-Hive-yellowgreen.svg?style=flat-square)
![RxDart](https://img.shields.io/badge/Reactive%20Programming-RxDart-orange.svg?style=flat-square)

## Descrição

O **Brasil_cripto** é um aplicativo Flutter desenvolvido para facilitar a busca e o acompanhamento do mercado de criptomoedas. Com uma interface intuitiva, você pode facilmente encontrar informações sobre diversas criptomoedas, visualizar seus detalhes, adicionar suas favoritas para um acompanhamento mais próximo e remover as que não te interessam mais.

## Funcionalidades Principais

* **Buscar Criptomoedas:** Encontre rapidamente qualquer criptomoeda disponível através de um sistema de busca eficiente.
* **Detalhes da Criptomoeda:** Visualize informações detalhadas sobre cada criptomoeda, como preço atual, variações percentuais, capitalização de mercado, volume e muito mais.
* **Favoritos:** Adicione criptomoedas à sua lista de favoritos para monitorar seus preços e informações de forma rápida e conveniente.
* **Gerenciar Favoritos:** Remova criptomoedas da sua lista de favoritos quando desejar.

## Arquitetura

Este projeto utiliza a arquitetura **MVVM (Model-View-ViewModel)** para separar a lógica de apresentação da interface do usuário, facilitando a manutenção, testabilidade e escalabilidade do código.

## Tecnologias Utilizadas

* **Flutter:** Framework de desenvolvimento de interface do usuário do Google para construir aplicativos nativamente compilados para mobile, web e desktop a partir de uma única base de código.
* **Dart:** Linguagem de programação utilizada pelo Flutter.
* **GetIt:** Um gerenciador de dependências simples para Dart e Flutter, utilizado para implementar a **Injeção de Dependência**, tornando o código mais desacoplado e testável.
* **Provider:** Um pacote popular para gerenciamento de estado no Flutter, utilizado para fornecer dados e lógica para a interface do usuário de forma reativa.
* **Hive:** Um banco de dados NoSQL leve e rápido para Dart e Flutter, utilizado para a **persistência de dados locais**, como a lista de criptomoedas favoritas.
* **RxDart:** Uma biblioteca que adiciona recursos de programação reativa (Streams) ao Dart, utilizada para lidar com fluxos de dados assíncronos de forma mais elegante.
* **API CoinGecko:** A API pública da [CoinGecko](https://www.coingecko.com/en/api) é utilizada como fonte primária para obter informações sobre as criptomoedas.

## Pré-requisitos

Antes de executar ou desenvolver o projeto, você precisará ter as seguintes ferramentas instaladas em sua máquina:

* **Flutter SDK:** Certifique-se de ter o SDK do Flutter instalado e configurado corretamente. Você pode seguir as instruções de instalação no [site oficial do Flutter](https://flutter.dev/docs/get-started/install).
* **Ambiente de Desenvolvimento:** Um ambiente de desenvolvimento integrado (IDE) como:
    * **Android Studio:** Recomendado para desenvolvimento Android.
    * **Xcode:** Necessário para desenvolvimento iOS (em um Mac).
    * **Visual Studio Code (VS Code):** Com os plugins Flutter e Dart instalados.
* **Git:** Para versionamento de código e clonagem do repositório.

## Como Executar o Projeto

1.  **Clone o repositório:**
    ```bash
    git clone [LINK_DO_SEU_REPOSITORIO]
    cd [NOME_DO_SEU_PROJETO]
    ```
    *(Substitua `[LINK_DO_SEU_REPOSITORIO]` pelo link do seu repositório Git e `[NOME_DO_SEU_PROJETO]` pelo nome da pasta do seu projeto).*

2.  **Obtenha as dependências:**
    ```bash
    flutter pub get
    ```

3.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```
    Este comando irá construir e executar o aplicativo no seu dispositivo conectado ou emulador/simulador configurado.

## Contato

[Rodrigo Ferreira]
[rgiovannif@gmail.com]
[(https://www.linkedin.com/in/rodrigogiovanniferreira/)]
