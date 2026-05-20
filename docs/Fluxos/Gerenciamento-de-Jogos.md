# Gerenciamento de Jogos

<a id="gerenciamento-de-jogos"></a>

<a id="fluxo-de-criacao-de-jogo-admin"></a>
### Criação de Jogo (Admin)

#### Caminho feliz - Criação bem-sucedida

1. Admin acessa painel de administração → gerenciamento de jogos.
1. Seleciona criar novo jogo e preenche detalhes (nome, descrição, categoria, etc.).
1. Sistema valida dados e salva o novo jogo no banco de dados.
1. Confirmação de criação é exibida.

**Resultado esperado:** novo jogo criado e disponível no sistema.

#### Caminhos alternativos

- Dados inválidos: retornar campos a corrigir.
- Jogo já existente: retornar erro informando duplicidade.

---

<a id="fluxo-de-edicao-de-jogo-admin"></a>
### Edição de Jogo (Admin)

#### Caminho feliz - Edição bem-sucedida

1. Admin seleciona jogo existente para editar.
1. Altera detalhes do jogo conforme necessário.
1. Sistema valida e salva as alterações.
1. Confirmação de edição é exibida.

#### Caminhos alternativos

- Jogo não encontrado: retornar erro.
- Dados inválidos: retornar campos a corrigir.
- Jogo com nome duplicado: retornar erro informando duplicidade.

---

<a id="fluxo-de-exclusao-de-jogo-admin"></a>
### Exclusão de Jogo (Admin)

#### Caminho feliz - Exclusão bem-sucedida
1. Admin seleciona jogo para exclusão e confirma a ação.
1. Sistema remove o jogo do banco de dados.
1. Confirmação de exclusão é exibida.

#### Caminhos alternativos

- Jogo não encontrado: retornar erro.

---

<a id="fluxo-de-listagem-de-jogos-admin"></a>
### Listagem de Jogos (Admin)

#### Caminho feliz - Listagem bem-sucedida

1. Admin acessa gerenciamento de jogos.
1. Sistema recupera e apresenta lista de jogos do banco de dados.
