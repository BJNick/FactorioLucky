
require "fate-functions"


DifferentLoots = {
	-- Military
	{weight = 1, stacks = {{name="submachine-gun", count=1},{name="piercing-rounds-magazine", count=50}}},
	{weight = 0.5, stacks = {{name="combat-shotgun", count=1},{name="shotgun-shell", count=100}}},
	{weight = 0.1, stacks = {{name="rocket-launcher", count=1},{name="rocket", count=10}}},
	{weight = 0.1, stacks = {{name="flamethrower", count=1},{name="flamethrower-ammo", count=40}}},
	-- Belts
	{weight = 1.2, stacks = {{name="transport-belt", count=50},{name="underground-belt", count=2},{name="splitter", count=1}}},
	{weight = 0.7, stacks = {{name="fast-transport-belt", count=50},{name="fast-underground-belt", count=2},{name="fast-splitter", count=1}}},
	{weight = 0.5, stacks = {{name="express-transport-belt", count=50},{name="express-underground-belt", count=2},{name="express-splitter", count=1}}},
	-- Logistics
	{weight = 1.2, stacks = {{name="inserter", count=10},{name="fast-inserter", count=5},{name="long-handed-inserter", count=2}}},
	{weight = 1.1, stacks = {{name="medium-electric-pole", count=10},{name="big-electric-pole", count=10},{name="substation", count=1}}},
	{weight = 1, stacks = {{name="pipe", count=25},{name="pipe-to-ground", count=2},{name="storage-tank", count=1}}},
	{weight = 1.1, stacks = {{name="red-wire", count=50},{name="green-wire", count=50},{name="small-lamp", count=5}}},
	-- Production
	{weight = 0.8, stacks = {{name="solar-panel", count=48},{name="accumulator", count=24},{name="substation", count=1}}},
	{weight = 1, stacks = {{name="boiler", count=3},{name="steam-engine", count=6},{name="offshore-pump", count=1}}},
	{weight = 0.9, stacks = {{name="electric-mining-drill", count=25}}},
	{weight = 0.6, stacks = {{name="pumpjack", count=5}}},
	{weight = 0.4, stacks = {{name="oil-refinery", count=1},{name="chemical-plant", count=3},{name="pump", count=1}}},
	-- Intermediates
	{weight = 0.25, stacks = {{name="iron-ore", count=50},{name="copper-ore", count=50},{name="coal", count=50},{name="stone", count=50}}},
	{weight = 1, stacks = {{name="electronic-circuit", count=20},{name="advanced-circuit", count=15},{name="processing-unit", count=10}}},
	{weight = 0.5, stacks = {{name="science-pack-1", count=50},{name="science-pack-2", count=50},{name="science-pack-3", count=50},{name="military-science-pack", count=50}}},
	{weight = 1, stacks = {{name="engine-unit", count=20},{name="battery", count=10},{name="copper-cable", count=10}}},
	-- Expensive
	{weight = 0.1, stacks = {{name="uranium-235", count=39}}},
	{weight = 0.05, stacks = {{name="nuclear-reactor", count=1},{name="heat-exchanger", count=3},{name="steam-turbine", count=3}}},
}




LuckyOutcomes = {
	{ -- Loot
		weight = 4,
		applied_function = function(entity, buffer)
			local choosen = ChooseRandom(DifferentLoots)
			if choosen.stack then
				DropLoot(entity, buffer, choosen.stack)
			else
				DropManyLoot(entity, buffer, choosen.stacks)
			end
		end,
	},
	{ -- Assembling machine / Lab / Centrifuge
		weight = 0.7,
		applied_function = function(entity, buffer, openedby)
			local surface = entity.surface
			local pos = entity.position
			local name = "assembling-machine-"..math.random(3)
			if math.random() < 0.3 then
				name = "lab"
			elseif math.random() < 0.3 then
				name = "centrifuge"
			end
			local placed = ClearNPlace(surface, {name=name, position=RelativePosition(pos,0,0), force=entity.force}, entity)
			if not placed then
				DropLoot(entity, nil, {name=name, count=1})
			end
		end,	
	},
	{ -- Car
		weight = 0.02,
		applied_function = function(entity, buffer)
			entity.surface.create_entity{name="car", position=entity.position, force=entity.force}
		end,
	},
	{ -- Medium explosion
		weight = 1,
		applied_function = function(entity, buffer, openedby)
			entity.surface.create_entity{name="medium-explosion", position=entity.position, force="enemy"}
			local entities_around = entity.surface.find_entities_filtered{area = {RelativePosition(entity.position, -3, -3), RelativePosition(entity.position, 3, 3)}}
			for _, en in pairs(entities_around) do
				if en.valid and en.health and en.name ~= "lucky-box" then en.damage(100, "neutral", "explosion") end
			end
		end,
	},
	{ -- Small biter
		weight = 1,
		applied_function = function(entity, buffer, openedby)
			entity.surface.create_entity{name="small-biter", position=entity.position, force="enemy"}
		end,
	},
	{ -- Medium biter
		weight = 0.4,
		applied_function = function(entity, buffer, openedby)
			DropLoot(entity, buffer, {name="raw-fish", count=5})
			entity.surface.create_entity{name="medium-biter", position=entity.position, force="enemy"}
		end,
	},
	{ -- Small splitter
		weight = 1,
		applied_function = function(entity, buffer, openedby) 
			entity.surface.create_entity{name="medium-spitter", position=entity.position, force="enemy"}
		end,
	},
	{ -- Medium splitter
		weight = 0.4,
		applied_function = function(entity, buffer, openedby) 
			DropLoot(entity, buffer, {name="raw-fish", count=5})
			entity.surface.create_entity{name="medium-spitter", position=entity.position, force="enemy"}
		end,
	},
	{ -- Worm
		weight = 0.1,
		applied_function = function(entity, buffer, openedby) 
			local surface = entity.surface
			local pos = entity.position
			DropLoot(entity, buffer, {name="raw-fish", count=5})
			entity.surface.create_entity{name="small-worm-turret", position=entity.position, force="enemy"}
			if openedby and openedby.is_player then
				openedby.print({"flying-text.whoops", {"flying-text.by-lucky-box"}}, {r=1,g=0.5,b=0.5,a=1})
			else
				ShowText(surface, pos, {"flying-text.whoops",""}, {r=1,g=0.5,b=0.5,a=1})
			end
		end,
	},
	{ -- Enemy turret
		weight = 0.1,
		applied_function = function(entity, buffer, openedby)
			local surface = entity.surface
			local pos = entity.position
			DropLoot(entity, buffer, {name="raw-fish", count=5})
			local turret = ClearNPlace(surface, {name="gun-turret", position=RelativePosition(pos,0.5,0.5), force="enemy"}, entity)
			turret.get_inventory(defines.inventory.turret_ammo).insert{name="firearm-magazine",count=(math.random(5)+3)}
			if openedby and openedby.is_player then
				openedby.print({"flying-text.whoops", {"flying-text.by-lucky-box"}}, {r=1,g=0.5,b=0.5,a=1})
			else
				ShowText(surface, pos, {"flying-text.whoops",""}, {r=1,g=0.5,b=0.5,a=1})
			end
		end,	
	},
	{ -- Biter Spawner
		weight = 0.1,
		applied_function = function(entity, buffer, openedby)
			local surface = entity.surface
			local pos = entity.position
			DropLoot(entity, buffer, {name="raw-fish", count=5})
			ClearNPlace(surface, {name="biter-spawner", position=RelativePosition(pos,0,0), force="enemy"}, entity)
			if openedby and openedby.is_player then
				openedby.print({"flying-text.whoops", {"flying-text.by-lucky-box"}}, {r=1,g=0.5,b=0.5,a=1})
			else
				ShowText(surface, pos, {"flying-text.whoops",""}, {r=1,g=0.5,b=0.5,a=1})
			end
		end,	
	},
	{ -- Splitter Spawner
		weight = 0.1,
		applied_function = function(entity, buffer, openedby)
			local surface = entity.surface
			local pos = entity.position
			DropLoot(entity, buffer, {name="raw-fish", count=5})
			ClearNPlace(surface, {name="spitter-spawner", position=RelativePosition(pos,0,0), force="enemy"}, entity)
			if openedby and openedby.is_player then
				openedby.print({"flying-text.whoops", {"flying-text.by-lucky-box"}}, {r=1,g=0.5,b=0.5,a=1})
			else
				ShowText(surface, pos, {"flying-text.whoops",""}, {r=1,g=0.5,b=0.5,a=1})
			end
		end,	
	},
	{ -- Tree
		weight = 1,
		applied_function = function(entity, buffer, openedby)
			local surface = entity.surface
			local pos = entity.position
			ClearNPlace(surface, {name="tree-0"..math.random(9), position=pos, force="neutral"}, entity)
			--ShowText(surface, pos, {"flying-text.trees"}, {r=0.5,g=1,b=0.5,a=1})
		end,
	},
	{ -- Belt circle
		weight = 0.5,
		applied_function = function(entity, buffer, openedby)
			local pos = nil
			if openedby then 
				pos = openedby.position
			else
				pos = entity.position
			end
			local surface = entity.surface
			local force = entity.force
			local name = "express-transport-belt"
			if math.random() < 0.5 then
				name = "fast-transport-belt"
				if math.random() < 0.3 then
					name = "transport-belt"
				end
			end
			ClearNPlace(surface, {name=name, direction=defines.direction.north, position=pos, force=force}, entity)
			ClearNPlace(surface, {name=name, direction=defines.direction.east, position=RelativePosition(pos,0,-1), force=force}, entity)
			ClearNPlace(surface, {name=name, direction=defines.direction.south, position=RelativePosition(pos,1,-1), force=force}, entity)
			ClearNPlace(surface, {name=name, direction=defines.direction.west, position=RelativePosition(pos,1,0), force=force}, entity)
		end,
	},
	{ -- Rock
		weight = 0.75,
		applied_function = function(entity, buffer, openedby)
			local surface = entity.surface
			local pos = entity.position
			ClearNPlace(surface, {name="rock-huge", position=RelativePosition(pos,0.5,0.5), force="neutral"}, entity)
			--ShowText(surface, pos, {"flying-text.rock"}, {r=1,g=1,b=0.5,a=1})
		end,	
	},
	{ -- Return box (Nope)
		weight = 0.5,
		applied_function = function(entity, buffer)
			entity.surface.create_entity{name="lucky-box", position=entity.position, force=entity.force}
			ShowText(entity.surface, entity.position, {"flying-text.nope"}, {r=1,g=0.5,b=0.5,a=1})
		end,
	},
	{ -- Return nothing
		weight = 0.75,
		applied_function = function(entity, buffer, openedby) -- Return chest
			if openedby and openedby.is_player() then
				ShowText(entity.surface, entity.position, {"flying-text.empty"}, {r=0.5,g=0.5,b=0.5,a=0.5})
			end
		end,
	},
	{ -- Wall trap
		weight = 0.5,
		applied_function = function(entity, buffer, openedby)
			local pos = nil
			if openedby then 
				pos = openedby.position
			else
				return nil
			end
			if openedby.is_player then
				openedby.print({"flying-text.trap", {"flying-text.by-lucky-box"}}, {r=1,g=1,b=0.5,a=1})
			else
				ShowText(entity.surface, pos, {"flying-text.trap",""}, {r=1,g=1,b=0.5,a=1})
			end
			local surface = entity.surface
			local force = "enemy"
			game.play_sound{path="entity-build/stone-wall",position=pos}
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,1,0), force=force})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,0,1), force=force})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,-1,0), force=force})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,0,-1), force=force})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,1,1), force=force})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,-1,1), force=force})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,-1,-1), force=force})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,1,-1), force=force})
			surface.create_entity{name="fire-flame", position=pos, force="neutral", initial_ground_flame_count=100}
			table.insert(EventDelayArray, {on_tick=game.tick+15*60, action=function() 
				ClearZone(surface, {RelativePosition(pos,-1.5,-1.5), RelativePosition(pos,1.5,1.5)})
				if openedby.is_player then
					openedby.print({"flying-text.enough", {"flying-text.by-lucky-box"}}, {r=1,g=1,b=0.5,a=1})
				else
					ShowText(entity.surface, pos, {"flying-text.enough",""}, {r=1,g=1,b=0.5,a=1})
				end
				game.play_sound{path="entity-mined/stone-wall",position=pos}
			end})
		end,
	},
	{ -- Water
		weight = 0.25,
		applied_function = function(entity, buffer, openedby)
			local pos = entity.position
			local surface = entity.surface
			local nearby = surface.find_entities_filtered{area={RelativePosition(pos,-2,-2),RelativePosition(pos,2,2)}, type="player"}
			for _,p in pairs(nearby) do
				local n = math.random(4)
				if n == 1 then
					p.teleport(RelativePosition(pos,2,0))
				elseif n == 2 then
					p.teleport(RelativePosition(pos,-2,0))
				elseif n == 3 then
					p.teleport(RelativePosition(pos,0,2))
				else
					p.teleport(RelativePosition(pos,0,-2))
				end
			end
			ClearZone(surface, {RelativePosition(pos,-1,-1),RelativePosition(pos,1,1)}, entity)
			surface.set_tiles({
				{name="water", position=pos},
				{name="water", position=RelativePosition(pos,1,0)},
				{name="water", position=RelativePosition(pos,-1,0)},
				{name="water", position=RelativePosition(pos,0,-1)},
				{name="water", position=RelativePosition(pos,0,1)},
				{name="water", position=RelativePosition(pos,1,1)},
				{name="water", position=RelativePosition(pos,-1,1)},
				{name="water", position=RelativePosition(pos,1,-1)},
				{name="water", position=RelativePosition(pos,-1,-1)},
			})
			if openedby and openedby.is_player then
				openedby.print({"flying-text.your-problem", {"flying-text.by-lucky-box"}}, {r=0.5,g=0.5,b=1,a=1})
			else
				ShowText(surface, pos, {"flying-text.your-problem",""}, {r=0.5,g=0.5,b=1,a=1})
			end
		end,
	},
	{ -- Hazard stone
		weight = 0.25,
		applied_function = function(entity, buffer, openedby)
			local pos = entity.position
			local surface = entity.surface
			for i=-4,4 do
				for j=-4,4 do
					if i == 4 or j == 4 or i == -4 or j == -4 then
						surface.set_tiles({{name="hazard-concrete-left", position=RelativePosition(pos,i,j)}})
					else
						surface.set_tiles({{name="concrete", position=RelativePosition(pos,i,j)}})
					end
				end
			end
			--ShowText(surface, pos, {"flying-text.your-problem"}, {r=0.5,g=0.5,b=1,a=1})
		end,
	},
	{ -- Annoying siren
		weight = 0.15,
		applied_function = function(entity, buffer, openedby) 
			local pos = entity.position
			local force = "enemy"
			local surface = entity.surface

			local speaker = ClearNPlace(surface, {
				name = "programmable-speaker", position = RelativePosition(pos,-1,0), force=force,
				parameters = {playback_volume=1,playback_globally=false,allow_polyphony=false},
			}, entity)
			local pole = ClearNPlace(surface, {
				name = "medium-electric-pole", position = RelativePosition(pos,-1,1), force=force,
			}, entity)
			speaker.connect_neighbour{wire=defines.wire_type.red,target_entity=pole}
			--local behavior = speaker.get_or_create_control_behavior()
			speaker.get_or_create_control_behavior().circuit_parameters = {signal_value_is_pitch = false, instrument_id = 0, note_id  = math.random(7)-1}
			speaker.get_or_create_control_behavior().circuit_condition = {condition={comparator="=",first_signal={type="virtual",name="signal-0"},constant=0}, fulfilled = true}
			local acc = ClearNPlace(surface, {
				name = "accumulator", position = RelativePosition(pos,1.5-1,0.5), force=force,
			}, entity)
			acc.energy = 100000
		end,
	},
	{ -- Slowdown
		weight = 0.15,
		applied_function = function(entity, buffer, openedby) 
			local pos = nil
			if openedby then 
				pos = openedby.position
			else
				pos = entity.position
			end
			if game.speed ~= 1 then
				return nil
			end
			game.print({"flying-text.slow", {"flying-text.by-lucky-box"}}, {r=1,g=1,b=1,a=1})
			local surface = entity.surface
			game.speed = 0.5
			--game.play_sound{path="utility/stone-wall",position=pos}
			table.insert(EventDelayArray, {on_tick=game.tick + (math.random(3)+4) * 60, action=function() 
				game.speed = 1
				--game.print({"flying-text.enough", {"flying-text.by-lucky-box"}}, {r=1,g=1,b=0.5,a=1})
				--game.play_sound{path="entity-mined/stone-wall",position=pos}
			end})
		end,
	},
	{ -- Speedup
		weight = 0.15,
		applied_function = function(entity, buffer, openedby) 
			local pos = nil
			if openedby then 
				pos = openedby.position
			else
				pos = entity.position
			end
			if game.speed ~= 1 then
				return nil
			end
			game.print({"flying-text.fast", {"flying-text.by-lucky-box"}}, {r=1,g=1,b=1,a=1})
			local surface = entity.surface
			game.speed = 2
			--game.play_sound{path="utility/stone-wall",position=pos}
			table.insert(EventDelayArray, {on_tick=game.tick + 4*(math.random(3)+4) * 60, action=function() 
				game.speed = 1
				--game.print({"flying-text.enough", {"flying-text.by-lucky-box"}}, {r=1,g=1,b=0.5,a=1})
				--game.play_sound{path="entity-mined/stone-wall",position=pos}
			end})
		end,
	},
	{ -- 'New' game
		weight = 0.05,
		applied_function = function(entity, buffer, openedby) 
			if openedby and openedby.is_player() and openedby.character then 
				pos = openedby.position
			else
				return nil
			end
			if game.surfaces["fake-new-game"] then
				return nil
			end
			local last_surface = openedby.character.surface
			local lx = openedby.character.position.x
			local ly = openedby.character.position.y
			local surface = game.create_surface("fake-new-game",{seed=last_surface.map_gen_settings.seed})

			local main_inventory = openedby.get_inventory(defines.inventory.player_main).get_contents()
			local quickbar_inventory = openedby.get_inventory(defines.inventory.player_quickbar).get_contents()
			local player_guns_inventory = openedby.get_inventory(defines.inventory.player_guns).get_contents()
			local player_ammo_inventory = openedby.get_inventory(defines.inventory.player_ammo).get_contents()
			local player_armor_inventory = openedby.get_inventory(defines.inventory.player_armor).get_contents()
			local player_tools_inventory = openedby.get_inventory(defines.inventory.player_tools).get_contents()

			surface.request_to_generate_chunks({0,0}, 1)
			table.insert(EventDelayArray, {on_tick=game.tick + 1 * 60, action=function() 
				openedby.teleport({0,0}, surface)
				openedby.print({"flying-text.new-game", {"flying-text.by-lucky-box"}}, {r=1,g=1,b=1,a=1})
				openedby.get_inventory(defines.inventory.player_main).clear()
				openedby.get_inventory(defines.inventory.player_quickbar).clear()
				openedby.get_inventory(defines.inventory.player_guns).clear()
				openedby.get_inventory(defines.inventory.player_ammo).clear()
				openedby.get_inventory(defines.inventory.player_armor).clear()
				openedby.get_inventory(defines.inventory.player_tools).clear()
			end})
			table.insert(EventDelayArray, {on_tick=game.tick + (math.random(9)+20 + 4) * 60, action=function() 
				openedby.print({"flying-text.kidding", {"flying-text.by-lucky-box"}}, {r=1,g=1,b=1,a=1})
				openedby.teleport({lx, ly}, last_surface)
				InsertAll(main_inventory, openedby.get_inventory(defines.inventory.player_main))
				InsertAll(quickbar_inventory, openedby.get_inventory(defines.inventory.player_quickbar))
				InsertAll(player_guns_inventory, openedby.get_inventory(defines.inventory.player_guns))
				InsertAll(player_ammo_inventory, openedby.get_inventory(defines.inventory.player_ammo))
				InsertAll(player_armor_inventory, openedby.get_inventory(defines.inventory.player_armor))
				InsertAll(player_tools_inventory, openedby.get_inventory(defines.inventory.player_tools))
				game.delete_surface(surface)
			end})
		end,
	},
	{ -- Teleport
		weight = 0.15,
		applied_function = function(entity, buffer, openedby) 
			if openedby and openedby.is_player() then   
				pos = openedby.position
			else
				return nil
			end
			openedby.print({"flying-text.magic", {"flying-text.by-lucky-box"}}, {r=0.5,g=0.5,b=1,a=1})
			surface = openedby.character.surface
			openedby.teleport(surface.find_non_colliding_position("player", RelativePosition(pos, math.random(100)-50, math.random(100)-50), 50, 1))
		end,
	},
}

Balance(DifferentLoots)
Balance(LuckyOutcomes)

function ChooseRandomLOutcome()
	return ChooseRandom(LuckyOutcomes).applied_function
end
