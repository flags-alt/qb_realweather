# qb_realweather

Professional QBCore weather resource for FiveM.
It syncs GTA weather and in-game time with real-world weather data from Open-Meteo.

Current version: **v1.0.0**

## Features

- Real-world weather sync (sun, clouds, fog, rain, thunder, snow)
- Real local clock sync for your configured city
- Automatic fallback mode if API is unavailable
- Robust client sync on join/reconnect
- Optional night blackout mode
- Admin commands for refresh and diagnostics

## Requirements

- FiveM server
- `qb-core`
- Internet access from server to `api.open-meteo.com`

## Installation

1. Place `qb_realweather` inside your server `resources` folder.
2. Add this to `server.cfg`:

```cfg
ensure qb-core
ensure qb_realweather
```

3. Disable other weather/time resources (for example `qb-weathersync`) to avoid conflicts.
4. Edit `config.lua` and set your city coordinates.

## Configuration

Edit `qb_realweather/config.lua`:

- `Config.Latitude`
  - City latitude (example Rome: `41.9028`)
- `Config.Longitude`
  - City longitude (example Rome: `12.4964`)
- `Config.UpdateIntervalMinutes`
  - API refresh interval in minutes
- `Config.SyncRealClock`
  - `true` = use real local clock for configured city
- `Config.Debug`
  - `true` = print debug logs in server console
- `Config.FallbackWeather`
  - Fallback GTA weather type used if startup API call fails
- `Config.FallbackHour`
  - Fallback in-game hour
- `Config.FallbackMinute`
  - Fallback in-game minute
- `Config.EnableNightBlackout`
  - Enable optional blackout during configured night hours
- `Config.NightBlackoutStartHour`
  - Blackout start hour
- `Config.NightBlackoutEndHour`
  - Blackout end hour

## Admin Commands

- `/realweatherrefresh`
  - Forces immediate weather update from API
- `/realweatherstatus`
  - Shows source, weather type, current synced time, temperature, and timezone

## How It Works

1. Server fetches current weather from Open-Meteo.
2. Weather codes are mapped to GTA weather types.
3. Server broadcasts synced payload to all clients.
4. Clients apply weather, clock, and blackout state.
5. If API is temporarily unavailable, script keeps last valid state (`stale`) or uses fallback at first boot.

## Recommended Production Setup

- Keep update interval between 5 and 15 minutes.
- Keep `Config.Debug = false` on production servers.
- Run only one weather/time authority resource.

## Troubleshooting

- Weather not changing:
  - Check if another weather resource is still running.
- Time not matching your city:
  - Verify latitude/longitude values.
- API issues:
  - Check server internet access and firewall/DNS rules.
- Quick diagnostics:
  - Run `/realweatherstatus` and review server console logs.

## Files

- `fxmanifest.lua`
- `config.lua`
- `server/main.lua`
- `client/main.lua`
- `CHANGELOG.md`
- `RELEASE_NOTES_v1.0.0.md`

## Changelog

See `CHANGELOG.md`.

## License

Add your preferred license before public distribution.

For more information: **@tronxxw**
