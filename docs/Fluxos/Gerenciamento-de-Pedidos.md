# Gerenciamento de Pedidos

<a id="gerenciamento-de-pedidos"></a>

<a id="fluxo-de-criacao-de-pedido"></a>
### Criação de Pedido

#### Caminho feliz — Pedido criado com sucesso

1. Sistema recebe solicitação de criação de pedido com detalhes do usuário e itens (pode incluir o header `Idempotency-Key`).
1. Sistema valida dados do usuário e lista de itens.
1. Se válidos, cria o pedido, calcula o total e define o status como `PendingPayment`.
1. Retorna confirmação com detalhes do pedido.

**Resultado esperado:** pedido criado com status `PendingPayment`.

#### Caminhos alternativos

- Dados inválidos: retornar campos a corrigir.
- Itens indisponíveis: retornar erro informando quais itens não estão disponíveis.
- Usuário não encontrado: retornar erro informando que o usuário não existe.
- Erro no cálculo do total: retornar erro informando falha no processamento do pedido.
- Requisição duplicada (mesma `Idempotency-Key`): retornar o mesmo pedido previamente processado.

---

<a id="fluxo-de-marcar-pedido-pago"></a>
### Marcar Pedido como Pago

#### Caminho feliz — Pagamento confirmado

1. Sistema de pagamento notifica o sistema sobre o pagamento bem-sucedido.
1. Sistema valida a notificação e atualiza o status do pedido para `paid`.
1. Se válido, envia confirmação ao usuário.

**Resultado esperado:** pedido atualizado para status `paid`.

#### Caminhos alternativos

- Notificação inválida: retornar erro informando falha na validação.
- Pedido não encontrado: retornar erro informando que o pedido não existe.
- Pedido já pago: informar que o pedido já foi pago.
- Pedido cancelado: informar que o pedido foi cancelado e não pode ser marcado como pago.
- Pedido estornado: informar que o pedido foi estornado e não pode ser marcado como pago.

---

<a id="fluxo-de-solicitar-estorno"></a>
### Solicitar Estorno

#### Caminho feliz — Solicitação de estorno registrada

1. Usuário solicita estorno para um pedido pago.
1. Sistema valida a solicitação e o status do pedido.
1. Se válido, registra a solicitação de estorno e notifica o sistema de pagamentos.
1. Sistema notifica time de pagamentos para processamento.
1. Confirmação é enviada ao usuário.

**Resultado esperado:** solicitação de estorno registrada com sucesso.

#### Caminhos alternativos

- Pedido não encontrado: retornar erro informando que o pedido não existe.
- Pedido não pago: retornar erro informando que apenas pedidos pagos podem ser estornados.
- Pedido já estornado: informar que o pedido já foi estornado.
- Pedido cancelado: informar que pedidos cancelados não podem ser estornados.
- Solicitação duplicada: informar que já existe uma solicitação de estorno em andamento para este pedido.

---

<a id="fluxo-de-marcar-estornado"></a>
### Marcar Pedido como Estornado

#### Caminho feliz — Estorno concluído

1. Sistema de pagamento notifica o sistema sobre o estorno bem-sucedido.
1. Sistema valida a notificação.
1. Se válido, atualiza o status do pedido para `refunded`.
1. Notifica o usuário sobre o estorno concluído.

**Resultado esperado:** pedido atualizado para status `refunded`.

#### Caminhos alternativos

- Notificação inválida: retornar erro informando falha na validação.
- Pedido não encontrado: retornar erro informando que o pedido não existe.
- Pedido não pago: retornar erro informando que apenas pedidos pagos podem ser estornados.
- Pedido já estornado: informar que o pedido já foi estornado.
- Pedido cancelado: informar que pedidos cancelados não podem ser estornados.
- Estorno não solicitado: informar que não há solicitação de estorno para este pedido.

---

<a id="fluxo-de-cancelamento-de-pedido"></a>
### Cancelamento de Pedido

#### Caminho feliz — Cancelamento bem-sucedido

1. Usuário solicita cancelamento de um pedido pendente.
1. Sistema valida a solicitação e o status do pedido.
1. Se válido, atualiza o status do pedido para `Cancelled`.
1. Notifica o usuário sobre o cancelamento.

**Resultado esperado:** pedido atualizado para status `Cancelled`.

#### Caminhos alternativos

- Pedido não encontrado: retornar erro informando que o pedido não existe.
- Pedido já cancelado: informar que o pedido já foi cancelado.
- Pedido pago: informar que pedidos pagos não podem ser cancelados.
- Pedido estornado: informar que pedidos estornados não podem ser cancelados.
- Solicitação duplicada: informar que o pedido já está em processo de cancelamento.
