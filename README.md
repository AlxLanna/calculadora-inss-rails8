# Desafio Técnico Credishop - Cálculo de Desconto INSS

Este projeto é uma solução para o desafio técnico proposto pela Credishop. O objetivo é criar uma aplicação web para realizar o cálculo do desconto de INSS com base no salário do proponente, permitir o cadastro de proponentes com seus respectivos endereços e contatos, e exibir um relatório/dashboard de proponentes agrupados por faixas salariais.

## Tecnologias Utilizadas

As principais tecnologias utilizadas neste projeto incluem:

* Ruby on Rails (versão 8.0.2)
* PostgreSQL (versão 15.3)
* Bootstrap (versão 5.x, será adicionado para o frontend)
* Docker e Docker Compose (para o ambiente de desenvolvimento)
* SolidQueue (para gerenciamento de background jobs)
* RuboCop (com `rubocop-rails-omakase` para linting e formatação de código)

## Executando a Aplicação

Após concluir todos os passos de "Configuração e Instalação do Ambiente (Docker)":

1.  Certifique-se de que os containers Docker estejam em execução:
    ```bash
    docker compose ps
    ```
    *(Você deve ver os serviços `app` e `db` com o status "running" ou "up").*

2.  Acesse a aplicação no seu navegador:
    * Abra `http://localhost:3000`
    
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
    
## Cronograma do Desafio (3 Dias)

<details>
  <summary><strong>### Primeiro dia: Fundação, Docker, Modelagem Inicial e Configurações</strong></summary>

  * ~~Criar e configurar o ambiente de desenvolvimento com Docker;~~
  * ~~Criar e configurar o repositório no GitHub (branch `desenvolvimento`);~~
  * ~~Criar o projeto em Rails + PostgreSQL e testar a conexão com o servidor;~~
  * ~~Modelagem de dados inicial:~~
    * ~~Criação dos modelos `Proponente`, `Endereco`, `Contato` e suas migrações.~~
    * ~~Definição das associações básicas entre os modelos.~~
    * ~~Implementação do serviço `CalculadoraInss` para lógica de cálculo do INSS (com faixas carregadas de arquivo YAML).~~
  * ~~Configurar RuboCop para padronização e qualidade de código;~~
  * ~~Início do `README.md` (documentação inicial e instruções de setup).~~ *(Concluído)*
</details>

<br>

<details>
  <summary><strong>### Segundo dia: Lógica de Negócio Principal e Backend</strong></summary>

  * Desenvolvimento do backend e o CRUD completo para Proponente (incluindo Endereços e Contatos aninhados, se aplicável).
  * Desenvolver lógica do cálculo do INSS assíncrono no formulário do proponente.
  * Criar background job com SolidQueue (ex: para notificação ou processamento após criação de novo proponente - o desafio requer "Incluir alguma job (onde achar que melhor se encaixa)" como Mínimo).
  * Popular o banco de dados com dados de teste (seeds - mínimo 10 registros).
  * Escrever testes (ex: com RSpec, que é "Desejado").
</details>

<br>

<details>
  <summary><strong>### Terceiro dia: Funcionalidades Adicionais, Relatórios e Finalização</strong></summary>

  * Finalizar qualquer possível pendência do dia 2.
  * Desenvolver o Dashboard/Relatório de proponentes por faixa salarial (com listagem e gráfico).
  * Implementar autenticação de usuários (ex: com Devise, que é "Desejado").
  * Finalizar o `README.md` com todas as instruções e detalhes do projeto.
  * Reforçar a documentação interna do código.
  * Revisão final e preparação para entrega.
</details>
