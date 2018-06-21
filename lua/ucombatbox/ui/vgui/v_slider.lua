
local PANEL = {}

AccessorFunc( PANEL, "m_val", "Value" )
AccessorFunc( PANEL, "m_min", "Max" )
AccessorFunc( PANEL, "m_max", "Min" )
AccessorFunc( PANEL, "m_stp", "Step" )
AccessorFunc( PANEL, "m_dig", "Digits" )

AccessorFunc( PANEL, "m_live", "Live" )

--Derma_Hook( PANEL, "Paint", "Paint", "Slider" )

function PANEL:Init()

	self:SetMouseInputEnabled( true )
	
	self:SetValue( 0 )
	self:SetMin( 400 )
	self:SetMax( 4000 )
	self:SetStep( 50 )
	self:SetValue( 400 )
	
	self:SetLive( true )
	
	self.fld = {
--		 % R   % T     %  L   % B [func]
		{0,2,  0,2,  0.8,-1,  1,-2},
		
		{0.8,1, 0,2, 0.5,-2, 1, -2},
		{0.8,1, 0.5,1, 0.5,-2, 1, -2},
	}
	
	local function OnMoveWang1 (mx,my,dmx,dmy,pcx,pcy)
		local dig = (self.m_dig^10)*m_stp
		
		local val= pcx * (self.m_max-self.m_min) + self.m_min
	
		self:SetValue(math.Clamp(math.floor(val*dig)/dig,self.m_min,self.m_max))
	end
	
	local function Paint1 (mx,my,dmx,dmy,pcx,pcy)
		local dig = (self.m_dig^10)*m_stp
		
		local val= pcx * (self.m_max-self.m_min) + self.m_min
	
		self:SetValue(math.Clamp(math.floor(val*dig)/dig,self.m_min,self.m_max))
	end
	
	
	--self:AddField({0,2,  0,2,  0.8,-1,  1,-2},OnMoveWang,,true)
end

function PANEL:AddField(tbl,func1,func2,func3)
	self.fld[#self.fld+1] = {unpack(tbl), OnMove =func1, Paint = func2, CanEdit = func3}
end

do
	--local su = surface
	
	local function inrange(tbl,mx,my)
		if mx > tbl[1] and mx < tbl[2] and my > tbl[3] and my < tbl[4] then
			return true, (mx-tbl[1])/(mx-tbl[3]), (mx-tbl[2])/(mx-tbl[4])
		else
			return false
		end
	end
	
	local cap = false
	local lpx,lpy = 0,0
	
	function PANEL:Paint(w,h)
	
		surface.SetDrawColor(50,50,50,70)
		surface.DrawRect(0,0,w,h)
		
		surface.SetDrawColor(50,50,50,70)
		for k,v in ipairs(self.mtx) do
				local mtx = {w*v[1]+v[2],
							h*v[3]+v[4],
							w*(v[5]-v[1])+(v[6]-v[2]),
							w*(v[7]-v[3])+(v[8]-v[4])}
								
			local inr,pcx,pcy = inrange(mtx,px,py)
			
			if inr then
				surface.SetDrawColor(150,150,150,170)
				
				if not cap and input.IsMouseDown(MOUSE_LEFT) then 
					cap = true
					lpx,lpy = self:CursorPos()
				end
			else
				surface.SetDrawColor(50,50,50,70)
			end
			if cap then
				if input.IsMouseDown(MOUSE_LEFT) then 
					local px,py = self:CursorPos()
					local dpx,dpy = px-lpx, py-lpy
					lpx,lpy = px,py
					
					local dpx
					
				else 
					cap = false
				end
			end
			
			surface.DrawRect(unpack[mtx])
				
								
		end
	end
end

--
-- We we currently editing?
--
function PANEL:IsEditing()

	return self.Dragging || self.Depressed

end

function PANEL:OnCursorMoved( x, y )

	if ( !self.Dragging && !self.Depressed ) then return end

	local w, h = self:GetSize()
	local iw, ih = 8,8 --self:GetSize()

	if ( self.m_bTrappedInside ) then

		w = w - iw
		h = h - ih

		x = x - iw * 0.5
		y = y - ih * 0.5

	end

	x = math.Clamp( x, 0, w ) / w
	y = math.Clamp( y, 0, h ) / h

	if ( self.m_iLockX ) then x = self.m_iLockX end
	if ( self.m_iLockY ) then y = self.m_iLockY end

	x, y = self:TranslateValues( x, y )

	self:SetSlideX( x )
	self:SetSlideY( y )

	self:InvalidateLayout()

end

function PANEL:TranslateValues( x, y )

	-- Give children the chance to manipulate the values..
	return x, y

end

function PANEL:OnMousePressed( mcode )

	self:SetDragging( true )
	self:MouseCapture( true )

	local x, y = self:CursorPos()
	self:OnCursorMoved( x, y )

end

function PANEL:OnMouseReleased( mcode )

	self:SetDragging( false )
	self:MouseCapture( false )

end



derma.DefineControl( "UCBSlider", "", PANEL, "Panel" )
