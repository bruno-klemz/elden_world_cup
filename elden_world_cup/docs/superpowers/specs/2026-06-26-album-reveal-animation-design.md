# Reveal Animation in the Album (not the Boss screen) — Design

**Data:** 2026-06-26
**Repo:** `elden_world_cup`
**Contexto:** Refina a animação de revelação ("colar a figurinha") que hoje vive no
hero da tela do boss e se perde quando o CTA é apertado com a tela rolada.

## Problema

A animação de recompensa (figurinha revelando: borrado P&B → colorido + brilho +
estrelas) acontece no **hero** da tela de detalhes do boss. Se o usuário rola a
tela e aperta o CTA "Marcar como derrotado", o hero está colapsado/fora de vista
e a celebração é perdida — justamente o momento mais importante do design.

## Conceito

A celebração migra da tela do boss para o **álbum**, respeitando a separação de
responsabilidades das telas:

- **Boss = UI de informação** (ficha/guia). Marcar é uma ação, não precisa
  celebrar ali.
- **Álbum = UI de registro/coleção**. É o lugar natural da recompensa: "a
  figurinha foi colada no álbum".

Isso resolve o problema na raiz: a animação não depende mais da posição do scroll
na tela do boss, porque nem acontece lá.

## Fluxo

1. Usuário toca numa figurinha → abre a tela do boss (full screen).
2. Toca no CTA **"Marcar como derrotado"** → marca o boss (persiste) e a tela faz
   **`Navigator.pop(boss.id)`**, fechando.
3. O **álbum** recebe o `bossId` do `await BossDetailsScreen.push(...)`. Se não-null:
   - Dispara `AlbumProgressRefreshed` (recarrega o progresso persistido).
   - **Auto-scroll** suave até o slot daquele boss (`Scrollable.ensureVisible`).
   - Dispara a **animação de revelação** naquele slot.
4. Se o usuário só voltou pelo back button → `pop(null)` → apenas refresh, sem
   animação (comportamento atual).

## Comportamento do CTA e estados (tela do boss)

- **Boss pendente:** CTA "Marcar como derrotado" → marca + `pop(boss.id)`.
- **Boss já derrotado** (reaberto): selo "✓ Conquista registrada" + link
  "Desmarcar". **Desmarcar não fecha** a tela (desmarca no lugar). A animação é
  exclusiva do momento da conquista (transição pendente → derrotado).
- A `RevealOverlay` **sai** do hero do boss; o hero não anima mais.

## Componentes afetados

### `boss/presenter/boss_details/`
- **`BossDetailsView`:** ao receber o estado em que o boss passou de pendente para
  derrotado (sinal do bloc), chama `Navigator.of(context).pop(boss.id)`. Remove o
  `RevealOverlay` e o estado local `_playReveal` do hero.
- **`BossDetailsBloc`/State:** mantém o `justRevealed` (transição pendente→derrotado),
  que a view usa apenas como gatilho do `pop(boss.id)` (não para animar). Desmarcar
  e revelar mapa nunca disparam pop.

### `album/presenter/album/`
- **`AlbumView`:**
  - `onBossTap` passa a capturar o retorno: `final id = await BossDetailsScreen.push(...)`.
  - Se `id != null` e `context.mounted`: `bloc.add(AlbumProgressRefreshed())` e
    `bloc.add(AlbumRevealRequested(id))`.
  - Mantém um `ScrollController` no `CustomScrollView` e um `GlobalKey` por slot
    (mapa `bossId → GlobalKey`). Ao receber `justRevealedBossId` no estado, faz
    `Scrollable.ensureVisible(key.currentContext)` e deixa o slot animar.
- **`AlbumBloc`/State:**
  - State ganha `String? justRevealedBossId`.
  - Evento `AlbumRevealRequested(bossId)` → seta `justRevealedBossId`.
  - Evento `AlbumRevealConsumed` → limpa `justRevealedBossId` (chamado quando a
    animação termina, para não repetir em rebuilds).
  - `AlbumProgressRefreshed` continua recarregando o progresso.
- **`StickerSlot`:** ganha `bool animateReveal` (default `false`). Quando `true`
  (apenas o slot do boss recém-derrotado), executa a transição borrado P&B →
  colorido com brilho + estrelas, reaproveitando a `RevealOverlay`. Ao terminar,
  chama um callback `onRevealDone` para a view disparar `AlbumRevealConsumed`.
- **`RegionSection`:** repassa `animateReveal`/`onRevealDone` ao slot correto e o
  `GlobalKey` por slot.

### Movimentação de arquivo
- **`RevealOverlay`** deixa de ser usada no boss e passa a ser detalhe do álbum:
  mover de `boss/presenter/boss_details/widgets/reveal_overlay.dart` para
  `album/presenter/album/widgets/reveal_overlay.dart`.

## Testes

- **`AlbumBloc`** (`bloc_test`): `AlbumRevealRequested` seta `justRevealedBossId`;
  `AlbumRevealConsumed` limpa; `AlbumProgressRefreshed` recarrega progresso sem
  afetar o id de revelação.
- **`StickerSlot`** (widget): com `animateReveal: true` renderiza o overlay de
  revelação (estrelas/brilho) e dispara `onRevealDone`; com `false` é estático.
- **`BossDetailsView`** (widget): tocar no CTA de um boss pendente resulta em
  `pop` com o `boss.id`; em um boss já derrotado, "Desmarcar" não fecha a tela.

## Fora de escopo

- Mudar a animação de revelação em si (mesmo efeito de luz + estrelas, só muda de
  lugar).
- Tela/efeito de celebração em tela cheia (descartado: o álbum é o lugar certo).
