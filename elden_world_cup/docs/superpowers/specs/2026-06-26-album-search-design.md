# Album Search / Quick Navigation — Design

**Data:** 2026-06-26
**Repo:** `elden_world_cup`
**Contexto:** Com 28 páginas no álbum folheável, falta acesso rápido a uma
região ou boss específico.

## Conceito

Uma **lupa flutuante** sempre visível no álbum abre uma **tela de busca** com
duas abas — **Regiões** e **Bosses** — cada uma com a lista completa no estado
inicial (navegação por descoberta) e um campo de busca que filtra a aba ativa.

## Acesso

- **Botão de lupa flutuante** sobreposto ao `PageView` (canto superior direito,
  com safe area), **sempre visível** (não vive no `SliverAppBar` colapsável das
  páginas — busca é navegação global). Toca → push da tela de busca.

## Tela de busca

- **Campo de busca** no topo, sempre visível. Filtra a lista da **aba ativa**.
  Trocar de aba mantém o texto e refiltra.
- **Abas:** "Regiões" (badge: total) e "Bosses" (badge: total). Default: Regiões.
- **Lista completa no estado inicial** (sem texto), rolável.

### Aba Regiões
- Itens: ícone 🗺️ + nome + "X/Y derrotados" + chevron.
- **Ordenação:** por nº de bosses derrotados (desc); **empate/zeradas usam a
  ordem do jogo** (`Region.order`) como desempate.
- Filtro: por nome da região (case/acento-insensível).

### Aba Bosses
- Itens: thumb (apagada/cinza se pendente) + nome + 👑 se principal + "Região ·
  status" + chevron.
- **Ordenação:** dois grupos — **★ Principais** (A-Z) e **Demais** (A-Z), com
  rótulos de seção.
- Filtro: por nome do boss (case/acento-insensível), preservando os grupos.

## Ação ao tocar num resultado

- **Região:** fecha a busca e o álbum **vai pra página** dela.
- **Boss:** fecha a busca, vai pra página da **região do boss** e **rola até o
  slot** dele (reusa o fluxo de `justRevealedBossId`/`ensureVisible` — sem a
  animação de derrota; só scroll/realce momentâneo). Reaproveitar
  `AlbumRevealRequested`? Não — esse dispara a animação. Em vez disso, um novo
  evento `AlbumNavigateToBoss(bossId)` que apenas posiciona (página + scroll),
  sem tocar o reveal. Para região, `AlbumNavigateToRegion(regionId)`.

## Componentes (feature `album`, bloc + get_it)

- **`AlbumView`:** adiciona o botão flutuante de lupa (Stack, sempre visível) →
  `SearchScreen.push(context)`. Trata os eventos de navegação: ao voltar da busca
  com um alvo, anima `PageController` até a página e (se boss) `ensureVisible`.
- **`SearchScreen`** (wire, `album/presenter/search/search_screen.dart`): cria o
  `SearchBloc` via locator. Retorna o alvo selecionado via `Navigator.pop` (um
  resultado: `SearchResult.region(id)` ou `SearchResult.boss(id, regionId)`), ou
  null se cancelado.
- **`SearchView`** (`album/presenter/search/search_view.dart`): campo + abas +
  listas. Consome o `SearchBloc`.
- **`SearchBloc`** (`album/presenter/search/bloc/`): segura `AlbumData` +
  `Progress` (via os usecases já existentes `LoadAlbumUsecase`/`LoadProgressUsecase`),
  a aba ativa e o texto; expõe as listas ordenadas/filtradas. Eventos:
  `SearchStarted`, `SearchTabChanged(tab)`, `SearchQueryChanged(text)`.
- **`SearchResult`** (domain-ish value, em `album/presenter/search/`): sealed/
  simples — `RegionResult(regionId)` | `BossResult(bossId, regionId)`.
- **AlbumView navegação:** como `SearchScreen.push` retorna o alvo, a `AlbumView`
  reusa seu `PageController` + `_slotKeys` para posicionar — não precisa de
  eventos novos no `AlbumBloc` se o posicionamento é feito na própria view. (Os
  "eventos de navegação" citados acima ficam locais à view; o `AlbumBloc` não
  muda.)

### Normalização de texto
Helper para busca acento-insensível (ex: "altus" acha "Planalto de Altus",
"pucao"~"poção"): minúsculas + remoção de diacríticos. Fica em
`album/presenter/search/search_match.dart` (função pura, testável).

## Testes

- **`SearchBloc`** (bloc_test): regiões ordenadas por derrotados (desempate por
  order); bosses agrupados principais(A-Z)/demais(A-Z); `SearchQueryChanged`
  filtra a aba ativa; `SearchTabChanged` mantém o texto.
- **`search_match`** (unit): normalização acento/caixa.
- **`SearchView`** (widget): mostra ambas as listas; trocar aba; tocar num item
  faz pop com o `SearchResult` certo.
- **`AlbumView`** (widget): com um `SearchResult` retornado, vai pra página certa.

## Fora de escopo (v1)

- Busca por loot, lore ou tipo de dano.
- Histórico de buscas / sugestões.
- Filtros combinados (ex: "só pendentes").
