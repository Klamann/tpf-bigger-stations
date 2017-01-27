--[[

station mod by Klamann

]]--

local constructionutil = require "constructionutil"
local paramsutil = require "paramsutil"
local railstationconfigutil = require "stationmod_railstationconfigutil"
--local stationmod_deps = require "stationmod_deps"
local stationmod = {}


-- store copies of functions that will be overriden in the `super` table
local super = {}
super.makeTrainStationNew = constructionutil.makeTrainStationNew
super.makePlatformConfig = railstationconfigutil.makePlatformConfig


--[[
local function makeNumTracksValues(stationConfig)
  local result = { }

  if stationConfig ~= nil then
    for i = 1, #stationConfig.tracksConfig do
      result[#result + 1] = _("${value}") % { value = stationConfig.tracksConfig[i].num }
    end
  else
    result = { _("1"), _("2"), _("3"), _("4"), _("5") }
  end

  return result
end

local function makeSizeIndexValues(stationConfig, platformConfig)
  local result = { }

  if stationConfig ~= nil and platformConfig ~= nil then
    for i = 1, #platformConfig do
      result[#result + 1] = _("${value} m") % { value = #platformConfig[i].firstPlatformParts * stationConfig.segmentLength }
    end
  else
    result = { _("1 m"), _("2 m"), _("3 m") }
  end

  return result
end
]]--




--[[

TODO reduce segment length to 40, add way more segments, calculate the proper segment index from selection

number of tracks
* first row: 1..8. second row: +0, +8, +16+, +24, +32

track length
* first row: 40, 80, 120, 160, 200. second row: +200, +400, +600, +800
* need to change `config.segmentLength = 40` in constructionutil -> does not work
* there's no proper entry points for that, so I'll probably have to copy most of that file :/
* maybe add another file with copied stuff, so it remains separate from my actual code

 ]]


-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function tprint (tbl, indent)
  if not indent then indent = 2 end
  for k, v in pairs(tbl) do
    local formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    else
      print(formatting .. tostring(v))
    end
  end
end


--- make a new train station
-- overrides `constructionutil.makeTrainStationNew`
-- adjust the configuration, before the original function gets called
-- @param config
--
--[[
function constructionutil.makeTrainStationNew(config)
  config.segmentLength = 20   -- TODO check why this doesn't help
  config.numTracks = 5
  return super.makeTrainStationNew(config)
end
--]]

--
-- parameter definitions
--


stationmod.numTracks = { 1, 2, 3, 4, 5, 6, 7, 8 }
stationmod.numTracksStr = { _("1"), _("2"), _("3"), _("4"), _("5"), _("6"), _("7"), _("8") }
stationmod.numTracksToAdd = { 0, 8, 16, 24, 32, 40 }
stationmod.numTracksToAddStr = { _("+0"), _("+8"), _("+16"), _("+24"), _("+32"), _("+40") }
stationmod.trackLength = { 80, 160, 240, 320, 400 }
stationmod.trackLengthStr = { _("80m"), _("160m"), _("240m"), _("320m"), _("400m") }
stationmod.trackLengthToAdd = { 0, 400, 800, 1200 }
stationmod.trackLengthToAddStr = { _("+0"), _("+400m"), _("+800m"), _("+1200m") }


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
    {   -- TODO change name
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


-- TODO fix compatibility issues with other mods, or move to separate buildings...

-- store the most recent state to see if this mod is currently active
stationmod.state = {}
stationmod.state.lastNumTracks = 0
stationmod.state.numTracksToAdd = 0
stationmod.state.numTracksIndex = 0


function railstationconfigutil.makeTrainStationConfig(params, stationConfig, stationBuilding, platformConfig)

  print("params:\n")
  for k, v in pairs(params) do
    print(tostring(k) .. ": " .. tostring(v))
  end
  print("\n\n")
  --tprint(params)
  print("stationConfig:")
  tprint(stationConfig)
  --print("stationBuilding:")
  --tprint(stationBuilding)
  --print("\n\nplatformConfig:\n")
  --tprint(platformConfig)
  --print("\n\n")

  -- in case you're wondering about all those +1 to the indices
  -- lua is 1-based, while every same programming language is 0-based,
  -- and lua gets called from c++ here, so all parameters we get are 0-based...

  -- TODO detect whether this is the active mod by storing the last value of numTracks and numTracksToAdd and numTracksIndex
  -- if numTracksIndex was changed last, but none of the others, another station is active
  -- this does not work, behaviour is pretty inconsistent...

  -- TODO look at stationConfig: name + stationType + type
  -- if name changes and newParamNil -> disable mod
  -- only re-enable when name changes and not newParamNil

  -- avoiding compatibility issues is impossible using this approach -> just add another station...
  -- yet, that will make this mod mandatory. if you remove it, the savegame is lost...
  -- TODO find out why some mods suck at this and fix it


  -- at least one of the new parameters is nil -> some other mod may be blocking them
  local newParamNil = params.numTracks == nil or params.numTracksToAdd == nil
  -- an old parameter is visible -> some other mod may have enabled this
  local oldParamsVisible = params.numTracksIndex ~= nil
  -- only enable the mod, if all new params are set and no old params are visible
  local enabled = not newParamNil -- or oldParamsVisible)


  local trackParamsNotNil = params.numTracks ~= nil and params.numTracksToAdd ~= nil
  local numTracksChanged = params.numTracks ~= stationmod.state.lastNumTracks
  local numTracksToAddChanged = params.numTracksToAdd ~= stationmod.state.numTracksToAdd
  local numTracksIndexChanged = params.numTracksIndex ~= stationmod.state.lastNumTracksIndex
  local active = trackParamsNotNil and (not numTracksIndexChanged or numTracksChanged or numTracksToAddChanged)
  stationmod.state.lastNumTracks = params.numTracks
  stationmod.state.numTracksToAdd = params.numTracksToAdd
  stationmod.state.numTracksIndex = params.numTracksIndex


  if not enabled then
    --params.numTracks = 0
    -- reset the track adder, if the user switches to an unsupported station
    print("at least one null param -> reset!")
    --params.numTracksToAdd = 0
  end


  local numTracks
  local trackConfigIndex

  -- see if this mod's custom parameters have been loaded (may be overriden by other mods)
  if enabled then
    -- calculate the intended number of tracks
    numTracks = stationmod.numTracks[params.numTracks+1] + stationmod.numTracksToAdd[params.numTracksToAdd+1]
    -- set the original parameter, so we don't have to change existing code
    params.numTracksIndex = numTracks-1
    -- calculate the track config index (must not exceed the length of the tracksConfig)
    trackConfigIndex = math.min(numTracks, #stationConfig.tracksConfig)
  else
    -- fall back to the default behaviour
    numTracks = stationConfig.tracksConfig[params.numTracksIndex + 1].num
    trackConfigIndex = params.numTracksIndex + 1
  end



  local selectedPlatformConfig
  if enabled then
    local trackLength = (params.trackLength+1) + #stationmod.trackLength * (params.trackLengthToAdd)
    stationConfig.numSizes = { trackLength }
    platformConfig = railstationconfigutil.makePlatformConfig(stationConfig)
    selectedPlatformConfig = platformConfig[1]
  else
    selectedPlatformConfig = platformConfig[params.sizeIndex + 1]
  end


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
    platformConfig = selectedPlatformConfig,
    trackType = stationConfig.trackTypes[(params.trackType or 0) + 1],
    catenary = params.catenary == 1,
    type = stationConfig.type
  }
end

return stationmod
