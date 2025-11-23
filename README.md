# Projeto de Slides com Typst

Este projeto serve como um template para criar e gerenciar múltiplas apresentações de slides usando [Typst](https://typst.app/). Ele inclui um script de automação em Python que compila todas as apresentações para o formato HTML e gera um painel de controle (`index.html`) para fácil acesso.

## Recursos

- **Build Automatizado**: O script `build_slides.py` encontra e compila recursivamente todos os slides do projeto.
- **Painel de Controle Central**: Um arquivo `index.html` é gerado na raiz, listando todas as apresentações compiladas com links diretos.
- **Organização Modular**: Cada apresentação fica em seu próprio diretório, mantendo os recursos (imagens, temas) isolados e organizados.
- **Compilação Eficiente**: Utiliza a função `to_html()` da biblioteca `touying` para uma compilação rápida e direta via Python.

## Estrutura do Projeto

Cada apresentação deve estar contida em seu próprio diretório. O arquivo de entrada principal para cada apresentação **deve** ser nomeado `main.typ`.

```
/
├───Controle Não Linear Slides/
│   ├───main.typ
│   ├───theme.typ
│   └───images/
│       └───...
│
├───Outra Apresentacao/
│   ├───main.typ
│   └───...
│
├───build_slides.py
└───README.md
```

## Pré-requisitos

Antes de começar, certifique-se de que você tem o seguinte instalado:

1.  **Python 3.x**: Necessário para executar o script.
2.  **Typst**: O compilador principal. [Instruções de instalação aqui](https://github.com/typst/typst#installation).
3.  **uv**: Um gerenciador de pacotes e construtor de ambientes Python rápido. [Instruções de instalação aqui](https://astral.sh/uv/install/).

## Como Usar

1.  **Clone ou configure seu projeto** seguindo a estrutura acima.
2.  **Instale os pré-requisitos** listados (Python, Typst e uv).
3.  **Torne o script executável**:
    ```bash
    chmod +x build_slides.py
    ```
4.  **Execute o script de build** a partir do diretório raiz do projeto:
    ```bash
    ./build_slides.py
    ```
    O `uv` detectará automaticamente as dependências declaradas no script e as instalará antes de executar.
5.  **Abra o painel de controle**: Após a execução do script, um arquivo `index.html` será criado na raiz do projeto. Abra-o em seu navegador para ver a lista de todas as suas apresentações.

## Como Adicionar uma Nova Apresentação

1.  Crie um novo diretório no projeto (ex: `Minha-Nova-Apresentacao/`).
2.  Dentro deste novo diretório, crie seu arquivo de slides principal com o nome `main.typ`.
3.  Adicione seus recursos (imagens, fontes, etc.) dentro do mesmo diretório.
4.  Execute novamente o script `./build_slides.py`. Sua nova apresentação aparecerá automaticamente no `index.html`.