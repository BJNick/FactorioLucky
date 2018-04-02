
require "fate-functions"


DifferentLoots = {
	-- Military
	{weight = 1, stacks = {{name="submachine-gun", count=1},{name="piercing-rounds-magazine", count=50}}},
	{weight = 0.5, stacks = {{name="combat-shotgun", count=1},{name="shotgun-shell", count=100}}},
	{weight = 0.1, stacks = {{name="rocket-launcher", count=1},{name="rocket", count=10}}},
	{weight = 0.1, stacks = {{name="flamethrower", count=1},{name="flamethrower-ammo", count=40}}},
	-- Belts
	{weight = 1.2, stacks = {{name="transport-belt", count=50},{name="underground-belt", count=2},{name="splitter", count=1}}},
	{weight = 0.5, stacks = {{name="fast-transport-belt", count=50},{name="fast-underground-belt", count=2},{name="fast-splitter", count=1}}},
	{weight = 0.1, stacks = {{name="express-transport-belt", count=50},{name="express-underground-belt", count=2},{name="express-splitter", count=1}}},
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
	{weight = 0.01, stacks = {{name="uranium-235", count=39}}},
	{weight = 0.005, stacks = {{name="nuclear-reactor", count=1},{name="heat-exchanger", count=3},{name="steam-turbine", count=3}}},
}




LuckyOutcomes = {
	{ -- Loot
		weight = 3,
		applied_function = function(entity, buffer)
			local choosen = ChooseRandom(DifferentLoots)
			if choosen.stack then
				DropLoot(entity, buffer, choosen.stack)
			else
				DropManyLoot(entity, buffer, choosen.stacks)
			end
		end,
	},
	{ -- Assembling machine
		weight = 0.3,
		applied_function = function(entity, buffer, openedby)
			local surface = entity.surface
			local pos = entity.position
			local placed = ClearNPlace(surface, {name="assembling-machine-"..math.random(3), position=RelativePosition(pos,0,0), force=entity.force}, entity)
			if not placed then
				DropLoot(entity, nil, {name="assembling-machine-"..math.random(3), count=1})
			end
		end,	
	},
	{ -- Lab
		weight = 0.3,
		applied_function = function(entity, buffer, openedby)
			local surface = entity.surface
			local pos = entity.position
			local placed = ClearNPlace(surface, {name="lab", position=RelativePosition(pos,0,0), force=entity.force}, entity)
			if not placed then
				DropLoot(entity, nil, {name="lab", count=1})
			end
		end,	
	},
	{ -- Car
		weight = 0.1,
		applied_function = function(entity, buffer)
			entity.surface.create_entity{name="car", position=entity.position, force=entity.force}
		end,
	},
	{ -- Medium explosion
		weight = 1,
		applied_function = function(entity, buffer)
			entity.surface.create_entity{name="medium-explosion", position=entity.position, force="enemy"}
			local entities_around = entity.surface.find_entities_filtered{area = {RelativePosition(entity.position, -3, -3), RelativePosition(entity.position, 3, 3)}}
			for _, en in pairs(entities_around) do
				if en.valid and en.health and en.name ~= "lucky-box" then en.damage(100, "neutral", "explosion") end
			end
		end,
	},
	{ -- Small biter
		weight = 1,
		applied_function = function(entity, buffer)
			entity.surface.create_entity{name="small-biter", position=entity.position, force="enemy"}
			ShowText(entity.surface, entity.position, {"flying-text.whoops"}, {r=1,g=0.5,b=0.5,a=1})
		end,
	},
	{ -- Medium biter
		weight = 0.4,
		applied_function = function(entity, buffer)
			DropLoot(entity, buffer, {name="raw-fish", count=5})
			entity.surface.create_entity{name="medium-biter", position=entity.position, force="enemy"}
			ShowText(entity.surface, entity.position, {"flying-text.whoops"}, {r=1,g=0.5,b=0.5,a=1})
		end,
	},
	{ -- Small splitter
		weight = 1,
		applied_function = function(entity, buffer) 
			entity.surface.create_entity{name="medium-spitter", position=entity.position, force="enemy"}
			ShowText(entity.surface, entity.position, {"flying-text.whoops"}, {r=1,g=0.5,b=0.5,a=1})
		end,
	},
	{ -- Medium splitter
		weight = 0.4,
		applied_function = function(entity, buffer) 
			DropLoot(entity, buffer, {name="raw-fish", count=5})
			entity.surface.create_entity{name="medium-spitter", position=entity.position, force="enemy"}
			ShowText(entity.surface, entity.position, {"flying-text.whoops"}, {r=1,g=0.5,b=0.5,a=1})
		end,
	},
	{ -- Worm
		weight = 0.1,
		applied_function = function(entity, buffer) 
			DropLoot(entity, buffer, {name="raw-fish", count=5})
			entity.surface.create_entity{name="small-worm-turret", position=entity.position, force="enemy"}
			ShowText(entity.surface, entity.position, {"flying-text.whoops"}, {r=1,g=0.5,b=0.5,a=1})
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
			ShowText(surface, pos, {"flying-text.whoops"}, {r=1,g=0.5,b=0.5,a=1})
		end,	
	},
	{ -- Biter Spawner
		weight = 0.1,
		applied_function = function(entity, buffer, openedby)
			local surface = entity.surface
			local pos = entity.position
			DropLoot(entity, buffer, {name="raw-fish", count=5})
			ClearNPlace(surface, {name="biter-spawner", position=RelativePosition(pos,0,0), force="enemy"}, entity)
		end,	
	},
	{ -- Splitter Spawner
		weight = 0.1,
		applied_function = function(entity, buffer, openedby)
			local surface = entity.surface
			local pos = entity.position
			DropLoot(entity, buffer, {name="raw-fish", count=5})
			ClearNPlace(surface, {name="spitter-spawner", position=RelativePosition(pos,0,0), force="enemy"}, entity)
		end,	
	},
	{ -- Tree
		weight = 1,
		applied_function = function(entity, buffer, openedby)
			local surface = entity.surface
			local pos = entity.position
			ClearNPlace(surface, {name="tree-0"..math.random(9), position=pos, force="neutral"}, entity)
			ShowText(surface, pos, {"flying-text.trees"}, {r=0.5,g=1,b=0.5,a=1})
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
			ClearNPlace(surface, {name="express-transport-belt", direction=defines.direction.north, position=pos, force=force}, entity)
			ClearNPlace(surface, {name="express-transport-belt", direction=defines.direction.east, position=RelativePosition(pos,0,-1), force=force}, entity)
			ClearNPlace(surface, {name="express-transport-belt", direction=defines.direction.south, position=RelativePosition(pos,1,-1), force=force}, entity)
			ClearNPlace(surface, {name="express-transport-belt", direction=defines.direction.west, position=RelativePosition(pos,1,0), force=force}, entity)
		end,
	},
	{ -- Rock
		weight = 0.75,
		applied_function = function(entity, buffer, openedby)
			local surface = entity.surface
			local pos = entity.position
			ClearNPlace(surface, {name="rock-huge", position=RelativePosition(pos,0.5,0.5), force="neutral"}, entity)
			ShowText(surface, pos, {"flying-text.rock"}, {r=1,g=1,b=0.5,a=1})
		end,	
	},
	{ -- Return box (Nope)
		weight = 0.5,
		applied_function = function(entity, buffer)
			entity.surface.create_entity{name="lucky-box", position=entity.position, force=entity.force}
			ShowText(entity.surface, entity.position, {"flying-text.nope"}, {r=1,g=0.5,b=0.5,a=1})
		end,
	},
	--[[{ -- Return chest
		weight = 1,
		applied_function = function(entity, buffer) 
			DropLoot(entity, buffer, {name="wooden-chest", count=1})
		end,
	},]]
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
			ShowText(entity.surface, pos, {"flying-text.trap"}, {r=1,g=1,b=0.5,a=1})
			local surface = entity.surface
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,1,0), force="neutral"})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,0,1), force="neutral"})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,-1,0), force="neutral"})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,0,-1), force="neutral"})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,1,1), force="neutral"})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,-1,1), force="neutral"})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,-1,-1), force="neutral"})
			ClearNPlace(surface, {name="stone-wall", position=RelativePosition(pos,1,-1), force="neutral"})
			surface.create_entity{name="fire-flame", position=pos, force="neutral", initial_ground_flame_count=100}
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
			ShowText(surface, pos, {"flying-text.your-problem"}, {r=0.5,g=0.5,b=1,a=1})
		end,
	},
	{ -- Hazard
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
}

Balance(DifferentLoots)
Balance(LuckyOutcomes)

function ChooseRandomLOutcome()
	return ChooseRandom(LuckyOutcomes).applied_function
end
