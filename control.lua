-- luacheck: globals remote script game defines

-- reuse same tables to reduce gc overheads
local sensors = {
  temperature = { 'evo_tile_temperature', 0      },
  elevation   = { 'evo_tile_elevation'  , 0      },
  wateravail  = { 'evo_tile_water'      , 0      },
  roughness   = { 'evo_tile_roughness'  , 0      }, -- roughness
  terrain     = { 'evo_tile_terrain'    , 'Land' }, -- sand, water, etc
  decorate    = { 'evo_tile_decorate'   , ''     }, -- brown cane, etc
  trees       = { 'evo_tile_trees'      , ''     }
}

local modName = 'evo_elev_temp' -- somewhat dated now, but meh.

local function initialise()
  remote.call( 'EvoGUI', 'create_remote_sensor', { mod_name = modName,
    name    = 'evo_tile_temp',
    text    = sensors.temperature,
    caption = 'Tile: Temperature'
  })

  remote.call( 'EvoGUI', 'create_remote_sensor', { mod_name = modName,
    name    = 'evo_tile_elev',
    text    = sensors.elevation,
    caption = 'Tile: Elevation'
  })

  remote.call( 'EvoGUI', 'create_remote_sensor', { mod_name = modName,
    name    = 'evo_tile_water',
    text    = sensors.wateravail,
    caption = 'Tile: Moisture'
  })

  remote.call( 'EvoGUI', 'create_remote_sensor', { mod_name = modName,
    name    = 'evo_tile_rough',
    text    = sensors.roughness,
    caption = 'Tile: Roughness'
  })

  remote.call( 'EvoGUI', 'create_remote_sensor', { mod_name = modName,
    name    = 'evo_tile_terrain',
    text    = sensors.terrain,
    caption = 'Tile: Terrain'
  })

  remote.call( 'EvoGUI', 'create_remote_sensor', { mod_name = modName,
    name    = 'evo_tile_decorate',
    text    = sensors.decorate,
    caption = 'Tile: Shrubbery'
  })

  remote.call( 'EvoGUI', 'create_remote_sensor', { mod_name = modName,
    name    = 'evo_tile_trees',
    text    = sensors.trees,
    caption = 'Tile: Trees'
  })

end--initialise

script.on_init( initialise )
script.on_load( initialise )

local format = string.format -- shortcut

local function updateSensors()

  if game.tick % 60 then -- once per second

    local player  = game.players[1]
    local surface = player.surface
    local pos     = player.position
    local x, y    = pos.x, pos.y
    local tile    = surface.get_tileproperties( x, y )
    local terrain = surface.get_tile( x, y ).prototype.localised_name
    local deco    = surface.find_entities_filtered{
      area = {{ x-0.5, y-0.5 }, { x+0.5,y+0.5}},
      type = 'decorative',
      limit = 1
    }[1]
    local tree    = surface.find_entities_filtered{
      area = {{ x-0.5, y-0.5 }, { x+0.5,y+0.5}},
      type = 'tree',
      limit = 1
    }[1]

    sensors.temperature[2] = format( '%.1f', tile.temperature          )
    sensors.elevation  [2] = format( '%.2f', tile.elevation            )
    sensors.wateravail [2] = format( '%.2f', tile.available_water *100 )
    sensors.roughness  [2] = format( '%.2f', tile.roughness       *100 )
    sensors.terrain    [2] = terrain
    sensors.decorate   [2] = deco and deco.localised_name or 'None'
    sensors.trees      [2] = tree and tree.localised_name or 'None'

    remote.call( 'EvoGUI', 'update_remote_sensor',
      'evo_tile_temp', sensors.temperature
    )

    remote.call( 'EvoGUI', 'update_remote_sensor',
      'evo_tile_elev', sensors.elevation
    )

    remote.call( 'EvoGUI', 'update_remote_sensor',
      'evo_tile_water', sensors.wateravail
    )

    remote.call( 'EvoGUI', 'update_remote_sensor',
      'evo_tile_rough', sensors.roughness
    )

    remote.call( 'EvoGUI', 'update_remote_sensor',
      'evo_tile_terrain', sensors.terrain
    )

    remote.call( 'EvoGUI', 'update_remote_sensor',
      'evo_tile_decorate', sensors.decorate
    )

    remote.call( 'EvoGUI', 'update_remote_sensor',
      'evo_tile_trees', sensors.trees
    )

  end

end--updateSensors

script.on_event( defines.events.on_tick, updateSensors )
