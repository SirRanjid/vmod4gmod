local PLUG = {}
PLUG.Parent = "mode"
PLUG.Name = "Save/Load"

local saves = {}

function testprintsaves()
	PrintTable(saves)
end

if not file.Exists("UCombatBox","DATA") then
	file.CreateDir( "UCombatBox" ) 
end

if file.Exists("UCombatBox/saves.txt","DATA") then
	saves = UCombatBox.pon.decode(file.Read("UCombatBox/saves.txt","DATA"))
end

do	--copy function that copies the userdata i need!
	local C = {
		Vector = function(v) return Vector(v.x,v.y,v.z) end,
		Angle = function(v) return Angle(v.p,v.y,v.r) end,
		Color = function(v) return Color(v.r,v.g,v.b,v.a) end,
	}

	function table.CopyC( t, lookup_table )
		if ( t == nil ) then return nil end

		local copy = {}
		setmetatable( copy, debug.getmetatable( t ) )
		for i, v in pairs( t ) do
			if ( !istable( v ) ) then
				if C[type(v)] then
					copy[ i ] = C[type(v)](v)
				else
					copy[ i ] = v
				end
			else
				lookup_table = lookup_table or {}
				lookup_table[ t ] = copy
				if ( lookup_table[ v ] ) then
					copy[ i ] = lookup_table[ v ] -- we already copied this table. reuse the copy.
				else
					copy[ i ] = table.CopyC( v, lookup_table ) -- not yet copied. copy it.
				end
			end
		end
		return copy
	end
end

local function savefunc(ent,nm)
	local tmp = table.CopyC(ent.Data)
	tmp._O = nil
	tmp._P = nil
	tmp._SETUP = nil
	saves[nm] = {name = nm, map = game.GetMap(), time = os.time(), owner = LocalPlayer():SteamID() ,content = tmp}
	file.Write("UCombatBox/saves.txt",UCombatBox.pon.encode(saves))
end

function PLUG:Setup(parent, menu, ent)
	
	
	local pnl = parent:Add("DPanel")
	pnl:SetTall( 20 )
	pnl:Dock(TOP)
	
	local sv_txt= pnl:Add("DTextEntry2")
	sv_txt:Dock(TOP)
	--te_pos:SetMultiline(true)
	sv_txt:SetText( "" )
	sv_txt:SetUpdateOnType(true)
	sv_txt.OnEnter = function( self )
		--self:GetValue()
	end


	local save = parent:Add("DButton")
	save:SetTall(20)
	save:Dock(TOP)
	
	save:SetText( "Save As" )
	save.override = false
	
	function sv_txt:OnValueChange( str )
		save.override = false

		if saves[str] then
			self.m_colText = Color(255,160,0,255)
		else
			self.m_colText = Color(0,0,0,255)
		end
		
	end
	
	local SavesP = parent:Add("DCollapsibleList")
	SavesP:SetLabel("Saves")
	
	function SavesP:Update()
		self:Clear()
		
		local lookup = table.ClearKeys( saves ) 
		
		table.sort(lookup,function(a,b)
			return a.time > b.time
		end)
	
	
		for k,v in ipairs(lookup) do
			local load_x = SavesP:Add("DButton")
			load_x:SetTall(16)
			load_x:Dock(TOP)
			load_x:SetText( v.name )
			function load_x:DoClick()
				if ent.Data._SETUP then menu.AddSurfaceInfo("\nLoading failed",Vector(255,120,0),2,v.name..": Can't load when deployed.",false) return end
				v.content._O = ent.Data._O
				v.content._P = ent.Data._P
				v.content._SETUP = ent.Data._SETUP
				--ent.Data = table.CopyC(v.content)
				table.Merge(ent.Data,table.CopyC(v.content))

				if menu.UpdateEnts then menu:UpdateEnts() end 
				
				menu.AddSurfaceInfo("\nLoaded",v.map == game.GetMap() and Vector(0,255,120) or Vector(255,120,0),5,v.name.." (Map: "..v.map.."; Time: "..os.date( "%H:%M:%S - %d %b %Y" , v.time)..")",true)
				menu.name:SetText(ent.Data._N)
				menu.ctx:StopDragging()
				hook.Call("UCB_Setup_Load",GAMEMODE)
			end
			
			load_x:SetColor(v.map == game.GetMap() and Color(0,120,30) or Color(120,30,0))
			
			function load_x:DoRightClick()
				sv_txt:SetText(v.name)
				sv_txt.m_colText = Color(255,160,0,255)
			end
			
			local del = load_x:Add("DButton")
			del:SetTall(16)
			del:SetWide(16)
			del:Dock(RIGHT)
			del:SetText( "X" )
			del:SetColor( Color(255,0,0,255) )
			function del:DoClick()
				saves[v.name] = nil
				file.Write("UCombatBox/saves.txt",UCombatBox.pon.encode(saves))
				SavesP:Update()
			end
			
		end
	end
	
	function save:DoClick()
		local name = sv_txt:GetValue()
		if saves[name] then
			if save.override then
				save.override = false
				savefunc(ent,name)
				SavesP:Update()
				save:SetText( "Save As" )
				menu.AddSurfacePrint("Saved",Vector(0,255,0),1.8,name,true)
			else
				save.override = true
				save:SetText( "Confirm Override" )
			end
		else
			savefunc(ent,name)
			SavesP:Update()
			save:SetText( "Save As" )
		end
	end
	
	function save:DoRightClick()
		if save.override then
			save.override = false
			save:SetText( "Save As" )
			menu.AddSurfacePrint("Cancelled",Vector(255,255,0),1.4,sv_txt:GetValue(),true)
		end
	end
	
	SavesP:Update()
	
end

UCombatBox.AddMenuPlugin(PLUG)