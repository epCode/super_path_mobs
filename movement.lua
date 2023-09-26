local mob_class = super_path_mobs.mob_class

function mob_class:goto_pos(selfpos, pos) -- walk toward a position (used for pathfinding)
  if pos and vector.distance(selfpos, pos)>0.7 then
    self._goto_pos = pos
  end
end

function mob_class:get_nvel() -- get horizontal velocity
  local vel = self.object:get_velocity()
  return math.abs(vel.x)+math.abs(vel.z)
end


function mob_class:set_move_normal(speed, yaw) -- basic function for moving (Use for most movment)
  local dir = minetest.yaw_to_dir(yaw)
  self.object:set_acceleration({x=dir.x*2*speed,y=self.object:get_acceleration().y,z=dir.z*2*speed})
  return dir
end



function mob_class:cap_velocity_set_speed(amount_slowed) -- how fast the mob comes to a stop
  local vel = self.object:get_velocity()
  self.object:add_velocity(vector.new(vel.x*-amount_slowed, 0, vel.z*-amount_slowed))
end



function mob_class:do_jump(collisions) -- calculate when to jump the do it
  local node = minetest.get_node(vector.add(self.object:get_pos(), vector.multiply(self.object:get_velocity(),0.5))) or {name=""}
  local node_def = minetest.registered_nodes[node.name]
  if collisions.touching_ground and (node_def and node_def.walkable or self.PATH and self:get_nvel()<0.1) then
    local vel = self.object:get_velocity()
    self.object:set_velocity(vector.new(vel.x,8,vel.z))
    minetest.after(0.3, function()
      if self and self.object then
        self.object:add_velocity(vel)
      end
    end)
  end
end
local sz = {}
minetest.register_on_mods_loaded(function()
  for _,node in pairs(minetest.registered_nodes) do
    table.insert(sz, node.name)
  end
end)

function mob_class:set_path(selfpos, pos) -- calculate and set path for pathfinding
  minetest.chat_send_all(sz[1])
  local nodes = minetest.find_nodes_in_area_under_air(vector.add(pos, vector.new(-4,-4,-4)), vector.add(pos, vector.new(4,4,4)), sz)
  local cn = vector.new(0,0,0)
  for _,n in pairs(nodes) do
    if vector.distance(cn,pos) > vector.distance(n,pos) then
      cn = n
    end
  end
  if #nodes>0 then
    local path = minetest.find_path(selfpos,vector.add(cn, vector.new(0,0.5,0)),10,1,4,"A*_noprefetch")
    self.PATH = path
  end
end




function mob_class:follow_path(pos, naturality) -- Go along set path (self.PATH)
  if self.PATH and #self.PATH > 2 then
    self:goto_pos(pos, self.PATH[math.random(naturality or 3)])
  end
end



function mob_class:get_pushed(pos)
  for _,obj in pairs(minetest.get_objects_inside_radius(pos, self.collisionbox[6]+0.4)) do
    if obj:is_player() or obj:get_luaentity() and obj:get_luaentity().esta_vivo then
      self.object:add_velocity(vector.direction(obj:get_pos(), pos))
    end
  end
end
