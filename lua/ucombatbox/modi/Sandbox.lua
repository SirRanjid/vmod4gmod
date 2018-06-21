local MODE = {}

MODE.Title 	= "Sandbox"
MODE.Author	= "Uke"

MODE.Desc	= "Isolated Sandbox"

MODE.ID 	= "sbox"
MODE.DERIVE = ""			--Sandbox is a standalone
MODE.PLAYABLE = true

function MODE:Initialize()
	
	--Default Values:
	--self:RegisterPlayerValueFunction("Prop","[P]",true)
	self:RegisterValueFunction("Prop","[P]",true)

	self:RegisterPlayerValueFunction("Kill","*k",true)
	self:RegisterPlayerValueFunction("Death","*d",true)
	self:RegisterPlayerValueFunction("Suicide","*s",true)

	self.Data._R.spawnmenu = true
	self.Data._R.spawning = true

end

function MODE:PlayerJoining(stdid, team_name)
	return self.PLAYABLE and nil or false
end

function MODE:CanChangeMode (mode)
	return UCombatBox.GameModes[mode].PLAYABLE
end

function MODE:OnRoundStart()
	self.Data._R.started = true

	self:ResetAllPlayers()
	if SERVER then self:RespawnAllPlayers() end
end

function MODE:Loadout(ply)
	return false
end


--DON'T EDIT THE MODE.SRC!
MODE.SRC = debug.getinfo(function() end).short_src	--for source determination in case you got a mode id twice it will show you.
return MODE