local mob_class = mob_test.mob_class

function mob_class:get_pickup(inv, pos) -- walk toward a position (used for pathfinding)
  for _,obj in pairs(minetest.get_objects_inside_radius(pos, 2)) do
    local l=obj:get_luaentity()
    if l and l.name == "__builtin:item" then
      inv:add_item("main",ItemStack(l.itemstring))
      obj:remove()
    end
  end
end

function mob_class:get_item(inv, name)
	for i=1, inv:get_size("main") do
		local it = inv:get_stack("main", i)
		if not it:is_empty() and it:get_name() == name then
      return it, i
		end
	end
end
