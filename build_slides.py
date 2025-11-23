#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "jinja2",
#     "touying",
# ]
#
# [tool.uv.sources]
# touying = { git = "https://github.com/AlanJs26/touying-exporter", rev = "4018d0d2b7daad7c7b261f82cc66a061d080c31b" }
#
# ///

import os
import subprocess
from jinja2 import Environment, select_autoescape

try:
    from touying import to_html
except ImportError:
    to_html = None  # Set to None if touying is not available


# --- Configuração ---
INDEX_TEMPLATE_STRING = """
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard de Slides Typst</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            margin: 2em;
            background-color: #f8f9fa;
            color: #212529;
        }
        h1 {
            color: #343a40;
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            margin: 0.5em 0;
        }
        a {
            text-decoration: none;
            color: #007bff;
            background-color: #ffffff;
            padding: 0.75em 1.25em;
            border: 1px solid #dee2e6;
            border-radius: 0.25rem;
            display: block;
            transition: background-color 0.2s, border-color 0.2s;
        }
        a:hover {
            background-color: #e9ecef;
            border-color: #ced4da;
        }
    </style>
</head>
<body>
    <h1>Apresentações de Slides</h1>
    <p>Clique em um link para visualizar a apresentação correspondente.</p>
    <ul>
        {% for slide in slides %}
        <li><a href="{{ slide.path }}" target="_blank">{{ slide.name }}</a></li>
        {% endfor %}
    </ul>
</body>
</html>
"""
ROOT_DIR = os.getcwd()
SLIDES_FILENAME = "main.typ"
OUTPUT_FILENAME = "index.html"


def compile_slides():
    """
    Encontra todos os arquivos 'main.typ' e os compila para HTML usando 'touying.to_html()'.
    Retorna uma lista de dicionários com informações sobre os slides compilados.
    """
    if to_html is None:
        print(
            "ERRO: O módulo 'touying' não foi encontrado. Certifique-se de que as dependências do script estão configuradas corretamente para o 'uv'."
        )
        return None

    print("Iniciando a compilação dos arquivos .typ usando touying.to_html()...")
    compiled_slides_info = []

    for dirpath, _, filenames in os.walk(ROOT_DIR):
        if SLIDES_FILENAME in filenames:
            relative_dir = os.path.relpath(dirpath, ROOT_DIR)
            print(f"Encontrado '{SLIDES_FILENAME}' em '{relative_dir}'")

            typ_file_path = os.path.join(dirpath, SLIDES_FILENAME)
            html_file_path = os.path.join(dirpath, "main.html")

            try:
                # Usa a função touying.to_html() diretamente
                to_html(typ_file_path, output=html_file_path)
                print(" -> Compilado com sucesso.")

                # Armazena o caminho relativo para o dashboard
                relative_path = os.path.relpath(html_file_path, ROOT_DIR)

                # Usa o nome do diretório pai como um nome descritivo
                presentation_name = os.path.basename(dirpath)
                if not presentation_name:  # Handle case where it's in the root dir
                    presentation_name = "Apresentação Raiz"

                compiled_slides_info.append(
                    {"path": relative_path, "name": presentation_name}
                )

            except Exception as e:
                print(f"  -> ERRO: Falha na compilação para {typ_file_path}")
                print(f"     Detalhes do erro: {e}")
                # Continua para o próximo arquivo mesmo que um falhe

    return compiled_slides_info


def create_dashboard(slides_list):
    """
    Cria um dashboard index.html a partir de uma lista de caminhos de slides usando Jinja2.
    """
    if not slides_list:
        print("Nenhum slide foi compilado. A criação do dashboard foi ignorada.")
        return

    print("\nCriando o dashboard...")
    try:
        # Configuração do Jinja2
        env = Environment(loader=None, autoescape=select_autoescape(["html"]))
        template = env.from_string(INDEX_TEMPLATE_STRING)

        # Renderiza o template com a lista de slides
        output_html = template.render(slides=slides_list)

        # Escreve o arquivo do dashboard na raiz do projeto
        with open(OUTPUT_FILENAME, "w", encoding="utf-8") as f:
            f.write(output_html)
        print(f"Dashboard '{OUTPUT_FILENAME}' criado com sucesso.")

    except ImportError:
        print(" -> ERRO: Biblioteca 'jinja2' não encontrada. Certifique-se de que as dependências do script estão configuradas corretamente para o 'uv'.")
    except Exception as e:
        print(f" -> Erro ao criar o dashboard: {e}")


def main():
    """
    Função principal para orquestrar a compilação e a criação do dashboard.
    """
    slides = compile_slides()
    if slides is not None:
        create_dashboard(slides)


if __name__ == "__main__":
    main()
