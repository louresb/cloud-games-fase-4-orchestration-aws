# Autenticação e Autorização

<a id="autenticacao-e-autorizacao"></a>

<a id="fluxo-de-login"></a>
### Login

#### Caminho feliz — Login bem-sucedido

1. Usuário abre a página de login.
1. Insere e-mail e senha.
1. Sistema valida credenciais.
1. Se válidas, gera um token de autenticação (JWT) contendo: `ID do usuário`, `Nome`, `Papel`.
1. Retorna o token ao cliente.
1. Cliente armazena o token (ex.: `localStorage`, cookie seguro).
1. Usuário acessa áreas protegidas usando o token.

**Resultado esperado:** usuário autenticado com token válido.

#### Caminhos alternativos

- Credenciais inválidas: retorna erro informando e-mail ou senha incorretos.
- Conta inativa: retorna orientação para ativação por e-mail.
- Conta bloqueada: retorna instrução para contatar suporte.
- Conta excluída: informa que conta foi excluída e não pode acessar; sugere reativação ou novo cadastro.

``` mermaid
flowchart LR
    login_interface 
    ==> user_actor 
    ==> user.authenticate 
    ==> user_aggregate
    ==> user.login_succeeded
    
    user_aggregate .-> user.login_failed.invalid_credentials
    user_aggregate .-> user.login_failed.account_not_confirmed
    user_aggregate .-> user.login_failed.account_blocked
    user_aggregate .-> user.login_failed.account_deleted

    %% Declarar os elementos
    login_interface["Interface Login<br/> (email, senha)"]:::view
    user_actor[Usuário]:::actor
    user.authenticate[Autenticar<br/>Credenciais]:::command
    user_aggregate[Usuário]:::aggregate
    user.login_succeeded[Usuário Autenticado]:::event
    user.login_failed.invalid_credentials[Credenciais Inválidas]:::event
    user.login_failed.account_not_confirmed[Conta Inativa]:::event
    user.login_failed.account_blocked[Conta Bloqueada]:::event
    user.login_failed.account_deleted[Conta Excluída]:::event

    %% Declarar as definições de classes (estilo)
    classDef view stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#00FF00, color:#333333
    classDef actor stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFFF66, color:#333333
    classDef command stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#48DDFF, color:#333333
    classDef aggregate stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFFFCA, color:#333333
    classDef event stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFCC00, color:#333333
```

---

<a id="fluxo-de-registro"></a>
### Registro

#### Caminho feliz — Registro bem-sucedido

1. Usuário abre página de registro.
1. Preenche nome, e-mail e senha.
1. Sistema valida dados.
1. Se válidos, cria conta e gera token de confirmação.
1. Envia e-mail de confirmação.
1. Usuário é orientado a ativar a conta pelo e-mail.

**Resultado esperado:** conta criada em estado `inactive` até confirmação por e-mail.

#### Caminhos alternativos

- E-mail já cadastrado: retorna erro e opções (login, recuperar senha, usar outro e-mail).
- Dados inválidos: retorna campos com problemas (formato de e-mail, senha fraca, etc.).


``` mermaid
flowchart LR
    interface_register 
    ==> user_actor 
    ==> user.register 
    ==> user_aggregate
    ==> user.registration_succeeded

    user_aggregate .-> user.registration_failed.existing_user
    user_aggregate .-> user.registration_failed.invalid_credentials

    %% Declarar os elementos
    interface_register["Interface Registro<br/>(nome, email, senha)"]:::view
    user_actor[Usuário]:::actor
    user.register[Registrar<br/>Usuário]:::command
    user_aggregate[Usuário]:::aggregate
    user.registration_succeeded[Usuário Registrado]:::event
    user.registration_failed.existing_user[Usuário Existente]:::event
    user.registration_failed.invalid_credentials[Credenciais Inválidas]:::event

    %% Declarar as definições de classes (estilo)
    classDef view stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#00FF00, color:#333333
    classDef actor stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFFF66, color:#333333
    classDef command stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#48DDFF, color:#333333
    classDef aggregate stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFFFCA, color:#333333
    classDef event stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFCC00, color:#333333
```
---

<a id="fluxo-de-confirmacao-de-e-mail"></a>
### Confirmação de E-mail

#### Caminho feliz — Confirmação bem-sucedida

1. Usuário clica no link de confirmação.
1. Sistema valida token.
1. Se válido, ativa a conta e remove token.
1. Redireciona para login com mensagem de sucesso.

**Resultado esperado:** conta ativada e pronta para login.

#### Caminhos alternativos

- Token inválido/expirado: orientar a solicitar novo link.
- Conta já ativada: informar que já está confirmada.

``` mermaid
flowchart LR
    interface_confirm
    ==> user_actor
    ==> user.confirm_email
    ==> user_aggregate
    ==> user.confirmation_succeeded

    user_aggregate .-> user.confirmation_failed.invalid_or_expired_token
    user_aggregate .-> user.confirmation_failed.already_confirmed

    %% Declarar os elementos
    interface_confirm["Link de Confirmação<br/>(token)"]:::view
    user_actor[Usuário]:::actor
    user.confirm_email[Confirmar E-mail<br/>Validar Token]:::command
    user_aggregate[Usuário]:::aggregate
    user.confirmation_succeeded[Conta Ativada]:::event
    user.confirmation_failed.invalid_or_expired_token[Token Inválido/Expirado]:::event
    user.confirmation_failed.already_confirmed[Conta Já Ativada]:::event

    %% Declarar as definições de classes (estilo)
    classDef view stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#00FF00, color:#333333
    classDef actor stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFFF66, color:#333333
    classDef command stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#48DDFF, color:#333333
    classDef aggregate stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFFFCA, color:#333333
    classDef event stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFCC00, color:#333333
```
---

<a id="fluxo-de-esqueci-a-senha"></a>
### Esqueci a Senha

#### Caminho feliz — Recuperação bem-sucedida

1. Usuário solicita recuperação informando o e-mail.
1. Sistema verifica existência do e-mail.
1. Se cadastrado, gera token de redefinição e envia link por e-mail.
1. Usuário é orientado a verificar o e-mail para redefinir a senha.

**Resultado esperado:** usuário recebe link seguro para redefinir senha.

#### Caminhos alternativos

- E-mail não cadastrado: informar que e-mail não foi encontrado.
- Formato de e-mail inválido: informar erro de validação.

``` mermaid
flowchart LR
    interface_forgot_password
    ==> user_actor
    ==> user.request_password_reset
    ==> user_aggregate
    ==> user.password_reset_token_sent

    user_aggregate .-> user.password_reset_failed.email_not_found
    user_aggregate .-> user.password_reset_failed.invalid_email_format

    %% Declarar os elementos
    interface_forgot_password["Interface Recuperação<br/>(email)"]:::view
    user_actor[Usuário]:::actor
    user.request_password_reset[Solicitar Redefinição<br/>Gerar Token]:::command
    user_aggregate[Usuário]:::aggregate
    user.password_reset_token_sent[Token Enviado]:::event
    user.password_reset_failed.email_not_found[E-mail Não Cadastrado]:::event
    user.password_reset_failed.invalid_email_format[Formato de E-mail Inválido]:::event

    %% Declarar as definições de classes (estilo)
    classDef view stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#00FF00, color:#333333
    classDef actor stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFFF66, color:#333333
    classDef command stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#48DDFF, color:#333333
    classDef aggregate stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFFFCA, color:#333333
    classDef event stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFCC00, color:#333333
```

---

<a id="fluxo-de-visualizacao-de-perfil-do-usuario"></a>
### Visualização de Perfil do Usuário

#### Caminho feliz — Visualização bem-sucedida

1. Usuário autenticado abre seção de perfil.
1. Sistema recupera e exibe informações do perfil.

#### Caminho alternativo — Usuário não autenticado

- Redirecionar para a página de login.

``` mermaid
flowchart LR
    profile_interface
    ==> user_actor
    ==> auth.check_token
    ==> user_aggregate
    ==> profile_view_succeeded

    user_aggregate .-> profile_view_failed.not_authenticated

    %% Declarar os elementos
    profile_interface["Interface Perfil<br/>(token)"]:::view
    user_actor[Usuário]:::actor
    auth.check_token[Verificar Token<br/>Autorização]:::command
    user_aggregate[Usuário]:::aggregate
    profile_view_succeeded[Perfil Exibido]:::event
    profile_view_failed.not_authenticated[Usuário Não Autenticado]:::event

    %% Declarar as definições de classes (estilo)
    classDef view stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#00FF00, color:#333333
    classDef actor stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFFF66, color:#333333
    classDef command stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#48DDFF, color:#333333
    classDef aggregate stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFFFCA, color:#333333
    classDef event stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFCC00, color:#333333
```

---

<a id="fluxo-de-redefinicao-de-senha"></a>
### Redefinição de Senha

#### Caminho feliz — Redefinição bem-sucedida

1. Usuário acessa link de redefinição.
1. Sistema valida token.
1. Se válido, exibe formulário para nova senha.
1. Usuário fornece e confirma a nova senha.
1. Sistema valida e atualiza a senha, removendo o token.
1. Redireciona para login com mensagem de sucesso.

#### Caminhos alternativos

- Token inválido/expirado: solicitar novo link.
- Senha inválida: exibir critérios não atendidos.

``` mermaid
flowchart LR
    reset_interface
    ==> user_actor
    ==> user.validate_reset_token
    ==> user_aggregate
    ==> user.password_reset_succeeded

    user_aggregate .-> user.password_reset_failed.invalid_or_expired_token
    user_aggregate .-> user.password_reset_failed.invalid_password

    %% Declarar os elementos
    reset_interface["Interface Redefinição<br/>(token, nova senha)"]:::view
    user_actor[Usuário]:::actor
    user.validate_reset_token[Validar Token<br/>Atualizar Senha]:::command
    user_aggregate[Usuário]:::aggregate
    user.password_reset_succeeded[Senha Atualizada]:::event
    user.password_reset_failed.invalid_or_expired_token[Token Inválido/Expirado]:::event
    user.password_reset_failed.invalid_password[Senha Inválida]:::event

    %% Declarar as definições de classes (estilo)
    classDef view stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#00FF00, color:#333333
    classDef actor stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFFF66, color:#333333
    classDef command stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#48DDFF, color:#333333
    classDef aggregate stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFFFCA, color:#333333
    classDef event stroke-width:1px, stroke-dasharray:none, stroke:#333333, fill:#FFCC00, color:#333333
```
