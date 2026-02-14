# Changelog

Tutte le modifiche rilevanti del progetto sono documentate in questo file.

## [1.0.0] - 2026-02-14

### Added
- Risorsa QBCore completa `qb_realweather` per sincronizzazione meteo e ora reale.
- Aggiornamento meteo periodico da Open-Meteo senza API key.
- Mapping meteo reale -> weather type GTA (`EXTRASUNNY`, `RAIN`, `THUNDER`, `FOGGY`, `SNOWLIGHT`, ecc.).
- Comandi admin:
  - `/realweatherrefresh`
  - `/realweatherstatus`
- Sincronizzazione su join player e sync manuale client->server.
- Modalita fallback/stale se API non disponibile.
- Blackout notturno opzionale via config.

### Changed
- Migliorata la robustezza della sincronizzazione orario con gestione `utc_offset_seconds`.
- Migliorata persistenza meteo lato client evitando reapply inutili.
- Aggiunto rate-limit richieste sync lato server per ridurre spam eventi.

### Fixed
- Corretto endpoint Open-Meteo: rimosso `time` dal parametro `current` per compatibilita API attuale.
- Migliorata validazione coordinate e normalizzazione ora/minuti.
