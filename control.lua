-- luacheck: globals remote script game defines

local function initialise()
  remote.call( 'EvoGUI', 'create_remote_sensor', {
    mod_name = 'evo_elev_temp',
    name = 'evo_temp',
    text = 'Temperature: 0ºC',
    caption = 'Temperature'
  })

  remote.call( 'EvoGUI', 'create_remote_sensor', {
    mod_name = 'evo_elev_temp',
    name = 'evo_elev',
    text = 'Elevation: 0m',
    caption = 'Elevation'
  })
end

script.on_init( initialise )
script.on_load( initialise )

local function round2dec( num, idp )
  return string.format('%.' .. (idp or 0) .. 'f', num)
end

local lastPos = {0,0}

local function updateStats()
  local player = game.players[1]
  local pos = { player.position.x, player.position.y }

  local ready = game.tick % 10 -- every 10 seconds
  local moved = not ready and ( pos[1] ~= lastPos[1] or pos[2] ~= lastPos[2] )

  if ready or moved then -- update sensor
    local tile = player.surface.get_tileproperties( unpack( pos ) )

    lastPos = pos

    remote.call(
      'EvoGUI',
      'update_remote_sensor',
      'evo_elev',
      'Elevation: '..round2dec( tile.elevation, 2 )..'m'
    )

    remote.call(
      'EvoGUI',
      'update_remote_sensor',
      'evo_temp',
      'Temperature: '..round2dec(tile.temperature)..'ºC'
    )
  end--if moved/update

end

script.on_event( defines.events.on_tick, updateStats )
