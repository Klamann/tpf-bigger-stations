--[[

station mod by Klamann

]]--

--local constructionutil = require "constructionutil"
local paramsutil = require "paramsutil"
local railstationconfigutil = require "stationmod_railstationconfigutil"
local stationmod = {}


-- store copies of functions that will be overriden in the `super` table
local super = {}
super.makeTrainStationConfig = railstationconfigutil.makeTrainStationConfig


-- logging setup
local log = require "log"
log.usecolor = false
-- choices: "trace", "debug", "info", "warn", "error", "fatal"
log.level = "debug"


--
-- utility functions
--


--- Print the contents of a table, recursively, with indentation.
-- @param tbl the table to print
-- @param indent sets the initial level of indentation (default=2)
--
function tprint (tbl, indent, printFunction)
  if indent == nil then indent = 2 end
  if printFunction == nil then printFunction = print end
  for k, v in pairs(tbl) do
    local formatting = string.rep(" ", indent) .. k .. ": "
    if type(v) == "table" then
      printFunction(formatting)
      tprint(v, indent+1, printFunction)
    else
      printFunction(formatting .. tostring(v))
    end
  end
end

--- return the keys of a table in a new array
function getTableKeys(tbl)
  local keys = {}
  local n=0
  for k,v in pairs(tbl) do
    n=n+1
    keys[n]=k
  end
  return keys
end

--- checks whether the contents of two arrays are equal
function areArraysEqual(ar1, ar2)
  if #ar1 ~= #ar2 then
    return false
  else
    for i=1, #ar1 do
      if ar1[i] ~= ar2[i] then
        return false
      end
    end
    return true
  end
end

--- creates a string representation of an array's contents (non-recursive)
function arrayToString(ar)
  return "[" .. table.concat(ar, ", ") .. "]"
end

--- creates a string representation of a table's contents (non-recursive)
function tableToString(tbl)
  local ar = {}
  local n=0
  for k, v in pairs(tbl) do
    n = n + 1
    ar[n] = tostring(k) .. ": " .. tostring(v)
  end
  return arrayToString(ar)
end


--
-- ui parameters
--


stationmod.numTracks = { 1, 2, 3, 4, 5, 6, 7, 8 }
stationmod.numTracksStr = { _("1"), _("2"), _("3"), _("4"), _("5"), _("6"), _("7"), _("8") }
stationmod.numTracksToAdd = { 0, 8, 16, 24, 32, 40 }
stationmod.numTracksToAddStr = { _("+0"), _("+8"), _("+16"), _("+24"), _("+32"), _("+40") }
stationmod.trackLength = { 80, 160, 240, 320, 400 }
stationmod.trackLengthStr = { _("80m"), _("160m"), _("240m"), _("320m"), _("400m") }
stationmod.trackLengthToAdd = { 0, 400, 800, 1200 }
stationmod.trackLengthToAddStr = { _("+0"), _("+400m"), _("+800m"), _("+1200m") }


--- this function overrides the original makeTrainStationParams from paramsutil.
-- it redeclares the default paramteres and adds the custom components that are required for this mod.
-- @param stationConfig the station's configuration (not required here)
-- @param platformConfig an array of available platform config options (also not needed)
--
function paramsutil.makeTrainStationParams(stationConfig, platformConfig)
  return {
    {
      key = "numTracks",
      name = _("Number of tracks"),
      values = stationmod.numTracksStr,
      defaultIndex = 0
    },
    {
      key = "numTracksToAdd",
      name = _(""),
      values = stationmod.numTracksToAddStr,
      defaultIndex = 0
    },
    {
      key = "trackLength",
      name = _("Platform length"),
      values = stationmod.trackLengthStr,
      defaultIndex = 1
    },
    {
      key = "trackLengthToAdd",
      name = _(""),
      values = stationmod.trackLengthToAddStr,
      defaultIndex = 0
    },
    paramsutil.makeTrackTypeParam(),
    paramsutil.makeTrackCatenaryParam(),
    {
      key = "streetSecondConnection",
      name = _("Second street connection"),
      values = { _("No"), _("Yes") }
    },
  }
end


--
-- train station config
--


-- store the most recent state to decide if this mod can be safely activated
stationmod.state = {}
stationmod.state.lastStationName = ""
stationmod.state.lastParams = {}
stationmod.state.selectedStationChanged = false
stationmod.state.enabled = false


--- this function overrides the original makeTrainStationConfig from railstationconfigutil.
-- it's purpose is to decide, whether the currently selected station is compatible with this mod
-- and then to either build a modded station config or to fall back to the default config
-- @param params the gui parameters
-- @param stationConfig the station's configuration (tracks, platforms, you name it)
-- @param stationBuilding definition of the station's building
-- @param platformConfig an array of available platform config options
--
function railstationconfigutil.makeTrainStationConfig(params, stationConfig, stationBuilding, platformConfig)

  -- log some stuff, for debugging...
  log.debug("--- makeTrainStationConfig ---")
  log.debug("params: " .. tableToString(params))
  log.trace("params:")
  tprint(params, 2, log.trace)
  log.trace("stationConfig:")
  tprint(stationConfig, 2, log.trace)
  log.trace("stationBuilding:")
  tprint(stationBuilding, 2, log.trace)
  log.trace("platformConfig:")
  tprint(platformConfig, 2, log.trace)

  --
  -- first, let's gather some useful information
  --

  -- at least one of the new parameters is nil
  local newParamNil = params.numTracks == nil or params.numTracksToAdd == nil or params.trackLength == nil or params.trackLengthToAdd == nil
  -- at least one of the old parameters is nil
  local oldParamNil = params.numTracksIndex == nil or params.sizeIndex == nil
  -- at least one of the old parameters is visible
  local oldParamVisible = params.numTracksIndex ~= nil or params.sizeIndex ~= nil
  -- generate a name from the stationConfig. sadly, this is not guaranteed to be unique
  local stationName = tostring(stationConfig.type) .. "-" .. tostring(stationConfig.stationType) .. "-" .. tostring(stationConfig.name)

  --[[
  now, let's detect whether the user switched to another station in the UI.
  we have 3 ways of detecting that a new station has been selected in the menu:
  1. the station name has changed
     * this can be easily figuered out, but sadly, modders sometimes use the same station names as the vanilla stations
  2. certain parameters are missing, depending on the previous mod state
     * this can be either
       - mod was enabled, but now mod params are missing
       - mod was disabled, but now old params are missing
     * if we jsut wanted to detect, whether the stationmod is available or not, we're done here
     * if we want to detect switches between any station, whether it's modded or not, we need one more step
  3. the list of ui parameter keys has changed
     * ok, some background here. this is how params behave:
       - new station selected in gui (first call): only params that are visible in the gui are available
       - parameter changed in same station (second call): all params that have been ever set are visible
       - parameter changed in same station (subsequent calls): parameters remain stable
     * this mindfuck is the reason why we can't have nice things
     * here's how we fix this:
       - when a new station has been selected, store this event (stationmod.state.selectedStationChanged = true)
       - next time, when selectedStationChanged is true, store the list of parameter keys and set it to false again
       - now check each time, if the list of parameter keys has changed. If it did, a new station has been selected
  ]]--

  --
  -- 1. has the station name changed?
  --

  local stationNameChanged = stationName ~= stationmod.state.lastStationName

  --
  -- 2. are any parameters missing?
  --

  -- the station mod has been disabled (was enabled, but mod params are missing)
  local stationModDisabled = stationmod.state.enabled and newParamNil
  -- the station mod has been enabled (was disabled, but old params are missing)
  local stationModEnabled = not stationmod.state.enabled and oldParamNil

  --
  -- 3. has the list of ui parameter keys changed?
  --

  -- current list of parameter key
  local paramKeys = getTableKeys(params)
  -- is the list of parameters equal to the previous one?
  local paramsChanged = false
  -- has the selected station changed in the previous call to this function?
  if stationmod.state.selectedStationChanged then
    -- store current parameters and reset event
    stationmod.state.lastParams = paramKeys
    stationmod.state.selectedStationChanged = false
  else
    -- compare stored parameters to the last known state
    paramsChanged = not areArraysEqual(paramKeys, stationmod.state.lastParams)
  end

  --
  -- evaluate the results and decide, whether the mod is to be enabled
  --

  -- check if the user switched to a new station in the menu
  if (stationNameChanged or stationModDisabled or stationModEnabled or paramsChanged) then

    -- find out what happened and alter state
    local switched = "switched to another station with the same name"
    if stationNameChanged then
      log.debug("selected station changed from \"" .. stationmod.state.lastStationName .. "\" to \"" .. stationName .. "\"")
      stationmod.state.lastStationName = stationName
    elseif stationModDisabled then
      log.debug(switched .. " (mod was enabled, but mod parameters are gone)")
    elseif stationModEnabled then
      log.debug(switched .. " (mod was disabled, but old parameters are gone)")
    elseif paramsChanged then
      log.debug(switched .. " (ui parameters suddenly changed)")
    end
    stationmod.state.selectedStationChanged = true

    -- decide, whether the mod will be enabled for the selected station
    stationmod.state.enabled = not newParamNil and oldParamNil
    log.debug("all new params availalbe: " .. tostring(not newParamNil) .. ", any old params visible: " .. tostring(oldParamVisible) .. " -> stationmod enabled: " .. tostring(stationmod.state.enabled))
  end

  if stationmod.state.enabled then
    -- call the mod config, if selected station is supported
    log.debug("generating stationmod config")
    return stationmod.makeTrainStationConfig(params, stationConfig, stationBuilding, platformConfig)
  else
    -- fall back to the default config, if there is reason for concern
    log.debug("generating default config (stationmod disabled)")
    return super.makeTrainStationConfig(params, stationConfig, stationBuilding, platformConfig)
  end
end


--- this is the custom makeTrainStationConfig function that gets called when the selected station supports this mod.
-- this is the case for all vanilla stations and certain mod stations that didn't temper with the track configuration.
-- @param params the gui parameters
-- @param stationConfig the station's configuration (tracks, platforms, you name it)
-- @param stationBuilding definition of the station's building
-- @param platformConfig an array of available platform config options
--
function stationmod.makeTrainStationConfig(params, stationConfig, stationBuilding, platformConfig)

  -- in case you're wondering about all those +1 to the indices:
  -- lua is 1-based, while every same programming language is 0-based.
  -- lua gets called from c++ here, so all parameters we get are 0-based...

  -- calculate the intended number of tracks
  local numTracks = stationmod.numTracks[params.numTracks+1] + stationmod.numTracksToAdd[params.numTracksToAdd+1]
  -- set the original parameter, so we don't have to change existing code
  params.numTracksIndex = numTracks-1
  -- calculate the track config index (must not exceed the length of the tracksConfig)
  local trackConfigIndex = math.min(numTracks, #stationConfig.tracksConfig)

  -- calculate the combined track length index
  local trackLengthIndex = (params.trackLength+1) + #stationmod.trackLength * (params.trackLengthToAdd)
  -- adjust the stationConfig and generate a new platformConfig
  stationConfig.numSizes = { trackLengthIndex }
  platformConfig = railstationconfigutil.makePlatformConfig(stationConfig)

  log.debug("building " .. tostring(numTracks) .. " tracks and " .. tostring(trackLengthIndex) .. " platform segments")

  return {
    -- multiply the number of tracks by this value
    trackMultiplier = 1,
    -- the number of tracks (actual number, not some weird index)
    numTracks = numTracks,
    -- track segment length (stretch or shorten the station by changing this value)
    segmentLength = stationConfig.segmentLength,
    -- distance from platform to track
    platformDistance = stationConfig.platformDistance,
    -- distance from one track to the next (default: 1 track, therefore no gap. multiply to leave gaps)
    trackDistance = params.state.track.trackDistance,
    stationType = stationConfig.stationType,
    streetConnectionType = 2, --params.streetConnectionType + 1,
    streetType = stationConfig.streetType,
    streetSecondConnection = params.streetSecondConnection,
    stairs = stationConfig.stairs,
    stairsPlatform = stationConfig.stairsPlatform,
    buildingWidth = stationBuilding[trackConfigIndex].width,
    stationBuilding = stationBuilding[trackConfigIndex].building,
    platformConfig = platformConfig[1],
    trackType = stationConfig.trackTypes[(params.trackType or 0) + 1],
    catenary = params.catenary == 1,
    type = stationConfig.type
  }
end

log.info("Klamann's stationmod has been loaded")
return stationmod
