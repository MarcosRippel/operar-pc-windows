# Exemplo genérico: painel de driver de áudio que precisa de administrador

Cenário típico (anonimizado): um agente precisa ajustar a latência de um cabo de áudio virtual. O driver só tem um painel de janela, sem linha de comando. O painel mostra um aviso do tipo «para persistir, rode como administrador» quando **não** está elevado.

## Como o agente operou
1. Abriu o painel com `Start-Process` e confirmou a janela com `Get-Process ... MainWindowTitle`.
2. Capturou a tela virtual com `System.Drawing.Graphics.CopyFromScreen`, depois só a janela (`GetWindowRect`), e leu o PNG por visão.
3. Focou com `SetForegroundWindow` (um toque em Alt libera o foco) e **verificou** com `GetForegroundWindow`.
4. Clicou por coordenada lida da captura (menu, depois item). Hoje o caminho preferido é `uia.ps1`; clique por coordenada é o último recurso.
5. Conferiu **por fora da tela**: nível de sinal (RMS/pico) do dispositivo e medida de latência.

## O que deu errado (e virou regra)
- Um valor de buffer incompatível com o cliente de captura deixou o dispositivo **mudo** por minutos. Lição: guarde o valor antigo antes, confira o sinal depois, volte ao valor anterior se quebrar.
- Um clique caiu na janela errada (foco errado) e travou outro programa. Lição: o clique só roda com a janela alvo em primeiro plano; abortar caso contrário.
- O humano exigiu abrir o painel como administrador. O agente havia afirmado que a mudança "ao vivo" funcionava sem admin e que admin só servia para **persistir**. Lição: separe o que foi provado do que foi suposto.

## Provado x não provado
- Provado: captura, foco, clique por `mouse_event`, leitura por imagem, conferência por nível de sinal; o painel sem admin mostra o aviso para persistir.
- **Não provado nesse caso**: uma execução elevada completa com sucesso. O padrão `Start-Process -Verb RunAs` vem de outros usos (RDP, firewall); confirme com um teste curto antes de prometer.
