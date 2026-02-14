# qb_realweather v1.0.0

Initial stable release for QBCore.

## Highlights

- Real-world weather synchronization for FiveM.
- Real local clock synchronization based on configured location.
- Lightweight, standalone resource (requires only `qb-core`).
- Admin refresh/status commands for operations and troubleshooting.
- Fallback and stale-state handling for API outages.

## Requirements

- FiveM server
- QBCore (`qb-core`)
- Server internet access to `api.open-meteo.com`

## Quick Install

1. Copy `qb_realweather` into your `resources` folder.
2. Add to `server.cfg`:
   ```cfg
   ensure qb-core
   ensure qb_realweather
   ```
3. Configure `Config.Latitude` and `Config.Longitude` in `config.lua`.
4. Disable any other weather/time resource to avoid conflicts.

## Admin Commands

- `/realweatherrefresh`
- `/realweatherstatus`

## Support

When requesting support, include:
- output of `/realweatherstatus`
- configured coordinates
- list of active weather/time resources

For more information: **@tronxxw**
