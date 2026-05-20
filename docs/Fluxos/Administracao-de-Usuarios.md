# Administração de Usuários

<a id="administracao-de-usuarios"></a>

<a id="fluxo-de-criacao-de-usuario-admin"></a>
### Criação de Usuário (Admin)

#### Caminho feliz — Criação bem-sucedida

1. Admin abre painel de administração → gerenciamento de usuários.
1. Seleciona criar usuário e preenche dados (nome, e-mail, papel, status).
1. Sistema valida dados e cria conta; gera token de primeiro acesso.
1. Envia e-mail ao novo usuário com instruções.

**Resultado esperado:** usuário criado em estado que exige definir a senha/primeiro acesso.

#### Caminhos alternativos

- E-mail já cadastrado: retornar erro; permitir editar usuário existente.
- Dados inválidos: retornar campos a corrigir.

---

<a id="fluxo-de-primeiro-acesso-do-usuario"></a>
### Primeiro Acesso do Usuário

#### Caminho feliz — Primeiro acesso bem-sucedido

1. Usuário clica no link de primeiro acesso e sistema valida token.
1. Se válido, exibe formulário para definir senha.
1. Usuário define senha; sistema valida e salva, removendo o token.
1. Redireciona para login.

#### Caminhos alternativos

- Token inválido/expirado: solicitar novo link.
- Primeiro acesso já realizado: informar que a senha já foi definida.

---

<a id="fluxo-de-edicao-de-usuario-admin"></a>
### Edição de Usuário (Admin)

#### Caminho feliz — Edição bem-sucedida

1. Admin seleciona usuário para editar.
1. Altera nome, e-mail, papel ou status.
1. Sistema valida e salva alterações.
1. Se e-mail alterado, enviar confirmação para o novo e-mail.

#### Caminhos alternativos

- E-mail já cadastrado: retornar erro.
- Dados inválidos: retornar validações a corrigir.

---

<a id="fluxo-de-exclusao-de-usuario-admin"></a>
### Exclusão de Usuário (Admin)

#### Caminho feliz — Exclusão bem-sucedida

1. Admin seleciona usuário e confirma exclusão.
1. Sistema marca status como `deleted`.
1. Impedir login do usuário excluído e enviar notificação por e-mail.

#### Caminhos alternativos

- Usuário não encontrado: retornar erro.
- Usuário já excluído: informar que não é possível excluir novamente.

---

<a id="fluxo-de-restauracao-de-conta-admin"></a>
### Restauração de Conta (Admin)

#### Caminho feliz — Restauração bem-sucedida

1. Admin seleciona usuário excluído e confirma restauração.
1. Sistema altera status para `active` e notifica o usuário.

#### Caminhos alternativos

- Usuário não encontrado: retornar erro.
- Usuário já ativo: informar que não há necessidade de restauração.

---

<a id="fluxo-de-bloqueio-desbloqueio-de-conta-admin"></a>
### Bloqueio/Desbloqueio de Conta (Admin)

#### Caminho feliz — Bloqueio/Desbloqueio bem-sucedido

1. Admin seleciona usuário e escolhe bloquear ou desbloquear.
1. Sistema atualiza status para `blocked` ou `active`.
1. Notificar usuário sobre a ação.

#### Caminhos alternativos

- Usuário não encontrado: retornar erro.
- Status incompatível (ex.: `deleted`): informar ação inválida.

---

<a id="fluxo-de-listagem-de-usuarios-admin"></a>
### Listagem de Usuários (Admin)

#### Caminho feliz — Listagem bem-sucedida

1. Admin acessa gerenciamento de usuários.
1. Sistema recupera e apresenta lista de usuários do banco de dados.
