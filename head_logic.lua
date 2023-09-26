local mob_class = super_path_mobs.mob_class


local function set_bone_position(obj, bone, pos, rot)
	local current_pos, current_rot = obj:get_bone_position(bone)
	local pos_equal = not pos or vector.equals(vector.round(current_pos), vector.round(pos))
	local rot_equal = not rot or vector.equals(vector.round(current_rot), vector.round(rot))
	if not pos_equal or not rot_equal then
		obj:set_bone_position(bone, pos or current_pos, rot or current_rot)
	end
end

local function dir_to_pitch(dir)
	--local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end

function mob_class:head_logic()
  if not self._look_at_dir then return end
  local self_rot = self.object:get_rotation()
  local mob_yaw = math.deg(-(-(self_rot.y)-(-minetest.dir_to_yaw(self._look_at_dir))))
  local mob_pitch = math.deg(dir_to_pitch(self._look_at_dir))


  if math.abs(mob_yaw) < 45 then
    set_bone_position(self.object,"Head", vector.new(0,5.8,0), vector.new(mob_pitch,mob_yaw,0))
  else
		set_bone_position(self.object,"Head", vector.new(0,5.8,0), vector.new(0,0,0))
	end

end

function mob_class:set_head_rot(selfpos, pos)
  self._look_at_dir = vector.direction(selfpos, pos)
end
