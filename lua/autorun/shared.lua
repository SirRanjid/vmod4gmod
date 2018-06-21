--[[
	autorun/shared.lua
	
	SHARED:
	
	Functions:
		UCombatBox:RegisterMode( MODE )
			--registers a gamemode
		
		UCombatBox:resolvedependencies()	
			--attempts to resolve all dependencies UCombatBox:RegisterMode could not resolve instantly
			
		UCombatBox:ReloadModi()
			--reloads, registers and resolves dependencies on all loaded modi
			>>calls hook: UCombatBox_ReloadedModi
			
	Hooks:
		UCombatBox_ReloadedModi
]]

UCombatBox = UCombatBox or {}
UCombatBox.NWString = 'CombatBox_EntityHandler'
UCombatBox.NWBase = 'CombatBox_Base'
UCombatBox.GameModes = {}

UCombatBox.STDID = {}
UCombatBox.DOSEND = true

AddCSLuaFile("ucombatbox/ucombatbox_pon.lua")
include("ucombatbox/ucombatbox_pon.lua")

--AddCSLuaFile("ucombatbox/utility.lua")
--include("ucombatbox/utility.lua")

do
	//plugins?
	local cl = {["sv_"] = false}
	local sv = {["cl_"] = false}
	setmetatable(cl,{ __index = function() return true end})
	setmetatable(sv,{ __index = function() return true end})
	
	local function load_plugins(fld)
		local files, dirs = file.Find(fld.."/*",'LUA','nameasc')
		for k,v in ipairs(files) do
			local str = v:sub(1,3)
			if SERVER then
				if cl[str] then AddCSLuaFile(fld.."/"..v) end
				if sv[str] then include(fld.."/"..v) end
			else
				include(fld.."/"..v)
				 --print(fld.."/"..v)
			end
		end
		for k,v in ipairs(dirs) do
			load_plugins(fld.."/"..v)
		end
	end
	load_plugins('ucombatbox/plugins')
	
	//utilities?
	load_plugins('ucombatbox/utility')
	//menus
	local function load_ui_stuff(fld)
		local files, dirs = file.Find(fld.."/*",'LUA','nameasc')

		for k,v in ipairs(files) do
			if SERVER then
				AddCSLuaFile(fld.."/"..v)
			else
				include(fld.."/"..v)
				 --print(fld.."/"..v)
			end
		end
		for k,v in ipairs(dirs) do
			load_ui_stuff(fld.."/"..v)
		end
	end
	hook.Add("InitPostEntity","UCB_load_ui",function() load_ui_stuff('ucombatbox/ui') end)
	
end

--disabling noclip in arena --#maybe add greater control over noclip (nocip for a sandbox)
hook.Add("PlayerNoClip","UCombatBox_OnNoclip",function(ply,desiredState)
	if ply.UCombatBox and UCombatBox.ents[ply.UCombatBox] then
		if desiredState then return ply.UCombatBox.Data._R.noclip end	--cant think of any game mode that could profit here
		--ply.UCombatBox:OnNoclip(ply,desiredState)
	end
end)

--only the real owner may move the box 
--keep track of boxes being held by players
hook.Add("PhysgunPickup","UCombatBox_DontPickupDeployed",function(ply,ent)
	if UCombatBox.ents[ent] then
		if (ent.Data and ent.Data._SETUP) --[[or ply != ent:GetOwnerEnt()]] then return false else
			ent.IsHeldByPlayer = ply --true --getting who's holding the entity
		end
	end
end)

hook.Add("PhysgunDrop","UCombatBox_PhysgunDrop",function(ply,ent) --resetting the heldbyplayer state when dropped
	if UCombatBox.ents[ent] then ent.IsHeldByPlayer = nil end
end)

--networking my own owners so I'm independent of other prop protections
local entmeta = FindMetaTable("Entity")

function entmeta:GetUCBShouldCollide(ent,alt)
	--if abc then  --print("getshdcoll",self,ent,self.UCombatBox,ent.UCombatBox, self.UCombatBox ~= ent.UCombatBox) end
	if self.UCombatBox == self and not ent.UCombatBox then return not self.Data._SETUP end
	--if ent.UCombatBox == ent and not self.UCombatBox then return ent.Data._SETUP end

	if self.UCombatBox ~= ent.UCombatBox then	--same arena or also not in any arena = draw
		return false
	else
		if self.UCombatBox == self and self.UCombatBox.Data._SETUP then return self.UCombatBox.Data._SB end
		--if ent.UCombatBox and ent.UCombatBox.Data._SETUP then return ent.UCombatBox.Data._SB end
		return alt 
	end
end
if CLIENT then
	function entmeta:GetUCBShouldHide(ent,alt)
		--[[if self.UCombatBox then 
			if self:IsPlayer() then
				if self.UCombatBox.Data._VP then return false	--show players anyways?
				else return not self:GetUCBShouldCollide(ent,alt) end
			else
				if not self.UCombatBox.Data._V then return false --if view is not isolated
				else return not self:GetUCBShouldCollide(ent, alt) end
			end
		else]]
			--if self.UCombatBox and not self.UCombatBox.Data._SETUP then return self.UCombatBox == ent.UCombatBox end
			-- --print(type(ent))
			-- --print(self,self:GetOwnerEnt())
			if self:GetOwnerEnt() == NULL and not self.UCombatBox then return false end
			--if type(ent) == "Player" then return false end
			return not self:GetUCBShouldCollide(ent,true)
		--end
	end
end
do
	local max, abs = math.max, math.abs
	
	local function absv(vec)
		return Vector(abs(vec.x) or 0,abs(vec.y) or 0,abs(vec.z) or 0)
	end
	
	local function boxPos(CENTER,POS,SIZE)
		local N = (POS-CENTER):GetNormalized()
		local M = absv(N)
		local O = max(M.x,max(M.y,M.z))
		
		return CENTER + (N/O)*((SIZE)/2)
	end
	
	hook.Add("ShouldCollide","UCombatBox_OnCollide",function(e1,e2)
		if e1:IsWorld() or e2:IsWorld() then return end --collisions with the world wont be handled here
		--if e1.UCombatBox == e1 --[[and e1.Data._SB ~= nil]] then if not e1.Data._SETUP then return true end return e1.Data._SB and e1:GetUCBShouldCollide(e2, nil) end
		-- --print("sc",e1:GetUCBShouldCollide(e2, nil))
		return e1:GetUCBShouldCollide(e2, true)
	end)
end

if SERVER then
	function entmeta:SetOwnerEnt(ply)
		if self.UCombatBox == self then
			self.Data._O[1] = ply:SteamID()
			self.Data._O[2] = UCombatBox.STDID[self.Data._O[1]]
			self:NetWorkMode("o1",ply:SteamID())
		else
			self.ubc_o_e = ply
			self.ubc_o_std = ply:SteamID()
			self:SetNWString( "ubc_o_std", ply:SteamID() )
		end
	end

	function entmeta:SetOwnerStdID(stid)
		if UCombatBox.STDID[stid] then self:SetOwnerEnt(UCombatBox.STDID[stid]) end
	end

	function entmeta:GetOwnerStdID()
		if self.UCombatBox == self then
			return self.Data._O[1]
		else
			return self.ubc_o_std
		end
	end

	function entmeta:GetOwnerEnt()
		 --print("GOE",self)
		 --print(debug.Trace())
		if UCombatBox.ents[self] then
			-- --print("GOE",self,self.Data,self.Data._O[1],UCombatBox.STDID[self.Data._O[1]])
			 --print("GOE1",self,UCombatBox.STDID[self.Data._O[1]] or NULL)
			return UCombatBox.STDID[self.Data._O[1]] or NULL
		else
			 --print("GOE2",self,self.Data,self.ubc_o_e or NULL)
			return self.ubc_o_e or NULL
		end
	end


else --if CLIENT then

	/*function entmeta:SetOwnerEnt() 
		--well nope
	end*/

	function entmeta:GetOwnerStdID()
		if self.UCombatBox == self then
			return self.Data._O[1]
		else
			return self:GetNWString( "ubc_o_std" ) or NULL
		end
	end

	function entmeta:GetOwnerEnt()
		-- --print("entmeta:GetOwnerEnt()",self.UCombatBox, self)
		if self.UCombatBox == self then
			return UCombatBox.STDID[self.Data._O[1]] or NULL
		else
			return UCombatBox.STDID[self:GetOwnerStdID()] or NULL
		end
	end
end

local function addtheppl()
	for k,v in ipairs(player.GetAll()) do
		if v.SteamID then UCombatBox.STDID[v:SteamID()] = v end
	end
end
addtheppl()

hook.Add( "InitPostEntity", "CombatBox_InitPost", function()
	addtheppl()
end )

include('ucombatbox/ucombatbox_pon.lua')

local len = string.len
local encode = UCombatBox.pon.encode
local decode = UCombatBox.pon.decode

UCombatBox.maxlen = 16
UCombatBox.datalen = 4

UCombatBox.ents = UCombatBox.ents or {}

--local use_chache = CLIENT --only clients cache

if SERVER then 
	util.AddNetworkString(UCombatBox.NWString)
	util.AddNetworkString(UCombatBox.NWBase)
else
	UCombatBox.Cache = {} --in case the entity isn't ready on the client we'll chache the information until the entities init function gets called

	hook.Add("Tick","DeCache",function()
		for id,v in pairs(UCombatBox.Cache) do
			local tucb = Entity(id)
			if tucb and tucb.UCombatBox == tucb then
				local succ_cnt = 0
				for i,tbl in ipairs(v) do
				--for i = #v, 1, -1 do
					--local tbl = v[i]
					local sf, _ = xpcall(function() tucb:HandleNetwork( tbl[1], tbl[2] and decode(tbl[2]) or nil) end,function() PrintTable(tbl) end)
					if sf then
						--UCombatBox.Cache[id] = nil
						--table.remove(v,i)
						succ_cnt = succ_cnt + 1
					else
						break
					end
				end
				for i = succ_cnt, 1, -1 do
					table.remove(v,i)
				end
			end
		end
	end)

end

local c0 = string.char(0)
local function trim0(str)
	local ret = ""
	for I = 1, str:len() do
		local char = str:sub(I,I)
		if char != c0 then
			ret = ret..char
		else
			break
		end
	end
	return ret
end

net.Receive(UCombatBox.NWString, function(dlen,ply)
	 --print("#rec")
	 --print("#rec")
	 --print("#rec")
	 --print(dlen,ply)
	local id = net.ReadInt(16)
	local ent = Entity(id)
	local mode = trim0(net.ReadData(UCombatBox.datalen))
	local slen = net.ReadInt(UCombatBox.maxlen)

	if not IsValid(ent) then
		if CLIENT then			--but only clientside
			 --print("rec",ent,mode,slen) 
			if slen == 0 then
				UCombatBox.Cache[id] = UCombatBox.Cache[id] or {}
				UCombatBox.Cache[id][#UCombatBox.Cache[id]+1] = {mode}
			else
				local strtbl = net.ReadData(slen)
				UCombatBox.Cache[id] = UCombatBox.Cache[id] or {}
				UCombatBox.Cache[id][#UCombatBox.Cache[id]+1] = {mode, strtbl}
				 --print( strtbl )
				--PrintTable()
			end
		end
		return
	end

	
	if SERVER and ent.HandlePermission[mode] and not ent.HandlePermission[mode](ent,ply) then  --[[print("noeern")]] return end
	
	if slen == 0 then
		if SERVER then	--redirect
			net.Start(UCombatBox.NWString)
				net.WriteEntity(ent)
				net.WriteData(mode,UCombatBox.datalen)
				net.WriteInt(0,UCombatBox.maxlen)
			net.Broadcast()
		end
		ent:HandleNetwork( mode )
	else
		local strtbl = net.ReadData(slen)
		local tbl = decode(strtbl)
		--PrintTable(tbl)
		--PrintTable(tbl)
		if not tbl or table.Count(tbl) == 0 then return end

		

		if SERVER then	--redirect
			if tbl._r and tbl._r ~= nil then	--maybe ill send the info to only a few
				local receivers = table.Copy(tbl._r)
				tbl._r = nil
				
				local nstrtbl = encode(tbl)
				local nlen = len(nstrtbl)
				
				net.Start(UCombatBox.NWString)
					net.WriteEntity(ent)
					net.WriteData(mode,UCombatBox.datalen)
					net.WriteInt(nlen,UCombatBox.maxlen)
					net.WriteData(nstrtbl,nlen)
				net.Send(receivers)
			else	
				net.Start(UCombatBox.NWString)
					net.WriteEntity(ent)
					net.WriteData(mode,UCombatBox.datalen)
					net.WriteInt(slen,UCombatBox.maxlen)
					net.WriteData(strtbl,slen)
				net.Broadcast()
			end
			ent:HandleNetwork( mode, tbl )
		elseif ent.HandleAssert[mode] then
			if ent.HandleAssert[mode](ent, tbl) then
				 --print(mode,ent,tbl) PrintTable(tbl)
				ent:HandleNetwork( mode, tbl )
			else
				 --print("cahced",mode,strtbl)
				UCombatBox.Cache[id] = UCombatBox.Cache[id] or {}
				UCombatBox.Cache[id][#UCombatBox.Cache[id]+1] = {mode, strtbl}
			end
		else
			ent:HandleNetwork( mode, tbl )
		end
	end
end)



--[[-----------------------------------------------------------
For non-arena-specific information exchange.
-------------------------------------------------------------]]

local function NetWorkBaseModeTarget(mode,plys,...)
	if not ... then
		net.Start(UCombatBox.NWBase)
			net.WriteData(mode,UCombatBox.datalen)
			net.WriteInt(0,UCombatBox.maxlen)
		if SERVER then
			net.Send(plys)
		else
			net.SendToServer()
		end
	else
		local strtbl, slen = encode({...})
		net.Start(UCombatBox.NWBase)
			net.WriteData(mode,UCombatBox.datalen)
			net.WriteInt(slen,UCombatBox.maxlen)
			net.WriteData(strtbl,slen)
		if SERVER then
			net.Send(plys)
		else
			net.SendToServer()
		end
	end
end

UCombatBox.NetWorkBaseModeTarget = function(mode,plys,...) NetWorkBaseModeTarget(mode,plys,...) end

local function NetWorkBaseMode(mode,...)
	 --print(mode,...)
	if not ... then
		net.Start(UCombatBox.NWBase)
			net.WriteData(mode,UCombatBox.datalen)
			net.WriteInt(0,UCombatBox.maxlen)
		if SERVER then
			net.Broadcast()
		else
			net.SendToServer()
		end
	else
		local strtbl, slen = encode({...})
		 --print(strtbl, slen)
		net.Start(UCombatBox.NWBase)
			net.WriteData(mode,UCombatBox.datalen)
			net.WriteInt(slen,UCombatBox.maxlen)
			net.WriteData(strtbl,slen)
		if SERVER then
			net.Broadcast()
		else
			net.SendToServer()
		end
	end
end

UCombatBox.NetWorkBaseMode = function(mode,...) NetWorkBaseMode(mode,...) end

/*-----------------------------
For getting players by their SteamID more efficiently.

-----------------------------*/
local function AddPlayer(ply,stdid) --#isolate server client ++ other shared
	-- --print("AddPlayer",ply,stdid)
	UCombatBox.STDID[stdid] = ply
	hook.Call("UCB_PlayerJoined",GAMEMODE,ply,stdid)
	if SERVER then NetWorkBaseMode("+p",ply,stdid) end
end

local function RemovePlayer(stdid)
	UCombatBox.STDID[stdid] = nil
	hook.Call("UCB_PlayerLeft",GAMEMODE,stdid)
	if SERVER then NetWorkBaseMode("-p",stdid) end
end

if SERVER then
	hook.Add("PlayerInitialSpawn","UCombatBox_OnConnect",function(ply)
		AddPlayer(ply,ply:SteamID())
	end)
	hook.Add("PlayerDisconnected","UCombatBox_OnDisconnect",function(ply)
		RemovePlayer(ply:SteamID())
	end)
end
local function RequestUpdate(ply,tbl) --tbl = nil
	local ent = tbl[1]
	if not ent then return end
	if ent.UCombatBox ~= ent then return end
	if SERVER and ply and ent:IsOperator(ply) then
		NetWorkBaseModeTarget("vU",ply,ent,ent.Data)
	--elseif CLIENT and ent:IsOperator(LocalPlayer()) then
	--	NetWorkBaseMode("^U",ent)
	end
end

local InfoExchangeHandle = {
	["+p"]	= function(ply,tbl) if CLIENT then AddPlayer(tbl[1],tbl[2]) end	end,			--combine information
	["-p"]	= function(ply,tbl) if CLIENT then RemovePlayer(tbl[1],tbl[2]) end end,			--player left?


	["+j"]	= function(ply,tbl) tbl[1]:AddPlayer(ply:SteamID(),tbl[2]) 	end,			--join a box
	["-j"]	= function(ply,tbl) tbl[1]:RemovePlayer(ply:SteamID(),tbl[2],tbl[3],tbl[4])	end,			--leave box

	["^E"]	= function(ply, tbl) 
		if SERVER and tbl[1] and tbl[1].IsOperator and tbl[1]:IsOperator(ply) then
			ply:SendLua("UCombatBox.OpenSetupMenu("..tbl[1]:EntIndex()..")")
		end
	end,

	["^U"]	= function(ply, tbl)  print("^U",ply,tbl) RequestUpdate(ply,tbl) end,
	["vU"]	= function(ply, tbl)  print("vU") hook.Call("UCB_ReceiveUpdate",GAMEMODE,tbl[1],tbl[2]) end,
}
/*function ENT:RequestEdit(stid)
	if CLIENT and not self:IsOperator(LocalPlayer()) then return end
	if SERVER then self:NetWorkMode("-mod",stid) end
	self.Data._MOD[stid] = nil
	hook.Call("UCB_Operator_Removed",GAMEMODE,stid)
end*/
if CLIENT then
	
	hook.Add("UCB_ReceiveUpdate","test",function(ent,tbl)  print("UCB_ReceiveUpdate",ent) PrintTable(tbl) end)

	local clflags =  FCVAR_CLIENTCMD_CAN_EXECUTE 

	concommand.Add( "vmod_edit",	--command for joining a server as player
		function(ply, cmd, args, argstr)
			local ID = tonumber(args[1])

			if ID ~= nil and Entity(ID) and UCombatBox.ents[Entity(ID)] then
				local ent = Entity(ID)
				if ent:IsOperator(ply) then
					UCombatBox.NetWorkBaseMode("^E",ent)
					 print("Requesting Edit: ",ent.Data._N,ent)
				else
					 print("Can't edit.")
				end
			else
				 print("Invalid: ",'"'..ID..'"')
			end
		end,

		function(cmd, argstr) --autocomplete function
			argstr = string.Trim( argstr )
			argstr = string.lower( argstr )
			argstr = string.gsub( argstr, "(%s)%s*", "%1" ) 
			
			local tbl = {}

			for ent, content in pairs( UCombatBox.ents ) do
				local name = ent.Data._N
				local ID = ent:EntIndex() 

				if ent.Data._SETUP and (string.find( string.lower( name ), argstr ) or string.find( string.lower( ID ), argstr )) then
					name = cmd.." "..ID

					table.insert( tbl, name )
				end
			end

			return tbl
		end,
	"tetset", clflags )
end

net.Receive(UCombatBox.NWBase, function(dlen,ply)
	local mode = trim0(net.ReadData(UCombatBox.datalen))
	local slen = net.ReadInt(UCombatBox.maxlen)
	 --print(mode,slen,UCombatBox.NWBase)
	if slen == 0 then
		if InfoExchangeHandle[mode] then
			InfoExchangeHandle[mode](ply)	--even though its for data exchange we may call only functions through it more efficiently
		end
	else
		local strtbl = net.ReadData(slen)
		
		local tbl = decode(strtbl)
		if not tbl or table.Count(tbl) == 0 then return end
		
		if InfoExchangeHandle[mode] then
			InfoExchangeHandle[mode](ply,tbl)
		end
	end
end)


local count, copy, merge, derivate = table.Count, table.Copy, table.Merge, {cache = {}, precount = 0}
local function copymerge(to,from)
	return merge(copy(to),from)
end

function UCombatBox:RegisterMode( MODE )
	--if type(MODE.SRC) == 'function' then MODE.SRC = debug.getinfo(MODE.SRC).short_src end
	if MODE.DERIVE == MODE.ID then MODE.DERIVE = '' end --why would you try making it derive itself -.-
	
	if MODE.DERIVE and MODE.DERIVE != '' and not UCombatBox.GameModes[MODE.DERIVE] then
		if derivate.cache[MODE.ID] then
			
			if MODE.SRC == derivate.cache[MODE.DERIVE].SRC then
				MsgC(Color(0,255,0),'\t[>] Update: '..MODE.Title..' extends ',Color(0,255,0),UCombatBox.GameModes[MODE.DERIVE].Title..'\n')
			else
				MsgC(Color(255,0,0),'\tDouble in Cache: '..MODE.ID..' ('..MODE.Title..' ['..MODE.SRC..'])\n',Color(0,255,160),'\t\tOriginal: '..derivate.cache[MODE.DERIVE].ID..' ('..derivate.cache[MODE.DERIVE].Title..' ['..derivate.cache[MODE.DERIVE].SRC..'])\n')
			end
			derivate.cache[MODE.ID] = MODE
		else
			derivate.cache[MODE.ID] = MODE
		end

	elseif MODE.DERIVE and MODE.DERIVE != '' then
		
		if UCombatBox.GameModes[MODE.ID] then
			if MODE.SRC == UCombatBox.GameModes[MODE.ID].SRC then
				MsgC(Color(0,255,0),'\t[>] Update: '..MODE.Title..' extends ',Color(0,255,0),UCombatBox.GameModes[MODE.DERIVE].Title..'\n')
			else
				MsgC(Color(255,0,0),'\t[>] Double: '..MODE.ID..' ('..MODE.Title..' ['..MODE.SRC..'])\n extends ',Color(0,255,0),UCombatBox.GameModes[MODE.DERIVE].Title..'\n',Color(0,255,160),'\t\tOriginal: '..UCombatBox.GameModes[MODE.ID].ID..' ('..UCombatBox.GameModes[MODE.ID].Title..' ['..UCombatBox.GameModes[MODE.ID].SRC..'])\n')
			end
		else
			MsgC(Color(0,255,160),'\t[>] Mode: '..MODE.Title..' extends ',Color(0,255,0),UCombatBox.GameModes[MODE.DERIVE].Title..'\n')
		end
		
		UCombatBox.GameModes[MODE.ID] = copymerge(UCombatBox.GameModes[MODE.DERIVE], MODE)
		derivate.precount = derivate.precount + 1
	
	elseif UCombatBox.GameModes[MODE.ID] then
		MsgC(Color(255,0,0),'\t[~] Double: '..MODE.ID..' ('..MODE.Title..' ['..MODE.SRC..'])\n',Color(0,255,160),'\t\tOriginal: '..UCombatBox.GameModes[MODE.ID].ID..' ('..UCombatBox.GameModes[MODE.ID].Title..' ['..UCombatBox.GameModes[MODE.ID].SRC..'])\n')
		
		UCombatBox.GameModes[MODE.ID] = MODE
	else
		MsgC(Color(0,255,160),'\t[+] Mode: '..MODE.Title..'\n')
		
		UCombatBox.GameModes[MODE.ID] = MODE
	end
end

function UCombatBox:resolvedependencies()
	--local cnt, solved = count(derivate.cache) + derivate.precount, derivate.precount
	if count(derivate.cache) > 0 then
		local maxeffort, i = count(derivate.cache), 0	--just in case it would somehow enter an infinite loop
		while count(derivate.cache) > 0 and i < maxeffort do
			for k,v in pairs(derivate.cache) do
				if UCombatBox.GameModes[v.DERIVE] then
					UCombatBox:RegisterMode( v )
					--solved = solved + 1
				elseif not derivate.cache[v.DERIVE] then
					MsgC(Color(255,0,0),'\tCould not resolve dependency on '..v.DERIVE..' of: '..v.ID..' ('..v.Title..' ['..v.SRC..'])\n')
					derivate.cache[k] = nil
				end
			end
			i = i+1
		end
	end
	--print('Resolved '..solved..'/'..(cnt)..' dependenc'..(solved == 1 and 'y' or 'ies')..'.')
	derivate.cache = {}
	derivate.precount = 0
end

function UCombatBox:ReloadModi()
	 print('\n\n\nUCombatBox is loading the modi...')

	if SERVER then
		local cl, sv, sh = 0,0,0
		for k,v in ipairs(file.Find('ucombatbox/modi/*.lua','LUA','nameasc')) do
			local sub3 = v:sub(1,3)
			if sub3 == 'cl_' then
				AddCSLuaFile('ucombatbox/modi/'..v)
				cl = cl+1
			elseif sub3 == 'sv_' then
				include('ucombatbox/modi/'..v)
				UCombatBox:RegisterMode( include('ucombatbox/modi/'..v) )
				sv = sv+1
			else
				AddCSLuaFile('ucombatbox/modi/'..v)
				UCombatBox:RegisterMode( include('ucombatbox/modi/'..v) )
				sh = sh+1
			end
		end
		UCombatBox:resolvedependencies()
		print('Loaded: '..cl..' Clientside, '..sv..' Serverside and '..sh..' Shared Scripts.')
	else
		local cl, sh = 0,0,0
		for k,v in ipairs(file.Find('ucombatbox/modi/*.lua','LUA','nameasc')) do
			local sub3 = v:sub(1,3)
			if sub3 == 'cl_' then
				UCombatBox:RegisterMode( include('ucombatbox/modi/'..v) )
				cl = cl+1
			elseif sub3 != 'sv_' then
				UCombatBox:RegisterMode( include('ucombatbox/modi/'..v) )
				sh = sh+1
			end
		end
		UCombatBox:resolvedependencies()
		print('Loaded: '..cl..' Clientside and '..sh..' Shared Scripts.')
	end
	MODE = nil
	
	hook.Call('UCombatBox_ReloadedModi')	--maybe it could be helpful somewhere
end

if CLIENT then
	concommand.Add("vmod_getrelatives_cl",function() for k,v in pairs(ents.GetAll()) do if v.UCombatBox then  print(v, v.UCombatBox) end end end)
else
	concommand.Add("vmod_getrelatives_sv",function() for k,v in pairs(ents.GetAll()) do if v.UCombatBox then  print(v, v.UCombatBox) end end end)
end

UCombatBox:ReloadModi()