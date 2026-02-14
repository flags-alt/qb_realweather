# qb_realweather v1.0.0

Release iniziale stabile per QBCore.

## Highlights
- Meteo reale e ora reale sincronizzati con la posizione configurata.
- Script standalone, leggero, senza dipendenze esterne oltre `qb-core`.
- Comandi admin per refresh e diagnostica rapida.
- Gestione fallback in caso di errore API.

## Requisiti
- FiveM Server
- QBCore (`qb-core`)
- Accesso internet lato server verso `api.open-meteo.com`

## Installazione rapida
1. Copia la cartella `qb_realweather` dentro `resources`.
2. Aggiungi in `server.cfg`:
   ```cfg
   ensure qb-core
   ensure qb_realweather
   ```
3. Configura `Config.Latitude` e `Config.Longitude` in `config.lua`.
4. Disattiva altri script meteo/orario per evitare conflitti.

## Comandi
- `/realweatherrefresh`
- `/realweatherstatus`

## Supporto
Per supporto tecnico, allega sempre:
- output console di `realweatherstatus`
- coordinate configurate
- lista di eventuali altri weather script attivi
