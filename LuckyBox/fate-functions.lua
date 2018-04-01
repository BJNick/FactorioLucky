
OutcomesTable = {
	{
		weight = 0.5,
		applied_function = function(entity) -- Explode
			entity.surface.create_entity{name="big-explosion", position=entity.position}
			local entities_around = entity.surface.find_entities_filtered{area = {RelativePosition(entity.position, -2, -2), RelativePosition(entity.position, 2, 2)}}
			for _, en in pairs(entities_around) do
				if en.valid and en.health then en.damage(100, "neutral", "explosion") end
			end
		end,
	},
	{
		weight = 1,
		applied_function = function(entity) -- Make ore patch -- TODO
			local surface=entity.surface
			local ore=nil
			local size=1
			local density=10
			for y=-size, size do
				for x=-size, size do
					a=(size+1-math.abs(x))*10
					b=(size+1-math.abs(y))*10
					if a<b then
						ore=math.random(a*density-a*(density-8), a*density+a*(density-8))
					end
					if b<a then
						ore=math.random(b*density-b*(density-8), b*density+b*(density-8))
					end
					if not surface.find_entity("iron-ore", {entity.position.x+x, entity.position.y+y}) then
						surface.create_entity({name="copper-ore", amount=ore, position={entity.position.x+x, entity.position.y+y}})
					end
				end
			end
		end
	},
	{
		weight = 1,
		applied_function = function(entity) -- Make ore patch -- TODO
			local surface=entity.surface
			local ore=nil
			local size=1
			local density=10
			for y=-size, size do
				for x=-size, size do
					a=(size+1-math.abs(x))*10
					b=(size+1-math.abs(y))*10
					if a<b then
						ore=math.random(a*density-a*(density-8), a*density+a*(density-8))
					end
					if b<a then
						ore=math.random(b*density-b*(density-8), b*density+b*(density-8))
					end
					if not surface.find_entity("copper-ore", {entity.position.x+x, entity.position.y+y}) then
						surface.create_entity({name="iron-ore", amount=ore, position={entity.position.x+x, entity.position.y+y}})
					end
				end
			end
		end
	},
	{
		weight = 2,
		applied_function = nil,
	},
}

function Balance()
	local sum = 0
	for i, outc in ipairs(OutcomesTable) do
		sum = sum + outc.weight
	end
	for i, outc in ipairs(OutcomesTable) do
		outc.chance = outc.weight/sum
	end
end

Balance()

function ChooseRandomOutcome()
	local p_chance = 1
	local c_chance = 1

	for i, outc in ipairs(OutcomesTable) do
		if math.random() < (outc.chance / p_chance) / c_chance then
			return outc.applied_function
		end
		p_chance = c_chance
		c_chance = 1 - outc.chance/c_chance
	end
end