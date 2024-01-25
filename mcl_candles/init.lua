local S = minetest.get_translator("mcl_candles")

local boxes = {
    {-1/16, -8/16, -1/16, 1/16, -2/16, 1/16},
    {-1/16, -8/16, -2/16, 3/16, -2/16, 3/16},
    {-4/16, -8/16, -2/16, 3/16, -2/16, 3/16},
    {-4/16, -8/16, -3/16, 3/16, -2/16, 3/16},
}

local cake_box = {
    {-7/16, -8/16, -7/16, 7/16, 0, 7/16},
    {-1/16, 0, -1/16, 1/16, 6/16, 1/16}
}

local color_defs = {
    {nil,           S("Candle"),                S("Cake With Candle"),              nil         },
	{"white",       S("White Candle"),          S("Cake With White Candle"),        "white"     },
	{"grey",        S("Grey Candle"),           S("Cake With Grey Candle"),         "dark_grey" },
	{"light_grey",  S("Light Grey Candle"),     S("Cake With Light Grey Candle"),   "grey"      },
	{"black",       S("Black Candle"),          S("Cake With Black Candle"),        "black"     },
	{"red",         S("Red Candle"),            S("Cake With Red Candle"),          "red"       },
	{"yellow",      S("Yellow Candle"),         S("Cake With Yellow Candle"),       "yellow"    },
	{"green",       S("Green Candle"),          S("Cake With Green Candle"),        "dark_green"},
	{"cyan",        S("Cyan Candle"),           S("Cake With Cyan Candle"),         "cyan"      },
	{"blue",        S("Blue Candle"),           S("Cake With Blue Candle"),         "blue"      },
	{"magenta",     S("Magenta Candle"),        S("Cake With Magenta Candle"),      "magenta"   },
	{"orange",      S("Orange Candle"),         S("Cake With Orange Candle"),       "orange"    },
	{"purple",      S("Purple Candle"),         S("Cake With Purple Candle"),       "violet"    },
	{"brown",       S("Brown Candle"),          S("Cake With Brown Candle"),        "brown"     },
	{"pink",        S("Pink Candle"),           S("Cake With Pink Candle"),         "pink"      },
	{"lime",        S("Lime Candle"),           S("Cake With Lime Candle"),         "green"     },
    {"light_blue",  S("Light Blue Candle"),     S("Cake With Light Blue Candle"),   "light_blue"}
}
-- TODO: Make better long descriptions
local lit_long_desc = "Lighted candles are sources of light. They can be unlighted by right-clicking with your empty hand on them."
local unlit_long_desc = "Unlighted candles can be lighted with a flint and steel. Rightclick on them with the flint and steel on your hand."

local function candles_add_fire_particle(pos, node)
    local fire_id = minetest.add_particlespawner({
        amount = 1,
        time = 0,
        minpos = pos,
        maxpos = pos,
        minvel = {x = 0, y = 0, z = 0},
        maxvel = {x = 0, y = 0, z = 0},
        minacc = {x = 0, y = 0, z = 0},
        maxacc = {x = 0, y = 0, z = 0},
        collisiondetection = false,
        minexptime = 2.5,
        maxexptime = 10,
        minsize = 3,
        maxsize = 5,
        vertical = false,
        texture = "mcl_candles_fire.png"
    })

    local meta = minetest.get_meta(pos)
    meta:set_int("fire_partspawn_id", fire_id)
end

local function candles_remove_fire_particle(pos)
    local meta = minetest.get_meta(pos)
    local id = meta:get_int("fire_partspawn_id")

    if id and id > 0 then
        minetest.delete_particlespawner(id)
    end
end

local function candles_on_construct(pos)
    -- TODO:
        -- Add smoke particles
        -- Fix fire particles
    candles_add_fire_particle(pos, minetest.get_node(pos))
end

local function candles_on_destruct(pos)
    -- TODO:
    -- Remove smoke particle spawner
    candles_remove_fire_particle(pos)
end

local function candles_on_place(itemstack, placer, pointed_thing)
    if placer then
        local pointed_node = minetest.get_node(pointed_thing.under)
        local node_name = pointed_node.name
        local same_color = node_name:sub(27) == itemstack:get_name():sub(27)
        local creative = minetest.is_creative_enabled(placer:get_player_name())

        if mcl_util.check_position_protection(pointed_thing.under, placer) then
            return
        end

        if node_name == "mcl_cake:cake" then
            local color = itemstack:get_name():sub(27)

            if color then
                minetest.set_node(pointed_thing.under, {name = "mcl_candles:cake_with_candle_unlit" .. color})
            else
                minetest.set_node(pointed_thing.under, {name = "mcl_candles:cake_with_candle_unlit"})
            end
        else
            if node_name:find("mcl_candles") and node_name:find("unlit") then
                if not same_color then
                    return itemstack
                end

                if node_name:find("1") then
                    minetest.set_node(pointed_thing.under, {name = node_name:gsub("1", "2")})
                    if not creative then itemstack:take_item() end
                elseif node_name:find("2") then
                    minetest.set_node(pointed_thing.under, {name = node_name:gsub("2", "3")})
                    if not creative then itemstack:take_item() end
                elseif node_name:find("3") then
                    minetest.set_node(pointed_thing.under, {name = node_name:gsub("3", "4")})
                    if not creative then itemstack:take_item() end
                end
            else
                if not mcl_util.check_position_protection(pointed_thing.above, placer) then
                    minetest.item_place(itemstack, placer, pointed_thing)
                else
                    return
                end
            end
        end
    else
        return
    end

    return itemstack
end

local function candles_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
    if clicker then
        local node_name = node.name

        if mcl_util.check_position_protection(pos, clicker) then
            return
        end

        if node_name:find("mcl_candles") then
            if node_name:find("unlit") then
                if itemstack:get_name():find("flint_and_steel") then
                    minetest.set_node(pos, {name = node_name:gsub("unlit", "lit")})

                    if not minetest.is_creative_enabled(clicker:get_player_name()) then
                        itemstack:add_wear()
                    end
                end
            elseif node_name:find("_lit") then
                if itemstack:is_empty() then
                    minetest.set_node(pos, {name = node_name:gsub("lit", "unlit")})
                end
            end
        end
    else
        return
    end

    return itemstack
end

local function register_candles(index, color_defs, box)
    local desc, itemimg, lit_name, unlit_name, text

    if index == 1 then
        desc = color_defs[2]
    else
        desc = color_defs[2] .. S(" @1", tostring(index))
    end

    if color_defs[1] then
        itemimg = "mcl_candles_item_" .. color_defs[1] .. ".png"
        lit_name = "mcl_candles:candle_" .. tostring(index) .. "_lit_" .. color_defs[1]
        unlit_name = "mcl_candles:candle_" .. tostring(index) .. "_unlit_" .. color_defs[1]
        text = "mcl_candles_candle_" .. color_defs[1] .. ".png"
    else
        itemimg = "mcl_candles_item.png"
        lit_name = "mcl_candles:candle_" .. tostring(index) .. "_lit"
        unlit_name = "mcl_candles:candle_" .. tostring(index) .. "_unlit"
        text = "mcl_candles_candle.png"
    end

    local unlit_defs = {
        collision_box = {type = "fixed", fixed = box},
        description = desc,
        drawtype = "mesh",
        drop = unlit_name:gsub(tostring(index), "1") .. " " .. tostring(index),
        -- TODO: Add or remove groups
        groups = {
            axey = 1, dig_by_piston = 1, handy = 1, pickaxey = 1,
            shearsy = 1, shovely = 1,  swordy = 1
        },
        inventory_image = itemimg,
        is_ground_content = false,
        -- TODO: Fix coordinate orientation and texture mapping of models (if necessary)
        mesh = "mcl_candles_candle_" .. tostring(index) .. ".obj",
        on_place = candles_on_place,
        on_rightclick = candles_on_rightclick,
        paramtype = "light",
        selection_box = {type = "fixed", fixed = box},
        sunlight_propagates = true,
        tiles = {text},
        use_texture_alpha = "clip",
        wield_image = itemimg,
        -- TODO:
        -- Add more _mcl parameters (if necessary)
        -- Add _tt_help (if necessary)
        _doc_items_longdesc = S(unlit_long_desc),
        _mcl_blast_resistance = 0.1,
        _mcl_hardness = 0.1,
    }

    local lit_defs = {
        collision_box = {type = "fixed", fixed = box},
        desc = desc .. " " .. S("Lit"),
        drawtype = "mesh",
        drop = unlit_name:gsub(tostring(index), "1") .. " " .. tostring(index),
        -- TODO: Add or remove groups
        groups = {
            axey = 1, dig_by_piston = 1, handy = 1, lit_candles = index, not_in_creative_inventory = 1,
            pickaxey = 1, shearsy = 1, shovely = 1,  swordy = 1
        },
        is_ground_content = false,
        light_source = 3 * index,
        -- TODO: Fix coordinate orientation and texture mapping of models (if necessary)
        mesh = "mcl_candles_candle_" .. tostring(index) .. ".obj",
        -- TODO: Add these parameters when functions are defined
        on_construct = candles_on_construct,
        on_destruct = candles_on_destruct,
        on_rightclick = candles_on_rightclick,
        paramtype = "light",
        selection_box = {type = "fixed", fixed = box},
        sunlight_propagates = true,
        tiles = {text},
        use_texture_alpha = "clip",
        -- TODO:
        -- Add more _mcl parameters (if necessary)
        -- Add _tt_help (if necessary)
        _doc_items_longdesc = S(lit_long_desc),
        _mcl_blast_resistance = 0.1,
        _mcl_hardness = 0.1,
    }

    minetest.register_node(unlit_name, unlit_defs)
    minetest.register_node(lit_name, lit_defs)

    if color_defs[1] then
        minetest.register_craft({
            output = "mcl_candles:candle_1_unlit_" .. color_defs[1],
            recipe = {"mcl_candles:candle_1_unlit", "mcl_dye:" .. color_defs[4]},
            type = "shapeless"
        })
    end
end

local function cake_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
    if clicker then
        local finepos = minetest.pointed_thing_to_face_pos(clicker, pointed_thing)
        local fpos = finepos.y % 1
        local p0 = pointed_thing.under
        local p1 = pointed_thing.above
        local color = node.name:sub(36)

        if mcl_util.check_position_protection(p0, clicker) then
            return
        end

        -- FIXME: Coordinate the actions of eating the cake and lighting the candle
        if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5) or (fpos < -0.5 and fpos > - 0.9999999) then
            if itemstack:get_name():find("flint_and_steel") then
                minetest.set_node(pos, {name = node.name:gsub("unlit", "lit")})
            end
        else
            if color then
                minetest.add_item(pos, ItemStack("mcl_candles:candle_1_unlit_" .. color))
            else
                minetest.add_item(pos, ItemStack("mcl_candles:candle_1_unlit"))
            end
            return minetest.registered_nodes["mcl_cake:cake"].on_rightclick(pos, node, clicker, itemstack)
        end
    else
        return
    end
end

local function register_cakes(color_defs)
    local drop, lit_name, unlit_name, text

    if color_defs[1] then
        drop = "mcl_candles:candle_1_unlit_" .. color_defs[1]
        lit_name = "mcl_candles:cake_with_candle_lit_" .. color_defs[1]
        unlit_name = "mcl_candles:cake_with_candle_unlit_" .. color_defs[1]
        text = "mcl_candles_candle_" .. color_defs[1] .. ".png"
    else
        drop = "mcl_candles:candle_1_unlit"
        lit_name = "mcl_candles:cake_with_candle_lit"
        unlit_name = "mcl_candles:cake_with_candle_unlit"
        text = "mcl_candles_candle.png"
    end

    local unlit_defs = {
        collision_box = {type = "fixed", fixed = cake_box},
        description = color_defs[3],
        drawtype = "mesh",
        drop = {
            items = {
                items = {drop, "mcl_cake:cake"},
                rarity = 1,
            }
        },
        -- TODO: Add or remove groups
        groups = {
            attached_node = 1, dig_by_piston = 1, handy = 1, not_in_creative_inventory = 1
        },
        is_ground_content = false,
        -- TODO: Fix coordinate orientation and texture mapping of models (if necessary)
        mesh = "mcl_candles_cake.obj",
        on_rightclick = cake_on_rightclick,
        paramtype = "light",
        selection_box = {type = "fixed", fixed = cake_box},
        sunlight_propagates = true,
        tiles = {text, "mcl_candles_cake.png"},
        use_texture_alpha = "clip",
        -- TODO:
        -- Add more _mcl parameters (if necessary)
        -- Add _tt_help (if necessary)
        -- Add _doc_long_desc
        _mcl_blast_resistance = 0.5,
        _mcl_hardness = 0.5,
    }

    local lit_defs = {
        collision_box = {type = "fixed", fixed = cake_box},
        description = color_defs[3] .. " " .. S("Lit"),
        drawtype = "mesh",
        drop = {
            items = {
                items = {drop, "mcl_cake:cake"},
                rarity = 1,
            }
        },
        -- TODO: Add or remove groups
        groups = {
            attached_node = 1, dig_by_piston = 1, handy = 1, not_in_creative_inventory = 1
        },
        is_ground_content = false,
        light_source = 3,
        -- TODO: Fix coordinate orientation and texture mapping of models (if necessary)
        mesh = "mcl_candles_cake.obj",
        -- TODO: Add these parameters when functions are defined
        --on_construct = cake_on_construct,
        --on_destruct = cake_on_destruct,
        --on_rightclick = cake_on_rightclick,
        paramtype = "light",
        selection_box = {type = "fixed", fixed = cake_box},
        sunlight_propagates = true,
        tiles = {text, "mcl_candles_cake.png"},
        use_texture_alpha = "clip",
        -- TODO:
        -- Add more _mcl parameters (if necessary)
        -- Add _tt_help (if necessary)
        -- Add _doc_long_desc
        _mcl_blast_resistance = 0.5,
        _mcl_hardness = 0.5,
    }

    minetest.register_node(unlit_name, unlit_defs)
    minetest.register_node(lit_name, lit_defs)
end

for i = 1, #boxes do
    for j = 1, #color_defs do
        register_candles(i, color_defs[j], boxes[i])
    end
end

for i = 1, #color_defs do
    register_cakes(color_defs[i])
end

for name, defs in pairs(minetest.registered_nodes) do
    if name:find("mcl_candles") and name:find("unlit") and not name:find("1") then
        defs.groups.not_in_creative_inventory = 1
    end
end

minetest.register_craft({
    output = "mcl_candles:candle_1_unlit",
    recipe = {
        {"mcl_mobitems:string"},
        {"mcl_honey:honeycomb"}
    }
})

minetest.register_lbm({
    label = "Candle Fire",
    name = "mcl_candles:candle_fire",
    nodenames = {"group:lit_candles"},
    run_at_every_load = true,
    action = candles_add_fire_particle
})
