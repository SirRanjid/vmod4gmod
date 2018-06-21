--[[
	entities/ukes_combatbox/init.lua

	SERVERSIDE
	
	Functions:
		ENT:NetworkValues(...)
			--some more complicated function to merge an update on the clients (universal + efficient)
			--can edit multiple variables at once
			--the table you give as parameter must have the structure of the ENT.Data table to replace some of its values
			--can do ENT:NetworkValues(Index("_R.mode"),"dm",Index("_N"),"test")
			--Index(str) takes a 'path'- like string to to edit the ENT.Data table
				--can be combined with regular tables etc.
			--don't know if i actually will ever use this over ENT:NetworkValues(...) but i'll keep it
	
		ENT:NetWorkMode(mode,...)
			--sends action updates to the players, like player join/leave or add a kill etc
			--modes are in the Handle table in entities/ukes_combatbox/init.lua
	
	
		ENT:Loadout(ply)
			--override the loadout of a player that spawns in the arena
			--run by the "UCombatBox_Loadout" from autorun/server/sv_init.lua
			
		ENT:OnSpawn(ply)
			--behavior when a player spawns (move him inside the arena)
			--run by the "UCombatBox_OnSpawn" from autorun/server/sv_init.lua		
		
		ENT:OnDeath(victim,attacker,inflictor)
			--behavior when a player died (add score etc.)
			--run by the "UCombatBox_OnDeath" from autorun/server/sv_init.lua
			--wouldn't modify this one as the hookfunctions are everything you should need
			>>calls the HookFunctions
			
		ENT:SendUpdate(plys)
			-- sends all settings to a player or a table of players
			
		ENT:BroadcastUpdate()
			--sends all settings to all clients
		
		ENT:FindSpawnLocation( ply )
			--finds the best spawnloacation for a player
			--or the best overall if no player is given
		
			ENT:traceForFree(start,endpos)	
				--companion function for FindSpawnLocation( ply ) to check for a good spawn

		
		ENT:RespawnPlayer(ply)
			--respawns a player
			
		ENT:RespawnAllPlayers()
			--respawns all players
			
	HookFunctions:
		
		ENT:OnSuicide(victim,inflictor)
			--run when victim suicided/killed himself
			
		ENT:OnTeamKill(attacker,victim,inflictor)
			--run when attacker killed victim
			--when friendly fire
		
		ENT:OnKill(attacker,victim,inflictor)
			--run when attacker killed victim
			--and they are not on the same team
			
		ENT:WinLoseCondition(ply,inflictor)
			--run when ply died or killed
			--to check if he won or lost
				--say he reached 50 kills and won or lost because of 50 teamkills etc.
				--in case you want to let someone only win if he kills with a specific weapon you have the inflictor
				
		function ENT:PlayerTakeDamage(ply,attacker,inflictor,dmginfo)
			--when a player of this combatbox receives damage from an entity or player that belongs to the CombatBox
			>>calls hook: UCB_PlayerTakeDamage(ply,attacker,inflictor,dmginfo) to let you override
			
		function ENT:EntityTakeDamage(ent,attacker,inflictor,dmginfo)
			--when an entity of this combatbox receives damage from an entity or player that belongs to the CombatBox
			--also called when PlayerTakeDamage gets called
			
			--NOTE: other damage will get nullified
			>>calls hook: UCB_EntityTakeDamage(ply,attacker,inflictor,dmginfo) to let you override

]]

AddCSLuaFile( "shared.lua" )
AddCSLuaFile("cl_init.lua")

include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos
	local ent = ents.Create( ClassName )
		ent:SetPos( SpawnPos )
		ent:SetAngles( Angle(0,0,0) )
	ent:Spawn()
	ent:Activate()

	--ent:SetOwnerEnt(ply)

	return ent
	
end

hook.Add("PlayerSpawnedProp","UCB_PlayerSpawnedProp",function(ply,mdl,ent)
	ent:SetOwnerEnt(ply)
	 --print("setownerenet",ent,ent:GetOwnerEnt())
	if ply.UCombatBox then ply.UCombatBox:AddEntity(ent) print("addent",ent) end
	--ent:SetOwnerEnt(ply)
end)

do
	local merge = table.Merge
	local encode = UCombatBox.pon.encode
	local decode = UCombatBox.pon.decode
	local type = type

	local Indexmt = {__index = Indexmt}

	function UCombatBox.Index(str)
		return setmetatable({str}, Indexmt)
	end

	function UCombatBox.IsIndex(tab)
		return getmetatable(v) == Indexmt
	end

	local Index, IsIndex, Explode = UCombatBox.Index, UCombatBox.IsIndex, string.Explode

	--[[
		function to send the relevant information of the ENT.Data table to be merged on the clients
	]]

	function ENT:NetworkValues(...)
		local args = {...}
		local tbl = {}
		local lastindex, lasttable
		
		for k,v in next, args do
			if type(v) == "table" then
				if IsIndex(v) then
					local indexes = Explode(v[1],"[,/;.]",true)
					lasttable = tbl
					for i,j in ipairs(indexes) do
						if not lasttable[j] then lasttable[j] = {} end
						lasttable = lasttable[j]
					end
				else
					merge(tbl,v)
				end
			else
				if not lastindex then
					lastindex = v
				else
					lasttable[lastindex] = v
					lastindex = nil
				end
			end
		end
		
		local strtbl, slen = encode(tbl)
		
		net.Start(UCombatBox.NWString)
			net.WriteEntity(self)
			net.WriteData("m",UCombatBox.datalen)
			net.WriteInt(slen,UCombatBox.maxlen)
			net.WriteData(strtbl,slen)
		net.Broadcast()
	end

	--[[
		Send information the ENT:HandleNetwork function on the client will handle
	]]

	function ENT:NetWorkMode(mode,...)
		if not UCombatBox.DOSEND then return end
		print("NetWorkMode",mode,...)
		if not ... then
			net.Start(UCombatBox.NWString)
				net.WriteEntity(self)
				net.WriteData(mode,UCombatBox.datalen)
				net.WriteInt(0,UCombatBox.maxlen)
			net.Broadcast()
			print("NetWorkMode1",mode,...)
		else
			local strtbl, slen = encode({...})
			net.Start(UCombatBox.NWString)
				net.WriteEntity(self)
				net.WriteData(mode,UCombatBox.datalen)
				net.WriteInt(slen,UCombatBox.maxlen)
				net.WriteData(strtbl,slen)
			net.Broadcast()
			print("NetWorkMode2",mode,...)
		end
	end
end

function ENT:Loadout(ply)
	--do nothing: use server settings: let override by modes
end

function ENT:OnSpawn(ply)
	
	local spwn  = self:FindSpawnLocation( ply )
	PrintTable(spwn)
	 --print("######find", ply, spwn[1], spwn[2])
	ply:SetPos(spwn[1])
	ply:SetEyeAngles(spwn[2])
end

function ENT:OnSuicide(victim,inflictor)

end
function ENT:WinLoseCondition(ply,inflictor)

end
function ENT:OnTeamKill(attacker,victim,inflictor)

end
function ENT:OnKill(attacker,victim,inflictor)

end

--attacker = atk,inflictor = inf
function ENT:EntityTakeDamage(ent,atk,inf,dmginfo)
	if ent.UCombatBox ~= atk.UCombatBox and ent.UCombatBox ~= inf.UCombatBox then return true end --#and or or?
	if ent.UCombatBox then 
		return hook.Call("UCB_EntityTakeDamage",GAMEMODE,ent,atk,inf,dmginfo)
	end
end

function ENT:PlayerTakeDamage(ply,atk,inf,dmginfo)
	if self:EntityTakeDamage(ply,atk,inf,dmginfo) then return true end
	if ply.UCombatBox then
		if ply.UCombatBox.Data._R.god then return true end
		if ply.UCombatBox.Data._R.god then return true end
		return hook.Call("UCB_PlayerTakeDamage",GAMEMODE,ply,atk,inf,dmginfo)
	end
end

function ENT:OnDeath(victim,attacker,inflictor)
	if victim == attacker then --if suicided
		self:AddSuicides(victim, 1)
		
		self:OnSuicide(victim,inflictor)
		self:WinLoseCondition(victim,inflictor)
	else
		if self.Data._P[ply].team and self.Data._P[ply].team 
		and self.Data._P[ply].team == self.Data._P[ply].team then --team kill
			--punish attacker?
			self:AddTeamKills(attacker, 1)
			
			self:OnTeamKill(attacker,victim,inflictor)
		else --legit kill
			self:AddKills(attacker, 1)
			
			self:OnKill(attacker,victim,inflictor)
		end
		
		self:WinLoseCondition(attacker,inflictor)
		self:WinLoseCondition(victim,inflictor)
	end
	
	self:AddDeaths(victim, 1) --either way he died once
	
end

--[[
	Get any information anywhere.
]]
do
	local encode = UCombatBox.pon.encode
	local decode = UCombatBox.pon.decode

	function ENT:SendUpdate(plys)
		local strtbl, slen = encode(self.Data)
		
		net.Start(UCombatBox.NWString)
			net.WriteEntity(self)
			net.WriteData("u",UCombatBox.datalen)
			net.WriteInt(slen,UCombatBox.maxlen)
			net.WriteData(strtbl,slen)
		net.Send(plys)
	end

	function ENT:BroadcastUpdate()
		local strtbl, slen = encode(self.Data)
		 --print(strtbl,slen,strtbl:len())
		net.Start(UCombatBox.NWString)
			net.WriteEntity(self)
			net.WriteData("u",UCombatBox.datalen)
			net.WriteInt(slen,UCombatBox.maxlen)
			net.WriteData(strtbl,slen)
		net.Broadcast()
	end
end

function ENT:Use(activator, caller, useType, value)
	 --print(activator, caller, useType, value)
	--self:AddPlayer(activator:SteamID())

	 --print(activator:SteamID(),",", self:IsOperator(activator))
	if self:IsOperator(activator) then
		activator:SendLua("UCombatBox.OpenSetupMenu("..self:EntIndex()..")")
	end
end

function ENT:UpdatePhysMesh()
	--self:SetAngles(Angle(0,0,0))
end	

local theworld = game.GetWorld()

function ENT:traceForFree(start,endpos)	

	local tr = util.TraceHull( {
		start = start,
		endpos = endpos,
		filter = function(ent) 
			return ent.UCombatBox == self and ent ~= self
		end,
		mins = Vector( -8, -8, 0 ),
		maxs = Vector( 8, 8, 0 ),
	} )
	
	return tr.Hit, tr.Fraction, tr.HitPos
end

do
	local cp = table.Copy
	local add = table.Add
	local rem = table.remove
	local ri = math.random
	local so = table.sort
	function ENT:FindSpawnLocation( ply )
		if ply then
			local stdid = ply:SteamID()

			local SpawnCandidates
			if self.Data._P[stdid] and self.Data._P[stdid].team and self.Data._T[self.Data._P[stdid].team] then
				SpawnCandidates = self.Data._T[self.Data._P[stdid].team]._S
			else SpawnCandidates = self.Data._S end
			
			if #SpawnCandidates > 0 then
				ValidSpawns = cp(SpawnCandidates)
				local found = false
				local cache = {}	--if no spawn was immediately found get the best from the cache
				while #ValidSpawns > 0 do
					local id = ri(1,#ValidSpawns)
					local spawn = ValidSpawns[id]
					spawn[1] = self:tanslateLocation(spawn[1])

					local HIT, FRC, POS = self:traceForFree(spawn[1],spawn[1]-Vector(0,0,self.Data.SIZE.z))
					if not HIT then
						return {POS,spawn[2]}
					else
						cache[#cache+1] = {FRC,{POS,spawn[2]}}
					end
					
					rem(ValidSpawns,id)
				end
				
				so(cache,function(a,b) return a[1]>b[1] end)
				
				return cache[1][2]
			else
				return {self:tanslateRelativeLocation(Vector(0.5,0.5,0)),Angle()}
			end
		else
			local ValidSpawns = cp(self.Data._S)
			for k,v in pairs(self.Data._T) do
				ValidSpawns = add(ValidSpawns,v._S)
			end
			
			if #ValidSpawns > 0 then
				local found = false
				local cache = {}	--if no spawn was immediately found get the best from the cache
				while #ValidSpawns > 0 do
					local id = ri(1,#ValidSpawns)
					local spawn = ValidSpawns[id]
					spawn[1] = self:tanslateLocation(spawn[1])
					
					local HIT, FRC, POS = self:traceForFree(spawn[1],spawn[1]-Vector(0,0,self.Data.SIZE.z))
					if not HIT then
						return {POS,spawn[2]}	--return first random free spawn
					else
						cache[#cache+1] = {FRC,{POS,spawn[2]}}
					end
					
					ri(ValidSpawns,id)
				end
				
				so(cache,function(a,b) return a[1]>b[1] end)
				
				return cache[1][2]	--return the spawnpoint with the most space on top
			else
				return {self:tanslateRelativeLocation(Vector(0.5,0.5,0)),Angle()}
			end
		end
		
	end
end

function ENT:RespawnPlayer(ply)
	ply:Spawn()
	ply:SetMoveType(MOVETYPE_WALK)
end

hook.Add("PlayerSpawnObject","UCB_SpawnMenuOpen",function(ply,model,skin)
	local ucb = ply and ply.UCombatBox or nil
	if ucb then
		return ucb.Data._R.spawning
	end
end)

function ENT:RespawnAllPlayers()
	for stdid,_ in pairs(self.Data._P) do --for all players
		if UCombatBox.STDID[stdid] then
			local ply = UCombatBox.STDID[stdid]
			if ply then ply:Spawn() ply:SetMoveType(MOVETYPE_WALK) end
		else
			local ply = player.GetBySteamID( stdid )
			if ply then ply:Spawn() ply:SetMoveType(MOVETYPE_WALK) end
		end
	end
end
do
	local mat = Matrix()
	function ENT:SpawnChildEntity(class,model,pos,ang,scale,frozen)
		local new_ent = ents.Create( class )
		if not IsValid( new_ent ) then return end
		self:AddEntity(new_ent)
		
		new_ent:SetModel( model )
		new_ent:SetPos( pos )
		new_ent:SetAngles( ang )
		
		new_ent:Spawn()
		 --print("propscale",new_ent,scale,new_ent.EnableMatrix,new_ent.SetModelScale)
		--if scale and new_ent.SetModelScale then
			--new_ent:SetModelScale(scale.x) --#nope
			/* --print("propscale",new_ent,scale)
			
			mat:Scale( scale )
			new_ent:EnableMatrix( "RenderMultiply", mat )*/

		--end
		
		if frozen then
			local phys = new_ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion( false )
			end
		end
	end
end
/*function vector boxPos(CENTER:vector,POS:vector,SIZE:vector){
        local N = (POS-CENTER):normalized()
        local M = abs(N)
        local O = max(M:x(),max(M:y(),M:z()))

        return CENTER + (N/abs(O))*(SIZE/2)
    }
*/
do
	local max = math.max
	
	hook.Add("OnPhysgunFreeze","UCombatBox_UpdateBoxOnFreeze",function(wep, phys, ent, ply)
		if UCombatBox.ents[ent] and ent.Data and ent.Data._SETUP then 
			ent:SetAngles(Angle(0,0,0))
			ent:DropToFloor()
			ent:SetPos(ent:GetPos() + Vector(0,0,2))
			
			phys:EnableMotion( false )
			--phys:SetAngles(Angle(0,0,0))
			--phys:SetPos(ent:GetPos())
			ent:UpdateSize()
		end
	end)
	
	hook.Add("PhysgunDrop","UCombatBox_OnBoxDrop",function(ply,ent)
		if UCombatBox.ents[ent] and ent.Data and ent.Data._SETUP then 
			ent:SetAngles(Angle(0,0,0))
			ent:DropToFloor()
			ent:SetPos(ent:GetPos() + Vector(0,0,2))
			local phys = ent:GetPhysicsObject()
			if phys then
				phys:EnableMotion( false )
				--phys:SetAngles(Angle(0,0,0))
				--phys:SetPos(ent:GetPos())
			end
			ent:UpdateSize()
		end
	end)
	
end
--[[local oec_cache = {}
hook.Add("Think","deccacheoec",function()
	for I = #oec_cache , 1, -1 do
		local ent = oec_cache[I]
		if not IsValid(ent) then --table.remove(oec_cache,I)  --print("-"..I)
			 --print("tesdt")
		else
			if IsValid(ent:GetOwnerEnt()) and ent:GetOwnerEnt().UCombatBox then ent:GetOwnerEnt().UCombatBox:AddEntity(ent) end
			if UCombatBox.ents[ent.UCombatBox] then ent:SetCustomCollisionCheck( true ) end
			table.remove(oec_cache,I)
			 --print(I,ent)
		end
	end
end)]]

hook.Add("OnEntityCreated","UCombatBox_OnEntityCreated",function(ent)
	-- --print("OnEntityCreated",ent)
	-- --print(ent.UCombatBox,UCombatBox.ents[ent.UCombatBox])
	--if ent then table.insert(oec_cache,ent) end
	-- --print(ent.UCombatBox,UCombatBox.ents[ent.UCombatBox])
	--if IsValid(ent:GetOwnerEnt()) and ent:GetOwnerEnt().UCombatBox then ent:GetOwnerEnt().UCombatBox:AddEntity(ent) end
	--if UCombatBox.ents[ent.UCombatBox] then ent:SetCustomCollisionCheck( true ) end
	ent:SetCustomCollisionCheck( true )
end)

function PlayerPickup( ply, ent )
	if ( ply:IsAdmin() and ent:GetClass():lower() == "player" ) or (ply.UCombatBox and ply.UCombatBox == ent.UCombatBox and ply.UCombatBox:IsOperator(ply)) then
		return true
	end
end
hook.Add( "PhysgunPickup", "Allow Player Pickup", PlayerPickup )