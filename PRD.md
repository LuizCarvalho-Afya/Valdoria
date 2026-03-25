Nome do Jogo
Valdoria
🎮 Tipo de Jogo
O jogo será desenvolvido em formato 2D (duas dimensões), com visão superior (top-down), onde o
jogador visualiza o personagem e o ambiente de cima.
🎮 História do Jogo
O continente de Valdoria é dividido entre antigos reinos, cada um moldado por diferentes filosofias,
culturas e formas de dominar a energia do Coração Arcano.
Arkhavel ergueu muralhas e treinou guerreiros.
Lunaris buscou conhecimento nas profundezas da magia.
Sylvandor viveu em harmonia com a natureza.
Nocthar prosperou nas sombras, longe dos olhos do mundo.
Além dos reinos, linhagens ancestrais — conhecidas como famílias — carregam traços únicos que
influenciam as habilidades de seus descendentes.
Por gerações, o equilíbrio foi mantido.
Até a corrupção surgir.
Uma energia desconhecida começou a se espalhar, distorcendo criaturas e afetando até mesmo a
essência do Coração Arcano. Nenhum reino foi poupado.
Agora, antigos conflitos são deixados de lado enquanto o mundo enfrenta uma ameaça em comum.
O jogador assume o papel de um aventureiro com uma linhagem própria, capaz de desenvolver
habilidades inspiradas nos estilos dos reinos.
Sua jornada começa na vila de Eldrin, onde os primeiros sinais da corrupção aparecem.
Cabe a ele explorar Valdoria, entender a origem do caos e decidir o destino do continente.
🎮 Mago
 Alto dano à distância
 Baixa defesa
 Skills de magia (ex: projéteis, área)
🎮 Tank
 Alta vida e defesa
 Baixo dano
 Focado em resistência
🎮 Healer
 Cura a si mesmo (ou futuro: aliados)
 Baixo dano
 Alta sobrevivência
🎮 Sistema de Combate (PRD)
Você pode colocar assim no seu documento:
🎮 Sistema de Combate
O combate será em tempo real, onde o jogador poderá atacar inimigos utilizando um ataque básico e
habilidades especiais (skills).
O sistema será baseado em detecção de colisão entre o jogador, inimigos e ataques.
🎮 Ataque Básico
 Ataque de curto alcance
 Executado por tecla ou clique
 Dano fixo ou baseado em atributo
🎮 Classe: Mago (Skills)
Coloca isso direto no PRD:
🎮 Mago
Alto dano à distância
Baixa defesa
Especialista em magia ofensiva
✨ Habilidades do Mago
🎮 Skill 1 — Projétil Arcano
 Tipo: ataque à distância
 Descrição: dispara um projétil mágico em linha reta
 Efeito: causa dano ao inimigo atingido
 Cooldown: baixo (1-3s)
👉 Função no jogo: ataque principal
👉 Implementação:
 criar um objeto (bola de magia)
 mover em linha reta
 detectar colisão
🎮 Skill 2 — Explosão Arcana
 Tipo: área
 Descrição: libera uma explosão ao redor do jogador
 Efeito: dano em todos os inimigos próximos
 Cooldown: médio (5-10s)
👉 Função:
 limpar vários inimigos
 útil quando cercado
👉 Implementação simples:
 checar inimigos em um raio
⚡ Skill 3 — Raio Energético
 Tipo: dano contínuo / linha
 Descrição: dispara um feixe mágico em direção ao inimigo
 Efeito: alto dano em linha reta
 Cooldown: alto (10-12s)
👉 Função:
 dano forte (tipo “ultimate simples”)
👉 Implementação:
 linha reta instantânea ou projétil rápido
🎮 Balanceamento (simples)
 Muito dano ✅
 Pouca vida ❌
 Depende de skill pra sobreviver
🎮 Classe: Tank (Skills)
🎮 Tank
Alta vida e defesa
Baixo dano
Especialista em resistência e sobrevivência
✨ Habilidades do Tank
🎮 Skill 1 — Golpe Pesado
 Tipo: ataque corpo a corpo
 Descrição: realiza um ataque forte de curta distância
 Efeito: causa dano ao inimigo próximo
 Cooldown: baixo (2-4s)
👉 Função no jogo: ataque básico mais forte que o normal
👉 Implementação:
 detectar inimigos próximos
 aplicar dano direto
🎮 Skill 2 — Escudo Protetor
 Tipo: defesa
 Descrição: aumenta a resistência do jogador temporariamente
 Efeito: reduz o dano recebido
 Duração: 3–5 segundos
 Cooldown: médio (5-7)
👉 Função:
 tankar dano
 sobreviver em situações difíceis
Implementação:
+10 (defesa) ou 20% do hp max restaurado
🎮 Skill 3 — Provocação
 Tipo: controle
 Descrição: chama a atenção dos inimigos próximos
 Efeito: faz com que monstros foquem no jogador
 Cooldown: médio (6-9s)
👉 Função:
 atrair inimigos
 controlar combate
👉 Implementação simples:
 inimigos próximos começam a perseguir o player
🎮 Balanceamento
 Muita vida ✅
 Muita defesa ✅
 Dano baixo ❌
 Ideal pra aguentar ataques
🎮
Classe: Healer
🎮 Healer
Baixo dano
Baixa vida
Alta utilidade e sobrevivência
✨ Habilidades do Healer
🎮 Skill 1 — Cura Básica
 Tipo: cura
 Descrição: recupera uma pequena quantidade de vida
 Efeito: restaura HP do jogador
 Cooldown: baixo (2-4s)
🎮 Skill 2 — Invisibilidade
 Tipo: utilidade
 Descrição: torna o jogador temporariamente invisível
 Efeito: inimigos param de detectar/perseguir o jogador
 Duração: 3–5 segundos
 Cooldown: alto (6-9s)
👉 Implementação simples:
player.visible = False
✨ Skill 3 — Cura Total
 Tipo: cura forte
 Descrição: restaura grande quantidade de vida
 Efeito: cura muito HP
 Cooldown: alto (10-15s)
👉 Função:
 “último recurso”
 salvar o player
👉 Implementação:
player.hp = player.max_hp
🎮 Balanceamento
 Muito frágil ❌
 Muito estratégico ✅
 Pode fugir (invisibilidade) ✅
 Sobrevive com cura ✅
🎮 Inteligência Artificial dos Monstros
Os monstros do jogo possuem um sistema de comportamento baseado em estados, permitindo
diferentes ações de acordo com a proximidade do jogador.
🎮 Estados dos Monstros
Os monstros possuem diferentes estados de comportamento:
 Idle (parado)
 Chase (perseguindo o jogador)
 Attack (atacando o jogador)
🎮 Sistema de Detecção
Cada monstro possui um raio de detecção.
Quando o jogador entra nesse raio, o monstro muda para o estado de perseguição.
🎮 Fluxo de Estados
O comportamento dos monstros segue o fluxo:
Idle → Chase → Attack
 Idle → Chase: quando o jogador entra no raio
 Chase → Attack: quando o jogador está muito próximo
 Attack → Idle: quando o jogador se afasta
🎮 Sistema de Ataque
Quando o monstro está próximo do jogador, ele causa dano automaticamente em intervalos de tempo.
🎮 Movimento dos Monstros
Durante o estado de perseguição, o monstro se move na direção do jogador.
O movimento é baseado na posição do player, aproximando-se continuamente.
🎮 Pathfinding (Caminho Mínimo)
O jogo utiliza um sistema de pathfinding para permitir que o jogador se mova automaticamente ao
clicar no mapa.
🎮 Movimento por Clique
Ao clicar em um ponto do mapa, o jogador irá se deslocar automaticamente até o local selecionado.
🎮 Algoritmo Utilizado
Será utilizado o algoritmo A* (A estrela) para calcular o caminho mais curto entre a posição atual do
jogador e o destino selecionado.
O algoritmo considera:
 Distância até o destino
 Presença de obstáculos
 Caminhos disponíveis no mapa
🎮 Representação do Mapa
O mapa será dividido em uma grade (grid), onde cada célula representa uma posição possível de
movimentação.
 Células livres podem ser atravessadas
 Células bloqueadas representam obstáculos
🎮 Desvio de Obstáculos
O algoritmo A* permite que o jogador encontre rotas alternativas ao detectar obstáculos, evitando
colisões com elementos do mapa.
🎮 Funcionamento do Sistema *(tem q
aprimorar certas coisas ainda)
O sistema de movimentação segue os seguintes passos:
1. O jogador clica no mapa
2. O sistema calcula o caminho utilizando o algoritmo A*
3. O caminho é armazenado em uma lista de posições
4. O jogador se move seguindo o caminho calculado
🎮 Sistema de NPCs
O jogo contará com diferentes tipos de NPCs, cada um com funções específicas dentro do mundo.
🎮 NPCs de Missão (Quests)
Alguns NPCs oferecerão missões ao jogador através do sistema de diálogo.
Essas missões podem incluir:
 Derrotar monstros
 Coletar itens
 Explorar áreas específicas
As quests são ativadas através de escolhas no diálogo.
🎮 NPCs de Loja
O jogo contará com NPCs comerciantes que permitem ao jogador comprar e vender itens.
🎮 Sistema de Compra e Venda
O jogador poderá:
 Comprar itens utilizando moeda do jogo
 Vender itens do inventário
Cada NPC terá um conjunto específico de itens disponíveis.
🎮 Tipos de Itens por Classe
Os itens disponíveis nas lojas são divididos por estilo de combate:
🎮 Equipamentos de Tank
 Armaduras pesadas
 Machados
 Marretas
🎮 Equipamentos de Mago
 Varinhas mágicas de diferentes materiais:
o Madeira
o Ferro
o Bronze
o Ouro
o Diamante
o Esmeralda
🎮 Itens de Healer
 Poções de cura
 Poções especiais (regen, buff, etc.)
🎮 Sistema de Inventário
O jogo possui um sistema de inventário responsável por armazenar e gerenciar os itens coletados pelo
jogador.
🎮 Armazenamento de Itens
Os itens coletados são armazenados em uma estrutura de dados (lista), contendo informações como:
 Nome do item
 Tipo (arma, armadura, consumível, etc.)
 Valor
 Efeito
🎮 Ordenação de Itens
O inventário permite a ordenação dos itens utilizando algoritmos de ordenação, como:
 QuickSort ou MergeSort
A ordenação pode ser feita com base em:
 Nome
 Tipo
 Valor
🎮 Filtro de Itens
O sistema permite filtrar itens com base em categorias, como:
 Apenas armas
 Apenas armaduras
 Apenas consumíveis
🎮 Integração com Sistema de Loja
O inventário é integrado ao sistema de compra e venda, permitindo:
 Adicionar itens comprados
 Remover itens vendidos
🎮 Funcionamento
O sistema segue os seguintes passos:
1. O jogador coleta ou compra um item
2. O item é adicionado ao inventário
3. O jogador pode visualizar, ordenar ou filtrar os itens
4. O jogador pode utilizar ou vender itens
