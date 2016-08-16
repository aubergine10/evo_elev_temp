-- luacheck: globals remote script game defines

-- reuse same tables to reduce gc overheads
local tempSensor = { 'evo_elev_temperature', 0 }
local elevSensor = { 'evo_elev_elevation'  , 0 }

local function initialise()
  remote.call( 'EvoGUI', 'create_remote_sensor', {
    mod_name = 'evo_elev_temp',
    name = 'evo_temp',
    text = tempSensor,
    caption = 'Temperature'
  })

  remote.call( 'EvoGUI', 'create_remote_sensor', {
    mod_name = 'evo_elev_temp',
    name = 'evo_elev',
    text = elevSensor,
    caption = 'Elevation'
  })
end--initialise

script.on_init( initialise )
script.on_load( initialise )

local format = string.format -- shortcut

local function updateSensors()

  if game.tick % 60 then -- once per second

    local player = game.players[1]
    local pos  = player.position
    local tile = player.surface.get_tileproperties( pos.x, pos.y )

    tempSensor[2] = format( '%.1f', tile.temperature )
    elevSensor[2] = format( '%.2f', tile.elevation   )

    remote.call( 'EvoGUI', 'update_remote_sensor',
      'evo_elev', elevSensor
    )

    remote.call( 'EvoGUI', 'update_remote_sensor',
      'evo_temp', tempSensor
    )

  end

end--updateSensors

script.on_event( defines.events.on_tick, updateSensors )
