
function DropLoot(entity, buffer, ...)
	for _, stack in ipairs({...}) do
		if buffer then
			buffer.insert(stack)
		elseif entity then
			entity.surface.create_entity{name="item-on-ground", position=entity.surface.find_non_colliding_position("item-on-ground", entity.position, 3, 0.5), force="neutral", stack=stack}
		end
	end
end

function DropManyLoot(entity, buffer, stacks)
	for _, stack in ipairs(stacks) do
		if buffer then
			buffer.insert(stack)
		else
			entity.surface.create_entity{name="item-on-ground", position=entity.surface.find_non_colliding_position("item-on-ground", entity.position, 3, 0.5), force="neutral", stack=stack}
		end
	end
end

function Balance(OutcomesTable)
	local sum = 0
	for i, outc in ipairs(OutcomesTable) do
		sum = sum + outc.weight
	end
	for i, outc in ipairs(OutcomesTable) do
		outc.chance = outc.weight/sum
	end
end

function ChooseRandom(OutcomesTable)
	local p_sum = 0
	for i, outc in ipairs(OutcomesTable) do
		if math.random() < outc.chance / (1 - p_sum) then
			return outc
		end
		p_sum = p_sum + outc.chance
	end
end

function ShowText(surface, pos, txt, clr)
	surface.create_entity{name="flying-text", text=txt, color=clr, position=pos, force="neutral"}
end

function PlaceIfCan(surface, entity)
	if surface.can_place_entity(entity) then
		return surface.create_entity(entity)
	else
		local col_box = game.entity_prototypes[entity.name].collision_box
		local array = nil
		if entity.position[1] then
			array = surface.find_entities({left_top=RelativePosition(col_box["left_top"], entity.position[1], entity.position[2]),right_bottom=RelativePosition(col_box["right_bottom"], entity.position[1], entity.position[2])})
		else
			array = surface.find_entities({left_top=RelativePosition(col_box["left_top"], entity.position.x, entity.position.y),right_bottom=RelativePosition(col_box["right_bottom"], entity.position.x, entity.position.y)})
		end
		for _,e in pairs(array) do
			if e.is_player() or e.type == "player" then
				e.teleport(surface.find_non_colliding_position("player", e.position, 5, 0.5))
			end
		end
		if surface.can_place_entity(entity) then
			return surface.create_entity(entity)
		end
	end
end

function ClearZone(surface, boundaries, except_that)
	local array = surface.find_entities(boundaries)
	for _,e in pairs(array) do
		if e.valid and not e.is_player() and e.type ~= "player" and e.can_be_destroyed() then
			if (not except_that or not except_that.valid or e.position.x ~= except_that.position.x or e.position.y ~= except_that.position.y) and e.prototype.mineable_properties and e.prototype.mineable_properties.products then
				DropManyLoot(e, nil, e.prototype.mineable_properties.products)
			end
			e.destroy()
		end
	end
end

function ClearNPlace(surface, entity, except_that)
	if surface.can_place_entity(entity) then
		return surface.create_entity(entity)
	else
		local col_box = game.entity_prototypes[entity.name].collision_box
		local array = nil
		if entity.position[1] then
			array = surface.find_entities({left_top=RelativePosition(col_box["left_top"], entity.position[1], entity.position[2]),right_bottom=RelativePosition(col_box["right_bottom"], entity.position[1], entity.position[2])})
		else
			array = surface.find_entities({left_top=RelativePosition(col_box["left_top"], entity.position.x, entity.position.y),right_bottom=RelativePosition(col_box["right_bottom"], entity.position.x, entity.position.y)})
		end
		local created_entity = surface.create_entity(entity)
		for _,e in pairs(array) do
			if e.valid and not e.is_player() and e.type ~= "player" and e.can_be_destroyed() then
				if (not except_that or not except_that.valid or e.position.x ~= except_that.position.x or e.position.y ~= except_that.position.y) and e.prototype.mineable_properties and e.prototype.mineable_properties.products then
					DropManyLoot(e, nil, e.prototype.mineable_properties.products)
				end
				if e.valid then
					e.destroy()
				end
			elseif e.valid and e.is_player() or e.type == "player" then
				e.teleport(surface.find_non_colliding_position("player", e.position, 5, 0.5))
			end
		end
		return created_entity
	end
end