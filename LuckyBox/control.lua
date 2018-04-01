
require "fate-functions"

function RelativePosition(position, x, y)
	if position[0] then
		return {position[0]+x,position[1]+y}
	else
		return {position.x+x,position.y+y}
	end
end

function EntityTriggered(event)
  local entity = event.entity
  if event.entity and entity.valid and entity.name == "lucky-box-1" then

  	--[[if event.player_index then
      for _, player in pairs(game.players) do
        player.print(game.players[event.player_index].name.." opened a lucky box!")
      end
	elseif event.robot then
      for _, player in pairs(game.players) do
        player.print("A robot opened a lucky box!")
      end
	elseif event.cause then
      for _, player in pairs(game.players) do
        player.print("A lucky box was destroyed!") 
      end
	else
	  for _, player in pairs(game.players) do
        player.print("A lucky box was triggered!")
      end
	end]]

	if event.buffer then
		event.buffer.clear()
	end

	local Todo = ChooseRandomOutcome()
	if Todo then Todo(entity) end

	if entity.valid and entity.can_be_destroyed() then
		entity.destroy()
	end

  end
end

script.on_event(defines.events.on_player_mined_entity, EntityTriggered)
script.on_event(defines.events.on_robot_mined_entity, EntityTriggered)
script.on_event(defines.events.on_entity_died, EntityTriggered)