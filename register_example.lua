mob_test.register_mob("man", {
  hp_min = 200,
  hp_max = 200,
  physical = true,
  collisionbox = {-0.2,-0.01,-0.2,0.2,1.7,0.2},
  visual = "mesh",
  mesh,
  animations = {
    stand     = {x = 0,   y = 79},
    lay       = {x = 162, y = 166},
    walk      = {x = 168, y = 187},
    mine      = {x = 189, y = 198},
    walk_mine = {x = 200, y = 219},
    sit       = {x = 81,  y = 160},
  },
  textures = {
    "character.png",
  },
  naturality = 4,
  mesh = "character.b3d"
})
