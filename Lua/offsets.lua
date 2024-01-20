local o = {}
-- Birb size = A4

o.colours = {
    0x0b1258,
    0x0b125C,
    0x0b1260,
    0x0b1264,
    0x0b1268,
    0x0b126C
}

o.birbs = {
	[1] = 0x0B75CC,
	[2] = 0x0B7670,
	[3] = 0x0B7714,
	[4] = 0x0B77B8,
	[5] = 0x0B785C,
	[6] = 0x0B7900
}

o.wPathT_cur = 0x00 -- short
o.wPathT_next = 0x02 -- short
o.wSpeed = 0x04 -- short -- actual speed?
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
--	/*5e*/short f_5e;//_00E711B6 - TEIOH 64, Other 32 - Player FF -- Appears to modify Run speed with 4e
--	/*60*/short wIsAutomatic;//_00E711B8 -- =01 = No
o.coop = 0x62 -- short
o.intel = 0x64 -- short
--	/*66*/short f_66;//_00E711BE = 0x02
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
--	/*82*/short wRankPos;//_00E711DA -- Position (zero indexed)
--	/*84*/short f_84;//_00E711DC
o.terrainmask = 0x86 -- 0x00 = Black, 0x03 = Normal, 0x01 = Blue, 0x02 = Green
o.name = 0x88 -- 8 bytes
o.wChocoboId = 0x90 -- short
o.wJockeyId = 0x92 -- short
--	/*94*/short wSFXCounter;//counter to next noise//_00E711EC
--	/*96*/short f_96;//original struct t_chocobo_ChocoboInfo::f_7c//_00E711EE
--	/*98*/short wLastSprint;//_00E711F0
--	/*9a*/short f_9a;//flag:some special ability?//_00E711F2 -- Appears unused, always FFFF
--	/*9c*/short f_9c;//[unused]flag:some special ability?//_00E711F4
--	/*9e*/short f_9e;//[unused]set to 0//_00E711F6
--	/*a0*/short f_a0;//flag:some special ability?//_00E711F8 -- Appears unused
--	/*a2*/short f_a2;//flag:some special ability?//_00E711FA -- Appears unused

--[[
o.birbcolours = {
	lightgreen = {0x00,0x50,0x00,0x00},
	lightblue = {0x00,0x00,0x50,0x00},
	pink? = {0x50,0x14,0x28,0x00},
	red = {0x50,0xD8,0xD8,0x00},
	mauve = {0x28,0xD8,0x50,0x00},
	white = {0x50,0x50,0x50,0x00}
	geen = {0x00,0x50,0x00,0x00},
	blue = {0x00,0x50,0x50,0x00},
	black = {0xB0,0xB0,0xB0,0x00},
	gold = {0x63,0x2F,0x8B,0x00}
	yellow = {0x50,0x50,0x00,0x00}
}
]]



return o