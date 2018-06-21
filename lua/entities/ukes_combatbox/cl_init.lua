--[[
	entities/ukes_combatbox/cl_init.lua
	
	CLIENT:

	Functions:
		ENT:DumpCache()
			--is ENT has a cache it will be removed

		ENT:HasCache()
			--returns true if ENT has something to decache

		ENT:DeCache()
			--allpies chached data and clears the cache
			--it also redeploys the box if its setup
]]

include("shared.lua")

ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

local LocalPlayer = LocalPlayer

do
	local sin, ct, clmp = math.sin, CurTime, math.Clamp
	local SuppressEngineLighting, Start3D, DrawWireframeBox, DrawLine, SetMaterial, DrawSprite, End3D = render.SuppressEngineLighting, cam.Start3D, render.DrawWireframeBox, render.DrawLine, render.SetMaterial, render.DrawSprite, cam.End3D
	
	function ENT:RenderOverride()
		SuppressEngineLighting( true )
		if not self.Data._SETUP then self:DrawModel() end
		SuppressEngineLighting( false )
	end
end
--[[
	Let's just quickly override the SetNoDraw function to add a needed check function
	--st...borrowed from cordon tool but it's efficient here (update relevant stuff as relevant stuff happens instead of regularily checking for every possible relevant stuff to update every time, but thats due to the the different purposes)
	--a semi-solid(touches but decides to ignore) cordon-tool box could have helped for the touchy-hook
	
	For drawing the relevant stuff to the right players.
]]

do
	local entmeta = FindMetaTable("Entity")
	UCombatBox.ori_ndraw = UCombatBox.ori_ndraw or entmeta.SetNoDraw
	local ori_ndraw = UCombatBox.ori_ndraw

	local function draw_check(self,nodraw) --also for collision
		if IsValid(self) then
			ori_ndraw(self,self:GetUCBShouldHide(LocalPlayer(),nodraw))
			--self.ucb_collide = not self:GetNoDraw() --also for collision
		end
	end

	function entmeta:SetNoDraw(nodraw)
		draw_check(self,nodraw)
	end

	function entmeta:CheckShouldDraw()
		draw_check(self,true) --,true
	end
end


hook.Add("OnEntityCreated","UCombatBox_OnEntityCreated",function(ent)
	-- --print(ent:GetOwnerEnt(),ent:GetOwner(),"sdad")
	--timer.Simple(0.1+LocalPlayer():Ping()/1000,function() if IsValid(ent:GetOwnerEnt()) then ent.UCombatBox = ent:GetOwnerEnt().UCombatBox end end)
	--if UCombatBox.ents[ent.UCombatBox] then ent:SetCustomCollisionCheck( true ) end
	-- --print("+#+#+#+hrf#h",ent,ent.CheckShouldDraw)
	ent:SetCustomCollisionCheck( true )
	--ent:CheckShouldDraw()
end)

do
	local anything = ents.GetAll
	
	local function checkvisall() --I could make it only check the relevant stuff like ignoring stuff from another UCombatBox that was not visible anyways but the gain(+cpu -ram) doesn't justify the effort on my end for me
		 --print("wca")
		for k,ent in pairs(anything()) do
			-- --print(ent,ent.CheckShouldDraw)
			ent:CheckShouldDraw()
		end
	end
	
	checkvisall()
	hook.Add( "InitPostEntity", "CombatBox_InitPostVis", function()
		checkvisall()
	end )

	hook.Add("UCombatBox_Join","UCombatBox_OnPlayerJoin",function(ent)
		if ent != LocalPlayer() then
			ent:CheckShouldDraw()
		else	--if we join we have to check everything
			checkvisall()
		end
	end)

	hook.Add("UCombatBox_Leave","UCombatBox_OnPlayerLeave",function(ent)
		if ent != LocalPlayer() then
			ent:CheckShouldDraw()
		else	--if we leave we also
			checkvisall()
		end
	end)
end

hook.Add("UCombatBox_Entity","UCombatBox_EntityAdded",function(ent)
	ent:CheckShouldDraw()
end)

hook.Add("SpawnMenuOpen","UCB_SpawnMenuOpen",function()
	local ucb = LocalPlayer() and LocalPlayer().UCombatBox or nil
	if ucb then
		return ucb.Data._R.spawnmenu
	end

	return true
end)

function ENT:NetWorkMode(mode,...)
	if not UCombatBox.DOSEND then return end
	if self.HandlePermission[mode] and not self.HandlePermission[mode](self,LocalPlayer()) then print("noperm",self,mode,self.HandlePermission[mode],self.HandlePermission[mode](self,LocalPlayer()),LocalPlayer()) return end

	if not ... then
		net.Start(UCombatBox.NWString)
			net.WriteEntity(self)
			net.WriteData(mode,UCombatBox.datalen)
			net.WriteInt(0,UCombatBox.maxlen)
		net.SendToServer()
	else
		local strtbl, slen = UCombatBox.pon.encode({...})
		net.Start(UCombatBox.NWString)
			net.WriteEntity(self)
			net.WriteData(mode,UCombatBox.datalen)
			net.WriteInt(slen,UCombatBox.maxlen)
			net.WriteData(strtbl,slen)
		net.SendToServer()
	end
end

function ENT:HasCache()
	return (UCombatBox.Cache[self:EntIndex()] ~= nil)
end

function ENT:GetCache()
	return UCombatBox.Cache[self:EntIndex()]
end

function ENT:DumpCache()
	if self:HasCache() then UCombatBox.Cache[self:EntIndex()] = nil end
end


function ENT:DeCache()
	local id = self:EntIndex()
	if UCombatBox.Cache[id] then
		local last_setup = self.Data._SETUP

		local recache={}

		for k,v in ipairs(UCombatBox.Cache[id]) do
			local mode = v[1]
			local tbl  = v[2]

			if tbl then
				tbl = UCombatBox.pon.decode(tbl)
				if self.HandleAssert[mode] then
					if self.HandleAssert[mode](self, tbl) then
						self:HandleNetwork( mode, tbl )
					else
						recache[#recache+1] = {mode, net.ReadData(slen)}
					end
				else
					self:HandleNetwork( mode, tbl )
				end
			else
				if self.HandleAssert[mode] then
					if self.HandleAssert[mode](self) then
						self:HandleNetwork( mode )
					else
						recache[#recache+1] = {mode}
					end
				else
					self:HandleNetwork( mode )
				end
			end
			
		end
		if #recache == 0 then
			UCombatBox.Cache[id] = nil
		else
			UCombatBox.Cache[id] = recache
		end

		if self.Data._SETUP != last_setup then
			self:ReloadPhys()
		end
		 --print("dech")
	else
		 --print("dech fail")
	end
end

local clflags =  FCVAR_CLIENTCMD_CAN_EXECUTE 

concommand.Add( "vmod_join",	--command for joining a server as player
	function(ply, cmd, args, argstr)
		local ID = tonumber(args[1])
		local jTeam = args[2] and args[2] or nil

		if ID ~= nil and Entity(ID) and UCombatBox.ents[Entity(ID)] then

			local ent = Entity(ID)
			local stdid = ply:SteamID()

			if ent.Data._T[jTeam] then --join a team
				UCombatBox.NetWorkBaseMode("+j",ent,jTeam)
				 --print("Attempting to join:",ent.Data._N,jTeam,ent)
			else
				print("Attempting to join:",ent.Data._N,ent)
				UCombatBox.NetWorkBaseMode("+j",ent)
				if jTeam ~=nil and jTeam ~= "" then  print("Invalid Team:",'"'..jTeam..'"') end --tried joining a team?
			end
		else
			if jTeam ~=nil and jTeam ~= "" then
				print("Invalid: ",'"'..ID..'"','"'..jTeam..'"')
			else
				print("Invalid: ",'"'..ID..'"')
			end
		end
	end,

	function(cmd, argstr) --autocomplete function
		argstr = string.Trim( argstr )
		argstr = string.lower( argstr )
		argstr = string.gsub( argstr, "(%s)%s*", "%1" ) 
		
		local expl = string.Explode(" ",argstr)
		local nexpl = #expl
		local tbl = {}

		if nexpl == 2 then
			local ID = tonumber(expl[1])
			local jTeam = string.Trim(expl[2])
			local ent = Entity(ID)

			if not ent.Data._R.forceteam and jTeam == "" then table.insert( tbl, cmd.." "..ID ) end --if you dont have to join a team and dont want to

			if ent.UCombatBox == ent then
				for ent, content in ipairs( ent.Data._T ) do
					local name = ent.Data._N
					local ID = ent:EntIndex() 

					if ent.Data._SETUP and (string.find( string.lower( name ), argstr ) or string.find( string.lower( ID ), argstr )) then
						name = cmd.." "..ID.." "..content

						table.insert( tbl, name )
					end
				end
			else

			end
		else
			for ent, content in pairs( UCombatBox.ents ) do
				local name = ent.Data._N
				local ID = ent:EntIndex() 

				if ent.Data._SETUP and (string.find( string.lower( name ), argstr ) or string.find( string.lower( ID ), argstr )) then
					name = cmd.." "..ID

					table.insert( tbl, name )
				end
			end
		end

		return tbl
	end,
"tetset", clflags )


concommand.Add( "vmod_leave",	--...
	function(ply, cmd, args, argstr)
		--PrintTable(args)

		local ID = tonumber(args[1])

		if ply and ply.UCombatBox then
			local stdid = ply:SteamID()
			local ent = ply.UCombatBox

			UCombatBox.NetWorkBaseMode("-j",ent)
			 print("Attempting to leave:",ent.Data._N,ent)
		else
			 print("Not joined.")
		end
	end,
	function(cmd, argstr)  --autocomplete function
		return {"nothing to complete here"}
	end,
"tetset", clflags )




/*
hook.Add("OnEntityCreated","UCombatBox_OnEntityCreated",function(ent)
	LP = LocalPlayer()
	timer.Simple(0.1,function()
		 --print("override",ent)
		if not ent.UCombatBox_DrawOverride then
			ent.UCombatBox_DrawOverride = true
			if ent.Draw then
				local odraw = ent.Draw
				function ent:Draw()
					if self.UCombatBox == LP.UCombatBox then	--same arena or also not in any arena
						odraw(self)
					elseif LP.UCombatBox and LP.UCombatBox.Data and LP.UCombatBox.Data._V then	--arena allows drawing
						odraw(self)
					elseif self:IsPlayer() and LP.UCombatBox and LP.UCombatBox.Data and LP.UCombatBox.Data._VP then	--arena allows player drawing
						odraw(self)
					end
				end
			end
		end
	end)
end)*/

if not ConVarExists("vmod_contextmenu") then CreateConVar( "vmod_contextmenu", 1, FCVAR_ARCHIVE , "" ) end
local convar = GetConVar("vmod_contextmenu")

local vis = convar:GetBool()

local function CreateServerBrowser()
	if VMOD_SERVERBROWSER then VMOD_SERVERBROWSER:Remove() end
	VMOD_SERVERBROWSER = g_ContextMenu:Add("DCollapsibleCategory")
	VMOD_SERVERBROWSER:Dock( TOP )
	VMOD_SERVERBROWSER:DockMargin(50,20,ScrW()/5,0)
	VMOD_SERVERBROWSER:SetSize(400,100)
	--VMOD_SERVERBROWSER.OSetVis = VMOD_SERVERBROWSER.SetVisible

	VMOD_SERVERBROWSER:SetVisible(vis)
	-- --print(vis,"vis",VMOD_SERVERBROWSER)
	local pnl = VMOD_SERVERBROWSER:Add("DPanel")
	pnl:Dock( TOP )
	pnl:SetSize(10,600)

	local exp_cache = {}

	local function inject_vmodicon_lol()
		local IconList
		for k,v in ipairs(g_ContextMenu:GetChildren()) do
			if v:GetName() == "DIconLayout" then
				IconList = v
				 --print(v)
			end
		end

		local function addserveritem(pnl,v,decay)
			local id = v:EntIndex()
			local cat = pnl:Add( "DCollapsibleCategory")

			function cat:Paint(w,h)
				surface.SetDrawColor(255,255,255,150)
				surface.DrawRect(0,0,w,h)
				surface.SetDrawColor(50,150,255,255)
				surface.DrawRect(0,0,w,20)
				return false
			end

			function cat:OnToggle(exp)
				exp_cache[v] = exp and true or nil
				 --print(exp_cache[v])
			end
			cat:Dock(TOP)
			cat:SetLabel("["..id.."] "..v.Data._N )
			local own = cat:Add( "Owner "..v.Data._O[1] )
			own:SetDisabled(true)
			function own:Think()
				if not IsValid(v) or not v.Data then self:Remove() decay() return end
				if v.Data._O[2] then
					self:SetText("Owner "..v.Data._O[2]:Name())
				else
					self:SetText("Owner "..v.Data._O[1])
				end
				--self:SetText()
			end

			--if v:CanJoin(LocalPlayer():SteamID(),LocalPlayer()) then
			local buts = {}
			local function updateteams()
				for b,_ in pairs(buts) do
					buts[b] = nil
					b:Remove()
				end
				print(next(v.Data._T))
				print(next(v.Data._T))
				print(next(v.Data._T))
				print(next(v.Data._T))
				print(next(v.Data._T))
				if not next(v.Data._T) then

					local but = cat:Add( "Join" )
					buts[but] = true
					function but:DoClick()
						if LocalPlayer().UCombatBox == v then
							RunConsoleCommand("vmod_leave")
						elseif v.Data._SETUP then
							RunConsoleCommand("vmod_join",tostring(id))
						end
					end

					function but:Think()
						if not IsValid(v) or not v.Data then self:Remove() decay() return end
						if LocalPlayer().UCombatBox == v then
							self:SetText("Leave")
							self:SetDisabled(false)
						else
							self:SetText("Join")
							self:SetDisabled(not v.Data._SETUP and not v:CanJoin(LocalPlayer():SteamID(),LocalPlayer()))
						end
					end
				else
					for tname,ttbl in pairs(v.Data._T) do
						local but = cat:Add( "Join "..tname )
						buts[but] = true
						function but:DoClick()
							if LocalPlayer().UCombatBox == v then
								RunConsoleCommand("vmod_leave")
							elseif v.Data._SETUP then
								RunConsoleCommand("vmod_join",tostring(id),tname)
							end
						end

						function but:Think()
							if not IsValid(v) or not v.Data then self:Remove() decay() return end
							if LocalPlayer().UCombatBox == v then
								self:SetText("Leave")
								self:SetDisabled(false)
							else
								self:SetText("Join")
								self:SetDisabled(not v.Data._SETUP and not v:CanJoin(LocalPlayer():SteamID(),LocalPlayer()))
							end
						end

						function but:Paint(w,h)
							surface.SetDrawColor(ttbl.color)
							surface.DrawRect(0,0,w,h)

							surface.SetDrawColor(50,50,50,230)
							surface.DrawOutlinedRect(0,0,w,h)

							surface.SetTextColor(255,255,255,255)
							surface.SetFont("ChatFont")
							local sx,sy = surface.GetTextSize(tname)
							surface.SetTextPos((w-sx)/2,(h-sy)/2)
							surface.DrawText(tname)
						end
					end
				end
			end

			updateteams()
			
			if LocalPlayer() then
				local but = cat:Add( "Edit" )
				function but:DoClick()
					-- --print("but",id)
					RunConsoleCommand("vmod_edit",tostring(id))
				end
			end

			--[[for k,v in ipairs(cat:GetChildren()) do
				v:NoClipping(true)
			end]]
			--cat:SizeToContentsY()

			cat:SetExpanded(exp_cache[v] or (LocalPlayer().UCombatBox == v))
		end

		if IconList then
			local but = IconList:Add("DPropertySheet")
			--local but = vgui.Create("DImageButton")
			but:SetSize(200,220)
			--but:SetIcon("icon64/tool.png")
			if IconList:GetChildren()[1] then but:MoveToBefore( IconList:GetChildren()[1] ) end

			--local panel1,panel2
			local panel1 = vgui.Create( "DScrollPanel", but )
			but:AddSheet( "Your", panel1, "icon16/application_home.png" )
			--panel1:AddColumn("Your Servers")
			--panel1:SetMultiSelect( false )

			local panel2 = vgui.Create( "DScrollPanel", but )
			but:AddSheet( "Public", panel2, "icon16/group.png" )

			function but:UpdateLists()
				if panel1 then panel1:Clear() end
				if panel2 then panel2:Clear() end


				for v,k in pairs(UCombatBox.ents) do
					if v:GetOwnerEnt() == LocalPlayer() then
						addserveritem(panel1,v,but.UpdateLists)
					end
				end

				for v,k in pairs(UCombatBox.ents) do
					-- --print(k,v)
					if v:GetOwnerEnt() ~= LocalPlayer() then
						addserveritem(panel2,v,but.UpdateLists)
					end
				end
			end

			but:UpdateLists()
			hook.Add("UCB_Init","ucb_updateservers",function()
				but:UpdateLists()
			end)

		end
	end

	--[[list.Set( "DesktopWindows", "VMod", {
		title = "VMod",
		icon = "icon64/tool.png",
		init = function( icon, window )
			if vis then
				vis = false
			else
				vis = true
			end
			convar:SetBool(vis)
			VMOD_SERVERBROWSER:SetExpanded(vis)
		end
	} )]]
	CreateContextMenu()
	inject_vmodicon_lol()
end

hook.Add("InitPostEntity","UCB_CreateServerBrowser",CreateServerBrowser)
CreateServerBrowser()
