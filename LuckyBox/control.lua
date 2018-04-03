
require "tiers.lucky-box"

function RelativePosition(position, x, y)
	if position[1] then
		return {position[1]+x,position[2]+y}
	else
		return {position.x+x,position.y+y}
	end
end

function EntityTriggered(event)
  local entity = event.entity
  if event.entity and entity.valid and entity.name == "lucky-box" then

	if event.buffer then
		event.buffer.clear()
	end

	local Todo = ChooseRandomLOutcome()
	if Todo then 
		if event.player_index then
			Todo(entity, event.buffer, game.players[event.player_index]) 
		elseif event.robot then
			Todo(entity, event.buffer, event.robot) 
		else
			Todo(entity, event.buffer) 
		end
	end

	if entity.valid and entity.can_be_destroyed() then
		entity.destroy()
	end

  end
end

script.on_event(defines.events.on_player_mined_entity, EntityTriggered)
script.on_event(defines.events.on_robot_mined_entity, EntityTriggered)
script.on_event(defines.events.on_entity_died, EntityTriggered)

EventDelayArray = {} -- {on_tick=, action=}

function CheckForDelays(event)
	for i=#EventDelayArray,1,-1 do
		if EventDelayArray[i].on_tick and EventDelayArray[i].on_tick < game.tick then
			EventDelayArray[i].action()
			table.remove(EventDelayArray, i)
		end
	end
end

script.on_nth_tick(60, CheckForDelays)