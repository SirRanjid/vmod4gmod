--[[
	Handling some basics globally instead each combatbox on their own.
	Like joining/disconnecting from the server...
]]

--send the info to new players

hook.Add("PlayerInitialSpawn","UCombatBox_NewPPL",function(ply)
	-- --print("PlayerInitialSpawn","UCombatBox_NewPPL",ply)
	local stdid = ply:SteamID()
	for k,v in next, UCombatBox.ents do
		
		if k:GetOwnerStdID() == stdid then
			k:SetOwnerEnt(ply)	--in case the owner disconnected and the owner isnt valid and not recognized anymore
		end

		k:SendUpdate(ply)

		-- --print(k:GetOwnerStdID(), k:GetOwnerEnt(),k)
		/*if k:GetOwnerStdID() == stdid then
			 --print(k:GetOwnerStdID(), stdid)
			k:SetOwnerEnt(ply)	--in case the owner disconnected and the owner isnt valid and not recognized anymore
		end*/
		
	end
end)

hook.Add("PlayerDisconnected","UCombatBox_OnDC",function(ply)
	if ply.UCombatBox and UCombatBox.ents[ply.UCombatBox] then
		local stdid = ply:SteamID()
		ply.UCombatBox:RemovePlayer(stdid,false,false,ply:Name().." disconnected.")
		ply.UCombatBox = nil
	end
end)

hook.Add("PlayerDeath","UCombatBox_OnDeath",function(ply,ent,atk)
	if ply.UCombatBox and UCombatBox.ents[ply.UCombatBox] and ply.UCombatBox.Data._SETUP then
		ply.UCombatBox:OnDeath(ply,atk,ent)
	end
end)

hook.Add("PlayerSpawn","UCombatBox_OnSpawn",function(ply)
	if ply.UCombatBox and UCombatBox.ents[ply.UCombatBox] then
		 --print(UCombatBox.ents[ply.UCombatBox], ply.UCombatBox)
		--PrintTable(UCombatBox.ents[ply.UCombatBox])
		ply.UCombatBox:OnSpawn(ply)
	end
end)

hook.Add("PlayerLoadout","UCombatBox_Loadout",function(ply)
	if ply.UCombatBox and UCombatBox.ents[ply.UCombatBox] and ply.UCombatBox.Data._SETUP then
		ply.UCombatBox:Loadout(ply)
	end
end)


hook.Add("EntityTakeDamage","UCombatBox_Damage",function(ent,dmginfo)
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	
	if ent.UCombatBox != attacker.UCombatBox and ent.UCombatBox != attacker:GetOwner().UCombatBox then return true end
	
	if ent.UCombatBox and UCombatBox.ents[ent.UCombatBox] then
		if ent.IsPlayer and ent:IsPlayer() then
			return ent.UCombatBox:PlayerTakeDamage(ent,attacker,inflictor,dmginfo)
		else
			return ent.UCombatBox:EntityTakeDamage(ent,attacker,inflictor,dmginfo)
		end
	end
end)

--[[---------------------------------------------------------
   proprietary common ownership declaration
-----------------------------------------------------------]]

if cleanup then
	UCombatBox.clAdd = UCombatBox.clAdd or cleanup.Add

	function cleanup.Add(ply,type,ent)
		if IsValid(ent) and IsValid(ply) then ent:SetOwnerEnt(ply) end
	    return UCombatBox.clAdd(ply,type,ent)
	end
end

do
	local plymeta = FindMetaTable("Player")

	if plymeta.AddCount then
		UCombatBox.AddCount = UCombatBox.AddCount or plymeta.AddCount

		function plymeta:AddCount(type,ent)
			ent:SetOwnerEnt(self)
			--if self.UCombatBox then timer.Simple(0.5,function() self.UCombatBox:AddEntity(ent) end) end
			if self.UCombatBox then self.UCombatBox:AddEntity(ent) end
			return UCombatBox.AddCount(self,type,ent)
		end
	end
end

--Override to get the string-escaping right:
local gsub = string.gsub --( string string, string pattern, string replacement, number maxReplaces )
--[[---------------------------------------------------------
   Undos an undo
-----------------------------------------------------------]]
function undo.Do_Undo( undo )

	if ( !undo ) then return false end
	
	local count = 0
	
	-- Call each function
	if ( undo.Functions ) then
		for index, func in pairs( undo.Functions ) do
		
			func[1]( undo, unpack(func[2]) )
			count = count + 1
			
		end
	end
	
	-- Remove each entity in this undo
	if ( undo.Entities ) then
		for index, entity in pairs( undo.Entities ) do
		
			if ( entity:IsValid() ) then
				entity:Remove()
				count = count + 1
			end
			
		end
	end
	
	if (count > 0) then
		local name = gsub(undo.Name, "(['\"])","\\%1")
		if ( undo.CustomUndoText ) then --here
			local txt = gsub(undo.CustomUndoText, "(['\"])","\\%1")
			undo.Owner:SendLua( "GAMEMODE:OnUndo( '"..name.."', '"..txt.."' )" )
		else
			undo.Owner:SendLua( "GAMEMODE:OnUndo( '"..name.."' )" )
		end
	end
	
	return count;
end
