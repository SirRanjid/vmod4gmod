-- add/edit/(re-)move/scale/rotate entities/spawns/vertices
UCombatBox.edit_spwn = CreateClientConVar( "ucb_setup_show_spawns", "1" ) 
UCombatBox.edit_ents = CreateClientConVar( "ucb_setup_show_ents", "1" ) 
UCombatBox.edit_mesh = CreateClientConVar( "ucb_setup_show_mesh", "0" ) 

local DragContext = UCombatBox.DragContext

local edit_spwn = UCombatBox.edit_spwn
local edit_ents = UCombatBox.edit_ents
local edit_mesh = UCombatBox.edit_mesh

local PLUG = {}
PLUG.Parent = "global"
PLUG.Name = "Entities"

PLUG.ent = UCombatBox.SetupMenu and UCombatBox.SetupMenu.ent or nil

UCombatBox.cents = UCombatBox.cents or {}

local cents = UCombatBox.cents
local mdlcch = {}

concommand.Add("vmod_print",function() PrintTable(mdlcch) end)

local flr = math.floor
local function floor1000(num)
	return flr(num*1000)/1000
end

function PLUG:createmodel(mdl,pos,ang,ref,sca)
	local cmdl = ClientsideModel( mdl, RENDERGROUP_BOTH )
	cmdl.UCombatBox = self.ent:GetOwnerEnt().UCombatBox

	--cmdl:SetModelScale(sca and sca.x or 1) --#nope

	/*local mat = Matrix()
	mat:Scale( sca or Vector(1,1,1) )
	cmdl:EnableMatrix( "RenderMultiply", mat )*/
	
	cmdl.osp = cmdl.SetPos
	function cmdl:SetPos(pos)
		self:osp(pos+self.ent.Data.POS)
	end
	
	local tab = {cmdl,ref,self.ent}
	mdlcch[ref] = tab
	
	cmdl:SetPos(pos)
	cmdl:SetAngles(ang)
	table.insert(cents,tab)
end

function PLUG:createspawn(pos,ang,ref)
	self:createmodel("models/editor/playerstart.mdl",pos,ang or Angle(0,0,0),ref)
end

function PLUG:addspawn(pos)
	local new_spawn = {pos-self.ent.Data.POS,Angle(0,0,0)}
	
	PLUG:createspawn(pos,nil,new_spawn)
	table.insert(self.ent.Data._S,new_spawn)
end

function PLUG:addent(pos,class,model)
	local new_ent = {pos-self.ent.Data.POS,Angle(0,0,0),class,model,Vector(1,1,1),true}
	
	self:createmodel(model,pos,Angle(0,0,0),new_ent,Vector(1,1,1))
	table.insert(self.ent.Data._E,new_ent)
end

do
	local rPLUG = {}
	rPLUG.Name = "addents"
	local ocmd = RunConsoleCommand
	
	--{pos,ang,class,model,scale}
	local spawners = {
		["entity"] = function(pos,c1) PLUG:addent(pos,c1,"") end,
		["model"] = function(pos,c1) PLUG:addent(pos,"prop_physics",c1) end,
	}
	
	spawners["vehicle"] = spawners["entity"]
	spawners["npc"] = spawners["entity"]
	spawners["weapon"] = spawners["entity"]
	

	local override = {
		["gm_spawn"] 		=	function()  end,
		["gm_spawnsent"] 	=	function()  end,
		["gm_spawnswep"] 	=	function()  end,
		["gm_spawnvehicle"] =	function()  end

	}
	
	local func = {
		["SpawnIcon"] = function(pos,pnl)
			--if not pnl.GetModelName then return end
			return spawners["model"](pos,pnl:GetModelName())
		end,
		["ContentIcon"] = function(pos,pnl)
			if pnl.GetContentType and pnl.GetSpawnName then return spawners[pnl:GetContentType()](pos,pnl:GetSpawnName()) end
		end,
	}
	
	spawners["gm_giveswep"] = spawners["gm_spawnswep"]

	function rPLUG:Setup(menu,tr)
		if #UCombatBox.Selection == 0 then
		
			local submenu = menu:AddSubMenu( "Add" )
			submenu:AddOption("Spawn",function()
				PLUG:addspawn(tr.HitPos)
			end):SetIcon("icon16/user_add.png")

			submenu:AddOption("Entity",function()
				ocmd("+menu")

				function RunConsoleCommand(cmd,...) 
					cmd = string.lower(cmd)

					if override[cmd] then
						 --print(cmd,"override")
						override[cmd](...)
					else
						ocmd(cmd,...)
					end
				end
				
				UCombatBox.SetupMenu:hook("VGUIMousePressed","UCB_Setup_AddEntity",function(pnl,btn)
					--local pnl = vgui.GetHoveredPanel():GetParent():GetParent():GetParent()
					
					if func[pnl:GetName()] ~= nil then
						 --print("buttonfunc","lol",pnl:GetName(),pnl)
						func[pnl:GetName()](tr.HitPos,pnl)
						
						ocmd("-menu")
						
						--RunConsoleCommand = ocmd
						return true
					end
				end)
				
				UCombatBox.SetupMenu:hook("OnSpawnMenuClose","UCB_Setup_CloseQM",function(pnl,btn)
					hook.Remove("OnSpawnMenuClose","UCB_Setup_AddEntity")
					hook.Remove("VGUIMousePressed","UCB_Setup_AddEntity")
					hook.Remove("UCB_SetupMenu_Close","UCB_Setup_CloseM")
					RunConsoleCommand = ocmd
					 --print("close")
				end)
				
				UCombatBox.SetupMenu:hook("UCB_SetupMenu_Close","UCB_Setup_CloseM",function(pnl,btn)
					hook.Remove("OnSpawnMenuClose","UCB_Setup_AddEntity")
					hook.Remove("VGUIMousePressed","UCB_Setup_AddEntity")
					hook.Remove("UCB_SetupMenu_Close","UCB_Setup_CloseM")
					RunConsoleCommand = ocmd
					 --print("close")
				end)
				
			end):SetIcon("icon16/brick_add.png")
			
		elseif #UCombatBox.Selection == 1 then
		
		end
	end
	
	UCombatBox.AddRMenuPlugin(rPLUG)
end

do
	local rPLUG = {}
	rPLUG.Name = "assignspawns"
	local ocmd = RunConsoleCommand
	
	function rPLUG:Setup(menu,tr)
		local box = UCombatBox.SetupMenu.ent
		if #UCombatBox.Selection > 0 then
			local spw_c = {}
			for k,v in pairs(UCombatBox.Selection) do
				for i,s in ipairs(box.Data._S) do
					if s == v[2] then spw_c[#spw_c+1] = {i,s} end
				end
			end
			if #spw_c <= 0 then return end
			local submenu = menu:AddSubMenu( "Assign Spawns" )
			for tn,tv in pairs(box.Data._T) do
				
				submenu:AddOption(tn,function()
					for i,v in pairs(spw_c) do
						tv._S[v[2]] = v[1]
					end
				end):SetIcon("icon16/user_add.png")
			end
		end
	end
	
	UCombatBox.AddRMenuPlugin(rPLUG)
end

function PLUG:UpdatePos(pos,ang,dlt_pos)
	for v,t in pairs(UCombatBox.Selection) do
		local new_pos = v[4]+dlt_pos

		new_pos.x = floor1000(new_pos.x)
		new_pos.y = floor1000(new_pos.y)
		new_pos.z = floor1000(new_pos.z)

		--new_pos:Rotate(ang)
		--new_pos = new_pos+pos-ent.Data.POS
		v[2][1] = new_pos
		--v[2][2].yaw = v[2][2].yaw + (ang.yaw or ang)
		v[1]:SetPos(new_pos+self.ent.Data.POS)
		--v[1]:SetAngles(v[2][2])
	end
end

local dragp = Vector()

/*---------------------------------------------------------------------------------------------------------------------------------------*\
	
DragContext

\*---------------------------------------------------------------------------------------------------------------------------------------*/

local ctx,cty, ctz = UCombatBox.DragContext.create3D("EntDrag",dragp,Angle(0,0,0),200,200,200,0,10)
ctx:SetEnabled(false)

function PLUG:getDragContext()
	local c = table.Count(UCombatBox.Selection)
	if c > 0 then
		dragp.x = 0
		dragp.y = 0
		dragp.z = 0
		for v,t in pairs(UCombatBox.Selection) do
			dragp = dragp + v[2][1]
		end
		
		dragp = dragp / c + self.ent.Data.POS
		
		ctx:SetPos(dragp)
		
		ctx:SetEnabled(true)
	else
		ctx:SetEnabled(false)
	end
end

function ctx:StartDragging(v_start_loc, pos_abs)
	self:SetOffset(dragp)
	
	for v,t in pairs(UCombatBox.Selection) do
		v[4] = Vector(v[2][1].x,v[2][1].y,v[2][1].z)
	end
end

--Move
function ctx:OnDragging(v_dist, pos_abs, pos_loc)
	local off = self:GetOffset()
	dragp = Vector(v_dist.x + off.x,off.y,off.z)
	
	PLUG:UpdatePos(off,Angle(0,0,0),dragp-off)
	--AddSurfaceInfo("Move X",Vector(255,0,0),1,math.floor(pos_abs.x).." ("..v_dist.x..")")
end

function cty:OnDragging(v_dist, pos_abs, pos_loc)
	local off = self:GetOffset()
	dragp = Vector(off.x,v_dist.x + off.y,off.z)
	
	PLUG:UpdatePos(off,Angle(0,0,0),dragp-off)
	--AddSurfaceInfo("Move Y",Vector(0,255,0),1,math.floor(pos_abs.x).." ("..v_dist.x..")")
end

function ctz:OnDragging(v_dist, pos_abs, pos_loc)
	local off = self:GetOffset()
	dragp = Vector(off.x,off.y,v_dist.x + off.z)
	
	PLUG:UpdatePos(off,Angle(0,0,0),dragp-off)
	--AddSurfaceInfo("Move Z",Vector(0,0,255),1,math.floor(pos_abs.x).." ("..v_dist.x..")")
end

do
	function ctx:StopDragging()
		PLUG:getDragContext()
	end
	function cty:StopDragging()
		PLUG:getDragContext()
	end
	function ctz:StopDragging()
		PLUG:getDragContext()
	end
	ctx:StopDragging()
end
cty.StartDragging = ctx.StartDragging
ctz.StartDragging = ctx.StartDragging

/*---------------------------------------------------------------------------------------------------------------------------------------*\
	
RotateContext

\*---------------------------------------------------------------------------------------------------------------------------------------*/
	
local ctx,cty, ctz = UCombatBox.DragContext.create3D("EntDrag",dragp,Angle(0,0,0),200,200,200,0,10)
ctx:SetEnabled(false)

function PLUG:getDragContext()
	local c = table.Count(UCombatBox.Selection)
	if c > 0 then
		dragp.x = 0
		dragp.y = 0
		dragp.z = 0
		for v,t in pairs(UCombatBox.Selection) do
			dragp = dragp + v[2][1]
		end
		
		dragp = dragp / c + self.ent.Data.POS
		
		ctx:SetPos(dragp)
		
		ctx:SetEnabled(true)
	else
		ctx:SetEnabled(false)
	end
end

function ctx:StartDragging(v_start_loc, pos_abs)
	self:SetOffset(dragp)
	
	for v,t in pairs(UCombatBox.Selection) do
		v[4] = Vector(v[2][1].x,v[2][1].y,v[2][1].z)
	end
end

--Move
function ctx:OnDragging(v_dist, pos_abs, pos_loc)
	local off = self:GetOffset()
	dragp = Vector(v_dist.x + off.x,off.y,off.z)
	
	PLUG:UpdatePos(off,Angle(0,0,0),dragp-off)
	--AddSurfaceInfo("Move X",Vector(255,0,0),1,math.floor(pos_abs.x).." ("..v_dist.x..")")
end

function cty:OnDragging(v_dist, pos_abs, pos_loc)
	local off = self:GetOffset()
	dragp = Vector(off.x,v_dist.x + off.y,off.z)
	
	PLUG:UpdatePos(off,Angle(0,0,0),dragp-off)
	--AddSurfaceInfo("Move Y",Vector(0,255,0),1,math.floor(pos_abs.x).." ("..v_dist.x..")")
end

function ctz:OnDragging(v_dist, pos_abs, pos_loc)
	local off = self:GetOffset()
	dragp = Vector(off.x,off.y,v_dist.x + off.z)
	
	PLUG:UpdatePos(off,Angle(0,0,0),dragp-off)
	--AddSurfaceInfo("Move Z",Vector(0,0,255),1,math.floor(pos_abs.x).." ("..v_dist.x..")")
end

do
	function ctx:StopDragging()
		PLUG:getDragContext()
	end
	function cty:StopDragging()
		PLUG:getDragContext()
	end
	function ctz:StopDragging()
		PLUG:getDragContext()
	end
	ctx:StopDragging()
end
cty.StartDragging = ctx.StartDragging
ctz.StartDragging = ctx.StartDragging

do
	local rPLUG = {}
	rPLUG.Name = "moveents"

	function rPLUG:Setup(menu,tr)
		if next(UCombatBox.Selection) then
		
			local move = menu:AddSubMenu( "Move Selection" )
			
			move:AddOption( "X: Add Point", function() ctx:AddPoint(tr.HitPos) end ):SetIcon("icon16/vector_add.png")
			move:AddOption( "Y: Add Point", function() cty:AddPoint(tr.HitPos) end ):SetIcon("icon16/vector_add.png")
			move:AddOption( "Z: Add Point", function() ctz:AddPoint(tr.HitPos) end ):SetIcon("icon16/vector_add.png")
		end
	end
	
	UCombatBox.AddRMenuPlugin(rPLUG)
end



local function setupmenuaddons(plg,p,m)
	local cbl_e_s = p:Add("DCheckBoxLabel")
	cbl_e_s:SetTall(20)
	cbl_e_s:Dock(TOP)
	cbl_e_s:SetText("Edit Spawns")
	cbl_e_s:SetValue(edit_spwn:GetBool())
	function cbl_e_s:OnChange( val )
		edit_spwn:SetBool(val)
		plg:UpdateEnts()
	end
	function cbl_e_s:Think()
		if self:GetChecked() ~= edit_spwn:GetBool() then
			self:SetValue( edit_spwn:GetBool()  ) 
		end
	end
	
	local cbl_e_e = p:Add("DCheckBoxLabel")
	cbl_e_e:SetTall(20)
	cbl_e_e:Dock(TOP)
	cbl_e_e:SetText("Edit Entities")
	cbl_e_e:SetValue(edit_ents:GetBool())
	function cbl_e_e:OnChange( val )
		edit_ents:SetBool(val)
		plg:UpdateEnts()
	end
	function cbl_e_e:Think()
		if self:GetChecked() ~= edit_ents:GetBool() then
			self:SetValue( edit_ents:GetBool()  ) 
		end
	end
	
	local cbl_e_m = p:Add("DCheckBoxLabel")
	cbl_e_m:SetTall(20)
	cbl_e_m:Dock(TOP)
	cbl_e_m:SetText("Edit Mesh")
	cbl_e_m:SetValue(edit_mesh:GetBool())
	function cbl_e_m:OnChange( val )
		edit_mesh:SetBool(val)
		plg:UpdateEnts()
	end
	function cbl_e_m:Think()
		if self:GetChecked() ~= edit_mesh:GetBool() then
			self:SetValue( edit_mesh:GetBool()  ) 
		end
	end
end

local flr = math.floor
local function floor1000(num)
	return flr(num*1000)/1000
end

function PLUG:Setup(parent, menu, ent)

	setupmenuaddons(self,parent,menu)

	self.ent = ent
	
	function PLUG:UpdateEnts()
		UCombatBox.Selection = {}
		
		for k,v in ipairs(cents) do
			v[1]:Remove()
			cents[k] = nil
		end
		if edit_spwn:GetBool() then
			for k,v in ipairs(ent.Data._S) do
				self:createspawn(v[1]+ent.Data.POS,v[2],v)
			end
		end
		
		if edit_ents:GetBool() and next(ent.Data._E)then
			for k,v in ipairs(ent.Data._E) do
				 --print(v[4],v[1]+ent.Data.POS,v[2],v,v[5])
				self:createmodel(v[4],v[1]+ent.Data.POS,v[2],v,v[5])
			end
		end
		
		/*if edit_mesh:GetBool() then
			for k,v in ipairs(ent.Data._M.v) do
				--if v.Remove then v:Remove() end
			end
		end*/
	end
	
	self:UpdateEnts()
	menu.UpdateEnts = function() PLUG:UpdateEnts() end
	
	/*---------------------------------------------------------------------------------------------------------------------------------------*\
	
	Selecting Stuff
	
	\*---------------------------------------------------------------------------------------------------------------------------------------*/
	--do

		menu:hook("PreDrawHalos","UCB_Halos",function()
			local tbl = {}
			for k,v in pairs(UCombatBox.Selection) do
				tbl[#tbl+1] = k[1]
			end
			halo.Add( tbl, Color(0,255,0,255), 1, 1, 4, true, true )
		end)
	--end

	do
		local function textentry(parent,tbl,name,...) --#make global
			local args = {...}
			local narg = #args

			self.args = args
			self.narg = narg

			local np = vgui.Create("DCollapsibleList",parent)
			np:Dock(TOP)
			np:SetLabel(name)

			local new= np:Add("DTextEntry2")
			new:SetTall( 20 )

			local txt = ""
			new.ovl = {}
			for k,v in ipairs(args) do
				if k == narg then
					txt = txt .. floor1000(tbl[v])
				else
					txt = txt .. floor1000(tbl[v]) .. ", "
				end
				new.ovl[v] = tbl[v]
			end

			new:SetText( txt )

			function new:CallBack() end

			function new:ReInit()
				local val = string.gsub(self:GetValue(),"[^%d%-%p]","")
				local expl = string.Explode( "%s*,%s*", val:Trim(), true )
				
				txt = ""
				for k,v in ipairs(args) do
					tbl[v] = math.Clamp(UCombatBox.MathParse:Calculate(expl[k]) or tbl[v],ent.MinScale.x,ent.MaxScale.x)
					if k == narg then
						txt = txt .. floor1000(tbl[v])
					else
						txt = txt .. floor1000(tbl[v]) .. ", "
					end
					new.ovl[v] = tbl[v]
				end
				self:SetText( txt )
			end

			new.OnEnter = function( nself )
				nself:ReInit()

				menu.ctx:StopDragging()

				nself:CallBack()
				
			end
			new.ovl = tbl
			function new:Think()
				for k,v in ipairs(args) do
					if tbl[v] ~= self.ovl[v] then self:ReInit() break end
				end
			end

			return new
		end

		local mx,my = 0,0
		local down = false

		local blurTex = Material( "pp/blurscreen" )
		blurTex:SetFloat( "$blur", 5 )

		UCombatBox.SetupMenu:hook("VGUIMousePressed","UCB_Setup_EntSelector",function( pnl, mc ) --#work on entity settings menu!!
			if mc == MOUSE_LEFT and not DragContext:IsInteracting() then
				down = true
				mx, my = gui.MousePos()
			elseif mc == MOUSE_RIGHT then
				timer.Simple(0.05+FrameTime(),function()
					local opf = vgui.Create("DFrame")
					opf:SetTitle("Options")
					opf.lblTitle:SetFont("ChatFont")
					opf:SetPos(gui.MouseX()-306,gui.MouseY()-16)
					opf:SetWide(300)
					opf:SetTall(400)
					opf:MakePopup()
					function opf:Paint(w,h) end
					/*function opf:Paint(w,h)
						surface.SetMaterial( blurTex )	
						surface.SetDrawColor( 0, 255, 255, 255 )	
						render.UpdateScreenEffectTexture()
						surface.SetMaterial(blurTex)
						local px,py = self:LocalToScreen(0,0)
						surface.DrawTexturedRect( px,py, ScrW(),ScrH() )
					end*/
					local dsp = opf:Add("DScrollPanel")
					dsp:Dock(FILL)
					local options = vgui.Create("DCollapsibleList",dsp)
					options:Dock(FILL)
					options:SetPos(gui.MouseX()-306,gui.MouseY()+16)
					options:SetLabel("Angles:")
					options:SetWide(300)
					options:DockPadding(6,0,0,0)
					--options:NoClipping( true ) 
					
					local badd = Angle()
					local BatchAdd = textentry(options,badd,"Batch Add","p","y","r")

					local sel_cache = {}

					for k,v in pairs(UCombatBox.Selection) do
						local new = textentry(options,k[2][2],tostring(k[1]),"p","y","r")
						sel_cache[k] = new
						function new:PaintOver()
							local vtbl = ent:tanslateLocation(k[2][1]):ToScreen()
							if vtbl.visible then
								local px,py = self:ScreenToLocal( vtbl.x,vtbl.y ) 
								DisableClipping( true )
								surface.SetDrawColor(0,255,0,255)
								surface.DrawLine(0,0,px,py)
								DisableClipping( false ) 
							end
							--Panel:LocalToScreen( number posX, number posY ) 
						end
						function new:CallBack()
							k[1]:SetAngles(k[2][2])
						end
					end
					
					function BatchAdd:CallBack()
						for k,v in pairs(UCombatBox.Selection) do
							local txt = ""
							for i,j in ipairs(self.args) do
								k[2][2][j] = k[2][2][j] + self.ovl[j]
								
								if i == self.args then txt = txt .. floor1000(k[2][2][j]) else
									txt = txt .. floor1000(k[2][2][j]) .. ", "
								end
							end

							--sel_cache[k]:SetText(txt)
						end
					end

					function opf:Think()
						if (not UCombatBox.RMenu or not IsValid(UCombatBox.RMenu)) and (not opf:IsHovered() and not opf:IsChildHovered()) then opf:Remove() end
					end
				end)
			end
		end)
		
		local function addselection(v)
			 --print("add",v)
			if not mdlcch[v] then return end 
			if input.IsKeyDown(KEY_LSHIFT) and UCombatBox.Selection[mdlcch[v]] then 
				UCombatBox.Selection[mdlcch[v]] = nil
			else
				UCombatBox.Selection[mdlcch[v]] = true
			end
		end
		
			local function checkselection() --#tmp
				if ctx:IsDragging() then return end
				local cx, cy = gui.MousePos()
				local mix,miy = math.min(cx,mx)-8, math.min(cy,my)-8
				local max,may = math.max(cx,mx)+8, math.max(cy,my)+8
				
				if not input.IsKeyDown(KEY_LCONTROL) then UCombatBox.Selection = {} end --
				
				if edit_spwn:GetBool() then
				
					for k,v in ipairs(ent.Data._S) do
						local ts = (v[1]+ent.Data.POS):ToScreen()
						PrintTable(ts)
						if ts.visible then
							if ts.x >= mix and ts.x <= max and ts.y >= miy and ts.y <= may then
								addselection(v)
							end
						end
					end
				end
				
				if edit_ents:GetBool() then
					for k,v in ipairs(ent.Data._E) do
						local ts = (v[1]+ent.Data.POS):ToScreen()
						if ts.visible then
							if ts.x >= mix and ts.x <= max and ts.y >= miy and ts.y <= may then
								addselection(v)
							end
						end
					end
				end
				
				if edit_mesh:GetBool() then
					for k,v in ipairs(ent.Data._M.v) do
						local ts = (v[1]+ent.Data.POS):ToScreen()
						if ts.visible then
							if ts.x >= mix and ts.x <= max and ts.y >= miy and ts.y <= may then
								addselection(v)
							end
						end
					end
				end
			end
		
		UCombatBox.SetupMenu:hook("Think","UCB_Setup_EntSelector_Think",function( pnl, mc )
			if down then
				cam.Start3D()
				if not input.IsMouseDown(MOUSE_LEFT) then
					down = false
					if ctx:IsHovered() then return end

					checkselection()
					self:getDragContext()
				end
				cam.End3D()
			end
		end)
		
		UCombatBox.SetupMenu:hook("CreateMove","UCB_Setup_EntSelector_KeyPress",function( ply, key )
			-- --print(key, input.IsKeyDown(KEY_LCONTROL) , input.IsKeyDown(KEY_A))
			if input.IsKeyDown(KEY_LCONTROL) then
				if input.WasKeyPressed(KEY_A) then --select all
					if edit_spwn:GetBool() then
						for k,v in ipairs(ent.Data._S) do
							addselection(v)
						end
					end
					
					if edit_ents:GetBool() then
						for k,v in ipairs(ent.Data._E) do
							addselection(v)
						end
					end
					
					if edit_mesh:GetBool() then
						for k,v in ipairs(ent.Data._M.v) do
							addselection(v)
						end
					end
					self:getDragContext()
				elseif input.IsKeyDown(KEY_D) then --duplicate selection

				end
			end
			if input.WasKeyPressed(KEY_DELETE) or input.WasKeyPressed(KEY_BACKSPACE) then
				for v,t in pairs(UCombatBox.Selection) do
					v[1]:Remove()
					table.RemoveByValue( ent.Data._S, v[2] ) 
					table.RemoveByValue( ent.Data._E, v[2] ) 
					table.RemoveByValue( ent.Data._M.v, v[2] ) 
					v[2] = nil
				end
				UCombatBox.Selection = {}
				self:getDragContext()
				
			end

		end)
		
		local SetMaterial = surface.SetMaterial
		local s_spawn = Material( "icon16/user_add.png" )

		local s_ent = Material( "icon16/brick_add.png" )
		local sprite = Material( "sprites/grip" )
		local sprite2 = Material( "effects/select_ring" )
		--local sprite2 = Material( "gui/sm_hover.png" )
		--pp/morph/brush_outline
		
		local function DrawSprite(x,y,w,h,col)
			surface.SetDrawColor(0,0,0,200)
			surface.DrawTexturedRect(x,y,w+1,h+1)
			surface.SetDrawColor(col or Color(255,255,255))
			surface.DrawTexturedRect(x,y,w,h)
		end
		
		
		UCombatBox.SetupMenu:hook("HUDPaint","UCombatBox_DrawBoxes",function(a,b)
			if not down then
				
				SetMaterial( sprite2 )
				for v,t in pairs(UCombatBox.Selection) do
					local ts = (v[2][1]+ent.Data.POS):ToScreen()
					if ts.visible then DrawSprite(ts.x-14,ts.y-14,28,28,Color(0,255,0,255)) end
				end
			end
			
			if edit_spwn:GetBool() then
				SetMaterial( s_spawn )
				for k,v in ipairs(ent.Data._S) do
					local ts = (v[1]+ent.Data.POS):ToScreen()
					if ts.visible then DrawSprite(ts.x-8,ts.y-8,16,16) end
				end
			end
			
			if edit_ents:GetBool() then
				SetMaterial( s_ent )
				for k,v in ipairs(ent.Data._E) do
					local ts = (v[1]+ent.Data.POS):ToScreen()
					if ts.visible then DrawSprite(ts.x-8,ts.y-8,16,16) end
				end
			end
			
			if down then
				SetMaterial( sprite )
				for v,t in pairs(UCombatBox.Selection) do
					local ts = (v[2][1]+ent.Data.POS):ToScreen()
					if ts.visible then DrawSprite(ts.x-8,ts.y-8,16,16) end
				end
			end

			if down then
				local cx, cy = gui.MousePos()
				local mix,miy = math.min(cx,mx), math.min(cy,my)
				local max,may = math.max(cx,mx), math.max(cy,my)
				surface.SetDrawColor(50,250,50,200)
				surface.DrawOutlinedRect(mix,miy,max-mix,may-miy)
				surface.SetDrawColor(50,250,50,30)
				surface.DrawRect(mix,miy,max-mix,may-miy)
			end

		end)
		
		UCombatBox.SetupMenu:hook("UCB_Setup_StopDragging","UCB_EntLoad_StopDragging",function(off)
			if input.IsKeyDown(KEY_LSHIFT) then
				for k,v in pairs(cents) do
					v[2][1] = v[2][1] - off
					v[1]:SetPos(v[2][1]+ent.Data.POS)
				end
			end
		end)

		UCombatBox.SetupMenu:hook("UCB_Setup_OnDragging","UCB_EntLoad_OnDragging",function(off)
			if input.IsKeyDown(KEY_LSHIFT) then
				for k,v in pairs(cents) do
					v[1]:SetPos(v[2][1]+ent.Data.POS-off)
				end
			else
				for k,v in pairs(cents) do
					v[1]:SetPos(v[2][1]+ent.Data.POS)
				end
			end
		end)
	
	end
end

function PLUG:Clear()
	for k,v in ipairs(cents) do
		v[1]:Remove()
		cents[k] = nil
	end
	UCombatBox.Selection = {}
	
	ctx:SetEnabled(false)
end

UCombatBox.AddMenuPlugin(PLUG)

if UCombatBox.setup_open then UCombatBox.OpenSetupMenu(UCombatBox.setup_open) end