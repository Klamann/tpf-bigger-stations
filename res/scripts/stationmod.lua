--[[

station mod by Klamann

]]--

local constructionutil = require "constructionutil"
local paramsutil = require "paramsutil"
local railstationconfigutil = require "railstationconfigutil"
--local stationmod_deps = require "stationmod_deps"
local stationmod = {}


-- store copies of functions that will be overriden in the `super` table
local super = {}
super.makeTrainStationNew = constructionutil.makeTrainStationNew



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
stationmod.sizeIndex = { 40, 80, 120, 160, 200 }
stationmod.sizeIndexStr = { _("40m"), _("80m"), _("120m"), _("160m"), _("200m") }
stationmod.lengthToAdd = { 40, 80, 120, 160, 200 }
stationmod.lengthToAddStr = { _("+0"), _("+200"), _("+400"), _("+600"), _("+800") }


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
      key = "sizeIndex",
      name = _("Platform length"),
      values = stationmod.sizeIndexStr,
      defaultIndex = 1
    },
    {
      key = "lengthToAdd",
      name = _(""),
      values = stationmod.lengthToAddStr,
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



function railstationconfigutil.makeTrainStationConfig(params, stationConfig, stationBuilding, platformConfig)

  --print("params:")
  --tprint(params)
  --print("stationConfig:")
  --tprint(stationConfig)
  --print("stationBuilding:")
  --tprint(stationBuilding)
  --print("\n\nplatformConfig:\n")
  --tprint(platformConfig)
  --print("\n\n")

  -- in case you're wondering about all those +1 to the indices
  -- lua is 1-based, while every same programming language is 0-based,
  -- and lua gets called from c++ here, so all parameters we get are 0-based...

  -- calculate the intended number of tracks
  local numTracks = stationmod.numTracks[params.numTracks+1] + stationmod.numTracksToAdd[params.numTracksToAdd+1]
  -- set the original parameter, so we don't have to change existing code
  params.numTracksIndex = numTracks-1
  -- calculate the track config index (must not exceed the length of the tracksConfig)
  local trackConfigIndex = math.min(numTracks, #stationConfig.tracksConfig)

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
    platformConfig = platformConfig[params.sizeIndex + 1],
    trackType = stationConfig.trackTypes[(params.trackType or 0) + 1],
    catenary = params.catenary == 1,
    type = stationConfig.type
  }
end



