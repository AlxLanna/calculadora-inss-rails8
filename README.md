# Cálculadora de Desconto INSS

O objetivo deste prjeto é criar uma aplicação web para realizar o cálculo do desconto de INSS com base no salário do proponente, permitir o cadastro de proponentes com seus respectivos endereços e contatos, e exibir um relatório/dashboard de proponentes agrupados por faixas salariais.

---


## Tecnologias Utilizadas

As principais tecnologias utilizadas neste projeto incluem:

* Ruby on Rails (versão 8.0.2)
* PostgreSQL (versão 15.3)
* Bootstrap (versão 5.x, será adicionado para o frontend)
* Docker e Docker Compose (para o ambiente de desenvolvimento)
* SolidQueue [nativo no Rails 8] (para gerenciamento de background jobs)
* RuboCop (com `rubocop-rails-omakase` para linting e formatação de código)

---
## Pré-requisitos

Antes de começar, certifique-se de que você tem os seguintes softwares instalados e configurados em sua máquina:

* [Docker Engine](https://docs.docker.com/engine/install/)
* [Docker Compose](https://docs.docker.com/compose/install/) (geralmente incluído no Docker Desktop)

---
## Configuração e Instalação do Ambiente (Docker)

Siga os passos abaixo para configurar e executar o ambiente de desenvolvimento localmente usando Docker:

1.  **Clone o Repositório:**
    * Se você ainda não o fez, clone o projeto para sua máquina local:
        ```bash
        git clone git@github.com:AlxLanna/desafio_credishop.git desafio_credishop
        cd desafio_credishop
        ```
        
2.  **Construa as Imagens Docker:**
    * Este comando irá construir a imagem para o serviço da aplicação Rails (`app`) conforme definido no `Dockerfile`.
        ```bash
        docker compose build
        ```

3.  **Inicie os Serviços Docker:**
    * Este comando iniciará os containers da aplicação (`app`) e do banco de dados (`db`) em segundo plano (`-d`).
        ```bash
        docker compose up -d
        ```

4.  **Crie e Configure o Banco de Dados:**
    * Execute os seguintes comandos para criar o banco de dados no container PostgreSQL, aplicar as migrações e popular com dados iniciais (seeds), se houver:
        ```bash
        docker compose exec app bundle exec rails db:create
        docker compose exec app bundle exec rails db:migrate
        # Quando o arquivo de seeds estiver pronto, adicione o comando abaixo:
        # docker compose exec app bundle exec rails db:seed
        ```

---
## Executando a Aplicação

Após concluir todos os passos de "Configuração e Instalação do Ambiente (Docker)":

1.  Certifique-se de que os containers Docker estejam em execução:
    ```bash
    docker compose ps
    ```
    *(Você deve ver os serviços `app` e `db` com o status "running" ou "up").*

2.  Acesse a aplicação no seu navegador:
    * Abra `http://localhost:3000`

---
## Executando RuboCop

Para verificar o estilo do código e as boas práticas com o RuboCop:

1.  Para inspecionar todos os arquivos e listar as ofensas:
    ```bash
    docker compose exec app bundle exec rubocop
    ```

2.  Para tentar corrigir automaticamente as ofensas que são seguras para auto-correção:
    ```bash
    docker compose exec app bundle exec rubocop -A
    ```

---

