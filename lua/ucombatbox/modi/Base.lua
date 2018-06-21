local MODE = {}

MODE.Title 	= "Base Gamemode"
MODE.Author	= "Uke"

MODE.Desc	= ""

MODE.ID 	= "base"			--id should be unique
MODE.DERIVE = ""			--copy settings from another mode(by it's id)
MODE.PLAYABLE = false		--the base gamemode is not meant to be playable!

function MODE:Initialize()
	
	--Default Values:
	self:RegisterValueFunction("Point","*P",true,true)
	self:RegisterValueFunction("Kill","*k",true,true)
	self:RegisterValueFunction("Assist","*a",true,true)	--should have the same value as an actual kill to get the focus away from k/d to being effective as teammate if it's a team mode
	self:RegisterValueFunction("TeamKill","*tk",true,true)
	self:RegisterValueFunction("Death","*d",true,true)
	self:RegisterValueFunction("Suicide","*s",true,true)
end

function MODE:PlayerJoining(stdid, team_name)
	return self.PLAYABLE and nil or false
end

function MODE:CanChangeMode (mode)
	return UCombatBox.GameModes[mode].PLAYABLE
end

do
	--local rnd = math.Rand
	function MODE:SetupSpawns()
		self.Data._S = {}
		for i = 1, 20 do
			local pos = self:tanslateRelativeLocation(Vector(rnd(0,1),rnd(0,1),1))
			local ang = Angle(0,(self.CENTER - pos):Angle().y+rnd(-90,90),0)
			self.Data._S[i] = {pos, ang}
		end
	end
end

function MODE:OnRoundStart()
	self.Data._R.started = true

	self:ResetAllPlayers()
	if SERVER then self:RespawnAllPlayers() end
end

function MODE:Loadout(ply)
	--to be overwritten
	return false
end


--DON'T EDIT THE MODE.SRC!
MODE.SRC = debug.getinfo(function() end).short_src	--for source determination in case you got a mode id twice it will show you.
return MODE