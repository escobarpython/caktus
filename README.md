# 🌵 Caktus | 2023 - 2024 - 2025
 
![Status](https://img.shields.io/badge/Status-In%20Development-orange)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange?logo=swift)
![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey?logo=apple)

O **Caktus** é um aplicativo iOS inovador projetado para monitorar a saúde e a atividade de suas plantas em tempo real. Combinando conectividade de hardware e Inteligência Artificial proprietária, o Caktus transforma dados técnicos em dicas práticas para o cuidado botânico.

> **Nota:** Este repositório contém a versão **Demo** do aplicativo, demonstrando toda a interface, fluxo de usuário e integração com a IA.

---

## 📱 Funcionalidades Principais

* **Autenticação:** Tela de login para gestão personalizada de jardins.
* **Conexão Bluetooth (BLE):** Interface pronta para pareamento com o sensor físico (em desenvolvimento) para coleta de dados de umidade, luz e temperatura.
* **Gestão de Coleção:**
    * Adição de plantas com fotos e nomes personalizados.
    * Exibição automática do **nome científico** abaixo do apelido dado à planta.
* **Dashboard de Monitoramento:**
    * Visualização de métricas vitais.
    * Explicações personalizadas: O app interpreta o que os dados significam especificamente para cada espécie.
* **Relatórios com IA:**
    * Sistema de IA treinado para gerar diagnósticos de saúde.
    * Busca inteligente de plantas por descrição ou características.
* **Dicas Customizadas:** Sugestões diárias baseadas nas necessidades individuais de cada planta cadastrada.

---

## 🛠️ Tecnologias Utilizadas

* **Linguagem:** [Swift](https://developer.apple.com/swift/)
* **Interface:** SwiftUI / UIKit
* **Hardware Sync:** Core Bluetooth (BLE)
* **Inteligência Artificial:** Modelo proprietário treinado para botânica e identificação.

---

## 📂 Estrutura do App

O app está organizado nos seguintes módulos principais:

1.  **Onboarding/Login:** Entrada do usuário.
2.  **Bluetooth Manager:** Tela de busca e conexão com sensores.
3.  **My Garden:** Listagem de todas as plantas monitoradas.
4.  **Plant Details:** Tela profunda com gráficos, status e o "significado" dos dados.
5.  **AI Lab:** Área de relatórios gerados por inteligência artificial e busca avançada.

---

## 🚀 Como Executar o Projeto

1.  Certifique-se de ter o **Xcode** instalado (versão estável mais recente).
2.  Clone este repositório:
    ```bash
    git clone [https://github.com/escobarpython/caktus.git](https://github.com/escobarpython/caktus.git)
    ```
3.  Abra o arquivo `.xcodeproj` ou `.xcworkspace` no Xcode.
4.  Selecione um simulador de iPhone ou um dispositivo real.
5.  Pressione `Cmd + R` para rodar.

*Obs: A funcionalidade de Bluetooth requer um dispositivo físico para escanear periféricos reais.*

---

## 🛠 Status do Projeto

- [x] UI/UX das telas principais.
- [x] Integração com modelo de IA (Demo).
- [x] Lógica de identificação de nomes científicos.
- [ ] Finalização do Hardware físico.
- [ ] Integração final Sensor <-> App.

---

## 👤 Desenvolvedor

Projeto desenvolvido por **Progressus** | Pedro Escobar (dev) - [GitHub Profile](https://github.com/escobarpython)

---
*Caktus: Porque sua planta não fala, mas a gente traduz.* 🪴
