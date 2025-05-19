local config = require "config"

local function round(num)
  return math.floor(num + 0.5)
end

local function exportData()
  local lines = api.engine.system.lineSystem.getLines()
  local result = {
    stations = {},
    lines = {},
    vehicles = {}
  }

  -- Stationen sammeln
  local stationComps = api.engine.getComponent("stationStreetStationComponent")
  for id, _ in pairs(stationComps) do
    local name = api.engine.getComponent(id, "nameComponent")
    local pos = api.engine.getComponent(id, "positionComponent")
    local paxComp = api.engine.getComponent(id, "stationPassengerComponent")

    local waitingPassengers = 0
    if paxComp then
      for _, count in pairs(paxComp.passengerCount or {}) do
        waitingPassengers = waitingPassengers + count
      end
    end

    if name and pos then
      table.insert(result.stations, {
        id = id,
        name = name.name,
        pos = { round(pos.position.x), round(pos.position.y) },
        waitingPassengers = waitingPassengers
      })
    end
  end

  -- Linien sammeln
  for id, line in pairs(lines) do
    local lineName = line.name or ("Line " .. tostring(id))
    local stopIds = {}
    for _, segment in ipairs(line.vehicleStopLists or {}) do
      for _, stop in ipairs(segment) do
        table.insert(stopIds, stop.station)
      end
    end
    table.insert(result.lines, {
      id = id,
      name = lineName,
      stations = stopIds,
      color = line.color or { 255, 255, 255 }
    })
  end

  -- Fahrzeuge sammeln
  local vehicles = api.engine.getComponent("vehicleComponent")
  local posComps = api.engine.getComponent("positionComponent")
  local names = api.engine.getComponent("nameComponent")
  local ownership = api.engine.getComponent("vehicleOwnerComponent")

  for id, vehicle in pairs(vehicles) do
    local name = names[id] and names[id].name or "Unknown"
    local pos = posComps[id] and posComps[id].position or { x = 0, y = 0 }
    local lineId = ownership[id] and ownership[id].line or -1

    table.insert(result.vehicles, {
      id = id,
      name = name,
      type = vehicle.vehicleType or "unknown",
      position = { round(pos.x), round(pos.y) },
      lineId = lineId
    })
  end

  -- JSON encode
  local json = require "json"
  local str = json.encode_pretty(result)

  -- In Datei schreiben
  local file = io.open(config.outputFile, "w")
  if file then
    file:write(str)
    file:close()
    print("MetroMesh extended export done.")
  else
    print("Failed to write MetroMesh export.")
  end
end

-- Wiederholt alle X Sekunden
local lastUpdate = -config.updateInterval
function updateFn()
  local time = game.interface.getGameTimeSec()
  if time - lastUpdate >= config.updateInterval then
    lastUpdate = time
    exportData()
  end
end

function data()
  return {
    updateFn = updateFn
  }
end
