local QBCore = exports['qb-core']:GetCoreObject()

local MIN_UPDATE_MINUTES = 1
local REQUEST_SYNC_COOLDOWN_SECONDS = 3

local VALID_WEATHER_TYPES = {
    EXTRASUNNY = true,
    CLEAR = true,
    CLOUDS = true,
    OVERCAST = true,
    RAIN = true,
    THUNDER = true,
    FOGGY = true,
    SMOG = true,
    XMAS = true,
    SNOW = true,
    SNOWLIGHT = true,
    BLIZZARD = true,
    NEUTRAL = true,
    CLEARING = true
}

local state = {
    weather = Config.FallbackWeather,
    hour = Config.FallbackHour,
    minute = Config.FallbackMinute,
    temperature = nil,
    source = 'fallback',
    updatedAt = 0,
    utcOffsetSeconds = nil,
    timezone = 'unknown'
}

local lastSyncRequestAt = {}

local function log(msg)
    if Config.Debug then
        print(('[qb_realweather] %s'):format(msg))
    end
end

local function notify(src, msg, msgType)
    TriggerClientEvent('QBCore:Notify', src, msg, msgType or 'primary')
end

local function sanitizeWeatherType(weatherType)
    local w = tostring(weatherType or ''):upper()
    if VALID_WEATHER_TYPES[w] then
        return w
    end

    local fallback = tostring(Config.FallbackWeather or 'CLEAR'):upper()
    if VALID_WEATHER_TYPES[fallback] then
        return fallback
    end

    return 'CLEAR'
end

local function normalizeHourMinute(hour, minute)
    local h = tonumber(hour) or Config.FallbackHour or 12
    local m = tonumber(minute) or Config.FallbackMinute or 0

    h = math.floor(h)
    m = math.floor(m)

    if h < 0 then h = 0 end
    if h > 23 then h = 23 end
    if m < 0 then m = 0 end
    if m > 59 then m = 59 end

    return h, m
end

local function shouldBlackout(hour)
    if not Config.EnableNightBlackout then
        return false
    end

    local startHour = tonumber(Config.NightBlackoutStartHour) or 22
    local endHour = tonumber(Config.NightBlackoutEndHour) or 6

    if startHour == endHour then
        return false
    end

    if startHour > endHour then
        return hour >= startHour or hour < endHour
    end

    return hour >= startHour and hour < endHour
end

local function mapOpenMeteoToGTA(weatherCode, isDay)
    local code = tonumber(weatherCode) or -1

    if code == 0 then
        return isDay and 'EXTRASUNNY' or 'CLEAR'
    end

    if code == 1 then
        return 'CLEAR'
    end

    if code == 2 then
        return 'CLOUDS'
    end

    if code == 3 then
        return 'OVERCAST'
    end

    if code == 45 or code == 48 then
        return 'FOGGY'
    end

    if (code >= 51 and code <= 67) or (code >= 80 and code <= 82) then
        return 'RAIN'
    end

    if code == 95 or code == 96 or code == 99 then
        return 'THUNDER'
    end

    if (code >= 71 and code <= 77) or code == 85 or code == 86 then
        return 'SNOWLIGHT'
    end

    return Config.FallbackWeather
end

local function parseTimeFromISO(isoString)
    if type(isoString) ~= 'string' then
        return Config.FallbackHour, Config.FallbackMinute
    end

    local hour, minute = isoString:match('T(%d%d):(%d%d)')
    return normalizeHourMinute(hour, minute)
end

local function getServerUtcOffsetSeconds()
    local now = os.time()
    local localDate = os.date('*t', now)
    local utcDate = os.date('!*t', now)
    return os.difftime(os.time(localDate), os.time(utcDate))
end

local function getRemoteClock(utcOffsetSeconds)
    local now = os.time()
    local utcNow = now - getServerUtcOffsetSeconds()
    local remoteEpoch = utcNow + (tonumber(utcOffsetSeconds) or 0)
    local remoteDate = os.date('!*t', remoteEpoch)

    if not remoteDate then
        return Config.FallbackHour, Config.FallbackMinute
    end

    return normalizeHourMinute(remoteDate.hour, remoteDate.min)
end

local function buildPayload()
    local hour, minute = normalizeHourMinute(state.hour, state.minute)

    if Config.SyncRealClock and state.utcOffsetSeconds ~= nil then
        hour, minute = getRemoteClock(state.utcOffsetSeconds)
    end

    local weather = sanitizeWeatherType(state.weather)
    local blackout = shouldBlackout(hour)

    return {
        weather = weather,
        hour = hour,
        minute = minute,
        temperature = state.temperature,
        source = state.source,
        updatedAt = state.updatedAt,
        blackout = blackout,
        timezone = state.timezone,
        utcOffsetSeconds = state.utcOffsetSeconds
    }
end

local function syncToAll()
    local payload = buildPayload()
    TriggerClientEvent('qb_realweather:client:sync', -1, payload)
    GlobalState.RealWeather = payload

    log(('Sync -> weather=%s time=%02d:%02d source=%s temp=%sC tz=%s off=%s')
        :format(
            payload.weather,
            payload.hour,
            payload.minute,
            payload.source,
            payload.temperature and tostring(payload.temperature) or 'n/a',
            payload.timezone or 'unknown',
            payload.utcOffsetSeconds and tostring(payload.utcOffsetSeconds) or 'n/a'
        )
    )
end

local function applyFallback(reason)
    if state.updatedAt > 0 then
        state.source = 'stale:' .. tostring(reason)
        state.updatedAt = os.time()
        syncToAll()
        return
    end

    state.weather = sanitizeWeatherType(Config.FallbackWeather)
    state.hour, state.minute = normalizeHourMinute(Config.FallbackHour, Config.FallbackMinute)
    state.temperature = nil
    state.source = 'fallback:' .. tostring(reason)
    state.updatedAt = os.time()

    syncToAll()
end

local function isCoordinatesValid(lat, lon)
    if type(lat) ~= 'number' or type(lon) ~= 'number' then
        return false
    end

    return lat >= -90.0 and lat <= 90.0 and lon >= -180.0 and lon <= 180.0
end

local function fetchRealWeather()
    local lat = tonumber(Config.Latitude)
    local lon = tonumber(Config.Longitude)

    if not isCoordinatesValid(lat, lon) then
        log(('Invalid coordinates: lat=%s lon=%s'):format(tostring(Config.Latitude), tostring(Config.Longitude)))
        applyFallback('invalid_coordinates')
        return
    end

    local endpoint = ('https://api.open-meteo.com/v1/forecast?latitude=%.6f&longitude=%.6f&current=temperature_2m,weather_code,is_day&timezone=auto')
        :format(lat, lon)

    PerformHttpRequest(endpoint, function(statusCode, body)
        if statusCode ~= 200 or not body or body == '' then
            log(('API error status=%s bodyLen=%s'):format(tostring(statusCode), tostring(body and #body or 0)))
            applyFallback('http_error')
            return
        end

        local decoded = json.decode(body)
        if not decoded or not decoded.current then
            log('API decode error or missing current payload')
            applyFallback('decode_error')
            return
        end

        local current = decoded.current
        local weatherCode = tonumber(current.weather_code)
        local isDay = tonumber(current.is_day) == 1
        local temperature = tonumber(current.temperature_2m)

        if not weatherCode then
            log('weather_code missing in response')
            applyFallback('missing_weather_code')
            return
        end

        local weatherType = sanitizeWeatherType(mapOpenMeteoToGTA(weatherCode, isDay))
        local nextHour, nextMinute = state.hour, state.minute

        if Config.SyncRealClock then
            local offset = tonumber(decoded.utc_offset_seconds)
            if offset ~= nil then
                state.utcOffsetSeconds = offset
            end

            state.timezone = tostring(decoded.timezone or state.timezone or 'unknown')

            if state.utcOffsetSeconds ~= nil then
                nextHour, nextMinute = getRemoteClock(state.utcOffsetSeconds)
            else
                nextHour, nextMinute = parseTimeFromISO(current.time)
            end
        else
            nextHour, nextMinute = normalizeHourMinute(state.hour, state.minute)
        end

        state.weather = weatherType
        state.hour, state.minute = normalizeHourMinute(nextHour, nextMinute)
        state.temperature = temperature
        state.source = 'open-meteo'
        state.updatedAt = os.time()

        syncToAll()
    end, 'GET', '', {
        ['Accept'] = 'application/json'
    })
end

CreateThread(function()
    Wait(2000)
    fetchRealWeather()

    local updateMinutes = tonumber(Config.UpdateIntervalMinutes) or 10
    if updateMinutes < MIN_UPDATE_MINUTES then
        updateMinutes = MIN_UPDATE_MINUTES
    end

    while true do
        Wait(math.floor(updateMinutes * 60000))
        fetchRealWeather()
    end
end)

CreateThread(function()
    while true do
        Wait(60000)

        if Config.SyncRealClock then
            syncToAll()
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    Wait(1000)
    syncToAll()
end)

AddEventHandler('playerDropped', function()
    local src = source
    lastSyncRequestAt[src] = nil
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function(playerSource)
    local src = source

    if (not src or src <= 0) and tonumber(playerSource) then
        src = tonumber(playerSource)
    end

    if not src or src <= 0 then
        return
    end

    local payload = buildPayload()
    TriggerClientEvent('qb_realweather:client:sync', src, payload)
end)

RegisterNetEvent('qb_realweather:server:requestSync', function()
    local src = source
    if not src or src <= 0 then
        return
    end

    local now = os.time()
    local last = lastSyncRequestAt[src] or 0
    if (now - last) < REQUEST_SYNC_COOLDOWN_SECONDS then
        return
    end

    lastSyncRequestAt[src] = now

    local payload = buildPayload()
    TriggerClientEvent('qb_realweather:client:sync', src, payload)
end)

if QBCore and QBCore.Commands and QBCore.Commands.Add then
    QBCore.Commands.Add('realweatherrefresh', 'Forza update meteo reale', {}, false, function(source)
        fetchRealWeather()
        notify(source, 'Aggiornamento meteo reale richiesto.', 'success')
    end, 'admin')

    QBCore.Commands.Add('realweatherstatus', 'Mostra stato realweather', {}, false, function(source)
        local payload = buildPayload()
        local msg = ('Fonte: %s | Meteo: %s | Ora: %02d:%02d | Temp: %sC | TZ: %s')
            :format(
                payload.source,
                payload.weather,
                payload.hour,
                payload.minute,
                payload.temperature and tostring(payload.temperature) or 'n/a',
                payload.timezone or 'unknown'
            )
        notify(source, msg, 'primary')
    end, 'admin')
else
    RegisterCommand('realweatherrefresh', function(src)
        fetchRealWeather()
        if src > 0 then
            notify(src, 'Aggiornamento meteo reale richiesto.', 'success')
        end
    end, false)

    RegisterCommand('realweatherstatus', function(src)
        local payload = buildPayload()

        if src > 0 then
            local msg = ('Fonte: %s | Meteo: %s | Ora: %02d:%02d | Temp: %sC | TZ: %s')
                :format(
                    payload.source,
                    payload.weather,
                    payload.hour,
                    payload.minute,
                    payload.temperature and tostring(payload.temperature) or 'n/a',
                    payload.timezone or 'unknown'
                )
            notify(src, msg, 'primary')
        else
            print(('[qb_realweather] source=%s weather=%s time=%02d:%02d temp=%sC tz=%s')
                :format(
                    payload.source,
                    payload.weather,
                    payload.hour,
                    payload.minute,
                    payload.temperature and tostring(payload.temperature) or 'n/a',
                    payload.timezone or 'unknown'
                )
            )
        end
    end, false)
end
