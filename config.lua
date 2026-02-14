Config = {}

-- Set your city coordinates (latitude/longitude)
-- Example Rome: 41.9028, 12.4964
Config.Latitude = 41.9028
Config.Longitude = 12.4964

-- Weather API refresh interval in minutes
Config.UpdateIntervalMinutes = 10

-- If true, syncs real local time for the configured city
Config.SyncRealClock = true

-- If true, prints debug logs in server console
Config.Debug = true

-- Fallback values used if API is unavailable during first startup
Config.FallbackWeather = 'CLEAR'
Config.FallbackHour = 12
Config.FallbackMinute = 0

-- Optional night blackout settings
Config.EnableNightBlackout = false
Config.NightBlackoutStartHour = 22
Config.NightBlackoutEndHour = 6
