local mob_class = super_path_mobs.mob_class

function mob_class:set_animation(name)
  if self.animations and self.animations[name] then
    local range = self.animations[name]
    if self.object:get_animation().range ~= range then
      self.object:set_animation(range, 20, 0, true)
    end
  end
end

function mob_class:check_animations() -- decide which animation to play
  if self:get_nvel() > 0.2 then
    self:set_animation("walk")
  else
    self:set_animation("stand")
  end
end
