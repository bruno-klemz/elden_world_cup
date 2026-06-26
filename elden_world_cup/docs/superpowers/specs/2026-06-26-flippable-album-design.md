# Flippable Album (one page per region) — Design

**Data:** 2026-06-26
**Repo:** `elden_world_cup`
**Contexto:** A tela do álbum passa de um scroll vertical único para um álbum
folheável, reforçando a metáfora de álbum físico.

## Conceito

Cada **região** vira uma **página** do álbum, navegada por **swipe horizontal**
(folhear). No futuro entram filtros / navegação rápida; por agora a experiência
é folhear página a página.

## Estrutura

- **Pager horizontal** (`PageView`): uma página por região, na ordem das regiões
  (já ordenadas por `Region.order`).
- **Cada página é autocontida** — seu próprio `CustomScrollView`:
  - **`SliverAppBar` colapsável** (mesmo padrão da tela de boss): header grande
    com **nome da região + progresso daquela região** (ex: "Limgrave" +
    "3 de 18 derrotados" + barra) que colapsa numa barra fina ao rolar e
    reexpande ao voltar ao topo.
  - **Grade de figurinhas** (3 colunas) da região, que **rola na vertical** se
    não couber. Sem limite de bosses por região.
  - Cada página lembra seu próprio scroll.
- **Removidos da tela principal:** o título "⚔️ Elden Album" e a barra/contador
  de progresso **geral**. Voltam no futuro com filtros/navegação rápida.
- **Indicador de página (dots):** uma **pílula flutuante** na base da tela, com
  um dot por região (o atual alongado e dourado), com borda + sombra própria.
  - A grade recebe **padding inferior = altura da pílula + respiro + safe area
    inferior**, para que o último item da região role totalmente acima da pílula
    e nunca fique coberto.
  - A pílula é `IgnorePointer` (não bloqueia toques na grade abaixo).

## Componentes (arquitetura atual: feature `album`, bloc + get_it)

- **`AlbumView`** (`album/presenter/album/album_view.dart`): passa a montar um
  `PageView` (com `PageController`) em vez do `CustomScrollView` único. Mantém o
  `BlocConsumer<AlbumBloc>`. Para cada região, renderiza uma `RegionPage`. A
  pílula `AlbumPageDots` fica sobreposta na base via `Stack`.
- **`RegionPage`** (novo widget, `album/presenter/album/widgets/region_page.dart`):
  o `CustomScrollView` + `SliverAppBar` colapsável + grade de uma região. Recebe:
  região, lista de bosses, `defeatedCount`, `isDefeated`, `revealBossId`,
  `onRevealDone`, `slotKeyFor`, `onBossTap`, `onQuickDefeat`. Substitui a
  `RegionSection` (a seção vira a página inteira; o header inline vira o
  `SliverAppBar`).
- **`AlbumPageDots`** (novo widget, `album/presenter/album/widgets/album_page_dots.dart`):
  recebe `count` e `currentIndex`; renderiza a pílula com os dots.
- **`RegionSection`** é removida (absorvida pela `RegionPage`).
- `StickerSlot`, `RevealOverlay` e a lógica de reveal/quick-check **permanecem**.

## Reveal entre páginas

Hoje, ao marcar um boss (tela de boss via pop, ou quick-check no álbum), o
`AlbumBloc` seta `justRevealedBossId` e a `AlbumView` faz `ensureVisible` + reveal
no slot. Com páginas, o slot pode estar em **outra página**:

1. No listener do `justRevealedBossId`, a `AlbumView` descobre o índice da região
   do boss (`state.regions.indexWhere(... boss.region ...)`).
2. Anima o `PageController` até essa página (`animateToPage`).
3. Após a página assentar, faz `Scrollable.ensureVisible` no slot (via o
   `GlobalKey` daquele boss) e deixa o `StickerSlot` tocar o reveal.

O `slotKeyFor` (mapa `bossId → GlobalKey`) e o fluxo de `AlbumRevealConsumed`
permanecem. O `PageController` é criado/disposto pela `AlbumView` (já é
`StatefulWidget`).

## Testes

- **`RegionPage`** (widget): renderiza o nome da região e o progresso no header;
  a grade mostra os slots dos bosses; tocar num slot dispara `onBossTap`.
- **`AlbumPageDots`** (widget): renderiza `count` dots; o `currentIndex` é o
  destacado.
- **`AlbumView`** (widget): renderiza uma página por região (PageView com N
  filhos); a página inicial é a primeira região.
- Testes de **bloc** não mudam (estado idêntico).

## Fora de escopo (v1)

- Filtros e navegação rápida (pular para uma região, "só os que faltam").
- Progresso geral do álbum na tela principal (removido por agora).
- Animação de "virar página" estilo livro 3D — o swipe padrão do `PageView`
  basta; um page-curl fica para depois se desejado.
