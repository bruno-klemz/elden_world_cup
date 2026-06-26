# Elden Album — Design (v1)

**Data:** 2026-06-26
**Repo:** `elden_world_cup`
**Plataformas:** iOS + Android (Flutter)

## 1. Visão geral

Elden Album é um app que funciona como um **álbum de figurinhas dos bosses de Elden Ring**, combinado com um **guia** do jogo. O usuário marca os bosses que derrotou; cada slot do álbum se preenche com a figurinha (arte do boss numa moldura dourada). Tocar em qualquer figurinha — derrotada ou não — abre uma bottom sheet com a ficha do boss: mapa de onde encontrá-lo, atributos de combate (forte vs / fraco para), loot e lore.

A metáfora central é o **álbum da Copa**: figurinhas em grade, seccionadas por grupos — aqui, as **regiões** do mapa de Elden Ring.

### Propósito duplo
1. **Álbum / coleção** — a satisfação de completar e ver o progresso.
2. **Guia** — onde achar o boss, como enfrentá-lo, o que ele dropa, e a lore para imersão.

## 2. Princípios e escopo da v1

- **100% offline / embarcado.** Sem backend, sem rede. Conteúdo nos assets; progresso no dispositivo.
- **Escopo enxuto.** Começar com ~12 bosses e estruturar para expandir até ~160 sem retrabalho de código.
- **YAGNI.** Sem busca, sem filtros, sem tela de estatísticas na v1 (só barra de progresso geral + contador por região).

### Risco conhecido (todo o projeto)
As artes dos bosses, a imagem do mapa e a lore são propriedade da FromSoftware/Bandai Namco. Aceitável para portfólio / fan project não-oficial. Se houver intenção de publicar e monetizar, isso exige atenção legal (arte original/estilizada, ou enquadramento claro como fan project não-oficial).

## 3. Arquitetura

App Flutter offline. Três camadas, cada uma com responsabilidade única e testável isoladamente:

- **`data/`** — carrega e faz parse de `assets/bosses.json`; lê/escreve o progresso em `shared_preferences`.
- **`domain/`** — modelos imutáveis (`Boss`, `Region`, `DamageType`, `LootItem`, `MapCoord`) e a lógica de progresso (marcar/desmarcar, contadores por região, % geral).
- **`presentation/`** — telas e widgets: álbum, figurinha (`StickerSlot`), bottom sheet do boss, mapa (preview + fullscreen).

### Persistência
- **Conteúdo:** `assets/bosses.json` (um arquivo único) + imagens em `assets/images/` + uma imagem base do mapa.
- **Progresso:** em `shared_preferences` (chave-valor simples), duas listas de IDs: bosses **derrotados** e bosses com o **mapa revelado** (ver §7). Um boss derrotado é tratado como tendo o mapa revelado, independentemente da lista de revelados.

## 4. Modelo de dados

`assets/bosses.json` contém uma lista de regiões e uma lista de bosses.

### Boss
```json
{
  "id": "malenia",
  "name": "Malenia",
  "subtitle": "Boss opcional",
  "region": "haligtree",
  "art": "images/malenia.webp",
  "locationName": "Elphael, Braço da Haligtree",
  "mapCoord": { "x": 0.62, "y": 0.44 },
  "strongVs": ["holy", "poison", "scarlet_rot"],
  "weakTo": ["fire", "bleed", "frost"],
  "loot": [
    { "name": "Mão de Malenia", "icon": "images/loot/hand_of_malenia.webp" },
    { "name": "Lembrança da Deusa da Podridão", "icon": "images/loot/remembrance.webp" }
  ],
  "lore": "Filha de Marika, Malenia nasceu amaldiçoada pela Escarlate Podridão..."
}
```

### Region
```json
{ "id": "haligtree", "name": "Haligtree", "order": 9 }
```
A ordem define a sequência das seções no álbum.

### DamageType
Enum fixo no código (não no JSON), cada valor com rótulo PT-BR, ícone e cor. Conjunto inicial: `holy`, `poison`, `scarlet_rot`, `fire`, `bleed`, `frost`, `lightning`, `magic`, `physical` (ajustável conforme os bosses curados).

### MapCoord
Coordenada **relativa** (0..1) na imagem base do mapa: `{ "x": 0.62, "y": 0.44 }`. Independe da resolução da imagem.

## 5. Tela do álbum

`CustomScrollView` composto por:

- **Header** — título + barra de progresso geral ("5 de 12 bosses derrotados").
- **Por região**, em ordem: um cabeçalho (nome da região + contador "2/3") seguido de uma **grade de 3 colunas** de figurinhas (`StickerSlot`).

### Estados do slot (`StickerSlot`)
- **Derrotado:** arte colorida preenchendo o slot (formato retrato ~3:4, crop sem distorção), moldura dourada, nome embaixo, selo ✓.
- **Pendente:** a mesma arte renderizada **borrada e em preto-e-branco** + nome embaixo (teaser). O usuário sabe qual boss é, mas a arte só "desbloqueia" colorida ao derrotar. **Não há ícone de cadeado** — o blur P&B já comunica "pendente", e a animação de revelação (luz) é o que conta o desbloqueio; o cadeado seria redundante e poluiria a figurinha.

Tocar em qualquer slot abre a bottom sheet do boss.

### Regra de arte
Padronizar artes em **retrato (~3:4 ou 4:5)** e usar crop que preenche o slot. Artes horizontais (widescreen) ficam mal no slot vertical e devem ser evitadas na curadoria.

## 6. Bottom sheet do boss

Uma única bottom sheet, usada para bosses derrotados e pendentes. Implementada como `CustomScrollView` com:

- **`SliverAppBar` colapsável** (`expandedHeight`, `pinned: true`, `FlexibleSpaceBar`): a arte do boss aparece expandida no topo e, ao rolar, encolhe até virar uma app bar fina com ‹ + thumbnail + nome (pinned). Ao voltar ao topo, a arte reaparece. Não há chip de status sobre a foto (seria redundante com o botão de ação).
  - **Hero borrado quando pendente:** se o boss ainda não foi derrotado, a arte do hero aparece **borrada e em preto-e-branco** (o mesmo tratamento do slot do álbum), com a chamada "⚔️ Derrote para revelar". Isso mantém a consistência com o álbum e preserva o desejo de revelar — a arte nítida e colorida é a recompensa por derrotar, não algo entregue só por abrir a ficha. Se já derrotado, o hero aparece nítido e colorido.
- **Seções roláveis**, nesta ordem:
  1. **📍 Onde encontrar** — preview do mapa com proteção de spoiler (ver §7) + nome do local.
  2. **⚔️ Combate** — duas colunas lado a lado: **Mais forte VS** (resistências) e **Mais fraco para** (fraquezas), cada tipo de dano com ícone + cor.
  3. **💎 Loot** — carrossel horizontal de itens dropados (ícone + nome).
  4. **📖 Lore** — texto.
- **Botão de ação** (rodapé do conteúdo):
  - Pendente: **"Marcar como derrotado"** (dourado preenchido).
  - Derrotado: **"Conquista registrada"** (estilo selo) + link discreto **"Desmarcar"**.

### Animação de revelação
Ao tocar em "Marcar como derrotado", a **animação de revelação acontece em dois lugares**:
1. **No hero da bottom sheet**, imediatamente: a arte desblura e ganha cor com um efeito de luz/brilho (✨) ali mesmo, no detalhe grande. O botão passa a "Conquista registrada".
2. **No slot do álbum**: ao voltar, a figurinha correspondente já aparece colorida na moldura dourada (com a mesma animação de revelação, caso a transição seja visível).

O efeito visual de luz é o mesmo nos dois contextos, mantendo a linguagem coerente.

## 7. Mapa interativo próprio

O mapa é **próprio e offline** — não usamos o mapa da Fextralife nem nenhum serviço externo (ver decisão e justificativa abaixo).

- **Imagem base única** do mapa de Elden Ring nos assets.
- **Preview** (na bottom sheet): a imagem base centrada/destacada no pin do boss, ~170px de altura, com pulso dourado no local e o badge "⤢ Toque para ampliar".
- **Fullscreen:** ao tocar no preview, abre uma tela com `InteractiveViewer` (pan + zoom nativos) sobre a imagem base, com o(s) pin(s). Um pin é clicável e abre a bottom sheet do boss correspondente — o mapa funciona como segunda forma de navegação além do álbum.
- **Coordenadas:** cada boss guarda `mapCoord {x,y}` relativo. O app posiciona o pin sobre a imagem base.

### Proteção de spoiler (lock/unlock do mapa)
O mapa é a maior fonte de **spoiler de exploração** ("onde ir") — e alguns jogadores querem achar o boss "na raça" sem que abrir a ficha (para ver loot/combate) entregue a localização. Por isso, **só a seção do mapa** nasce protegida:

- **Bloqueado (padrão para boss pendente):** o preview do mapa aparece **borrado**, com 🔒 + a copy "Localização oculta para evitar spoiler" e um botão **"👁 Revelar mapa"**. As demais seções (combate, loot, lore) aparecem normalmente — só o mapa é protegido.
- **Revelado:** após tocar em "Revelar mapa", o preview mostra o pin + local + "⤢ Ampliar", com um controle discreto **"🔒 Ocultar"** para voltar a esconder.
- **Memória do estado:**
  - **Lembra por boss** — o estado revelado é persistido por boss (no `shared_preferences`). Revelar o mapa da Malenia não revela o de outros bosses.
  - **Boss derrotado nasce revelado** — não faz sentido esconder a localização de um boss já derrotado; nesse caso o preview já aparece revelado.

### Ferramenta de curadoria (dev-only)
Uma tela utilitária, **não incluída no app final**, que exibe a imagem base e captura a coordenada (x,y) ao clicar — para acelerar a curadoria quando o catálogo expandir até ~160 bosses.

### Por que mapa próprio (e não a Fextralife)
A Fextralife tem mapa interativo com URL por boss (`id/lat/lng`), mas: quebraria o requisito offline; traria anúncios de terceiros para dentro do app; o mapa é conteúdo proprietário deles (esconder ads ou puxar tiles viola os Termos de Uso); e um webview "só do site deles" tem risco concreto de rejeição na App Store. O custo marginal do mapa próprio é baixo — por boss é apenas um par (x,y).

## 8. Testes

- **`domain/`** (unit) — marcar/desmarcar boss; contadores por região; percentual geral; revelar/ocultar mapa por boss; regra "boss derrotado ⇒ mapa revelado"; imutabilidade dos modelos.
- **`data/`** (unit) — parse de `bosses.json` (incluindo campos opcionais e enums de dano); round-trip de leitura/escrita do progresso no `shared_preferences` (derrotados **e** mapas revelados, com fake/in-memory).
- **`presentation/`** (widget) — `StickerSlot` nos dois estados (pendente borrado sem cadeado vs. derrotado colorido); hero da bottom sheet borrado quando pendente vs. nítido quando derrotado; botão de ação alternando marcar/desmarcar; mapa nos estados bloqueado/revelado; colapso do `SliverAppBar`.

## 9. Fora de escopo (v1)

- Backend, contas, sync entre dispositivos.
- Busca e filtros (ex: "só os que faltam").
- Tela de estatísticas/conquistas dedicada.
- Catálogo completo dos ~160 bosses (começamos com ~12).
- Campos extras na ficha: HP, runas, epíteto, dica de estratégia, pré-requisitos (podem entrar em versões futuras — o modelo de dados comporta).
