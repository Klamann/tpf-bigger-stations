--[[

this file contains a copy of the original constructionutil where bugfixes
have been applied that were not yet patched by UG.

copy from res/scripts/constructionutil.lua, lines 145 to 940

fixes a bug that causes terraign alignments to fail
when stations are built with a second street connection.
yes, we have to copy almost the entire file to fix 4 lines of code...

replaces

    result.terrainAlignmentLists[#result.terrainAlignmentLists]

with

    result.terrainAlignmentLists[#result.terrainAlignmentLists + 1]

in lines 709, 773, 819, 871 of the original file.

]]--
local constructionutil = require("constructionutil")
local transf = require "transf"
local vec3 = require "vec3"


-- ##############################
-- ##### PLATFORMS / TRACKS #####
-- ##############################

local function makePlatformsAndTracks(config, result)

  result.models = { }
  result.terminalGroups = { }

  local snapNodes = { }

  -- inputs
  local trackMultiplier = config.trackMultiplier												-- for debug only
  local numTracks = config.numTracks * trackMultiplier										-- number of tracks
  local trackDistance = config.trackDistance													-- distance between tracks
  local platformDistance = config.platformDistance											-- distance between pattforms
  local segmentLength = config.segmentLength													-- length of platform segments
  local stationType = config.stationType														-- head / through

  -- calculated
  local stationLength = #config.platformConfig.firstPlatformParts * config.segmentLength		-- total length of the station
  local numSegments = #config.platformConfig.firstPlatformParts								-- total width of the station
  --numSegments = config.stationLength

  local stationWidth = math.floor(numTracks / 2) * trackDistance + math.floor(numTracks / 2 - 0.5) * platformDistance
  config.stationWidth = stationWidth

  local edges = { }

  for tracks = 0, numTracks do

    local trackOffset
    local platformModel
    local terminals = { }
    local terminalsLeft = { }
    local terminalsRight = { }

    local xOffset
    local yOffset

    local trackAddLength = 2.0

    if (stationType == "head" and tracks > 0) then

      trackOffset = ( ( ( tracks % 2 ) * 2 ) - 1) * ((math.floor((tracks + 3) / 4)) * trackDistance + (math.floor((tracks + 1) / 4) ) * platformDistance - trackDistance / 2)

      if (tracks % 4 == 0) or ((tracks - 1) % 4 == 0) then
        edges[#edges + 1] = { { trackOffset,  .0 ,  .0 },  					  				{ .0, stationLength / 2, .0 } }
        edges[#edges + 1] = { { trackOffset,  .0 + stationLength / 2,  .0 }, 			 	{ .0, stationLength / 2, .0 } }
        edges[#edges + 1] = { { trackOffset,  .0 + stationLength / 2,  .0 },  				{ .0, stationLength / 2 + trackAddLength, .0 } }
        edges[#edges + 1] = { { trackOffset,  .0 + stationLength + trackAddLength,  .0 }, 	{ .0, stationLength / 2 + trackAddLength, .0 } }
        snapNodes[#snapNodes+1] = (tracks - 1) * 4 + 3
      else
        edges[#edges + 1] = { { trackOffset,  .0 + stationLength + trackAddLength,  .0 }, 	{ .0, -stationLength / 2 - trackAddLength, .0 } }
        edges[#edges + 1] = { { trackOffset,  .0 + stationLength / 2,  .0 },  				{ .0, -stationLength / 2 - trackAddLength, .0 } }
        edges[#edges + 1] = { { trackOffset,  .0 + stationLength / 2,  .0 },  				{ .0, -stationLength / 2, .0 } }
        edges[#edges + 1] = { { trackOffset,  .0 ,  .0 },  					  				{ .0, -stationLength / 2, .0 } }
        snapNodes[#snapNodes+1] = (tracks - 1) * 4
      end

      for segements = 1, numSegments do

        xOffset = trackOffset + ( ( ( ( tracks % 2 ) * 2 ) - 1) * ( platformDistance / 2) )
        yOffset = segements * segmentLength - segmentLength / 2

        if ((tracks - 1) % 4 == 0 and tracks < numTracks - 1) then -- track 1, 5, 9 ... but not last two -> double
          result.models[#result.models + 1] = {
            id = config.platformConfig.middlePlatformParts[segements].part,
            transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.middlePlatformParts[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
          }
          terminalsLeft[#terminalsLeft + 1] = { #result.models - 1, 0 }
          terminalsRight[#terminalsRight + 1] = { #result.models - 1, 1 }

          if (config.platformConfig.middlePlatformRoof[segements].part ~= "") then
            result.models[#result.models + 1] = {
              id = config.platformConfig.middlePlatformRoof[segements].part,
              transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.middlePlatformRoof[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
            }
          end

        end


        if ((tracks - 2) % 4 == 0 and tracks < numTracks - 1 ) then -- track 2, 6, 10 ... but not last two -> double
          result.models[#result.models + 1] = {
            id = config.platformConfig.middlePlatformParts[segements].part,
            transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.middlePlatformParts[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
          }
          terminalsLeft[#terminalsLeft + 1] = { #result.models - 1, 0 }
          terminalsRight[#terminalsRight + 1] = { #result.models - 1, 1 }

          if (config.platformConfig.middlePlatformRoof[segements].part ~= "") then
            result.models[#result.models + 1] = {
              id = config.platformConfig.middlePlatformRoof[segements].part,
              transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.middlePlatformRoof[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
            }
          end
        end

        if ((tracks - 1) % 4 == 0  and tracks >= numTracks - 1) then -- odd, in last 2 tracks -> single plattform right
          result.models[#result.models + 1] = {
            id = config.platformConfig.lastPlatformParts[segements].part,
            transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.lastPlatformParts[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
          }
          terminals[#terminals + 1] = { #result.models - 1, 0 }

          if (config.platformConfig.lastPlatformRoof[segements].part ~= "") then
            result.models[#result.models + 1] = {
              id = config.platformConfig.lastPlatformRoof[segements].part,
              transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.lastPlatformRoof[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
            }
          end
        end

        if ((tracks - 2) % 4 == 0  and tracks >= numTracks - 1) then -- even, in last 2 tracks -> single plattform left
          result.models[#result.models + 1] = {
            id = config.platformConfig.firstPlatformParts[segements].part,
            transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.firstPlatformParts[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
          }
          terminals[#terminals + 1] = { #result.models - 1, 0 }

          if (config.platformConfig.firstPlatformRoof[segements].part ~= "") then
            result.models[#result.models + 1] = {
              id = config.platformConfig.firstPlatformRoof[segements].part,
              transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.firstPlatformRoof[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
            }
          end
        end

      end

      if ((tracks - 1) % 4 == 0 and tracks < numTracks - 1) then
        result.terminalGroups[#result.terminalGroups + 1] = { terminals = terminalsLeft, vehicleNodeOverride = tracks * 4 - 2 }
        result.terminalGroups[#result.terminalGroups + 1] = { terminals = terminalsRight, vehicleNodeOverride = (tracks+2) * 4 - 2 }
      end

      if ((tracks - 2) % 4 == 0 and tracks < numTracks - 1) then
        result.terminalGroups[#result.terminalGroups + 1] = { terminals = terminalsRight, vehicleNodeOverride = tracks * 4 - 2 }
        result.terminalGroups[#result.terminalGroups + 1] = { terminals = terminalsLeft, vehicleNodeOverride = (tracks+2) * 4 - 2 }
      end

      if ((tracks - 1) % 4 == 0  and tracks >= numTracks - 1) then
        result.terminalGroups[#result.terminalGroups + 1] = { terminals = terminals, vehicleNodeOverride = tracks * 4 - 2 }
      end

      if ((tracks - 2) % 4 == 0  and tracks >= numTracks - 1) then
        result.terminalGroups[#result.terminalGroups + 1] = { terminals = terminals, vehicleNodeOverride = tracks * 4 - 2 }
      end
    end


    if (stationType == "through") then

      trackOffset = math.floor(tracks / 2) * trackDistance + math.floor(tracks / 2 - 0.5) * platformDistance

      if (tracks > 0) then
        local trackLength = stationLength + 2.0 * trackAddLength

        if (tracks % 2 == 0) then
          edges[#edges + 1] = { { trackOffset,  .0 - trackLength / 2 ,  .0 },  { .0, trackLength / 2, .0 } }
          edges[#edges + 1] = { { trackOffset,  .0 ,  .0 }, 					 { .0, trackLength / 2, .0 } }
          edges[#edges + 1] = { { trackOffset,  .0 ,  .0 },  				     { .0, trackLength / 2, .0 } }
          edges[#edges + 1] = { { trackOffset,  .0 + trackLength / 2 ,  .0 },  { .0, trackLength / 2, .0 } }
        else
          edges[#edges + 1] = { { trackOffset,  .0 + trackLength / 2 ,  .0 },  { .0, -trackLength / 2, .0 } }
          edges[#edges + 1] = { { trackOffset,  .0 ,  .0 },  				     { .0, -trackLength / 2, .0 } }
          edges[#edges + 1] = { { trackOffset,  .0 ,  .0 }, 					 { .0, -trackLength / 2, .0 } }
          edges[#edges + 1] = { { trackOffset,  .0 - trackLength / 2 ,  .0 },  { .0, -trackLength / 2, .0 } }
        end

        snapNodes[#snapNodes+1] = (tracks - 1) * 4
        snapNodes[#snapNodes+1] = (tracks - 1) * 4 + 3
      end

      for segements = 1, numSegments do
        xOffset = trackOffset + platformDistance / 2
        yOffset = segements * segmentLength - segmentLength / 2 - stationLength / 2

        if (tracks % 2 == 0 and tracks == 0) then							-- even, first track -> first single platform
          result.models[#result.models + 1] = {
            id = config.platformConfig.firstPlatformParts[segements].part,
            transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.firstPlatformParts[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
          }

          terminals[#terminals + 1] = { #result.models - 1, 0 }

          if (config.platformConfig.firstPlatformRoof[segements].part ~= "") then
            result.models[#result.models + 1] = {
              id = config.platformConfig.firstPlatformRoof[segements].part,
              transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.firstPlatformRoof[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
            }
          end
        end

        if (tracks % 2 == 0 and tracks == numTracks) then					--- even, last track -> last single pattform
          result.models[#result.models + 1] = {
            id = config.platformConfig.lastPlatformParts[segements].part,
            transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.lastPlatformParts[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
          }

          terminals[#terminals + 1] = { #result.models - 1, 0 }

          if (config.platformConfig.lastPlatformRoof[segements].part ~= "") then
            result.models[#result.models + 1] = {
              id = config.platformConfig.lastPlatformRoof[segements].part,
              transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.lastPlatformRoof[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
            }
          end
        end

        if (tracks % 2 == 0 and (tracks ~= 0 and tracks ~= numTracks)) then	-- even, not first or last -> build double platform
          result.models[#result.models + 1] = {
            id = config.platformConfig.middlePlatformParts[segements].part,
            transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.middlePlatformParts[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
          }

          terminalsLeft[#terminalsLeft + 1] = { #result.models - 1, 0 }
          terminalsRight[#terminalsRight + 1] = { #result.models - 1, 1 }

          if (config.platformConfig.middlePlatformRoof[segements].part ~= "") then
            result.models[#result.models + 1] = {
              id = config.platformConfig.middlePlatformRoof[segements].part,
              transf = transf.rotZYXTransl(transf.degToRad(config.platformConfig.middlePlatformRoof[segements].orientation, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
            }
          end
        end
      end

      if (tracks % 2 == 0 and tracks == 0) then
        result.terminalGroups[#result.terminalGroups + 1] = { terminals = terminals, vehicleNodeOverride = 2 }
      end

      if (tracks % 2 == 0 and tracks == numTracks) then
        result.terminalGroups[#result.terminalGroups + 1] = { terminals = terminals, vehicleNodeOverride = #edges - 2 }
      end

      if (tracks % 2 == 0 and (tracks ~= 0 and tracks ~= numTracks)) then
        result.terminalGroups[#result.terminalGroups + 1] = { terminals = terminalsLeft, vehicleNodeOverride = tracks * 4 - 2 }
        result.terminalGroups[#result.terminalGroups + 1] = { terminals = terminalsRight, vehicleNodeOverride = tracks * 4 + 2 }
      end

    end



  end

  result.edgeLists = {
    {
      type = "TRACK",
      params = {
        type = config.trackType,
        catenary = config.catenary
      },
      edges = edges,
      snapNodes = snapNodes
    },
  }

end



-- #################
-- ##### FACES #####
-- #################

local function makeFaces(config, result)

  -- inputs
  local trackMultiplier = config.trackMultiplier												-- for debug only
  local numTracks = config.numTracks * trackMultiplier										-- number of tracks
  local trackDistance = config.trackDistance													-- distance between tracks
  local platformDistance = config.platformDistance											-- distance between pattforms
  local segmentLength = config.segmentLength													-- length of platform segments
  local stationType = config.stationType														-- head / through

  -- calculated
  local stationLength = #config.platformConfig.firstPlatformParts * config.segmentLength		-- total length of the station
  local numSegments = #config.platformConfig.firstPlatformParts								-- total width of the station
  local stationWidth = math.floor(numTracks / 2) * trackDistance + math.floor(numTracks / 2 - 0.5) * platformDistance

  local terrainFaces = { }
  local groundFace = { }

  if (stationType == "head") then
    xOffset = .0
    yOffset = stationLength / 2

    terrainFaces = {
      {
        { -stationWidth / 2 - platformDistance / 2 + xOffset + (5 * (numTracks % 2)) , -stationLength / 2 + yOffset, .0},
        {  stationWidth / 2 + platformDistance / 2 + xOffset + (2.5 * (numTracks % 2)) , -stationLength / 2 + yOffset, .0},
        {  stationWidth / 2 + platformDistance / 2 + xOffset + (2.5 * (numTracks % 2)) ,  stationLength / 2 + yOffset, .0},
        { -stationWidth / 2 - platformDistance / 2 + xOffset + (5 * (numTracks % 2)) ,  stationLength / 2 + yOffset, .0}
      },
    }

    groundFace = {
      { -stationWidth / 2 - platformDistance / 2 + xOffset + (5 * (numTracks % 2)) , -stationLength / 2 + yOffset, .0},
      {  stationWidth / 2 + platformDistance / 2 + xOffset + (2.5 * (numTracks % 2)) , -stationLength / 2 + yOffset, .0},
      {  stationWidth / 2 + platformDistance / 2 + xOffset + (2.5 * (numTracks % 2)) ,  stationLength / 2 + yOffset, .0},
      { -stationWidth / 2 - platformDistance / 2 + xOffset + (5 * (numTracks % 2)) ,  stationLength / 2 + yOffset, .0}
    }

  end

  if (stationType == "through") then
    xOffset = stationWidth / 2
    yOffset = .0

    terrainFaces = {
      {
        { -stationWidth / 2 - platformDistance / 2 + xOffset - 2.5, -stationLength / 2 + yOffset, .0},
        {  stationWidth / 2 + platformDistance / 2 + xOffset - (2.5 * (numTracks % 2)) , -stationLength / 2 + yOffset, .0},
        {  stationWidth / 2 + platformDistance / 2 + xOffset - (2.5 * (numTracks % 2)) ,  stationLength / 2 + yOffset, .0},
        { -stationWidth / 2 - platformDistance / 2 + xOffset - 2.5,  stationLength / 2 + yOffset, .0}
      },
    }

    groundFace = {
      { -stationWidth / 2 - platformDistance / 2 + xOffset - 2.5, -stationLength / 2 + yOffset, .0},
      {  stationWidth / 2 + platformDistance / 2 + xOffset - (2.5 * (numTracks % 2)) , -stationLength / 2 + yOffset, .0},
      {  stationWidth / 2 + platformDistance / 2 + xOffset - (2.5 * (numTracks % 2)) ,  stationLength / 2 + yOffset, .0},
      { -stationWidth / 2 - platformDistance / 2 + xOffset - 2.5,  stationLength / 2 + yOffset, .0}
    }

  end

  result.terrainAlignmentLists = {
    {
      type = "EQUAL",
      faces = terrainFaces,
    }
  }

  local groundFaces = { }
  groundFaces[#groundFaces + 1] = { face = groundFace, modes = { { type = "FILL", key = "industry_gravel_small_01" } } }
  groundFaces[#groundFaces + 1] = { face = groundFace, modes = { { type = "STROKE_OUTER", key = "building_paving" } } }
  result.groundFaces = groundFaces

end

-- ####################
-- ##### BUILDING #####
-- ####################

local function makeStationBuilding(config, result)

  local stationBuilding = config.stationBuilding

  -- inputs
  local trackMultiplier = config.trackMultiplier												-- for debug only
  local numTracks = config.numTracks * trackMultiplier										-- number of tracks
  local trackDistance = config.trackDistance													-- distance between tracks
  local platformDistance = config.platformDistance											-- distance between pattforms
  local segmentLength = config.segmentLength													-- length of platform segments
  local stationType = config.stationType														-- head / through

  -- calculated
  local stationLength = #config.platformConfig.firstPlatformParts * config.segmentLength		-- total length of the station
  local numSegments = #config.platformConfig.firstPlatformParts								-- total width of the station
  local stationWidth = math.floor(numTracks / 2) * trackDistance + math.floor(numTracks / 2 - 0.5) * platformDistance

  if (config.stationType == "head") then
    result.models[#result.models + 1] = {
      id = stationBuilding,
      transf = transf.rotZYXTransl(transf.degToRad(.0, .0, .0), vec3.new(.0, -10.0, .0))
    }

    for tracks = 1, numTracks do

      trackOffset = ( ( ( tracks % 2 ) * 2 ) - 1) * ((math.floor((tracks + 3) / 4)) * trackDistance + (math.floor((tracks + 1) / 4) ) * platformDistance - trackDistance / 2)


      if (numTracks == 1) then
        xOffset = trackOffset - trackDistance / 2 - platformDistance / 2
        yOffset = 0

        result.models[#result.models + 1] = {
          id = config.platformConfig.headParts.singleTrackLast,
          transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
        }
      end


      if ((tracks - 1) % 4 == 0) then -- track 1, 5, 9 ...

        xOffset = trackOffset - trackDistance / 2
        yOffset = 0

        result.models[#result.models + 1] = {
          id = config.platformConfig.headParts.doubleTrack,
          transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
        }
      end

      if ((tracks - 2) % 4 == 0) then -- track 2, 6, 10 ...

        xOffset = trackOffset + trackDistance / 2
        yOffset = 0

        result.models[#result.models + 1] = {
          id = config.platformConfig.headParts.doubleTrack,
          transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
        }
      end



      if ((tracks - 1) % 4 == 0 and tracks >= numTracks - 1) then -- track 1, 5, 9 ... and last two -> close single terminal

        xOffset = trackOffset + platformDistance / 2
        yOffset = 0

        result.models[#result.models + 1] = {
          id = config.platformConfig.headParts.singleTerminalLast,
          transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
        }
      end

      if ((tracks - 2) % 4 == 0 and tracks >= numTracks - 1) then -- track 2, 6, 10 ... and last two -> close single terminal

        xOffset = trackOffset - platformDistance / 2
        yOffset = 0

        result.models[#result.models + 1] = {
          id = config.platformConfig.headParts.singleTerminalFirst,
          transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
        }
      end


      if ((tracks - 1) % 4 == 0 and tracks < numTracks - 1) then -- track 1, 5, 9 ... and not last two -> close terminal

        xOffset = trackOffset + platformDistance / 2
        yOffset = 0

        result.models[#result.models + 1] = {
          id = config.platformConfig.headParts.doubleTerminal,
          transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
        }
      end

      if ((tracks - 2) % 4 == 0 and tracks < numTracks - 1) then -- track 2, 6, 10 ... and not last two -> close terminal

        xOffset = trackOffset - platformDistance / 2
        yOffset = 0

        result.models[#result.models + 1] = {
          id = config.platformConfig.headParts.doubleTerminal,
          transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
        }
      end


      if ((tracks + 1 ) % 4 == 0 and tracks >= numTracks - 1) then -- track 3, 7, 11 ... and last two close single track

        xOffset = trackOffset - trackDistance / 2
        yOffset = 0

        result.models[#result.models + 1] = {
          id = config.platformConfig.headParts.singleTrackFirst,
          transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
        }
      end


      if (tracks % 4 == 0 and tracks >= numTracks - 1) then -- track 4, 8, 12 ... and last two close single track

        xOffset = trackOffset + trackDistance / 2
        yOffset = 0

        result.models[#result.models + 1] = {
          id = config.platformConfig.headParts.singleTrackLast,
          transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(xOffset, yOffset, 0))
        }
      end




    end

  end

  if (config.stationType == "through") then
    result.models[#result.models + 1] = {
      id = stationBuilding,
      transf = transf.rotZYXTransl(transf.degToRad(270.0, .0, .0), vec3.new(-10.0, .0, .0))
    }
  end

end


-- ##################
-- ##### STREET #####
-- ##################

local function makeStreet(config, result)

  local stationLength = #config.platformConfig.firstPlatformParts * config.segmentLength		-- total length of the station

  if (config.streetType == nil) then config.streetType = "old_small" end
  if (config.stairs == nil) then config.stairs = "station/train/passenger/1850/platform_stairs.mdl" end
  if (config.stairsPlatform == nil) then config.stairsPlatform = "station/train/passenger/1850/platform_single_stairs_second.mdl" end

  local roadEdges = { }
  local snapNodes = { }

  if (config.stationType == "head") then
    roadEdges[#roadEdges + 1] = { { 0.0, -40.0,  0.0 },  { 00.0, 20.0, 0.0 } }
    roadEdges[#roadEdges + 1] = { { 0.0, -20.0,  0.0 },  { 00.0, 20.0, 0.0 } }

    snapNodes[#snapNodes+1] = 0
  end

  if (config.stationType == "through") then
    roadEdges[#roadEdges + 1] = { { -40.0, 0.0,  0.0 },  { 20.0, 0.0, 0.0 } }
    roadEdges[#roadEdges + 1] = { { -20.0, 0.0,  0.0 },  { 20.0, 0.0, 0.0 } }

    snapNodes[#snapNodes+1] = 0
  end

  if (config.stationType == "head" and config.streetSecondConnection == 1) then

    if ((config.numTracks - 1) % 4 == 0) then -- track 1, 5, 9 ...

      if config.type == "cargo" then cargoOffset = 2.5 else cargoOffset = 0.0 end

      roadEdges[#roadEdges + 1] = { { config.stationWidth / 2 +  8.5 + config.trackDistance / 2, stationLength - config.segmentLength,  0.0 },  { 20.0, 0.0, 0.0 } }
      roadEdges[#roadEdges + 1] = { { config.stationWidth / 2 + 28.5 + config.trackDistance / 2, stationLength - config.segmentLength,  0.0 },  { 20.0, 0.0, 0.0 } }

      roadEdges[#roadEdges + 1] = { { -config.stationWidth / 2 -  8.5 + config.trackDistance / 2 + cargoOffset, stationLength - config.segmentLength,  0.0 },  { -20.0, 0.0, 0.0 } }
      roadEdges[#roadEdges + 1] = { { -config.stationWidth / 2 - 28.5 + config.trackDistance / 2 + cargoOffset, stationLength - config.segmentLength,  0.0 },  { -20.0, 0.0, 0.0 } }

      snapNodes[#snapNodes+1] = 3
      snapNodes[#snapNodes+1] = 5

      result.models[#result.models + 1] = {
        id = config.stairs,
        transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(config.stationWidth / 2 + 5.0 + config.trackDistance / 2, stationLength - config.segmentLength,  0.0))
      }

      result.models[#result.models + 1] = {
        id = config.stairs,
        transf = transf.rotZYXTransl(transf.degToRad(180.0, 0.0, 0.0), vec3.new(-config.stationWidth / 2 - 5.0 + config.trackDistance / 2 + cargoOffset, stationLength - config.segmentLength,  0.0))
      }
      result.models[#result.models + 1] = {
        id = config.stairsPlatform,
        transf = transf.rotZYXTransl(transf.degToRad(180.0, 0.0, 0.0), vec3.new(-config.stationWidth / 2 - config.platformDistance / 2  + config.trackDistance / 2 + cargoOffset, stationLength - config.segmentLength,  0.0))
      }

      terrainFaces = {
        {
          { -config.stationWidth / 2 -  8.5 + config.trackDistance / 2 + cargoOffset, stationLength - config.segmentLength - config.segmentLength / 2 - 3, .0},
          { config.stationWidth / 2 +  8.5 + config.trackDistance / 2, stationLength - config.segmentLength - config.segmentLength / 2 - 3, .0},
          { config.stationWidth / 2 +  8.5 + config.trackDistance / 2, stationLength - config.segmentLength + config.segmentLength / 2 + 3, .0},
          { -config.stationWidth / 2 -  8.5 + config.trackDistance / 2 + cargoOffset, stationLength - config.segmentLength + config.segmentLength / 2 + 3, .0},
        },
      }

      result.terrainAlignmentLists[#result.terrainAlignmentLists + 1] =
      {
        type = "EQUAL",
        faces = terrainFaces,
      }

    end

    if ((config.numTracks - 2) % 4 == 0) then -- track 2, 6, 10 ...
      roadEdges[#roadEdges + 1] = { { config.stationWidth / 2 +  8.5, stationLength - config.segmentLength,  0.0 },  { 20.0, 0.0, 0.0 } }
      roadEdges[#roadEdges + 1] = { { config.stationWidth / 2 + 28.5, stationLength - config.segmentLength,  0.0 },  { 20.0, 0.0, 0.0 } }

      roadEdges[#roadEdges + 1] = { { -config.stationWidth / 2 -  8.5, stationLength - config.segmentLength,  0.0 },  { -20.0, 0.0, 0.0 } }
      roadEdges[#roadEdges + 1] = { { -config.stationWidth / 2 - 28.5, stationLength - config.segmentLength,  0.0 },  { -20.0, 0.0, 0.0 } }

      snapNodes[#snapNodes+1] = 3
      snapNodes[#snapNodes+1] = 5

      result.models[#result.models + 1] = {
        id = config.stairs,
        transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(config.stationWidth / 2 + 5.0, stationLength - config.segmentLength,  0.0))
      }

      result.models[#result.models + 1] = {
        id = config.stairs,
        transf = transf.rotZYXTransl(transf.degToRad(180.0, 0.0, 0.0), vec3.new(-config.stationWidth / 2 - 5.0, stationLength - config.segmentLength,  0.0))
      }
    end

    if ((config.numTracks  + 1 ) % 4 == 0) then -- track 3, 7, 11 ... and last two close single track

      roadEdges[#roadEdges + 1] = { { config.stationWidth / 2 +  8.5 + config.trackDistance -.5, stationLength - config.segmentLength,  0.0 },  { 20.0, 0.0, 0.0 } }
      roadEdges[#roadEdges + 1] = { { config.stationWidth / 2 + 28.5 + config.trackDistance -.5, stationLength - config.segmentLength,  0.0 },  { 20.0, 0.0, 0.0 } }

      roadEdges[#roadEdges + 1] = { { -config.stationWidth / 2 -  8.5 + config.platformDistance / 2, stationLength - config.segmentLength,  0.0 },  { -20.0, 0.0, 0.0 } }
      roadEdges[#roadEdges + 1] = { { -config.stationWidth / 2 - 28.5 + config.platformDistance / 2, stationLength - config.segmentLength,  0.0 },  { -20.0, 0.0, 0.0 } }

      snapNodes[#snapNodes+1] = 3
      snapNodes[#snapNodes+1] = 5

      result.models[#result.models + 1] = {
        id = config.stairs,
        transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(config.stationWidth / 2 + 5.0 + config.trackDistance -.5, stationLength - config.segmentLength, 0.0))
      }

      result.models[#result.models + 1] = {
        id = config.stairsPlatform,
        transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(config.stationWidth / 2 + config.platformDistance / 2 + config.trackDistance -.5, stationLength - config.segmentLength, 0.0))
      }

      result.models[#result.models + 1] = {
        id = config.stairs,
        transf = transf.rotZYXTransl(transf.degToRad(180.0, 0.0, 0.0), vec3.new( - config.stationWidth / 2 - 5.0 + config.platformDistance / 2, stationLength - config.segmentLength,  0.0))
      }

      terrainFaces = {
        {
          { -config.stationWidth / 2 -  8.5 + config.platformDistance / 2, stationLength - config.segmentLength - config.segmentLength / 2 - 3, .0},
          { config.stationWidth / 2 +  8.5 + config.trackDistance -.5, stationLength - config.segmentLength - config.segmentLength / 2 - 3, .0},
          { config.stationWidth / 2 +  8.5 + config.trackDistance -.5, stationLength - config.segmentLength + config.segmentLength / 2 + 3, .0},
          { -config.stationWidth / 2 -  8.5 + config.platformDistance / 2, stationLength - config.segmentLength + config.segmentLength / 2 + 3, .0},
        },
      }

      result.terrainAlignmentLists[#result.terrainAlignmentLists + 1] =
      {
        type = "EQUAL",
        faces = terrainFaces,
      }

    end

    if (config.numTracks  % 4 == 0) then -- track 4, 8, 12 ...

      roadEdges[#roadEdges + 1] = { { config.stationWidth / 2 +  8.5 + config.trackDistance / 2 -.5, stationLength - config.segmentLength,  0.0 },  { 20.0, 0.0, 0.0 } }
      roadEdges[#roadEdges + 1] = { { config.stationWidth / 2 + 28.5 + config.trackDistance / 2 -.5, stationLength - config.segmentLength,  0.0 },  { 20.0, 0.0, 0.0 } }

      roadEdges[#roadEdges + 1] = { { -config.stationWidth / 2 -  8.5 - config.trackDistance / 2 +.5, stationLength - config.segmentLength,  0.0 },  { -20.0, 0.0, 0.0 } }
      roadEdges[#roadEdges + 1] = { { -config.stationWidth / 2 - 28.5 - config.trackDistance / 2 +.5, stationLength - config.segmentLength,  0.0 },  { -20.0, 0.0, 0.0 } }

      snapNodes[#snapNodes+1] = 3
      snapNodes[#snapNodes+1] = 5

      result.models[#result.models + 1] = {
        id = config.stairs,
        transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(config.stationWidth / 2 + 5.0 + config.trackDistance / 2 -.5, stationLength - config.segmentLength, 0.0))
      }
      result.models[#result.models + 1] = {
        id = config.stairsPlatform,
        transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(config.stationWidth / 2 + config.trackDistance / 2 + config.platformDistance / 2 -.5, stationLength - config.segmentLength, 0.0))
      }

      result.models[#result.models + 1] = {
        id = config.stairs,
        transf = transf.rotZYXTransl(transf.degToRad(180.0, 0.0, 0.0), vec3.new(-config.stationWidth / 2 - 5.0 - config.trackDistance / 2 +.5, stationLength - config.segmentLength,  0.0))
      }
      result.models[#result.models + 1] = {
        id = config.stairsPlatform,
        transf = transf.rotZYXTransl(transf.degToRad(180.0, 0.0, 0.0), vec3.new(-config.stationWidth / 2 - config.platformDistance / 2 - config.trackDistance / 2 +.5, stationLength - config.segmentLength,  0.0))
      }

      terrainFaces = {
        {
          { -config.stationWidth / 2 -  8.5 - config.trackDistance / 2 +.5, stationLength - config.segmentLength - config.segmentLength / 2 - 3, .0},
          { config.stationWidth / 2 +  8.5 + config.trackDistance / 2 -.5, stationLength - config.segmentLength - config.segmentLength / 2 - 3, .0},
          { config.stationWidth / 2 +  8.5 + config.trackDistance / 2 -.5, stationLength - config.segmentLength + config.segmentLength / 2 + 3, .0},
          { -config.stationWidth / 2 -  8.5 - config.trackDistance / 2 +.5, stationLength - config.segmentLength + config.segmentLength / 2 + 3, .0},
        },
      }

      result.terrainAlignmentLists[#result.terrainAlignmentLists + 1] =
      {
        type = "EQUAL",
        faces = terrainFaces,
      }

    end

  end

  if (config.stationType == "through" and config.streetSecondConnection == 1 and config.numTracks % 2 == 0) then

    roadEdges[#roadEdges + 1] = { { config.stationWidth +  8.5, 0.0,  0.0 },  { 20.0, 0.0, 0.0 } }
    roadEdges[#roadEdges + 1] = { { config.stationWidth + 28.5, 0.0,  0.0 },  { 20.0, 0.0, 0.0 } }

    snapNodes[#snapNodes+1] = 3

    result.models[#result.models + 1] = {
      id = config.stairs,
      transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(config.stationWidth + 5.0, 0.0,  0.0))
    }

  end

  if (config.stationType == "through" and config.streetSecondConnection == 1 and config.numTracks % 2 ~= 0 ) then

    if config.type == "cargo" then cargoOffset = 2.5 else cargoOffset = 0.0 end

    roadEdges[#roadEdges + 1] = { { config.stationWidth +  8.5 - cargoOffset, 0.0,  0.0 },  { 20.0, 0.0, 0.0 } }
    roadEdges[#roadEdges + 1] = { { config.stationWidth + 28.5 - cargoOffset, 0.0,  0.0 },  { 20.0, 0.0, 0.0 } }

    snapNodes[#snapNodes+1] = 3

    result.models[#result.models + 1] = {
      id = config.stairs,
      transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(config.stationWidth + 5.0 - cargoOffset, 0.0,  0.0))
    }

    result.models[#result.models + 1] = {
      id = config.stairsPlatform,
      transf = transf.rotZYXTransl(transf.degToRad(0.0, 0.0, 0.0), vec3.new(config.stationWidth + config.platformDistance / 2  - cargoOffset, 0.0,  0.0))
    }

    terrainFaces = {
      {
        { config.stationWidth +  8.5 - cargoOffset, - config.segmentLength / 2 - 3, .0},
        { config.stationWidth, - config.segmentLength / 2 - 3, .0},
        { config.stationWidth,   config.segmentLength / 2 + 3, .0},
        { config.stationWidth +  8.5 - cargoOffset, config.segmentLength / 2 + 3, .0},
      },
    }

    result.terrainAlignmentLists[#result.terrainAlignmentLists + 1] =
    {
      type = "EQUAL",
      faces = terrainFaces,
    }

  end

  result.edgeLists[#result.edgeLists + 1] = {
    type = "STREET",
    params = { type = config.streetType .. ".lua" },
    edges = roadEdges,
    snapNodes = snapNodes
  }

  local groundFace

  if (config.stationType == "through") then
    local xx = -19.9
    result.terrainAlignmentLists[1].faces[#result.terrainAlignmentLists[1].faces + 1] = { { xx, -config.buildingWidth / 2, .0 }, { .0, -config.buildingWidth / 2.0, .0 }, { .0, config.buildingWidth / 2.0, .0 }, { xx, config.buildingWidth / 2.0 , .0 } }
    result.terrainAlignmentLists[1].faces[#result.terrainAlignmentLists[1].faces + 1] = { { -20.0, -7.0, .0 }, { xx, -7.0, .0 }, { xx, 7.0, .0 }, { -20.0, 7.0, .0 } }

    groundFace = { { .0, -config.buildingWidth / 2}, { .0, config.buildingWidth/2}, { xx, config.buildingWidth / 2 },
      { xx, 6 }, { -20, 6 }, { -20, -6 }, { xx, -6 },	{xx, -config.buildingWidth / 2 } }
  end

  if (config.stationType == "head") then
    local yy = -19.9
    result.terrainAlignmentLists[1].faces[#result.terrainAlignmentLists[1].faces + 1] = { { -config.buildingWidth / 2.0, yy, .0 }, { config.buildingWidth / 2.0, yy, .0 }, { config.buildingWidth / 2.0, .0, .0 }, { -config.buildingWidth / 2.0, .0, .0 } }
    result.terrainAlignmentLists[1].faces[#result.terrainAlignmentLists[1].faces + 1] = { { -6.0, -20.0, .0 }, { 6.0, -20.0, .0 }, { 6.0, yy, .0 }, { -6.0, yy, .0 } }

    groundFace = { { -config.buildingWidth / 2, yy }, { -6.0, yy }, { -6.0, -20.0 }, { 6.0, -20.0 }, { 6.0, yy }, { config.buildingWidth / 2, yy }, { config.buildingWidth / 2 , .0 }, { -config.buildingWidth / 2 , .0 } }
  end

  result.groundFaces[#result.groundFaces + 1] = { face = groundFace, modes = { { type = "FILL", key = "industry_concrete_01" } } }
  result.groundFaces[#result.groundFaces + 1] = { face = groundFace, modes = { { type = "STROKE_OUTER", key = "building_paving" } } }

  if (config.stationType == "through" and config.streetSecondConnection == 1) then
    result.terrainAlignmentLists[1].faces[#result.terrainAlignmentLists[1].faces + 1] = { { config.stationWidth, 6.0, 0.0 }, { config.stationWidth, -6.0, 0.0 }, { config.stationWidth + 15.0, -6.0, 0.0 }, { config.stationWidth + 15.0, 6.0, 0.0 } }

    groundFace = { { config.stationWidth, 6.0 }, { config.stationWidth, -6.0 }, { config.stationWidth + 15.0, -6.0 }, { config.stationWidth + 15.0, 6.0 } }
    result.groundFaces[#result.groundFaces + 1] = { face = groundFace, modes = { { type = "FILL", key = "industry_concrete_01" } } }
    result.groundFaces[#result.groundFaces + 1] = { face = groundFace, modes = { { type = "STROKE_OUTER", key = "building_paving" } } }
  end

  if (config.stationType == "head" and config.streetSecondConnection == 1) then

    groundFace = { { - config.stationWidth / 2 - 14.0, stationLength - config.segmentLength + 6 }, { - config.stationWidth / 2 - 14.0, stationLength - config.segmentLength - 6 }, { config.stationWidth / 2 + 14.0, stationLength - config.segmentLength - 6 }, { config.stationWidth / 2 + 14.0, stationLength - config.segmentLength + 6 } }
    result.groundFaces[#result.groundFaces + 1] = { face = groundFace, modes = { { type = "FILL", key = "industry_concrete_01" } } }
    result.groundFaces[#result.groundFaces + 1] = { face = groundFace, modes = { { type = "STROKE_OUTER", key = "building_paving" } } }
  end


end


function constructionutil.makeTrainStationNew(config)
  local result = {}

  makePlatformsAndTracks(config, result)
  makeFaces(config, result)
  makeStationBuilding(config, result)
  makeStreet(config, result)

  result.cost = 60000 + config.numTracks * 24000
  result.maintenanceCost = result.cost / 6

  return result
end


return constructionutil
