/*
3D Drag Context for World Editing
X = Main Drag Value 
Y = Offset

If the width is smaller than the height Y becomes the Main Value.
If width and height are the same it got an animation for squares.
*/

if SERVER then return end

UCombatBox.DragContext = UCombatBox.DragContext or {}
local DragContext = UCombatBox.DragContext 
local contexts = {}
contexts[1] = {}
DragContext.__index = DragContext
local function EyeVec()
	if not input.IsMouseDown(MOUSE_RIGHT) then
		return gui.ScreenToVector( gui.MousePos() )
	else
		return EyeVector()
	end
end

DragContext.Dragging = false
function DragContext:IsInteracting()
	return DragContext.Dragging
end

surface.CreateFont( "SomeThreeDeeFont", {
	font = "DebugFixed", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 24,
	weight = 500,
	--antialias = true,
	--shadow = true,
	outline = true,
} )


AccessorFunc( DragContext, "updt_mode", "UpdateMode", FORCE_BOOL )
	--false[standard]:update on position change 	
	--true: do nothing
	--if you manually want to call the DragContext:UpdatePos(new_world_pos) 
AccessorFunc( DragContext, "Enabled", "Enabled", FORCE_BOOL )
AccessorFunc( DragContext, "sx", "SizeX" )
AccessorFunc( DragContext, "sy", "SizeY" )
AccessorFunc( DragContext, "pos", "Pos" )
AccessorFunc( DragContext, "off", "Offset" )
AccessorFunc( DragContext, "grid", "GridSize" )
AccessorFunc( DragContext, "face", "Face", FORCE_BOOL)

DragContext.updt_mode = false
--DragContext.lastupdatepos = Vector(0,0,0) --must be initiated with the original pos later
DragContext.Enabled = true
DragContext.off = Vector(0,0,0)

DragContext:SetGridSize(1)

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
	local function lPI(self, viewVec, viewOri, norm, ori,ang) --where you look on the dragcontext
		
		local d = norm:Dot(ori)
		
		if norm:Dot(viewVec) == 0 then return end
		
		local x = (d - norm:Dot(viewOri)) / norm:Dot(viewVec)
		local worldpos = viewOri + viewVec*x
		
		local localpos = WorldToLocal(worldpos,Angle(0,0,0),ori,ang)
		
		
		return worldpos, localpos
	end
	
	local function linePlaneIntersection(self, viewVec, viewOri, norm, ori,ang) --where you look on the dragcontext
		
		local worldpos, localpos = lPI(self, viewVec, viewOri, norm, ori,ang) 
		--magnetic
		
		if not input.IsKeyDown( KEY_LCONTROL ) and self.hover then
			worldpos = check_mag(self,worldpos,localpos,ang)
		end

		local localpos = WorldToLocal(worldpos,Angle(0,0,0),ori,ang)
		
		
		
		return worldpos, localpos
	end
	
--end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--Drag Context Stuff Below
--~~~~~~~~~~~~~~~~~~~~~__/\__~~~~~~~~~~~~~~~~~~~~~~~--
--~~~~~~~~~~~~~~~~~~~~~\____/~~~~~~~~~~~~~~~~~~~~~~~--
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

function DragContext:SetSizeX(sx)
	self.sx = sx+40
	self.sx2 = self.sx/2
	
	if self.sx ~= self.sy then
		self.dpoint_local.default = {Vector(0,0,0),Vector(self.border-self.sx2,0,0),Vector(self.sx2-self.border,0,0)}
	else
		self.dpoint_local.default = {Vector(0,0,0),
		Vector(self.border-self.sx2,0,0),Vector(self.sx2-self.border,0,0),
		Vector(0,self.border-self.sy2,0),Vector(0,self.sy2-self.border,0),
		
		Vector(self.sx2-self.border,self.sy2,0),Vector(self.border-self.sx2,self.sy2-self.border,0),
		Vector(self.sx2-self.border,-self.sy2,0),Vector(self.border-self.sx2,-self.sy2-self.border,0),
		}
	end
end

function DragContext:SetSizeY(sy)
	self.sy = sy+40
	self.sy2 = self.sy/2
	
	if self.sx ~= self.sy then
		self.dpoint_local.default = {Vector(0,0,0),Vector(self.border-self.sx2,0,0),Vector(self.sx2-self.border,0,0)}
	else
		self.dpoint_local.default = {Vector(0,0,0),
		Vector(self.border-self.sx2,0,0),Vector(self.sx2-self.border,0,0),
		Vector(0,self.border-self.sy2,0),Vector(0,self.sy2-self.border,0),
		
		Vector(self.sx2-self.border,self.sy2,0),Vector(self.border-self.sx2,self.sy2-self.border,0),
		Vector(self.sx2-self.border,-self.sy2,0),Vector(self.border-self.sx2,-self.sy2-self.border,0),
		}
	end
end

function DragContext:UpdatePos(pos)
	if self:GetUpdateMode() then
		self.pos = pos
	else
		self.pos = pos
--linePlaneIntersection(self, viewVec, viewOri, norm, ori,ang)
		_, self.drag_start_local = lPI(self, self.dir, self.drag_start, self.dir, self.pos,self.ang)
		for k,v in ipairs(self.dpoint) do
			_, self.dpoint_local[k] = lPI(self, self.dir, v, self.dir, self.pos,self.ang)
		end
		
	end
	--+n-a
end

function DragContext:SetPos(pos)

	self:UpdatePos(pos)
	--+n-a
end

function DragContext:StartDragging(v_start_loc, pos_abs)

end

function DragContext:OnDragging(v_dist, pos_abs, pos_loc)

end

function DragContext:StopDragging(v_dist, pos_abs, pos_loc)

end

function DragContext:OnHover()

end

function DragContext:OnIdle()

end

function DragContext:Callback()

end

/*------------------------------------------------------------------------------*\
	DragContext.create(id,pos,ang,sx,sy)
		-creates 3d drag context
		
		-id: some string to identify each context 
			--creating with the same id will override the old
		
		-pos: world pos vector
		
		-ang: rotate the the plane
		
		-sx: width
		
		-sy: height
\*------------------------------------------------------------------------------*/
function DragContext.create(id,pos,ang,sx,sy,border)
	local context = contexts[id] or {}
	contexts[id] = context
	
	setmetatable(context,UCombatBox.DragContext)
	
	context.border = border or 20
	
	context.id = id
	context.pos = pos
	context.dir = ang:Up()
	context.ang = ang
	context.sx = sx+context.border*2
	context.sy = sy+context.border*2
	
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
	
	SetDir( context.ang:Forward() )
	
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
	context.dpoint_local = {}
	context.dpoint_local.default = {}
	
	function context:IsDragging()
		return self.drag
	end
	
	if context.sx ~= context.sy then
		context.dpoint_local.default = {Vector(0,0,0),Vector(context.border-context.sx2,0,0),Vector(context.sx2-context.border,0,0)}
	else
		context.dpoint_local.default = {Vector(0,0,0),
		Vector(context.border-context.sx2,0,0),Vector(context.sx2-context.border,0,0),
		Vector(0,context.border-context.sy2,0),Vector(0,context.sy2-context.border,0),
		
		Vector(context.sx2-context.border,context.sy2,0),Vector(context.border-context.sx2,context.sy2-context.border,0),
		Vector(context.sx2-context.border,-context.sy2,0),Vector(context.border-context.sx2,-context.sy2-context.border,0),
		}
	end
	
	context.face_ang = Angle(0,0,0)
	
	do
		local m1 = false
		
		local flr = math.floor
		local function toGrid(self,vec)
			vec = vec/self.grid
			return Vector(flr(vec.x),flr(vec.x),flr(vec.x))*self.grid
		end
		
		local historyLimit = 7 --the n'th will get removed
		
		function context:AddPoint(pos_world,doremove)
			local n, d, dist = -1, -1, 0
			for k,v in ipairs(self.dpoint) do
				dist = v:Distance(pos_world)
				if dist < self.border and (dist < d or d == -1) then n = k; d = dist end
			end

			if doremove and n ~= -1 then
				table.remove(self.dpoint,n)
				table.remove(self.dpoint_local,n)
				return
			end

			table.insert(self.dpoint,1,pos_world)
			if self.dpoint[historyLimit] ~= nil then table.remove(self.dpoint,historyLimit); table.remove(self.dpoint_local,historyLimit) end
			
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
					if not input.IsKeyDown( KEY_LALT ) then
						self.drag = true	---------------------------------/\-----start dragging
						--mt = SysTime()+0.2
						self.drag_start = self.hitpos
						self.drag_start_local  = self.hitpos_local
						
						self:StartDragging(self.drag_start_local, self.drag_start)
						self:AddPoint(self.drag_start)	
					else
						self:AddPoint(self.hitpos,true)	
					end
				elseif not m1 and self.drag then
					--if mt < SysTime() then
						self:AddPoint(self.hitpos)	
					--end
					self.drag = false	-----------------------------------------------//---------stop dragging
					local dpos = self.hitpos_local-self.drag_start_local 
					
					--if hook.Call("DragContextShouldStopDragging",GAMEMODE,self.id) ~= false then --#maybe later?
						self:StopDragging(toGrid(self,dpos), self.hitpos, self.hitpos_local)
					--end
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

function DragContext.create3D(id,pos,ang,sx1,sx2,sx3,sy,border)
	local id1 = id.." X"
	local id2 = id.." Y"
	local id3 = id.." Z"
	
	local ctx = DragContext.create(id1,pos,ang+Angle(0,0,0),sx1,sy,border)
	local cty = DragContext.create(id2,pos,ang+Angle(0,90,0),sx2,sy,border)
	local ctz = DragContext.create(id3,pos,ang+Angle(-90,EyeAngles().y,0),sx3,sy,border)
	
	ctx:SetFace(true)
	cty:SetFace(true)
	ctz:SetFace(true)
	
	function ctx:SetEnabled(t) --#move to make 3d
		self.Enabled = t
		cty.Enabled = t
		ctz.Enabled = t
	end
	
	function ctx:SetPos(t)
		self:UpdatePos(t)
		cty:UpdatePos(t)
		ctz:UpdatePos(t)
	end
	
	function ctx:clear()
		self:Remove()
		cty:Remove()
		ctz:Remove()		
	end
	
	cty.StopDragging = ctx.StopDragging
	ctz.StopDragging = ctx.StopDragging
	
	function ctx:IsDragging()
		return self.drag or cty.drag or ctz.drag
	end
	
	function ctx:IsHovered()
		return self.hover or cty.hover or ctz.hover
	end
	
	return ctx, cty, ctz
end

function DragContext:SetAng(ang)
	self.dir = ang:Up()
	self.ang = ang
	do
		local dir = self.ang:Forward()
		self.col_act = Color( 255*dir.x, 255*dir.y, 255*dir.z, 60 )
		self.col_idle = Color( 255*dir.x, 255*dir.y, 255*dir.z, 0 )
		self.col_full = Color( 255*dir.x, 255*dir.y, 255*dir.z, 250 )
		
		self.col_cact = Color( 255-255*dir.x, 255-255*dir.y, 255-255*dir.z, 60 )
		self.col_cidle = Color( 255-255*dir.x, 255-255*dir.y, 255-255*dir.z, 0 )
		self.col_cfull = Color( 255-255*dir.x, 255-255*dir.y, 255-255*dir.z, 250 )
		
	end
	self.fwd = self.ang:Forward()
	self.afwd = Vector(1,1,1)-self.fwd
end

function DragContext:GetAng()
	return self.ang
end

function DragContext:Render()
	
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
					cam.IgnoreZ(false)
					surface.DrawRect(self.drag_start_local.x,-self.sy2,drag_dist,self.sy)
					surface.SetDrawColor( self.col_act )
					cam.IgnoreZ(true)
					surface.DrawRect(self.drag_start_local.x,-self.sy2/3,drag_dist,self.sy2/1.5)
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
				cam.IgnoreZ(false)
				surface.DrawOutlinedRect( -self.sx2-1, -self.sy2-1, self.sx+2, self.sy+2 )
				cam.IgnoreZ(true)
				
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
			cam.IgnoreZ(false)
			surface.DrawOutlinedRect( -self.sx2-1, -self.sy2-1, self.sx+2, self.sy+2 )
		end
		
	cam.End3D2D()
end

hook.Add("Think","UCombatBox_DragContext_Think",function()
	for k,ctx in pairs(contexts) do
		if ctx.Enabled then
			ctx:Think()
		end
	end
	table.sort(contexts[1],function( a, b ) return (a.dist or -1) < (b.dist or -1) end)
	DragContext.Dragging = false
	local fst = false
	for i,ctx in ipairs(contexts[1]) do
		if ctx.Enabled then
			if not fst and ctx.hover then
				fst = true
				if not ctx.act then 
					ctx.act = true
					ctx:OnHover()
				end
				DragContext.Dragging = true
			elseif ctx.act then 
				ctx.act = false
				ctx:OnIdle()
			end
		end
	end 
end)

/*hook.Add("SetupMove","UCombatBox_DragContext_Wheel",function(ply,mv,cmd)
	
	for k,ctx in pairs(contexts) do
		if ctx.Enabled then
			ctx:Think()
		end
	end
end)*/

hook.Add("PostDrawTranslucentRenderables","UCombatBox_DragContext_Draw",function()
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

function DragContext:Remove()
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
