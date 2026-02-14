# Changelog

All notable changes to this project are documented in this file.

## [1.0.0] - 2026-02-14

### Added
- Complete QBCore resource `qb_realweather` for real-time weather and clock synchronization.
- Periodic weather updates from Open-Meteo (no API key required for base usage).
- Real-weather to GTA weather mapping (`EXTRASUNNY`, `RAIN`, `THUNDER`, `FOGGY`, `SNOWLIGHT`, etc.).
- Admin commands:
  - `/realweatherrefresh`
  - `/realweatherstatus`
- Client join synchronization and manual sync request flow.
- Optional night blackout behavior via config.
- Release package artifacts (`zip`, `sha256`, release manifest).

### Changed
- Improved time synchronization robustness using `utc_offset_seconds`.
- Improved client persistence behavior to avoid unnecessary weather re-application.
- Added server-side sync request rate limiting.

### Fixed
- Updated Open-Meteo endpoint query for current API compatibility (removed `time` from `current` parameter).
- Added stronger coordinate validation and hour/minute normalization.
