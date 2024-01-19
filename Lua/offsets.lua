local offsets = {}
local o = {}
-- Birb size = A4
offsets.course = 0x10
offsets.jockey = 0x22
offsets.chocobo = 0x24
offsets.sprinting = 0x3C
offsets.rs1 = 0x6A
offsets.rs2 = 0x72
offsets.top_speed = 0x74
offsets.acc = 0x7A
offsets.coop = 0x7E
offsets.intel = 0x80
offsets.stam1 = 0x84
offsets.stam2 = 0x88
offsets.winorder = 0x8C
offsets.pos = 0x9E
offsets.name = 0xA4

o.colours = {
    0x0b1258,
    0x0b125C,
    0x0b1260,
    0x0b1264,
    0x0b1268,
    0x0b126C
}

offsets.birbs = { --These offsets are at least 6 bytes off!
	[1] = 0x0B75B0,
	[2] = 0x0B7654,
	[3] = 0x0B76F8,
	[4] = 0x0B779C,
	[5] = 0x0B7840,
	[6] = 0x0B78E4
}

o.birbs = {
	[1] = 0x0B75CC, -- B0
	[2] = 0x0B7670, -- 54
	[3] = 0x0B7714, -- 6F8
	[4] = 0x0B77B8, -- 79C
	[5] = 0x0B785C, -- 40
	[6] = 0x0B7900  -- E4
}

o.wPathT_cur = 0x00 -- short
o.wPathT_next = 0x02 -- short
o.wSpeed = 0x04 -- short
o.jockey = 0x06 -- short
--	/*08*/struct SVECTOR sPos_prev;//(only y used)
--	/*10*/struct SVECTOR sPos_cur;
--	/*18*/struct VECTOR vSpeed_dec;
--	/*28*/struct SVECTOR sPos_next;
--	/*30*/struct SVECTOR sRot_cur;
--	/*38*/struct SVECTOR sRot_next;
--	/*40*/struct SVECTOR sPos_orig;//for finish line
--	/*48*/short f_48;//_00E711A0
--	/*4a*/short f_4a;//set but not used?//_00E711A2
o.is_sprinting = 0x4c -- short 2=sprint
--	/*4e*/short f_4e;//_00E711A6
--	/*50*/short f_50;//always 0[never set]?//_00E711A8
--	/*52*/short f_52;//index in pGUIDE//_00E711AA
o.rs1 = 0x54 -- short
o.rs2 = 0x56 -- short
o.wTopSpeed = 0x58 -- short
o.accel = 0x5a -- short
--	/*5c*/short f_5c;//set, not used?//_00E711B4
--	/*5e*/short f_5e;//_00E711B6
--	/*60*/short wIsAutomatic;//_00E711B8
o.coop = 0x62 -- short
o.intel = 0x64 -- short
--	/*66*/short f_66;//_00E711BE
o.stamina = 0x68 -- int
o.maxstamina = 0x6C -- int
o.raceposition = 0x70 -- short
--	/*72*/short wAnimationCounter;//_00E711CA
--	/*74*/short f_74;//unused animation counter//_00E711CC
--	/*76*/short wAnimationCounterIncr;//_00E711CE
--	/*78*/short wPrevAnimationId;//_00E711D0
--	/*7a*/char __7a[2];
--	/*7c*/short f_7c;//xpos on track?//_00E711D4
--	/*7e*/short wFinished;//_00E711D6
--	/*80*/short wAnimationId;//_00E711D8
--	/*82*/short wRankPos;//_00E711DA
--	/*84*/short f_84;//_00E711DC
--	/*86*/short wTerrainMask;//_00E711DE
o.name = 0x88 -- 8 bytes
o.wChocoboId = 0x90 -- short
o.wJockeyId = 0x92 -- short
--	/*94*/short wSFXCounter;//counter to next noise//_00E711EC
--	/*96*/short f_96;//original struct t_chocobo_ChocoboInfo::f_7c//_00E711EE
--	/*98*/short wLastSprint;//_00E711F0
--	/*9a*/short f_9a;//flag:some special ability?//_00E711F2
--	/*9c*/short f_9c;//[unused]flag:some special ability?//_00E711F4
--	/*9e*/short f_9e;//[unused]set to 0//_00E711F6
--	/*a0*/short f_a0;//flag:some special ability?//_00E711F8
--	/*a2*/short f_a2;//flag:some special ability?//_00E711FA

return o