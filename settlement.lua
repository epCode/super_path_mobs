local mob_class = super_path_mobs.mob_class



function mob_class:build_house(name, pos, inv, selfpos)
  local modpath = minetest.get_modpath("super_path_mobs").."/schems/"..name..".mts"
  local schemdata = minetest.read_schematic(modpath, {})

  if not self.HOUSE then
    self.HOUSE = {}

-------------------Support Pillars
    local ss = schemdata.size

    local supports = {vector.new(ss.x-1,0,ss.z-1), vector.new(0,0,ss.z-1), vector.new(ss.x-1,0,0), vector.new(0,0,0)}
    self.house_suports = {}
    for _,vec in pairs(supports) do
      local supos = vector.add(pos, vec)

      for i_=1, 30 do
        local support_bottom = vector.add(supos, vector.new(0,-i_,0))
        if minetest.get_node(support_bottom).name ~= "air" or i_==30 then
          table.insert(self.house_suports, vector.add(support_bottom, vector.new(0,1,0)))
          break
        end
      end
    end

    for _,vec in pairs(self.house_suports) do
      for i_=1, 30 do
        local support_node = vector.add(vec, vector.new(0,i_-1,0))
        if support_node.y > pos.y-1 then
          break
        end
        table.insert(self.HOUSE, {support_node, {name="default:wood"}})
      end
    end
------------------------------------


    local i = 1
    for z=0, schemdata.size.z-1 do
      for y=0, schemdata.size.y-1 do
        for x=0, schemdata.size.x-1 do
          local mapnode = schemdata.data[i]
          if not x or not y or not z or not mapnode then return end


          local pos2 = {x=x,y=y,z=z}
          local poss = (vector.add(pos,pos2))

          local t = {poss, mapnode}
          table.insert(self.HOUSE, t)

          i = i + 1
        end
      end
    end

  end

  if not self._needed_items then
    self._needed_items = {}
    local _i = 0
    for _,node in pairs(self.HOUSE) do
      _i = _i + 1
      name = node[2].name
      if not self._needed_items[_i] then
        self._needed_items[_i] = {count=0,name=_i}
      end
      self._needed_items[_i].count = self._needed_items[_i].count + 1
      minetest.chat_send_all(self._needed_items[1].name)
    end
  end


  if not self.house_on then
    self.house_on = 1
  end
  if self.HOUSE and #self.HOUSE>self.house_on-1 and #self._needed_items == 0 then
    local node_name = self.HOUSE[self.house_on][2].name
    if not self:get_item(inv, node_name) and minetest.get_item_group(node_name, "not_in_creative_inventory")==0 then
    else
      local item, index = self:get_item(inv, node_name)
      self:goto_pos(selfpos, self.HOUSE[self.house_on][1])
      minetest.set_node(self.HOUSE[self.house_on][1], self.HOUSE[self.house_on][2])
      if item then
        item:take_item(1)
        inv:set_stack("main", index, item)
      end
      self.house_on = self.house_on+1
    end

  elseif self.HOUSE and #self.HOUSE==self.house_on-1 then
    self.HOUSE = nil
    self.house_on = nil
    self.house_built = true
  end
end

function mob_class:find_housing_materials(inv)
  if self._needed_items and self._needed_items[1] then
    self._looking_for = self._needed_items[1]
    local item = mob_class:get_item(inv, self._looking_for.name)
    if not item then return end
    if self._looking_for.count < item:get_count() - 1 then
      table.remove(self._needed_items, 1)
      self._looking_for = self._needed_items[1]
      return
    end
    self.state = "material_gathering"
  end
end
