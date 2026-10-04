# Project BIT Historical Timeline — 1980–1984

Version: 0.1.0

This is a curated, game-oriented baseline of historical events from January 1980 through December 1984.

## Layout

- `1980/1980-01.json` ... `1984/1984-12.json`: one file per monthly turn.
- `history_1980_1984_master.json`: all 60 months plus the source registry.
- `history.schema.json`: JSON Schema for monthly files.
- `sources.json`: source registry used by `source_keys`.

## Design rules

Historical facts and game interpretation are kept separate.

`headline`, `summary`, `date`, `scope`, and `tags` describe the historical event.

`economic_sectors` and `game_relevance` are **game-design metadata**. They are suggested hooks such as `oil_price`, `consumer_sentiment`, `interest_rates`, or `defense_sector`; they do not assert that a specific security rose or fell because of the event.

`importance` uses a 1–5 scale:
- 1: minor flavor
- 2: notable period flavor
- 3: significant
- 4: major
- 5: era-defining / potentially major game-world impact

## Date precision

Exact dates use `YYYY-MM-DD`.

When this baseline intentionally avoids asserting an exact day, `date` is `YYYY-MM` and `date_precision` is `month`.

`known_as_of` is the earliest date this version assumes the event can be exposed to the player. In v0.1 it normally matches the event date. A later pass can distinguish `event_date`, `public_knowledge_date`, and `resolution_date` for rumors, investigations, and long-running events.

## Suggested Godot/Codex use

A monthly turn can load:

`res://data/history/1982/1982-09.json`

Then:
1. Sort/filter events by `importance`.
2. Pick 2–5 headlines for the player's newspaper/news feed.
3. Use `category`, `tags`, `economic_sectors`, and `game_relevance` for contextual narration.
4. Do **not** directly change historical stock prices from `game_relevance`; use the game's market-price dataset as the source of truth.
5. Keep event IDs stable once referenced by saves, achievements, quests, or narrative triggers.

## Sources and verification

This is a curated starting dataset rather than a scholarly or exhaustive chronology. Timeline pages were used as broad event indexes, while NBER and Federal Reserve History were used for the key U.S. business-cycle/monetary-policy context.

Before an event drives a deterministic gameplay consequence, verify the relevant facts and pair it with actual historical market/economic data.

## Recommended next extension

For v0.2 add:
- `start_date` / `end_date` for long-running events
- `public_knowledge_date`
- `regions`
- `countries`
- `companies`
- `tickers`
- `confidence`
- `market_link_strength`
- separate player-facing `news_copy`
