local MODE = {}

MODE.Title 	= "Russian Tennis"
MODE.Author	= "Uke"

MODE.ID 	= "rut"			--id should be unique
MODE.DERIVE = "base"		--copy settings drom another mode(by it's id)
MODE.PLAYABLE = true		--can you play it or should it just be a base for others, or both?

MODE.Desc	= "Kill each other with exploding barrels!"

function MODE:PlayerJoining(stdid, team_name)
	--since its derived from base, that doesnt allow joining we should override so ppl can join this one
	return not self.Data._R.started	--dont allow joins mid-round
end

do
	local fl = math.floor
	local rnd = math.Rand
	function MODE:SetupSpawns()
		self.Data._S = {}
		for i = 1, 20 do
			local pos = self:tanslateRelativeLocationMargin(Vector(rnd(0,1),rnd(0,1),1),Vector(60,60,60))
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
	ply:Give("weapon_physgun")
	return true
end

function MODE:PreBrain()
	if SERVER then
		
	end
end

function MODE:PrepBrain(remaining_time)

end

function MODE:RoundBrain(remaining_time)
	
end


function MODE:PostBrain()

end


--DON'T EDIT THE MODE.SRC!
MODE.SRC = debug.getinfo(function() end).short_src	--for source determination in case you got a mode id twice it will show you.
return MODE