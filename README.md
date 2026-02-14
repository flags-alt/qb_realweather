# qb_realweather

Script QBCore che sincronizza meteo e orario di FiveM con meteo reale (API Open-Meteo).

Versione corrente: **v1.0.0**

## Funzioni

- Meteo reale periodico (pioggia, nuvole, nebbia, temporale, neve)
- Ora reale della localita configurata
- Comandi admin QB:
  - `/realweatherrefresh`
  - `/realweatherstatus`
- Fallback automatico se API non raggiungibile
- Sync robusta su join player

## Installazione

1. Copia `qb_realweather` nella tua cartella `resources`.
2. In `server.cfg` aggiungi:

```cfg
ensure qb-core
ensure qb_realweather
```

3. Configura coordinate citta in `qb_realweather/config.lua`:
   - `Config.Latitude`
   - `Config.Longitude`

## Importante

- Disattiva altri script che gestiscono meteo/orario (es. `qb-weathersync`) per evitare conflitti.
- Se Open-Meteo non risponde, lo script usa i valori fallback del config.

## Config principali

- `Config.UpdateIntervalMinutes`: frequenza aggiornamento API
- `Config.SyncRealClock`: sincronizza ora reale
- `Config.EnableNightBlackout`: blackout luci notturno opzionale

## Comandi admin

- `/realweatherrefresh`: forza update API immediato
- `/realweatherstatus`: mostra stato attuale sync

## Changelog

Vedi `qb_realweather/CHANGELOG.md`.

## Note

Open-Meteo e gratuito e senza API key per uso base.
