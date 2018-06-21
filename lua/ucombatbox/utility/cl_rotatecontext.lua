/*
3D Drag Context for World Editing
X = Main Drag Value 
Y = Offset

If the width is smaller than the height Y becomes the Main Value.
If width and height are the same it got an animation for squares.
*/

if SERVER then return end

UCombatBox.RotateContext = UCombatBox.RotateContext or {}
local RotateContext = UCombatBox.RotateContext 
local contexts = {}
contexts[1] = {}
RotateContext.__index = RotateContext
local function EyeVec()
	if not input.IsMouseDown(MOUSE_RIGHT) then
		return gui.ScreenToVector( gui.MousePos() )
	else
		return EyeVector()
	end
end

AccessorFunc( RotateContext, "updt_mode", "UpdateMode", FORCE_BOOL )
	--false[standard]:update on position change 	
	--true: do nothing
	--if you manually want to call the RotateContext:UpdatePos(new_world_pos) 
AccessorFunc( RotateContext, "Enabled", "Enabled", FORCE_BOOL )
AccessorFunc( RotateContext, "sx", "SizeX" )
AccessorFunc( RotateContext, "sy", "SizeY" )
AccessorFunc( RotateContext, "pos", "Pos" )
AccessorFunc( RotateContext, "off", "Offset" )
AccessorFunc( RotateContext, "grid", "GridSize" )
AccessorFunc( RotateContext, "face", "Face", FORCE_BOOL)

RotateContext.updt_mode = false
--RotateContext.lastupdatepos = Vector(0,0,0) --must be initiated with the original pos later
RotateContext.Enabled = true
RotateContext.off = Vector(0,0,0)

RotateContext:SetGridSize(1)

local mat = Material("gui/point.png")

function QuickTraceWithInfo(start,dest,filter)
	local len = dest:Length()
	
	tr = util.TraceLine( {
		start = start,
		endpos = start+dest,
		filter = filter,
		mask = MASK_NPCWORLDSTATIC,
	} )
	
	tr.EndPos = start+dest
	tr.Length = len
	tr.Distance = len * tr.Fraction
	tr.HitVec = dest * tr.Fraction
	tr.Valid = not tr.StartSolid and tr.Hit
	
	return tr
end

------------------------
local function check_mag(self,worldpos,localpos,ang)
	if self.sy ~= self.sx then
		--if ((self.drag_start-worldpos)*ang:Forward()):Length() < self.border then return self.drag_start end
		
		if self.sy < self.sx then
			local fw = QuickTraceWithInfo(worldpos-ang:Forward()*self.border,ang:Forward()*self.border*2)
			if fw.Valid then
				return fw.HitPos
			else
				bk = QuickTraceWithInfo(worldpos+ang:Forward()*self.border,-ang:Forward()*self.border*2)
				
				if bk.Valid then return bk.HitPos end
				
			end

		else
			
			local ri = QuickTraceWithInfo(worldpos-ang:Right()*self.border,ang:Right()*self.border*2)
			if ri.Valid then
				return ri.HitPos
			else
				li = QuickTraceWithInfo(worldpos+ang:Right()*self.border,-ang:Right()*self.border*2)
				
				if li.Valid then return li.HitPos end
				
			end
			
		end
		
		--if self.hover or self.drag then
			local close = -1 --math.abs(localpos.x)
			local kN = 0
			for k,v in ipairs(self.dpoint_local) do
				local dis = math.abs(localpos.x-v.x)
				if (dis < close or kN == 0) and dis < self.border then
					close = dis
					kN = k
				end
			end
			
			for k,v in ipairs(self.dpoint_local.default) do
				local dis = math.abs(localpos.x-v.x)
				if (dis < close or kN == 0) and dis < self.border then
					close = dis
					kN = -k
				end
			end
			
			if kN > 0 then
				return self.dpoint[kN]*self.fwd + self.pos*self.afwd --LocalToWorld(,self.ang,Vector(0,0,0),Angle(0,0,0))
			elseif kN < 0 then
				return LocalToWorld(self.dpoint_local.default[-kN],Angle(0,0,0),self.pos,self.ang)
			end
		--end
	else
		if ((self.drag_start-worldpos)*(ang:Forward()+ang:Right())):Length() < self.border then return self.drag_start end
	end
	
	
	
	return worldpos
end
--do
	local wp = Vector()
	hook.Add("HudPaint","c_test",function()
		local xyv = wp:ToScreen()
		
		local x = math.Clamp(xyv.x,5,ScrW()-5)
		local y = math.Clamp(xyv.y,5,ScrH()-5)
		
		surface.SetDrawColor(255,255,0,255)
		surface.DrawRect(x-3,y-3,6,60)
	end)
	
	local function lPI(self, viewVec, viewOri, norm, ori,ang) --where you look on the RotateContext
		
		local d = norm:Dot(ori)
		
		if norm:Dot(viewVec) == 0 then return end
		
		local x = (d - norm:Dot(viewOri)) / norm:Dot(viewVec)
		local worldpos = viewOri + viewVec*x
		
		local localpos = WorldToLocal(worldpos,Angle(0,0,0),ori,ang)
		
		
		return worldpos, localpos
	end
	
	local function linePlaneIntersection(self, viewVec, viewOri, norm, ori,ang) --where you look on the RotateContext
		
		local worldpos, localpos = lPI(self, viewVec, viewOri, norm, ori,ang) 
		--magnetic
		
		if not input.IsKeyDown( KEY_LCONTROL ) and self.hover then
			worldpos = check_mag(self,worldpos,localpos,ang)
			wp = worldpos
		end

		local localpos = WorldToLocal(worldpos,Angle(0,0,0),ori,ang)
		
		
		
		return worldpos, localpos
	end
	
--end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--Drag Context Stuff Below
--~~~~~~~~~~~~~~~~~~~~~__/\__~~~~~~~~~~~~~~~~~~~~~~~--
--~~~~~~~~~~~~~~~~~~~~~\____/~~~~~~~~~~~~~~~~~~~~~~~--
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

function RotateContext:SetSizeX(sx)
	self.sx = sx+40
	self.sx2 = self.sx/2
end

function RotateContext:SetSizeY(sy)
	self.sy = sy+40
	self.sy2 = self.sy/2
end

function RotateContext:UpdatePos(pos)
	self.pos = pos
end

function RotateContext:SetPos(pos)

	self:UpdatePos(pos)
	--+n-a
end

function RotateContext:StartDragging(v_start_loc, pos_abs)

end

function RotateContext:OnDragging(v_dist, pos_abs, pos_loc)

end

function RotateContext:StopDragging(v_dist, pos_abs, pos_loc)

end

function RotateContext:OnHover()

end

function RotateContext:OnIdle()

end

function RotateContext:Callback()

end

/*------------------------------------------------------------------------------*\
	RotateContext.createMove(id,pos,ang,sx,sy)
		-creates 3d drag context
		
		-id: some string to identify each context 
			--creating with the same id will override the old
		
		-pos: world pos vector
		
		-ang: rotate the the plane
		
		-sx: width
		
		-sy: height
\*------------------------------------------------------------------------------*/
function RotateContext.create(id,pos,ang,sx,sy,border)
	local context = contexts[id] or {}
	contexts[id] = context
	
	setmetatable(context,UCombatBox.RotateContext)
	
	context.border = border or 20
	
	context.id = id
	context.pos = pos
	context.dir = ang:Up()
	context.ang = ang
	context.sx = sx+context.border*2
	context.sy = sy
	
	context.sx2 = context.sx/2
	context.sy2 = context.sy/2
	
	local function SetDir( dir )
	
		context.col_act = Color( 255*dir.x, 255*dir.y, 255*dir.z, 200 )
		context.col_idle = Color( 255*dir.x, 255*dir.y, 255*dir.z, 80 )
		context.col_full = Color( 255*dir.x, 255*dir.y, 255*dir.z, 250 )
		
		context.col_cact = Color( 255-255*dir.x, 255-255*dir.y, 255-255*dir.z, 200 )
		context.col_cidle = Color( 255-255*dir.x, 255-255*dir.y, 255-255*dir.z, 80 )
		context.col_cfull = Color( 255-255*dir.x, 255-255*dir.y, 255-255*dir.z, 250 )
		
	end
	
	SetDir( context.dir )
	
	context.fwd = context.ang:Forward()
	context.afwd = Vector(1,1,1)-context.fwd
	
	context.act = false
	context.hover = false
	context.drag = false
	context.Enabled = true
	
	context.dist = -1
	context.hitpos = Vector(0,0,0)
	context.hitpos_local = Vector(0,0,0)
	
	context.drag_start = Vector(0,0,0)
	context.dpoint = {}
	context.drag_start_local = Vector(0,0,0)
	
	context.face_ang = Angle(0,0,0)
	
	do
		local m1 = false
		
		local flr = math.floor
		local function toGrid(self,vec)
			vec = vec*self.grid
			return Vector(flr(vec.x),flr(vec.x),flr(vec.x))/self.grid
		end
		
		local historyLimit = 7 --the n'th will get removed
		
		function context:AddPoint(pos_world)
			for k,v in ipairs(self.dpoint) do
				if v:Distance(pos_world) < self.border then return end
			end

			table.insert(self.dpoint,1,pos_world)
			if self.dpoint[historyLimit] ~= nil then table.remove(self.dpoint,historyLimit) end
			
			for k,v in ipairs(self.dpoint) do
				local an, di = self.face and self.face_ang or self.ang, self.face and self.face_dir or self.dir
				
				_, self.dpoint_local[k] = linePlaneIntersection(self, di, v, di, self.pos,an)
			end
		end

		--local mt = 0
		
		function context:Think()
			if not self.Enabled then return end
			
			local an, di = self.face and self.face_ang or self.ang, self.face and self.face_dir or self.dir
			
			local hp, hpl = lPI(self, EyeVec(), EyePos(), di, self.pos,an)
			self.hitpos, self.hitpos_local = linePlaneIntersection(self, EyeVec(), EyePos(), di, self.pos,an)
			
			if not self.hitpos then return end
			
			
			if self.sy > self.sx then
				self.hitpos_local = Vector(self.hitpos_local.y,self.hitpos_local.z,self.hitpos_local.x)
				self.hover = (math.abs(hpl.x) <= self.sy2 and math.abs(hpl.y) <= self.sx2) or self.drag
			else
				self.hover = (math.abs(hpl.x) <= self.sx2 and math.abs(hpl.y) <= self.sy2) or self.drag
			end
			
			if self.drag then
				self.dist = -2
			else
				self.dist = hp:Distance(EyePos()) or -1
			end
			
			if m1 ~= input.IsMouseDown( MOUSE_LEFT ) then
				m1 = input.IsMouseDown( MOUSE_LEFT )
				if m1 and self.hover and self.act then
					self.drag = true	---------------------------------/\-----start dragging
					--mt = SysTime()+0.2
					self.drag_start = self.hitpos
					self.drag_start_local  = self.hitpos_local
					
					self:StartDragging(self.drag_start_local, self.drag_start)
					self:AddPoint(self.drag_start)	
				elseif not m1 and self.drag then
					--if mt < SysTime() then
						self:AddPoint(self.hitpos)	
					--end
					self.drag = false	-----------------------------------------------//---------stop dragging
					local dpos = self.hitpos_local-self.drag_start_local 
					self:StopDragging(toGrid(self,dpos), self.hitpos, self.hitpos_local)
					
				end
			end

			if self.drag then
				local dpos = self.hitpos_local-self.drag_start_local 
				self:OnDragging(toGrid(self,dpos), self.hitpos, self.hitpos_local)
			end
		end
	end
	
	contexts[1] = {}
	for k,ctx in pairs(contexts) do
		table.insert(contexts[1],ctx)
	end
	
	return context
end

function RotateContext.create3D(id,pos,ang,sx1,sx2,sx3,sy)
	local id1 = id.."_p"
	local id2 = id.."_y"
	local id3 = id.."_r"
	
	local ctp = RotateContext.create(id1,pos + Vector(sz.x-50,0,sz.z),ang+Angle(0,0,0),sx1+100,sy)
	local cty = RotateContext.create(id2,pos + Vector(0,sz.y-50,sz.z),ang+Angle(0,90,0),sx2+100,sy)
	local ctr = RotateContext.create(id3,pos + Vector(0,0,sz.z-50),ang+Angle(-90,EyeAngles().y,0),sx3+100,sy)
	
	return ctp, cty, ctr
end

function RotateContext:SetAng(ang)
	self.dir = ang:Up()
	self.ang = ang
	do
		local dir = self.dir
		self.col_act = Color( 255*dir.x, 255*dir.y, 255*dir.z, 200 )
		self.col_idle = Color( 255*dir.x, 255*dir.y, 255*dir.z, 80 )
		self.col_full = Color( 255*dir.x, 255*dir.y, 255*dir.z, 250 )
		
		self.col_cact = Color( 255-255*dir.x, 255-255*dir.y, 255-255*dir.z, 200 )
		self.col_cidle = Color( 255-255*dir.x, 255-255*dir.y, 255-255*dir.z, 80 )
		self.col_cfull = Color( 255-255*dir.x, 255-255*dir.y, 255-255*dir.z, 250 )
		
	end
	self.fwd = self.ang:Forward()
	self.afwd = Vector(1,1,1)-self.fwd
end

function RotateContext:GetAng()
	return self.ang
end

function RotateContext:Render()
	
	if self.face then
		cam.Start3D2D( self.pos, self.face_ang , 1 )
	else
		cam.Start3D2D( self.pos, self.ang , 1 )
	end
			
		if self.act then
			surface.SetDrawColor( self.col_act )
		else
			surface.SetDrawColor( self.col_idle )
		end
		
		if self.hover and self.act then
			cam.IgnoreZ(true)
				local drag_dist = self.hitpos_local.x - self.drag_start_local.x
				
				if self.drag then
					surface.SetDrawColor( self.col_idle ) --bold line from drag start:
					surface.DrawRect(self.drag_start_local.x,-self.sy2,drag_dist,self.sy)
					surface.SetDrawColor( self.col_act )
					cam.IgnoreZ(false)
					surface.DrawRect(self.drag_start_local.x,-self.sy2/2,drag_dist,self.sy2)
					cam.IgnoreZ(true)
				else
					surface.DrawRect(-self.sx2,-self.sy2,self.sx,self.sy)
				end
				if not input.IsKeyDown( KEY_LCONTROL ) then
					surface.SetDrawColor( self.col_cfull )
				else
					surface.SetDrawColor( self.col_full )
				end
				if self.sy > self.sx then
					surface.DrawOutlinedRect(-self.sx2-3,-self.hitpos_local.x-20,self.sx+6,40)
				elseif self.sy < self.sx then
					surface.DrawOutlinedRect(self.hitpos_local.x-20,-self.sy2-3,40,self.sy+6)
				else
					surface.DrawOutlinedRect(self.hitpos_local.x-20,self.hitpos_local.y-20,40,40)
				end
				
				surface.SetDrawColor( self.col_full )
				surface.DrawOutlinedRect( -self.sx2, -self.sy2, self.sx, self.sy )
				surface.DrawOutlinedRect( -self.sx2-1, -self.sy2-1, self.sx+2, self.sy+2 )
				
				surface.SetDrawColor( self.col_cfull )
				for k,v in ipairs(self.dpoint_local.default) do
					surface.DrawRect(self.dpoint_local.default[k].x-3,-3,6,6)
				end
				
				surface.SetDrawColor( self.col_cfull )
				for k,v in ipairs(self.dpoint_local) do
					surface.DrawRect(self.dpoint_local[k].x-4,-4,8,8)
					/*surface.SetTextColor(self.col_cfull)
					surface.SetFont("SomeThreeDeeFont")
					surface.SetTextPos(self.dpoint_local[k].x-4,5)
					surface.DrawText("["..k.."]")*/
				end

				surface.DrawOutlinedRect(self.drag_start_local.x-6,-6,12,12)
				
				--
			cam.IgnoreZ(false)
			
		else
			if self.sy > self.sx then
				surface.DrawRect(-self.sx2,-self.sy2,self.sx,self.sy)
				
				surface.DrawOutlinedRect(-self.sx2-3,-self.hitpos_local.x-20,self.sx+6,40)
			elseif self.sy < self.sx then
				surface.DrawRect(-self.sx2,-self.sy2,self.sx,self.sy)

				surface.DrawOutlinedRect(self.hitpos_local.x-20,-self.sy2-3,40,self.sy+6)
			else
				surface.DrawRect(-self.sx2,-self.sy2,self.sx,self.sy)

				surface.DrawOutlinedRect(self.hitpos_local.x-20,self.hitpos_local.y-20,40,40)
			end
			
			surface.SetDrawColor( self.col_full )
			
			cam.IgnoreZ(true)
			surface.DrawOutlinedRect( -self.sx2, -self.sy2, self.sx, self.sy )
			surface.DrawOutlinedRect( -self.sx2-1, -self.sy2-1, self.sx+2, self.sy+2 )
			cam.IgnoreZ(false)
		end
		
	cam.End3D2D()
end

hook.Add("Think","UCombatBox_RotateContext_Think",function()
	for k,ctx in pairs(contexts) do
		if ctx.Enabled then
			ctx:Think()
		end
	end
	table.sort(contexts[1],function( a, b ) return (a.dist or -1) < (b.dist or -1) end)
	
	local fst = false
	for i,ctx in ipairs(contexts[1]) do
		if ctx.Enabled then
			if not fst and ctx.hover then
				fst = true
				if not ctx.act then 
					ctx.act = true
					ctx:OnHover()
				end
			elseif ctx.act then 
				ctx.act = false
				ctx:OnIdle()
			end
		end
	end 
end)

hook.Add("PostDrawTranslucentRenderables","UCombatBox_RotateContext_Draw",function()
	for i = #contexts[1] , 1 ,-1 do
		local context = contexts[1][i]
		if context.Enabled then 
			if context.face then
				local p, a = WorldToLocal(EyePos(),Angle(),context.pos,context.ang)
				local ang = math.deg(math.atan(p.z/p.y))-90
				
				context.face_ang = Angle(context.ang.p,context.ang.y,context.ang.r)
				context.face_ang:RotateAroundAxis(context.fwd,ang)
				
				context.face_dir = context.face_ang:Up()
			end
			context:Render()
		end
	end
end)

function RotateContext:Remove()
	if contexts[self.id] then
		contexts[self.id] = nil
		
		self = nil
		
		contexts[1] = {}
		for k,ctx in pairs(contexts) do
			table.insert(contexts[1],ctx)
		end
		
		return true
	else
		return false
	end
end

if CLIENT and UCombatBox.OpenSetupMenu then
	UCombatBox.OpenSetupMenu(UCombatBox.setup_open or -1)
end
