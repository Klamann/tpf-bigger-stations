local railstationconfigutil = require "railstationconfigutil"

local function makePlatformConfigPassenger(stationConfig)
  local result = {}
  local numSizes = stationConfig.numSizes or { 1, 2, 3, 4 }

  if (stationConfig.stationType == "head") then
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

      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_open_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_open.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_open_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}


      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }

      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }

      for j = 2, i do
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}


        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }

        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "",0 }
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "",0 }

    end
  else
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


      local numExt = i - 1


      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_start_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      if numExt > 1 then
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      else
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
      end
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }

      for j = numExt, 1, -1 do
        if (j % 2 == 0) then
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        end

        if (j % 2 == 0) then
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        end

        if (j % 2 == 0) then
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        end

        if numExt > 1 then
          if j > 1 then
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          elseif j == 1 then
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
          else
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
          end
        else
          config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
          config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        end

        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_repeat_empty.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_repeat_empty.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}


      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }

      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }

      for j = 1, numExt do
        if (j % 2 == 0) then
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        end

        if (j % 2 == 0) then
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        end

        if (j % 2 == 0) then
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        else
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        end

        if numExt > 1 then
          if j == 1 then
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          elseif j > 1 then
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
          else
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
            config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
          end
        else
          config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
          config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        end

        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end


      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_first_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      if numExt > 1 then
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      else
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
      end
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "station/train/${type}/${year}/platform_double_roof_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }

    end
  end

  return result
end

local function makePlatformConfigCargo(stationConfig)
  local result = { }
  local numSizes = stationConfig.numSizes or { 1, 2, 3, 4 }

  if (stationConfig.stationType == "head") then
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


      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}


      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }

      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }

      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }

      for j = 2, i do
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}


        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }

        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }

        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "",0 }
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "",0 }

    end
  else
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


      local numExt = i - 1


      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_start_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_start.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_start_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }

      for j = numExt, 1, -1 do
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }

        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }

        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end

      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_stairs.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_stairs_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}


      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }

      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }

      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }

      for j = 1, numExt do
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_repeat.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
        config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_repeat_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
        config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }

        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
        config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }

        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
        config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }
      end


      config.firstPlatformParts[#config.firstPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_first.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.middlePlatformParts[#config.middlePlatformParts + 1] = { part = "station/train/${type}/${year}/platform_double_end.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}
      config.lastPlatformParts[#config.lastPlatformParts + 1] = { part = "station/train/${type}/${year}/platform_single_end_last.mdl" % { type = stationConfig.type, year = stationConfig.name }, orientation = 0}

      config.firstPlatformRoof[#config.firstPlatformRoof + 1] = { part = "", 0 }
      config.middlePlatformRoof[#config.middlePlatformRoof + 1] = { part = "", 0 }
      config.lastPlatformRoof[#config.lastPlatformRoof + 1] = { part = "", 0 }

    end
  end

  return result
end

function railstationconfigutil.makePlatformConfig(stationConfig)
  if stationConfig.type == "passenger" then
    return makePlatformConfigPassenger(stationConfig)
  else
    return makePlatformConfigCargo(stationConfig)
  end
end

return railstationconfigutil
