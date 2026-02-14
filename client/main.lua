local current = {
    weather = tostring(Config.FallbackWeather or 'CLEAR'):upper(),
    hour = tonumber(Config.FallbackHour) or 12,
    minute = tonumber(Config.FallbackMinute) or 0,
    blackout = false
}

local applied = {
    weather = nil,
    blackout = nil
}

local function normalizeHourMinute(hour, minute)
    local h = tonumber(hour) or 12
    local m = tonumber(minute) or 0

    h = math.floor(h)
    m = math.floor(m)

    if h < 0 then h = 0 end
    if h > 23 then h = 23 end
    if m < 0 then m = 0 end
    if m > 59 then m = 59 end

    return h, m
end

local function applyWeatherIfChanged(weatherType)
    local weather = tostring(weatherType or current.weather or 'CLEAR'):upper()
    if applied.weather == weather then
        return
    end

    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypeOvertimePersist(weather, 15.0)
    Wait(150)
    SetWeatherTypePersist(weather)
    SetWeatherTypeNow(weather)
    SetWeatherTypeNowPersist(weather)

    applied.weather = weather
end

local function applyTimeNow(hour, minute)
    local h, m = normalizeHourMinute(hour, minute)
    NetworkOverrideClockMillisecondsPerGameMinute(60000)
    NetworkOverrideClockTime(h, m, 0)
end

local function applyBlackoutIfChanged(value)
    local blackout = value == true
    if applied.blackout == blackout then
        return
    end

    SetArtificialLightsState(blackout)
    applied.blackout = blackout
end

local function applyPayload(payload)
    if type(payload) ~= 'table' then
        return
    end

    current.weather = tostring(payload.weather or current.weather or 'CLEAR'):upper()
    current.hour, current.minute = normalizeHourMinute(payload.hour, payload.minute)
    current.blackout = payload.blackout == true

    applyWeatherIfChanged(current.weather)
    applyTimeNow(current.hour, current.minute)
    applyBlackoutIfChanged(current.blackout)
end

RegisterNetEvent('qb_realweather:client:sync', function(payload)
    applyPayload(payload)
end)

CreateThread(function()
    Wait(2500)

    local gs = GlobalState.RealWeather
    if type(gs) == 'table' then
        applyPayload(gs)
    else
        applyWeatherIfChanged(current.weather)
        applyTimeNow(current.hour, current.minute)
        applyBlackoutIfChanged(current.blackout)
    end

    TriggerServerEvent('qb_realweather:server:requestSync')

    while true do
        Wait(300000)
        TriggerServerEvent('qb_realweather:server:requestSync')

        -- Mantiene meteo/blackout persistenti anche dopo alcuni cambi client-side.
        SetWeatherTypeNowPersist(current.weather)
        applyBlackoutIfChanged(current.blackout)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('qb_realweather:server:requestSync')
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    SetArtificialLightsState(false)
end)
