super_path_mobs = {}
super_path_mobs.mob_class = {}
super_path_mobs.mob_class_meta = {__index = super_path_mobs.mob_class}
local mob_class = super_path_mobs.mob_class

dofile(minetest.get_modpath("super_path_mobs") .. "/entinvs.lua")
dofile(minetest.get_modpath("super_path_mobs") .. "/inventory.lua")
dofile(minetest.get_modpath("super_path_mobs") .. "/animation.lua")
dofile(minetest.get_modpath("super_path_mobs") .. "/movement.lua")
dofile(minetest.get_modpath("super_path_mobs") .. "/settlement.lua")
dofile(minetest.get_modpath("super_path_mobs") .. "/head_logic.lua")


function super_path_mobs.register_mob(name, def)
  complete_mob_definition = {
    hp_min = def.hp_min,
    hp_max = def.hp_max,
    physical = def.physical,
    collisionbox = def.collisionbox or {-0.2,-0.01,-0.2,0.2,1.7,0.2}, --fallback default player sized collisionbox
    visual = def.visual or "sprite",
    automatic_face_movement_dir = def.default_yaw_offset or -90,
    automatic_face_movement_max_rotation_per_sec = def.rotation_speed or 300,
    timer = 0,
    view_range = def.view_range or 16,
    state = def.spawn_state or "wander",
    animations = def.animations or {},
    damage_texture_modifier = "^[colorize:#b80000:200",
    textures = def.textures,
    mesh = def.mesh,
    esta_vivo = true,
    naturality = def.naturality or 3, -- how natural the movment looks. the more, the less accurate. but at one it looks very robotic 3 is recommended
    on_activate = function(self)
      self.object:set_acceleration({x=self.object:get_acceleration().x,y=-14,z=self.object:get_acceleration().z})
    end,
    get_staticdata = function(self)
      return minetest.serialize({})
    end,
    on_step = function(self, dtime, moveresult)
      if not self or not self.object then return end

      local inv = mcl_entity_invs.load_inv(self,self._inv_size)
      local pos = self.object:get_pos()


      self.timer = self.timer + dtime

      local player = minetest.get_player_by_name("singleplayer")

      self:check_animations()

      if not moveresult.touching_ground then -- ground decel
        self:cap_velocity_set_speed(0.03)
      else-- air decel
        self:cap_velocity_set_speed(0.1)
      end

      self:do_jump(moveresult)

      self:follow_path(pos, self.naturality)

      self:get_pushed(pos)

      self:get_pickup(inv, pos)

      --self:find_housing_materials(inv)

      if self._goto_pos and vector.distance(pos, self._goto_pos)>0.7 then--- if we have a place to go, go. else stop
        self:set_move_normal(8, minetest.dir_to_yaw(vector.direction(pos, self._goto_pos)))
      elseif self._goto_pos and vector.distance(pos, self._goto_pos)<0.8 then
        self._goto_pos = nil
        self:set_move_normal(0,0)
      end

      if self.follow then
        self:set_path(pos, self.follow:get_pos())
        mob_class:set_head_rot(pos, self.follow:get_pos())
        self:head_logic()
      end

      if self.timer > 0.3 then
        self.timer = 0


        local closest_target = nil
        for _,playertarget in ipairs(minetest.get_connected_players()) do
          local dist = vector.distance(pos, playertarget:get_pos())
          if dist < self.view_range then
            if not closest_target or dist < closest_target then
              closest_target = dist
              self.follow = playertarget
            end
          end
        end

        if self.follow then
          self:set_path(pos, self.follow:get_pos())
        end
        if not self.house_built then---Build a house
          if not self.house_pos then
            local nodes = minetest.find_nodes_in_area_under_air(vector.add(pos,vector.new(-10,-10,-10)), vector.add(pos,vector.new(10,10,10)), {"default:dirt_with_grass", "default:dry_dirt_with_dry_grass"})
            self.house_pos = nodes[1]
          else
            --self:build_house("house", self.house_pos, inv, pos)
          end
        end



      end

    end,
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
      if not dir then return end

      local pos = self.object:get_pos()
      --minetest.chat_send_all(minetest:get_node(pos, vector.new(0,-0.1,0))).name)
      if not minetest.registered_nodes[minetest:get_node(vector.add(pos, vector.new(0,-0.1,0))).name].walkable then return end

      local kb = vector.add(vector.multiply(dir, vector.new(6,0,6)), vector.new(0,5,0))

      self.object:add_velocity(kb)
    end,
  }
  minetest.register_entity("super_path_mobs:"..name,setmetatable(complete_mob_definition, super_path_mobs.mob_class_meta))

  if def.inventory then
    mcl_entity_invs.register_inv("super_path_mobs:"..name,def.inventory.title,def.inventory.size,def.inventory.show--[[enable]],true)
  end
end



dofile(minetest.get_modpath("super_path_mobs") .. "/register_example.lua")
