UCombatBox.SetupMenu = UCombatBox.SetupMenu or nil

--local mtx = include("inc_matrix.lua")

function UCombatBox.OpenSetupMenu(id)
	if UCombatBox.SetupMenu ~= nil and IsValid(UCombatBox.SetupMenu) then UCombatBox.SetupMenu:Remove() end
	
	local ent = Entity(id)
	local box = UCombatBox.ents[ent]

	local cpy = table.Copy(box)

	--in case there is no such box or you're not an owner.
	if not box or not box.STDID[LocalPlayer():SteamID()] then return end

	local menu = vgui.Create("DFrame")
	menu:DockPadding(50,50,50,50)
	menu:SetSize(415,640)
	--menu:Center()
	menu:MakePopup()
	menu:SetTitle("")
	
	menu.bck = vgui.Create("DPanel") --magic
	menu.bck:SetPos(0,0)
	menu.bck:Dock(FILL)
	menu.bck:SetCursor( "sizeall" ) 
	
	local name = menu:Add("DTextEntry")
	name:DockPadding(5,5,5,5)
	name:SetPos(5,3)
	name:SetSize(300,18)
	name:SetText("test") --(box._N and box._N ~= "") and box._N or LocalPlayer():Name().."'s CombatBox")
	
	local global = menu:Add("DPanel")
	global:DockPadding(5,5,5,5)
	global:SetPos(5,30)
	global:SetSize(200,400)
	--global:Dock(LEFT)
	
	local mode = menu:Add("DPanel")
	mode:DockPadding(5,5,5,5)
	mode:SetPos(210,30)
	mode:SetSize(200,400)
	--mode:Dock(LEFT)
	
	local invite = menu:Add("DPanel")
	invite:DockPadding(5,5,5,5)
	invite:SetPos(5,435)
	invite:SetSize(405,200)
	function invite:Paint(w,h)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawRect(0,0,w,h)
	end
	--invite:Dock(BOTTOM)
	 --print("tetsetset")
	function UCombatBox.SetupMenuAddOption(prnt, typ, tbl, test)
		
	end
	
	local addo = UCombatBox.SetupMenuAddOption --seems like making things moddable requires names everybody can understand while I'm even too lazy to copy/paste long names
	
	--menu:SizeToContents()
	
	local py = 50 
	
	local SurfaceInfos = {}
	
	local function DrawSurfaceInfo(txt)
	
		local sx,sy = surface.GetTextSize(txt)
		py = py + 2 + sy
		
		surface.SetTextColor(0,0,0,150)
		surface.SetTextPos(51, py+1)
		surface.DrawText(txt)
		
		surface.SetTextColor(0,200,0,255)
		surface.SetTextPos(50, py)
		surface.DrawText(txt)
		
	end
	
	local function AddSurfaceInfo(id,txt)
		
		if txt then
			SurfaceInfos[id] = txt
		else
			SurfaceInfos[#SurfaceInfos+1] = id
		end
	end
	
	hook.Add("HUDPaint","UCombatBox.SetupMenu_HUD",function()
		surface.SetFont("default")
		
		py = 50
		
		for k,txt in pairs(SurfaceInfos) do
			DrawSurfaceInfo(k..": "..txt)
		end
		DrawSurfaceInfo("")
		
		AddSurfaceInfo("Size: "..ent.SIZE.x..", "..ent.SIZE.y..", "..ent.SIZE.z)
		for k,txt in ipairs(SurfaceInfos) do
			DrawSurfaceInfo(SurfaceInfos[1])
			table.remove(SurfaceInfos,1)
		end
		
	end)
	
	hook.Remove("CalcView","UCombatBox.SetupMenu_View")
	
	do --view + drag
		local cx,cy = gui.MousePos()
		local mx,my = 0,0
		local ox,oy = 0,0
		
		local dist = 1
		
		local distlerp = 1
		
		local view = {

			angles = Angle(0,0,0),
			origin = Vector(0,0,0),
			fov = 0,

			drawviewer = true,
			
		}
		
		function menu.bck:OnMouseWheeled(d)
			dist = math.Clamp(dist - d,1,10)
		end
		
		local faces = {
			{Vector(1,0.5,0.5),Angle(0,0,0),Color(255,0,0,254),"sizewe",Vector(1,0,0)},
			--{Vector(0,0.5,0.5),Angle(0,180,0),Color(170,0,0,240),"sizewe",Vector(-1,0,0)},
			
			{Vector(0.5,1,0.5),Angle(0,90,0),Color(0,255,0,254),"sizewe",Vector(0,1,0)},
			--{Vector(0.5,0,0.5),Angle(0,-90,0),Color(0,170,0,240),"sizewe",Vector(0,-1,0)},
			
			{Vector(0.5,0.5,1),Angle(-90,0,0),Color(0,0,255,254),"sizens",Vector(0,0,1)},
			--{Vector(0.5,0.5,0),Angle(90,0,0),Color(0,0,170,240),"sizens",Vector(0,0,-1)},
		}
		
		local mat = Material("widgets/disc.png")
		
		for k,tbl in ipairs(faces) do
			
			local vec = tbl[1]
			local ang = tbl[2]
			
			local icon = menu.bck:Add( "DModelPanel")
			icon:SetSize( 60, 60 )
			icon:SetModel( "models/editor/cone_helper.mdl" )
			
			tbl.icon = icon
			
			icon:SetCamPos( Vector( -50, 0, 0 ) )
			icon:SetLookAt( Vector( 0, 0, 0 ) )
			icon:SetFOV( 20 )
			icon.Entity:SetAngles(ang)
			icon:SetColor(tbl[3])
			
			icon:SetCursor( tbl[4] ) 
			
			local sin,cos,pi = math.sin, math.cos, math.pi
			
			
			function icon:LayoutEntity( drw ) 
				local v = (ent:GetPos() + ent.SIZE*vec):ToScreen()
				local px,py = v.x-30,v.y-30
				
				self:SetPos(math.Clamp(px,2,ScrW()-62),math.Clamp(py,2,ScrH()-62))
				
				self:SetVisible(v.visible)
				
				local p = view.angles.p
				local y = -view.angles.y
				local y2 = y+90
				
				local vv = Vector(-50,0,0)
				vv:Rotate(view.angles)
				self:SetCamPos( vv )
				
				--drw:SetAngles( Angle(p * -cos(y/180*pi),y,p * -sin(y/180*pi)))
			end
			
			icon.drag = false
			
			--local tbo = mtx:new(3,1,0)
			--local tbt = mtx:new(3,3,0)
			--PrintTable(viewl)
			--tbo[r][c] --https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection#Parametric_form
			--tbo[1][1] = la.x - o.x
			--tbo[2][1] = la.y - o.y
			--tbo[3][1] = la.z - o.z
			
			--tbt[1][1] = la.x - lb.x
			--tbt[2][1] = la.y - lb.y
			--tbt[3][1] = la.z - lb.z
			
			--tbt[1][2] = of.x - o.x
			--tbt[2][2] = of.y - o.y
			--tbt[3][2] = of.z - o.z
			
			--tbt[1][3] = or.x - o.x
			--tbt[2][3] = or.y - o.y
			--tbt[3][3] = or.z - o.z
			
			function icon:Paint( w, h )

				if ( !IsValid( self.Entity ) ) then return end

				local x, y = self:LocalToScreen( 0, 0 )

				self:LayoutEntity( self.Entity )

				local ang = self.aLookAngle
				if ( !ang ) then
					ang = ( self.vLookatPos - self.vCamPos ):Angle()
				end

				cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ )
				
					render.SuppressEngineLighting( true )
					render.SetColorModulation( self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255 )
					render.SetBlend( ( self:GetAlpha() / 255 ) * ( self.colColor.a / 255 ) )
					
					self:DrawModel()
					
					render.SuppressEngineLighting( false )
				cam.End3D()

				self.LastPaint = RealTime()
				
				surface.SetMaterial(mat)
				if self.Hovered or self.drag then
					surface.SetDrawColor(self.colColor)
					surface.DisableClipping(true)
					surface.DrawTexturedRectRotated(w/2,h/2,64,64,12*math.sin(SysTime()*4+60*k))
					surface.DisableClipping(false)
				else
					surface.SetDrawColor(Color(50,50,50,120))
					surface.DisableClipping(true)
					surface.DrawTexturedRectRotated(w/2,h/2,64,64,0)
					surface.DisableClipping(false)
				end
				
				if self.drag == nil then
					self:StoreInfo()
					self.drag = true
				end
				
				if self.drag == true then
					surface.SetDrawColor(self.colColor)
					
					local cx,cy =  self:CursorPos() 
					local dx,dy = cx - self.mdx, cy - self.mdy
					local ddist = Vector(dx,dy,0):Dot(Vector(self.nx,self.ny,0))
					
					icon:StoreInfo()
					--if ddist > 4 or ddist < - 4 then
						local cdir = Vector(dx,dy,0):GetNormalized()
						local ang = (((cdir.x*self.nx)+(cdir.y*self.ny))/((math.abs(cdir.x)*math.abs(self.nx))+(math.abs(cdir.y)*math.abs(self.ny))))
						
						surface.DisableClipping(true)
							
							surface.SetDrawColor(Color(50,50,50,120))
							surface.DrawRect(self.p1.x,self.p1.y,10,10)
							
							surface.SetDrawColor(self.colColor)

							local add = Vector(self.nx,self.ny,0)*ddist
							--if ang < 0 then add = add * -1 end
							
							local dest_x, dest_y  = math.floor(self.mdx+add.x),math.floor(self.mdy+add.y)
							
							surface.DrawLine(self.mdx,self.mdy,dest_x, dest_y)
							
							
							surface.SetFont("Default")
							surface.SetTextPos(dest_x, dest_y)
							
							--local ddi = math.abs(Vector(self.mdx,self.mdy,0):Distance(Vector(self.p1.x,self.p1.y,0)))
							
							local curs = (ent.SIZE*tbl[5]):Length()
							local mins = (ent.MinScale*tbl[5]):Length()
							local maxs = (ent.MaxScale*tbl[5]):Length()
							
							local mult = (ddist/math.abs(Vector(self.mdx,self.mdy,0):Distance(Vector(self.p1.x,self.p1.y,0))))
							
							local pct = ((curs-mins)+((maxs-curs)*mult))  / (maxs-mins)
							
							if pct > 1 or pct < 0 then
								surface.SetTextColor(255,0,0,255)
							else
								surface.SetTextColor(255,255,255,255)
							end
							surface.DrawText(math.floor(100*pct).."%")

							
							surface.SetTextPos(dest_x, dest_y+20)
							--surface.DrawText((math.floor(mult*100)/100).."u")
							
							--line
							local la = view.origin + gui.ScreenToVector( gui.MousePos() )
							local lb = la + view.angles:Forward()
							
							local o = ent:GetPos() + ent.SIZE*vec --ent:GetPos()	--origin = position of box
							local of = o+tbl[5]	--front
							local onl = o:Cross(of)--right
							
							tbo[1][1] = la.x - o.x
							tbo[2][1] = la.y - o.y
							tbo[3][1] = la.z - o.z
							
							
							tbt[1][1] = la.x - lb.x
							tbt[2][1] = la.y - lb.y
							tbt[3][1] = la.z - lb.z
							
							tbt[1][2] = of.x - o.x
							tbt[2][2] = of.y - o.y
							tbt[3][2] = of.z - o.z
							
							tbt[1][3] = onl.x - o.x
							tbt[2][3] = onl.y - o.y
							tbt[3][3] = onl.z - o.z

							local tuv = tbt:invert():mul(tbo)
							
							local i_t,i_u,i_v = tuv[1][1],tuv[2][1],tuv[3][1]
							
							local intersect = la + (lb-la)*i_t
							local its = intersect:ToScreen()
							
							surface.SetDrawColor(Color(250,50,50,250))
							surface.DrawRect(its.x,its.y,10,10)
							
							
							surface.DrawText(its.x..", "..its.y)
							
							
						surface.DisableClipping(true)
					--else
					--	ent:SetSize(self.SIZB)
					--end
				end
				
				
			end
			
			function icon:StoreInfo()
				local pos = ent:GetPos() + ent.SIZE*vec

				self.SIZB = Vector(ent.SIZE.x,ent.SIZE.y,ent.SIZE.z)
				self.p1 = (pos + tbl[5]*(Vector(ent.MaxScale.X-ent.SIZE.x,ent.MaxScale.Y-ent.SIZE.y,ent.MaxScale.Z-ent.SIZE.z))):ToScreen()
				
				if not self.p1.visible then
					self.drag = false
					--self.p1 = (pos + -tbl[5]*Vector(ent.MaxScale.X,ent.MaxScale.Y,ent.MaxScale.Z)):ToScreen()
				end
				
				
				self.p1.x = self.p1.x - self.x
				self.p1.y = self.p1.y - self.y
				
				
				
				pos = (ent:GetPos() + ent.SIZE*vec):ToScreen()
				
				self.mdx = pos.x - self.x
				self.mdy = pos.y - self.y
				
				self.ddir = Vector(self.p1.x-self.mdx,self.p1.y-self.mdy,0):GetNormalized() 
				
				self.nx = self.ddir.x
				self.ny = self.ddir.y
				
			end
			
			function icon:OnMousePressed( keyCode ) 
				if self.drag == true then return end
				if keyCode == MOUSE_LEFT then
					self:StoreInfo()
					self.drag = nil
				end
			end
			
			function icon:Think()
				if self.drag and not input.IsMouseDown(MOUSE_LEFT) then 
					local cx,cy =  self:CursorPos() 
					local dx,dy = cx - self.mdx, cy - self.mdy
					local ddist = Vector(dx,dy,0):Dot(Vector(self.nx,self.ny,0))
					
					
					--if ddist > 4 or ddist < - 4 then
						local cdir = Vector(dx,dy,0):GetNormalized()
						local ang = (((cdir.x*self.nx)+(cdir.y*self.ny))/((math.abs(cdir.x)*math.abs(self.nx))+(math.abs(cdir.y)*math.abs(self.ny))))

							local curs = (ent.SIZE*tbl[5]):Length()
							local mins = (ent.MinScale*tbl[5]):Length()
							local maxs = (ent.MaxScale*tbl[5]):Length()

							local mult = (ddist/math.abs(Vector(self.mdx,self.mdy,0):Distance(Vector(self.p1.x,self.p1.y,0))))
							
							local pct = ((curs-mins)+((maxs-curs)*mult))  / (maxs-mins)
							
							
							if tbl[5].x ~= 0 then
								--ent:SetSize(ent.SIZE.x * tbl[5].x * mult,ny,nz)
								ent:SetSize(ent.MaxScale.X * pct,self.SIZB.y,self.SIZB.z)
							elseif tbl[5].y ~= 0 then
								ent:SetSize(self.SIZB.x,ent.MaxScale.Y * pct,self.SIZB.z)
							elseif tbl[5].z ~= 0 then
								ent:SetSize(self.SIZB.x,self.SIZB.y,ent.MaxScale.Z * pct)
							end
					--else
					--	ent:SetSize(self.SIZB)
					--end
					self.drag = false
					
					icon:StoreInfo()
				end
			end
		end
		
		function menu.bck:Paint(w,h) end
		
		function menu.bck:Think()
			if not IsValid(menu) then self:Remove() return end
			
			
			table.sort( faces, function( a, b ) return 	((ent:GetPos() + ent.SIZE*a[1]) - view.origin):Length() >
														((ent:GetPos() + ent.SIZE*b[1]) - view.origin):Length() end )
			
			for k,ft in ipairs(faces) do
				ft.icon:SetZPos(k)
			end
		end
		
		function menu.bck:OnMouseWheeled(d)
			dist = math.Clamp(dist - d,1,10)
		end
		
		local drl, drr = false, false
		
		function menu.bck:OnMousePressed( keyCode ) 
			if drl or drr then return end
			
			if keyCode == MOUSE_LEFT then
				drl = true
			elseif keyCode == MOUSE_RIGHT then
				drr = true
			end
		end
		
		hook.Add( "CalcView", "UCombatBox.SetupMenu_View", function()
			if input.IsKeyDown(IN_USE) then menu:Remove() end
			if not IsValid(menu) then hook.Remove("CalcView","UCombatBox.SetupMenu_View") hook.Remove("HUDPaint","UCombatBox.SetupMenu_HUD") return end
			
			local ocx,ocy = cx,cy
			cx,cy = gui.MousePos()
			local dcx,dcy = cx-ocx,cy-ocy
			
			distlerp = distlerp + math.Clamp(dist - distlerp,-FrameTime()*5,FrameTime()*5)
			local di = (distlerp+10)^3 -1331
			
			
				if drr then
					mx,my = mx - dcx*0.3,my + dcy*0.3
					
					if not input.IsMouseDown(MOUSE_RIGHT) then drr = false end
					
				elseif drl then
					local a = (ent.SIZE:Length()+di)/ent.SIZE:Length()
				
					ox,oy = ox - dcx*a,oy + dcy*a
					
					if not input.IsMouseDown(MOUSE_LEFT) then drl = false end
					
				end
			
			
			local newview = {}
			
			local sx,sy,sz = ent.SIZE.x, ent.SIZE.y, ent.SIZE.z
			local x,y,z = ent:GetPos() + ent.SIZE/2
			
			local ea = LocalPlayer():EyeAngles()
			
			newview.angles = (ea + Angle(math.Clamp(my,-89-ea.p,89-ea.p),mx,0))
			newview.origin = Vector(x,y,z) - (newview.angles:Forward() * (ent.SIZE:Length()+di)) + (newview.angles:Right()*ox) + (newview.angles:Up()*oy)
			newview.fov = fov

			newview.drawviewer = true -- this doesn't work (probably because I use SetViewEntity serverside)
			view = newview
			return newview
		end)
	end
	
	/*hook.Add( "PrePlayerDraw", "UCombatBox.SetupMenu_View", function( ply )
		if IsValid(menu) and ply == LocalPlayer() then return true end
		if not IsValid(menu) then hook.Remove("CalcView","UCombatBox.SetupMenu") return end
	end )*/
	
	UCombatBox.SetupMenu = menu
end