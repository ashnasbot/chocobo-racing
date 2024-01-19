local json = require "json"
local fn = require "birblib"
local offset = require "offsets"

console.log("-*- Setup -*-")

-- Setup stuff
-- Don't spam the screen with debug
client.displaymessages(false)
client.enablerewind(false)
client.SetSoundOn(false)
math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
console.clear()
console.log("-*- Birbracing begin -*-")

-- Load Game
client.openrom("c:\\users\\ashnas\\desktop\\bizhawk\\psx\\iso\\Final Fantasy 7 CD2.cue")
--local slot = math.random(1, 4) -- S class disabled as it's too quick
local slot = math.random(1, 3)
slot = 1
console.log("loading slot " .. slot .. " time " .. os.time())
savestate.loadslot(slot)
local classes = {
	[1] = "C",
	[2] = "B",
	[3] = "A",
	[4] = "S"
}

-- Set RNG (4 bytes starting at 0x9010)
fn.set_rand_val()

-- set long vs short course
fn.set_course(0xBF) -- long
-- fn.set_course(0x40) -- Short

console.log("Entering birb select")
fn.press_key("○")
fn.wait_frames(300)

-- This has to happen early as the models are pre-loaded
local birbdata = fn.load_birbs(classes[slot])
fn.wait_frames(30)

console.log("In birb select")
console.log("Sound On")
client.SetSoundOn(true)
console.log("Setting birb names")
fn.wait_frames(30)

--[[ Stat ranges
class C:
73-87 -> 14 window
251-278 -> 17 window

class B:
89-105 -> 16 window
300-329 -> 29 window
]]
print("this is the ", fn.get_course_length(), "course")

for i, birb in pairs(birbdata) do
	local base = offset.birbs[i]
	local location
	if birb["picked"] == false then
		goto continue
	end

	memory.write_u16_le(base+offset.jockey, birb["jockey"])
	memory.write_u16_le(base+offset.rs1, birb["run"])
	memory.write_u16_le(base+offset.rs2, birb["run"])
	memory.write_u16_le(base+offset.wTopSpeed, birb["speed"])
	memory.write_u16_le(base+offset.intel, birb["intel"])
	memory.write_u16_le(base+offset.stamina, birb["stam"])
	memory.write_u16_le(base+offset.maxstamina, birb["stam"])
	memory.write_u16_le(base+offset.accel, birb["accel"])

	location = offset.birbs[i] + offset.name
	-- Clear memory first
	for pos=0,6 do
		memory.writebyte(location + pos, 0xFF)
	end
	-- write name
	for pos=0, math.min(string.len(birb["name"])-1, 5) do
		memory.writebyte(location + pos, string.byte(birb["name"], pos+1) - 0x20)
	end
	::continue::
end

for birb=1,6 do
	fn.debug_birb(birb)
end

-- Birb carosel
--local frames = 3180
local frames = 3180
local time_to_start = frames // 60
while frames > 0 do
	for _=1,3 do
		if frames > 0 then
			fn.wait_frames(60)
			frames = frames - 60
			time_to_start = frames // 60
			fn.set_gil(time_to_start)
		end
	end
	fn.press_key("R1")
end

fn.press_key("Start")
fn.wait_frames(180)
local message = {nickname = "ashnasbot",
    channel = "ashnas", --FIXME: Hard coded!!
	message = "And They're off!",
	type = "TWITCHCHATMESSAGE",
	tags = {
		response = 1
	}}
local res = comm.httpPost("http://localhost:8080/replay_event", json.encode(message))
console.log("Done selecting, race start!")

fn.clear_cheats()
fn.set_gil(99999)

local postracetimer
frames = 0
local winner = false
while true do
	emu.frameadvance();
	frames = frames + 1
	postracetimer = memory.readbyte(0x0F5049)
	if postracetimer >= 1 then
		if frames % 60 == 0 then
			gui.cleartext()
			local choco1pos = memory.readbyte(offset.birbs[1] + offset.raceposition)
			local choco2pos = memory.readbyte(offset.birbs[2] + offset.raceposition)
			local choco3pos = memory.readbyte(offset.birbs[3] + offset.raceposition)
			local choco4pos = memory.readbyte(offset.birbs[4] + offset.raceposition)
			local choco5pos = memory.readbyte(offset.birbs[5] + offset.raceposition)
			local choco6pos = memory.readbyte(offset.birbs[6] + offset.raceposition)
			local pos = {}
			pos[choco1pos] = 1
			pos[choco2pos] = 2
			pos[choco3pos] = 3
			pos[choco4pos] = 4
			pos[choco5pos] = 5
			pos[choco6pos] = 6
			for i = 1,6 do
				local base = offset.birbs[pos[i]]
				if base ~= nil then
					local name = memory.read_u32_be(base+offset.name)
					local name2 = memory.read_u16_be(base+offset.name+4)
					local namec = fn.decode_name(string.format('%X',name)) .. fn.decode_name(string.format('%X',name2))
					local str = string.format("%d: %s", i, namec)
					gui.drawText(16, i*16, str)
					if pos[i] == 1 and winner == false then
						winner = true
						local msg = {nickname = "ashnasbot",
							channel = "ashnas", --FIXME: Hard coded!!
							message = string.format("%s is the winner!", namec),
							type = "TWITCHCHATMESSAGE",
							tags = {
								response = 1
							}}
						local res = comm.httpPost("http://localhost:8080/replay_event", json.encode(msg))
					end
				end
			end
		end
	end

	if postracetimer >= 11 then
		console.log("-*- birbrace complete -*-")

		local choco1pos = memory.readbyte(offset.birbs[1] + offset.raceposition)
		local choco2pos = memory.readbyte(offset.birbs[2] + offset.raceposition)
		local choco3pos = memory.readbyte(offset.birbs[3] + offset.raceposition)
		local choco4pos = memory.readbyte(offset.birbs[4] + offset.raceposition)
		local choco5pos = memory.readbyte(offset.birbs[5] + offset.raceposition)
		local choco6pos = memory.readbyte(offset.birbs[6] + offset.raceposition)
		console.log(choco1pos)
		console.log(choco2pos)
		console.log(choco3pos)
		console.log(choco4pos)
		console.log(choco5pos)
		console.log(choco6pos)
		fn.wait_frames(60)

		if choco1pos == 1 then client.exitCode(1) end
		if choco2pos == 1 then client.exitCode(2) end
		if choco3pos == 1 then client.exitCode(3) end
		if choco4pos == 1 then client.exitCode(4) end
		if choco5pos == 1 then client.exitCode(5) end
		if choco6pos == 1 then client.exitCode(6) end
		break
	elseif frames % 60 == 0 then
		console.clear()
		for birb=1,6 do
			fn.debug_birb(birb)
		end
	end
end