Config = {}

-- Imposta la tua citta usando latitudine/longitudine
-- Esempio Roma: 41.9028, 12.4964
Config.Latitude = 41.9028
Config.Longitude = 12.4964

-- Ogni quanti minuti aggiornare i dati meteo reali dall'API
Config.UpdateIntervalMinutes = 10

-- Se true sincronizza l'orario reale locale della citta configurata
Config.SyncRealClock = true

-- Se true stampa log utili in console
Config.Debug = true

-- Fallback usato se API non risponde al primo avvio
Config.FallbackWeather = 'CLEAR'
Config.FallbackHour = 12
Config.FallbackMinute = 0

-- Blackout notturno opzionale
Config.EnableNightBlackout = false
Config.NightBlackoutStartHour = 22
Config.NightBlackoutEndHour = 6
