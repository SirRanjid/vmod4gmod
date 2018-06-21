UCombatBox.hud = UCombatBox.hud or {_E = {}, _L = {}, _POS = {}, _3D = {}, _ANG = {}, act = true}
local hud = UCombatBox.hud
local function drawFunc(x,y,w,h,mx,my,txt)
	surface.SetDrawColor(50,50,50,120)
	surface.DrawRect(x,y,w,h)
end


local function loadsettings()
	local strdata = file.Read( "ucombatbox/ucb_hud_settings.txt" ) 
	if not strdata or strdata == "" then return end
	local tbldata = UCombatBox.pon.decode(strdata)
	if not tbldata or not next(tbldata) then return end
	table.Merge(UCombatBox.hud,tbldata)
end

local function savesettings()
	local strdata = UCombatBox.pon.encode(UCombatBox.hud)
	if not strdata or strdata == "" then return end
	file.Write("ucombatbox/ucb_hud_settings.txt",strdata)
end

local PLUGM = {x = 0, y = 0, w = 0, h = 0, ang = Angle(0,0,0), is3d = false,act = false,hover = false,press = false, dim = true}
PLUGM.__index = PLUGM
PLUGM.__tostring = function(...) return "[UBC_HUD]" end
PLUGM.btns = {}
PLUGM.hooks = {}
local surface = surface

do
	local function drawButton(btn,x,y,w,h,txt)
		surface.SetDrawColor(50,50,50,120)
		surface.DrawRect(x,y,w,h)
	end

	function PLUGM:AddButton(name,txt,x,y,w,h,drawfnc)
		self.btns[name] = {
			["x"] = x, 
			["y"] = y, 
			["w"] = w, 
			["h"] = h, 
			["txt"] = txt, 
			["df"] = drawButton and drawButton or drawfnc, 
			["hover"] = false, 
			["press"] = false, 
		}
	end
end

function PLUGM:hook(hoo,name,func)
	name = "UCB_HC_" .. name
	 --print("###","hook",hoo,name)
	self.hooks[hoo] = self.hooks[hoo] or {}
	self.hooks[hoo][name] = true

	hook.Add(hoo,name,func)
end

function PLUGM:Clear()
	for k,v in pairs(self.hooks) do
		for i,j in pairs(v) do
			hook.Remove(k,i)
			self.hooks[k][i] = nil
		end
		self.hooks[k] = nil
	end
	self.act = false
end

function PLUGM:Draw(a,b,c,d,e,f) drawFunc(a,b,c,d,e,f) end

function PLUGM:DrawOverlay()
	
end

function PLUGM:DoClick()

end

function PLUGM:Init()

end

function PLUGM:Think()

end

function PLUGM:GetScreenPos()
	return self.x, self.y
	/*if not self.ang then return self.x, self.y end

	local ppos = EyeVector()*((math.sqrt(ScrW()^2+ScrH()^2)*math.sin(LocalPlayer():GetFOV()/360*math.pi))/(1.891))
	ppos:Rotate(Angle(90,90,0)-self.ang)
	--F= Z-Zc=F
	--X' = ((X - Xc) * ((Z-Zc)/Z)) + Xc
	--Y' = ((Y - Yc) * ((Z-Zc)/Z)) + Yc
	local ts = (EyePos()+ppos):ToScreen()
	return self.x+ts.x-ScrW()/2 , self.x+ts.y-ScrH()/2, ts.Visible*/
end

function PLUGM:Make3D(b,ang)
	if b then
		self.ang = ang and ang or Angle(0,0,0)
		self.is3d = true
	else
		self.ang = nil
		self.is3d = nil
	end
end

function PLUGM:MakeDim(b)
	self.dim = b
end
do
	local dim = 1
	function PLUGM:GetDim()
		local coli = math.Clamp(render.ComputeLighting( EyePos(), Vector(0,0,1) ):Length()*30,0.2,1)
		dim = Lerp(FrameTime()*4,dim,coli)
		return dim
	end
end
do
	local pos, ang,scw,sch,scw2,sch2,dist,flr = EyePos(), EyeAngles(), ScrW(),ScrH(), ScrW()/2,ScrH()/2,math.sqrt(ScrW()*ScrH())/2,math.floor

	hook.Add("UCB_HUD_UpdtRes","BarUpdateRes",function(sw,sh)
		scw,sch,scw2,sch2,dist = sw,sh,sw/2,sh/2,math.sqrt(sw*sh)/2
	end)

	function PLUGM:DrawLabel(tbl,x,y,w,h,val,max,ang,mat,ca,col_bg)
		local w2,h2 = w/2,h/2

		if self.is3d then
			x,y = scw2-w2, sch2-h2
		else
			x,y = x-w2, y-h2
		end

		local mpx,mpy = 2+(w-4)*co+x,y+h2
		surface.DrawRect(2+x,2+y,flr((w-4)*co),h-4)
		surface.SetFont("ChatFont")
		
		surface.SetFont("ChatFont")
		txt = val .. txt
		tsx, tsy = surface.GetTextSize(val)
		surface.SetTextPos(x+w-tsx-4,mpy-tsy/2)
		surface.DrawText(txt)
	end


	local function load_hudelements(fld)
		local files, dirs = file.Find(fld.."/*",'LUA','nameasc')
		for k,v in ipairs(files) do
			local PLUG_EXTENSION = include(fld.."/"..v)
			if istable(PLUG_EXTENSION) then
				--debug.setfenv( PLUG_EXTENSION, debug.getfenv( PLUGM )  ) 
				table.Merge(PLUGM,PLUG_EXTENSION)
				 --print("Reloaded Custum GUI Element: "..fld.."/"..v)
			end
		end
		for k,v in ipairs(dirs) do
			load_hudelements(fld.."/"..v)
		end
	end
	load_hudelements('ucombatbox/ui/cgui')

end

do
	local pos, ang,scw,sch,scw2,sch2,flr = EyePos(), EyeAngles(), ScrW(),ScrH(), ScrW()/2,ScrH()/2,math.floor
	local dist = (math.sqrt(ScrW()^2+ScrH()^2)*math.sin(LocalPlayer():GetFOV()/360*math.pi))/(1.891) --*1.093
	--local dist = ScrW()*(ScrH()/ScrW())*math.sin(LocalPlayer():GetFOV()/360*math.pi)/math.sin(0.5*math.pi)
	--local dist = (1160-80)*math.sin(LocalPlayer():GetFOV()/360*math.pi)/math.sin(0.5*math.pi)
	hook.Add("UCB_HUD_UpdtRes","BarUpdateRes2",function(sw,sh)
		scw,sch,scw2,sch2,dist = sw,sh,sw/2,sh/2,(math.sqrt(ScrW()^2+ScrH()^2)*math.sin(LocalPlayer():GetFOV()/360*math.pi))/(1.891)
	end)
	local cm_r, cm_g, cm_b = render.GetColorModulation()
	local dim = 1
	odrawcol = odrawcol or surface.SetDrawColor
	local function setdrawcl(a,b,c,d)
		if IsColor(a) then
			odrawcol(a.r*dim,a.g*dim,a.b*dim,a.a)
		else
			odrawcol(a*dim,b*dim,c*dim,d)
		end
	end

	hook.Add("HUDPaint","UCB_HUD_HUDPaint",function()
		if not hud.act then return end
		dim = PLUGM:GetDim()
		local mx,my = gui.MouseX(), gui.MouseY()
		for i,he in ipairs(hud._E) do
			if he.act then
				local cv_x = GetConVar(he.cvn.."_x")
				local cv_y = GetConVar(he.cvn.."_y")
				local cv_ap = GetConVar(he.cvn.."_ap")
				local cv_ay = GetConVar(he.cvn.."_ay")
				local cv_ar = GetConVar(he.cvn.."_ar")

				he.x = cv_x:GetFloat()
				he.y = cv_y:GetFloat()
				he.ang.ap = cv_ap:GetFloat()
				he.ang.ay = cv_ay:GetFloat()
				he.ang.ar = cv_ar:GetFloat()

				if he.is3d then
					--cam.Start3D(Vector(0,0,0),he.ang)
					--cam.Start3D2D( -Vector(ScrW()-he.x,-ScrH()+he.y,dist) , Angle(), 1 )

					local vec = Vector(-dist,he.x-scw2,he.y-sch2)
					--vec:Rotate(he.ang)
					cam.Start3D(vec,Angle(0,0,0))
					local v2 = Vector(-ScrW()/2,ScrH()/2,0) --,ScrW()-he.x/2,-ScrH()+he.y/2)
					local a2 = Angle( he.ang.r,  he.ang.y-90,  he.ang.p+90 )--Angle(90,0,0)
					v2:Rotate(a2)
					cam.Start3D2D( v2 , a2, 1 )
				end

				if he.dim then
					cm_r, cmm_g, cm_b = render.GetColorModulation()
					/*--local tr = util.QuickTrace( LocalPlayer():GetShootPos(), gui.ScreenToVector( gui.MousePos() )*0, LocalPlayer() )
					
					--if tr.Hit then
						--dim = math.min(render.ComputeLighting( tr.HitPos, tr.HitNormal ):Length()*80,1)
						--chat.AddText('"'..tostring(dim)..'"')
						--render.SetColorModulation( cm_r*dim.x, cmm_g*dim.x, cm_b*dim.x ) 
					--else
						dim = math.min(render.ComputeLighting( EyePos(), EyeAngles():Forward() ):Length()*80,1)
						--chat.AddText('"'..tostring(dim)..'"')
						--render.SetColorModulation( cm_r*dim.x, cmm_g*dim.x, cm_b*dim.x ) 
					--end*/

					surface.SetDrawColor = setdrawcl
				end

				local ex,ey,ew,eh =  he.x,he.y,he.w,he.h
				
				--he:Draw(he.x,he.y,he.w,he.h)
				he:Draw(ex,ey,ew,eh)

				
				if he.is3d then
					cam.End3D2D()
					cam.End3D()
				end

				for k,v in ipairs(he.btns) do
					v.df(he.x+v.x,he.y+v.y,he.w+v.w,he.h+v.h,v.txt)
				end
				he:DrawOverlay()
				if he.dim then
					--render.SetColorModulation( cm_r, cmm_g, cm_b ) --cleaning up properly
					surface.SetDrawColor = odrawcol
				end
			end
		end
	end)
end
do
	local lpress = false
	local function check(x,y,w,h,mx,my)
		if mx >= x and my >= y and mx <= x+w and my <= y+h then
			return true
		end
		return false
	end
	local hovered_k, input, gui, vgui = 0, input, gui, vgui

	global_hoverwrld = global_hoverwrld or vgui.IsHoveringWorld

	local nohover = true 

	local function custom__hoverwrld()
		return nohover and global_hoverwrld() or nohover
	end

	vgui.IsHoveringWorld = custom__hoverwrld

	local hovercache = {}

	local ScrW, ScrH = ScrW, ScrH
	local lscw, lsch = ScrW(), ScrH()

	hook.Add("Tick","UCB_HUD_Think",function()

		if lscw ~= ScrW() or lsch ~= ScrH() then
			lscw, lsch = ScrW(), ScrH()
			hook.Call("UCB_HUD_UpdtRes",GAMEMODE,lscw,lsch)
		end

		if next(hovercache) then
			local mx,my = gui.MouseX(), gui.MouseY()

			for _,v in pairs(hovercache) do
				local ex,ey,ew,eh = v.x,v.y,v.w,v.h
				if v.hover and not check(v.x+ex,v.y+ey,v.w,v.h,mx,my) then
					v.hover = false
					v.press = false
				end
			end
		end

		if not hud.act then return end
		for i,he in ipairs(hud._E) do
			local cv_x = GetConVar(he.cvn.."_x")
			local cv_y = GetConVar(he.cvn.."_y")
			local cv_ap = GetConVar(he.cvn.."_ap")
			local cv_ay = GetConVar(he.cvn.."_ay")
			local cv_ar = GetConVar(he.cvn.."_ar")

			--[[he.x = cv_x:GetFloat()
			he.y = cv_y:GetFloat()
			he.ang.ap = cv_ap:GetFloat()
			he.ang.ay = cv_ay:GetFloat()
			he.ang.ar = cv_ar:GetFloat()]]

			if he.act then
				if vgui.CursorVisible() then
					local mx,my,ex,ey,ew,eh = gui.MouseX(), gui.MouseY(), he.x,he.y,he.w,he.h

					he.hover = check(ex,ey,ew,eh,mx,my)
					if he.hover then hovercache[he] = he end

					he.press = false

					hovered_k = 0
					nohover = true
					for k,v in ipairs(he.btns) do
						if check(v.x+ex,v.y+ey,v.w,v.h,mx,my) then 
							hovered_k = k --priority is ipairs(hud._E)
							v.hover = true
							hovercache[v] = v
							nohover = false
						else
							v.hover = false
							if v.lpress then 
								he.btns[hovered_k].press = false
								he.btns[hovered_k].lpress = nil
								he:DoClick()
							end
						end
						v.df(v.x,v.y,v.w,w.h,mx,my)
					end

					if hovered_k > 0 then 
						if input.IsKeyDown(MOUSE_LEFT) then he.btns[hovered_k].press = true he.btns[hovered_k].lpress = true end --for leftclick
						--#maybe add rightclick
					elseif input.IsKeyDown(MOUSE_LEFT) and he.hover then
						he.press = true
					end
				end
				he:Think()
			end
		end
	end)
end

function UCombatBox.AddHudElement(PLUG)
	--print("###","HUDPlugin",PLUG.Name)
	--print("PLUG.Name",PLUG.Name)
	local cvn = "vmod_hud_"..PLUG.Name:lower():gsub("%s","_")
	

	setmetatable(PLUG,PLUGM)
	PLUG.__index = PLUG
	PLUG.__tostring = function(...) return "[UBC_HUD: "..PLUG.Name.."]" end
	PLUG:Init()

	PLUG.cvn = cvn

	if not ConVarExists(cvn.."_x") then CreateConVar( cvn.."_x", PLUG.x, FCVAR_ARCHIVE, "" ) end
	if not ConVarExists(cvn.."_y") then CreateConVar( cvn.."_y", PLUG.y, FCVAR_ARCHIVE, "" ) end
	if not ConVarExists(cvn.."_ap") then CreateConVar( cvn.."_ap", PLUG.ang.p, FCVAR_ARCHIVE, "" ) end
	if not ConVarExists(cvn.."_ay") then CreateConVar( cvn.."_ay", PLUG.ang.y, FCVAR_ARCHIVE, "" ) end
	if not ConVarExists(cvn.."_ar") then CreateConVar( cvn.."_ar", PLUG.ang.r, FCVAR_ARCHIVE, "" ) end

	local cv_x = GetConVar(cvn.."_x")
	local cv_y = GetConVar(cvn.."_y")
	local cv_ap = GetConVar(cvn.."_ap")
	local cv_ay = GetConVar(cvn.."_ay")
	local cv_ar = GetConVar(cvn.."_ar")

	PLUG.x = cv_x:GetFloat() or PLUG.x
	PLUG.y = cv_y:GetFloat() or PLUG.y
	PLUG.ang.p = cv_ap:GetFloat() or PLUG.ang.p
	PLUG.ang.y = cv_ay:GetFloat() or PLUG.ang.y
	PLUG.ang.r = cv_ar:GetFloat() or PLUG.ang.r

	PLUG.act = true
	for k,v in ipairs(hud._E) do
		if v.Name == PLUG.Name then
			hud._E[k] = PLUG --update
			hud._L[PLUG.Name] = PLUG --update

			if not hud._POS[PLUG.Name] then hud._POS[PLUG.Name] = {PLUG.x,PLUG.y} end
			if not hud._3D[PLUG.Name] then hud._3D[PLUG.Name] = PLUG.is3d end
			if PLUG.ang and not hud._ANG[PLUG.Name] then hud._ANG[PLUG.Name] = Angle(PLUG.ang.p,PLUG.ang.y,PLUG.ang.r) end
			return
		end
	end
	hud._L[PLUG.Name] = PLUG
	table.insert(hud._E,PLUG)
end 

if table.Count(hud._E) > 0 then
	for k,PLUG in pairs(hud._E) do
		hud._E[k]:Clear()
		hud._E[k] = nil
		hud._L[PLUG.Name] = nil
	end
end

do
	local open_editors = {}

	local function queuesave()
		if not timer.Exists("ucb_hud_savesettings") then
			timer.Create( "ucb_hud_savesettings", 5, 1, savesettings ) 
		end
		 --print("UCB_HUD_SETTINGS","saved.")
	end

	hook.Add("OnContextMenuOpen","UCB_HUD_GetEditors",function()
		if next(open_editors) then
			for v,_ in pairs(open_editors) do
				if v and v:IsValid() then v:Remove() end
			end
		end
		 --print("+","open")
		if not hud.act then return end
		for i,he in  ipairs(hud._E) do
			--if he.act then

				local pnl = vgui.Create("DImageButton",g_ContextMenu)
				open_editors[pnl] = true
				pnl:SetImage("icon16/anchor.png")
				pnl:SetText(he.Name or "")
				pnl:SetPos(he.x,he.y)
				pnl:SetSize(24,24)
				---pnl:MakePopup()

				local lastdrag = false
				local ox,oy = 0,0
				local ox2,oy2,or2 = 0,0,0
				local px,py = he.x,he.y
				local mx,my = 0,0
				--local othink = pnl.Think

				local cv_x = GetConVar(he.cvn.."_x")
				local cv_y = GetConVar(he.cvn.."_y")
				local cv_ap = GetConVar(he.cvn.."_ap")
				local cv_ay = GetConVar(he.cvn.."_ay")
				local cv_ar = GetConVar(he.cvn.."_ar")

				pnl.Think = function ( self, code ) 
					--othink(frame)
					--if code == MOUSE_LEFT then

					he.x = cv_x:GetFloat()
					he.y = cv_y:GetFloat()
					he.ang.ap = cv_ap:GetFloat()
					he.ang.ay = cv_ay:GetFloat()
					he.ang.ar = cv_ar:GetFloat()

						if lastdrag != self:IsDown() then
							lastdrag = self:IsDown()
							ox,oy = he.x, he.y
							ox2,oy2,or2 = he.ang.x, he.ang.y, he.ang.r
							px,py = pnl:GetPos()
							mx,my = gui.MousePos()
						end

						if lastdrag then
							if input.IsMouseDown(MOUSE_LEFT) then
								he.x,he.y = ox+gui.MouseX()-mx,oy+gui.MouseY()-my
								--pnl:SetPos(he.x,he.y)
								--print(he.cvn,"cv_x",cv_x:GetFloat())
								cv_x:SetFloat(he.x)
								--print(he.cvn,"#cv_x",cv_x:GetFloat())
								cv_y:SetFloat(he.y)

								self:SetPos(he.x,he.y)
							elseif input.IsMouseDown(MOUSE_RIGHT) then
								he.ang.y,he.ang.p = (oy2+(gui.MouseX()-mx))%360,(ox2+(gui.MouseY()-my))%360
								cv_ap:SetFloat(he.ang.p)
								cv_ay:SetFloat(he.ang.y)
							elseif input.IsMouseDown(MOUSE_MIDDLE) then
								he.ang.r = (or2+(gui.MouseX()-mx))%360 --(gui.MouseY()-my)
								cv_ar:SetFloat(he.ang.r)
							end
						end

					--end
				end

				pnl.PaintOver = function(self,w,h)
					local txt = ""
					surface.SetFont("default")
					surface.DisableClipping( true ) 
					if lastdrag then
						if input.IsMouseDown(MOUSE_LEFT) then
							txt = "X: "..(he.x).."| Y: "..(he.y)
						elseif input.IsMouseDown(MOUSE_RIGHT) then
							txt = "Pitch: "..(he.ang.p).."| Yaw: "..(he.ang.y)
						elseif input.IsMouseDown(MOUSE_MIDDLE) then
							txt = "Roll: "..(he.ang.r)
						end
						surface.SetTextColor(0,0,0,240)
						surface.SetTextPos(17,9)
						surface.DrawText(txt)
						surface.SetTextColor(255,255,255,220)
						surface.SetTextPos(16,8)
						surface.DrawText(txt)
						surface.DisableClipping( false ) 
					else
						txt = ("dP["..tostring(he.x).."| "..tostring(he.y).."]\n".."A["..tostring(he.ang.p).."| "..tostring(he.ang.y).."| "..tostring(he.ang.r).."]")
						surface.SetTextColor(0,0,0,240)
						surface.SetTextPos(17,9)
						surface.DrawText(txt)
						surface.SetTextColor(200,200,200,220)
						surface.SetTextPos(16,8)
						surface.DrawText(txt)
						surface.DisableClipping( false ) 
					end
				end

				/*pnl.btnMaxim.DoClick = function ( button ) 
					he.act = not he.act
					if he.act then
						he:Init()
					else
						he:Clear()
					end
					queuesave()
				end
				pnl.btnMaxim:SetDisabled( false )*/

				-- --print("+",tostring(open_editors[pnl]),pnl)
			--end
		end
	end)

	hook.Add("OnContextMenuClose","UCB_HUD_CloseEditors",function()
		if next(open_editors) then
			for v,_ in pairs(open_editors) do
				if IsValid(v) then v:Remove() end
			end
		end
	end)
end


local function load_hudelements(fld)
	local files, dirs = file.Find(fld.."/*",'LUA','nameasc')
	for k,v in ipairs(files) do
		include(fld.."/"..v)
		 --print("Reloaded HUD Element: "..fld.."/"..v)
	end
	for k,v in ipairs(dirs) do
		load_hudelements(fld.."/"..v)
	end
end
load_hudelements('ucombatbox/ui/hud')

loadsettings()