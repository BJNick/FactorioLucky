data:extend(
{
  {
    type = "simple-entity-with-force",
    name = "lucky-box",
    icon = "__LuckyBox__/graphics/icons/lucky-box-1.png",
    icon_size = 32,
    flags = {"placeable-neutral","placeable-player", "player-creation", "not-rotatable", "not-repairable"},
    minable = {mining_time = 0.5, result = "lucky-box"},
    max_health = 50,
    map_color = {r=1,g=1,b=0,a=1},
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    mined_sound = { filename = "__base__/sound/machine-open.ogg", volume = 1.0 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 1.0 },
    picture =
    {
      filename = "__LuckyBox__/graphics/entities/lucky-box-1.png",
      priority = "extra-high",
      width = 46,
      height = 33,
      shift = {0.25, 0.015625}
    },
  },
}
)