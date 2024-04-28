local json = require "json"
local offset = require "offsets"
local birblib = {}

local function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function press_key(key)
	local input = shallowcopy(joypad.get(1) )
	input[key] = true
	for _=1,5 do
		joypad.set(input, 1)
		emu.frameadvance();
	end
end

---Wait a number of frames
---@param min integer
---@param max? integer
local function wait_frames(min, max)
	max = max or min
	local r = min
	if min ~= max then
		r = math.random(min, max)
	end
	for _=1,r do
		emu.frameadvance();
	end
end

local function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

-- Converts a big endian hex string name to text 
local function decode_name(input)
    local a = ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~'
	local res = ''
	local i = 1

	while i <= string.len(input) do
		local val = string.sub(input, i, i + 1)
		local dec = tonumber(val, 16)
	  
		if dec >= string.len(a) then
			if dec ~= 255 then
				dec = 0
			end
		end
		res = res .. string.sub(a, dec + 1, dec + 1)
		i = i + 2
	end
	return res
end

--[[ TODO: encodeName
	-- Encode a string
a =""" !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~"""
#myin = "MIKE!"
myin = input("Please enter a string: ")
res = ""
for b in myin:
 pos = a.find(b)
 hexN = '{0:x}'.format(int(pos)).upper()
 if len(hexN) == 1:
  hexN = "0"+hexN
 res +=hexN
print(res)
res2 ="".join(reversed([res[i:i+2] for i in range(0, len(res), 2)]))
print("reverse: "+res2)
]]

local function set_rand()
	local addr = 0x009010  -- General RNG seed
    -- TODO: Move these to offsets
	local value = math.random(0, 9999999)
	memory.write_u32_le(addr, value)

	local addr2 = 0x51568
	memory.write_u32_le(addr2, value)

	--local addr3 = 0x95DC8  -- Affects course length
	--memory.write_u16_le(addr3, value)
end

local function set_gil(value)
	local giladdr = 0x09D260
	memory.write_u32_le(giladdr, value)
end


local debug = false
local function birb_debug(birb)
	local base = offset.birbs[birb]
	--local course = memory.read_u16_be(base+offset.course)        -- 20xx : DE = long course, 03 = short
	local jockey = memory.read_u16_le(base+offset.wJockeyId)           -- 0 = plat, 1 = gold, 2 = bronze, 3 = silver
	--local chocobo = memory.readbyte(base+offset.chocobo)         -- 0 = walking, 1 = sprinting
	--local sprintyness = memory.readbyte(base+offset.sprinting)   -- how likely the choco is to sprint
	local rs1 = memory.read_u16_le(base+offset.rs1)              -- Run speed? x34?
	local rs2 = memory.read_u16_le(base+offset.rs2)              -- Alt run speed (used by bronzes appraently)
	local top_speed = memory.read_u16_le(base+offset.wTopSpeed)  -- sprint speed
	local acc = memory.read_u16_le(base+offset.accel)                 -- acceleration?
	local coop = memory.read_u16_le(base+offset.coop)               -- irrelevant?
	local intel = memory.read_u16_le(base+offset.intel)             -- 50 or 100, how stamina is managed
	local stam = memory.read_u16_le(base+offset.stamina)       -- current stam   
	local stammax = memory.read_u16_le(base+offset.maxstamina)       -- max stam
	local sprint = tostring(memory.read_u16_le(base+offset.is_sprinting) == 0x02)
	--local winorder = memory.readbyte(base+offset.winorder)
	--local pos = memory.readbyte(base+offset.pos)                 -- 0 = Green
	-- names are stored as big endian, even though the psx uses little endian
	local name = memory.read_u32_be(base+offset.name)
	local name2 = memory.read_u16_be(base+offset.name+4)
	local namec = decode_name(string.format('%X',name)) .. decode_name(string.format('%X',name2))
	local output = string.format("%6s: spd:%d rs:%d,%d accel:%X coop:%X int:%X stam:%d/%d jockey:%X sprint:%s", namec, top_speed//34, rs2, rs1, acc, coop, intel, stam//10, stammax//10, jockey, sprint)
	print(output)
	if debug == true then
		local dump = memory.read_bytes_as_array(base, 0xa4)
		for i, e in ipairs(dump) do
			dump[i] = string.format("%02x", e)
		end
		print(table.concat(dump, " "))
		print(" ")
	end
end


local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function get_keys(t)
  local keys={}
  for key,_ in pairs(t) do
    table.insert(keys, key)
  end
  return keys
end


local cheats = {}

local function clear_cheats()
	print("Removing patches")
	for _,code in ipairs(cheats) do
		client.removecheat(code)
	end
	wait_frames(600)
end

-- The value appears to switch on the 7th bit of this value
-- 0x40 = Short
-- 0xBF = Long
local function set_course(val)
	local courseval = 0x095DC8
	local v1 = string.upper(string.format("30%06x 00%02x", courseval, val))
	client.addcheat(v1)
	table.insert(cheats, v1)
	print(string.format("Course: %x", mainmemory.read_u8(courseval)))
end


local function set_birb_colour(pos, colour)
	local addr = offset.colours[pos]
	local t = {}
	if (type(colour) == "table") then
		-- {RR, GG, BB, AA}
		t[2] = ((colour[1]<<8) | (colour[2])) & 0xFFFF;
		t[1] = ((colour[3]<<8) | (colour[4])) & 0xFFFF;
	elseif (type(colour) == "string") then
		-- #RRGGBBAA
		t[2] = tonumber(colour:sub(2,5), 16)
		t[1] = tonumber(colour:sub(6,9), 16)
	else
		for i = 0, 1 do
			t[i+1] = (colour >> (i * 16)) & 0xFFFF
		end
	end
	-- Fix endianness
	t[1] = ((t[1]>>8) | (t[1]<<8)) & 0xFFFF;
	t[2] = ((t[2]>>8) | (t[2]<<8)) & 0xFFFF;
	--
	local v1 = string.upper(string.format("80%06x %04x", addr, t[2]))
	local v2 = string.upper(string.format("80%06x %04x", addr + 2, t[1]))
	-- these need to be set as cheats, as the data is reloaded at a specific frame
	-- which we cannot hook
	client.addcheat(v1) -- r, g
	client.addcheat(v2) -- b, a
	table.insert(cheats, v1)
	table.insert(cheats, v2)
end

local function set_birb_jockey(pos, jockey)
	local base = offset.birbs[pos]
	local addr = base+offset.jockey
	local v3 = string.upper(string.format("80%06x %04x", addr, jockey))
	client.addcheat(v3)
	table.insert(cheats, v3)
end

local function load_birbs(class)
	local birbdata
	local retbirbs = {}
	-- Load file
	local birbfile = "chocobos.json"
	local f = io.open(birbfile, "r")
	if f ~= nil then
		birbdata = json.decode(f.read(f, "a"))
		f.close(f)
	else
		return {}
	end

	local keys = get_keys(birbdata)
	shuffle(keys)
	print("Picking birbs for a class", class, "race")
	-- Choose birbs
	for slot=1,6 do
		local birb
		if math.random(1, 2) == 2 then
			birb = {
				["picked"] = false
			}
		else
			while true do
				local top = tablelength(keys)
				if top == 0 then
					birb = {
						["picked"] = false
					}
					break
				else
					local key = table.remove(keys, 1)
					birb = birbdata[key]
					if birb["class"] == class then
						print("Picked", key, "in slot", slot)
						birb["name"] = key
						birb["picked"] = true
						break
					end
				end
			end
			if birb["picked"] == true then
				set_birb_colour(slot, birb["colour"])
				set_birb_jockey(slot, birb["jockey"])
			end
		end
		retbirbs[slot] = birb
	end
	return retbirbs
end

local function get_course_length()
	return string.format("%x", memory.read_u16_le(offset.birbs[1] + 0x86))
end

local function read_birb_name(base)
	local addr = base + offset.name
	local name = memory.read_u32_be(addr)
	local name2 = memory.read_u16_be(addr+4)
	return decode_name(string.format('%X',name)) .. decode_name(string.format('%X',name2))
end

birblib.set_gil = set_gil
birblib.set_rand_val = set_rand
birblib.press_key = press_key
birblib.wait_frames = wait_frames
birblib.decode_name = decode_name
birblib.read_birb_name = read_birb_name
birblib.debug_birb = birb_debug
birblib.shuffle = shuffle
birblib.load_birbs = load_birbs
birblib.clear_cheats = clear_cheats
birblib.set_course = set_course
birblib.get_course_length = get_course_length

return birblib