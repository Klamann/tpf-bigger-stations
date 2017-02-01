--[[

station mod by Klamann

]]--

local constructionutil = require("constructionutil_bugfix")
local paramsutil = require "paramsutil"
local railstationconfigutil = require "railstationconfigutil"
local stationmod = {}


-- store copies of functions that will be overriden in the `super` table
local super = {}
super.makeTrainStationConfig = railstationconfigutil.makeTrainStationConfig


-- logging setup
local log = require "stationmod_log"
log.usecolor = false
-- choices: "trace", "debug", "info", "warn", "error", "fatal"
log.level = "debug"   -- TODO set to "error" for release...


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
-- platform config
--


function stationmod.makePlatformConfigPassenger(stationConfig)
  local result = {}
  local numSizes = stationConfig.numSizes or { 1, 2, 3, 4 }
  local numTracks = stationConfig.numTracks or 1
  local secondStreet = stationConfig.streetSecondConnection or False
  local singleTrack = numTracks == 1 and not secondStreet

  if (stationConfig.stationType == "head") then

    --
    -- passenger terminal station
    --

    local headParts = {
      singleTerminalFirst = "station/train/${type}/${year}/platform_single_terminal_first.mdl" % { type = stationConfig.type, year = stationConfig.name },
      singleTerminalLast = "station/train/${type}/${year}/platform_single_terminal_last.mdl" % { type = stationConfig.type, year = stationConfig.name },
      doubleTerminal = "station/train/${type}/${year}/platform_double_terminal.mdl" % { type = stationConfig.type, year = stationConfig.name },
      doubleTrack = "station/train/${type}/${year}/platform_double_track.mdl" % { type = stationConfig.type, year = stationConfig.name },
      singleTrackFirst	= "station/train/${type}/${year}/platform_single_track_first.mdl" % { type = stationConfig.type, year = stationConfig.name },
      singleTrackLast 	= "station/train/${type}/${year}/platform_single_track_last.mdl" % { type = stationConfig.type, year = stationConfig.name },
    }

    for _, i in ipairs(numSizes) do
      result[#result + 1] = { }
      local config = result[#result]

      config.firstPlatformParts = { }
      config.middlePlatformParts = { }
      config.lastPlatformParts = { }

      config.firstPlatformRoof = { }
      config.middlePlatformRoof = { }
      config.lastPlatformRoof = { }

      config.headParts = headParts

      -- station head, i.e. where the building is (20m)
      local defaultHead = i > 1 or not secondStreet or ((numTracks - 2) % 4 == 0)
      if defaultHead then
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_open_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_open.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_open_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0 }
      else
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      end

      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
      if i > 1 then   -- add the roof for stations >40m
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      else
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
      end
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }

      -- extend by 40m each time
      for j = 2, i do

        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        if (i % 2 == j % 2) then
          -- build stairs
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          -- just the platform
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        end

        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }

      end

      -- station foot, i.e. where the rails leave the station (20m)
      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "",0 }
      if i > 1 then   -- add the roof for stations >40m
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      else
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
      end
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "",0 }

    end
  else

    --
    -- passenger through station
    --

    local headParts = {
      singleTerminalFirst = "",
      singleTerminalLast = "",
      doubleTerminal = "",
      doubleTrack = "",
      singleTrackFirst	= "",
      singleTrackLast 	= "",
    }

    for _, i in ipairs(numSizes) do
      result[#result + 1] = { }
      local config = result[#result]

      config.firstPlatformParts = { }
      config.middlePlatformParts = { }
      config.lastPlatformParts = { }

      config.firstPlatformRoof = { }
      config.middlePlatformRoof = { }
      config.lastPlatformRoof = { }

      config.headParts = headParts

      local numExt = i - 2
      local hasOuterRoof = numExt > 2

      -- start of through station (skip for 40m station, except if singleTrack, then skip center)
      if i > 1 or singleTrack then
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_start_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        if hasOuterRoof then
          config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        end
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      -- extensions to the center (add for >80m station)
      for j = numExt, 1, -1 do
        local stairs = (j-3) % 4 == 0
        if stairs then
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        end

        if hasOuterRoof then
          if j > 2 then
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          elseif j == 2 then
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          else
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
          end
        else
          config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        end
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      -- center of the through statiosn (always visible, only elements of the 40m station, except if 40m and just one platform)
      if i > 1 or not singleTrack then
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_repeat_empty.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0 }
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        if i > 1 then
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_repeat_empty.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        end

        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        if i > 1 then
          config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
          config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        end
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      -- extension away from the center (add for >80m station)
      for j = 1, numExt do
        local stairs = (j-3) % 4 == 0
        if stairs then
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        end

        if hasOuterRoof then
          if j == 2 then
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          elseif j > 2 then
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          else
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
          end
        else
          config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        end
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      -- end of through station (skip for 40m station, except if singleTrack, then skip center)
      if i > 1 or singleTrack then
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        if hasOuterRoof then
          config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        end
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

    end
  end

  return result
end


function stationmod.makePlatformConfigCargo(stationConfig)
  local result = { }
  local numSizes = stationConfig.numSizes or { 1, 2, 3, 4 }
  local numTracks = stationConfig.numTracks or 1
  local secondStreet = stationConfig.streetSecondConnection or False
  local singleTrack = numTracks == 1 and not secondStreet

  if (stationConfig.stationType == "head") then

    --
    -- cargo terminal station
    --

    local headParts = {
      singleTerminalFirst = "station/train/${type}/${year}/platform_single_terminal_first.mdl" % { type = stationConfig.type, year = stationConfig.name },
      singleTerminalLast = "station/train/${type}/${year}/platform_single_terminal_last.mdl" % { type = stationConfig.type, year = stationConfig.name },
      doubleTerminal = "station/train/${type}/${year}/platform_double_terminal.mdl" % { type = stationConfig.type, year = stationConfig.name },
      doubleTrack = "station/train/${type}/${year}/platform_double_track.mdl" % { type = stationConfig.type, year = stationConfig.name },
      singleTrackFirst	= "station/train/${type}/${year}/platform_single_track_first.mdl" % { type = stationConfig.type, year = stationConfig.name },
      singleTrackLast 	= "station/train/${type}/${year}/platform_single_track_last.mdl" % { type = stationConfig.type, year = stationConfig.name },
    }
    for _, i in ipairs(numSizes) do
      result[#result + 1] = { }
      local config = result[#result]

      config.firstPlatformParts = { }
      config.middlePlatformParts = { }
      config.lastPlatformParts = { }

      config.firstPlatformRoof = { }
      config.middlePlatformRoof = { }
      config.lastPlatformRoof = { }

      config.headParts = headParts

      -- station head, i.e. where the building is (20m)
      if i > 1 then
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      else
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      end

      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }

      -- extensions (add for >40m station)
      for j = 2, i do
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        if (i % 2 == j % 2) then
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0 }
        else
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        end

        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      -- station foot, i.e. where the rails leave the station (20m)
      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "",0 }
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "",0 }

    end
  else

    --
    -- cargo through station
    --

    for _, i in ipairs(numSizes) do

      local headParts = {
        singleTerminalFirst = "",
        singleTerminalLast = "",
        doubleTerminal = "",
        doubleTrack = "",
        singleTrackFirst	= "",
        singleTrackLast 	= "",
      }
      result[#result + 1] = { }
      local config = result[#result]

      config.firstPlatformParts = { }
      config.middlePlatformParts = { }
      config.lastPlatformParts = { }

      config.firstPlatformRoof = { }
      config.middlePlatformRoof = { }
      config.lastPlatformRoof = { }

      config.headParts = headParts

      local numExt = i - 2

      -- start of through station (skip for 40m station, except if singleTrack, then skip center)
      if i > 1 or singleTrack then
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_start_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_start_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      -- extensions to the center (add for >80m station)
      for j = numExt, 1, -1 do
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      -- center of the through station (always visible, only elements of the 40m station, except if 40m and just one platform)
      if i > 1 or not singleTrack then
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0 }
        if i > 1 then
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0 }
        else
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0 }
        end

        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      -- extension away from the center (add for >80m station)
      for j = 1, numExt do
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      -- end of through station (skip for 40m station, except if singleTrack, then skip center)
      if i > 1 or singleTrack then
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

    end
  end

  return result
end


function stationmod.makePlatformConfig(stationConfig)
  if stationConfig.type == "passenger" then
    return stationmod.makePlatformConfigPassenger(stationConfig)
  else
    return stationmod.makePlatformConfigCargo(stationConfig)
  end
end


--
-- ui parameters
--


stationmod.numTracks = { 1, 2, 3, 4, 5, 6, 7, 8 }
stationmod.numTracksStr = { _("1"), _("2"), _("3"), _("4"), _("5"), _("6"), _("7"), _("8") }
stationmod.numTracksToAdd = { 0, 8, 16, 24, 32, 40 }
stationmod.numTracksToAddStr = { _("+0"), _("+8"), _("+16"), _("+24"), _("+32"), _("+40") }
stationmod.trackLength = { 40, 80, 120, 160, 200 }
stationmod.trackLengthStr = { _("40 m"), _("80 m"), _("120 m"), _("160 m"), _("200 m") }
stationmod.trackLengthToAdd = { 0, 200, 400, 600, 800 }
stationmod.trackLengthToAddStr = { _("+0"), _("+200"), _("+400"), _("+600"), _("+800") }


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
    stationmod.state.enabled = not newParamNil  -- and oldParamNil
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
  stationConfig.numTracks = numTracks
  stationConfig.streetSecondConnection = params.streetSecondConnection ~= 0
  platformConfig = stationmod.makePlatformConfig(stationConfig)

  -- always build the smallest station building, if the shortest available track is used
  if trackLengthIndex == 1 then
    trackConfigIndex = 1
  end

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
