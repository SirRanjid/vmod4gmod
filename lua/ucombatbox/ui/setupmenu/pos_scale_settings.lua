--panels for moving/scaling and some settings

local scroll_speed = UCombatBox.scroll_speed
local ucb_zoom = UCombatBox.ucb_zoom
local ucb_light = UCombatBox.ucb_light

local PLUG = {}
PLUG.Parent = "global"
PLUG.Name = "Pos/Scale"

local flr = math.floor
local function floor1000(num)
	return flr(num*1000)/1000
end

function PLUG:Setup(parent, menu, ent)
	
	local Position = parent:Add("DCollapsibleList")
	Position:SetLabel("Position")
	
	local Scale = parent:Add("DCollapsibleList")
	Scale:SetLabel("Scale")
	
	local show = Scale:Add("DCheckBoxLabel")
	show:SetTall(20)
	--show:Dock(TOP)
	show:SetText("Show")
	show:SetValue(menu.scx:GetEnabled())
	function show:OnChange( val )
		menu.scx:SetEnabled(val)
		menu.scy:SetEnabled(val)
		menu.scz:SetEnabled(val)
	end
	function show:Think()
		if self:GetChecked() ~= menu.scx:GetEnabled() then
			self:SetValue( menu.scx:GetEnabled()  ) 
		end
	end
	
	--Scale:SizeToContentsY()
	
	local te_sca= Scale:Add("DTextEntry2")
	te_sca:SetTall( 20 )
	--te_pos:SetMultiline(true)
	te_sca:SetText( ent.Data.SIZE.x..", "..ent.Data.SIZE.y..", "..ent.Data.SIZE.z )
	te_sca.OnEnter = function( self )
		local val = string.gsub(self:GetValue(),"[^%d%-%p]","")
		local expl = string.Explode( "%s-,%s-", val:Trim(), true )
		
		ent.Data.SIZE.x = math.Clamp(UCombatBox.MathParse:Calculate(expl[1]) or ent.Data.SIZE.x,ent.MinScale.x,ent.MaxScale.x)
		ent.Data.SIZE.y = math.Clamp(UCombatBox.MathParse:Calculate(expl[2]) or ent.Data.SIZE.y,ent.MinScale.y,ent.MaxScale.y)
		ent.Data.SIZE.z = math.Clamp(UCombatBox.MathParse:Calculate(expl[3]) or ent.Data.SIZE.z,ent.MinScale.z,ent.MaxScale.z)
		
		menu.ctx:StopDragging()
		
		self:SetText( floor1000(ent.Data.SIZE.x)..", "..floor1000(ent.Data.SIZE.y)..", "..floor1000(ent.Data.SIZE.z) )
	end

	local show = Position:Add("DCheckBoxLabel")
	show:SetTall(20)
	show:Dock(TOP)
	show:SetText("Show")
	show:SetValue(menu.ctx:GetEnabled())
	function show:OnChange( val )
		menu.ctx:SetEnabled(val)
		menu.cty:SetEnabled(val)
		menu.ctz:SetEnabled(val)
	end
	function show:Think()
		if self:GetChecked() ~= menu.ctx:GetEnabled() then
			self:SetValue( menu.ctx:GetEnabled()  ) 
		end
	end
	
	local te_pos = Position:Add("DTextEntry2")
	te_pos:SetTall( 20 )
	--te_pos:SetMultiline(true)
	te_pos:SetText( ent.Data.POS.x..", "..ent.Data.POS.y..", "..ent.Data.POS.z )
	te_pos.OnEnter = function( self )
		local val = string.gsub(self:GetValue(),"[^%d%-%p]","")
		local expl = string.Explode( "%s-,%s-", val:Trim(), true )
		
		ent.Data.POS.x = UCombatBox.MathParse:Calculate(expl[1]) or ent.Data.POS.x
		ent.Data.POS.y = UCombatBox.MathParse:Calculate(expl[2]) or ent.Data.POS.y
		ent.Data.POS.z = UCombatBox.MathParse:Calculate(expl[3]) or ent.Data.POS.z
		
		menu.ctx:StopDragging()
		
		self:SetText( floor1000(ent.Data.POS.x)..", "..floor1000(ent.Data.POS.y)..", "..floor1000(ent.Data.POS.z) )
	end
	
	Position:SetTall(110)

	local Settings = parent:Add("DCollapsibleList")
	Settings:SetLabel("Settings")
	
	local light = Settings:Add("DCheckBoxLabel")
	light:SetTall(20)
	light:Dock(TOP)
	light:SetText("Toggle Light")
	light:SetValue(ucb_light:GetBool())
	function light:OnChange( val )
		ucb_light:SetBool(val)
	end
	function light:Think()
		if self:GetChecked() ~= ucb_light:GetBool() then
			self:SetValue( ucb_light:GetBool()  ) 
		end
	end
	
	local zoom = Settings:Add("DNumSlider")
	zoom:SetTall(20)
	zoom:Dock(TOP)
	zoom:SetText( "Zoom:" )
	zoom:SetMin( 0 )
	zoom:SetMax( 20 )
	zoom:SetDecimals( 2 )
	zoom:SetValue( ucb_zoom:GetFloat() ) 
	function zoom:OnValueChanged( val )
		ucb_zoom:SetFloat(val)
	end
	function zoom:Think()
		if self:GetValue() ~= ucb_zoom:GetFloat() then
			self:SetValue( ucb_zoom:GetFloat()  ) 
		end
	end
	
	local speed = Settings:Add("DNumSlider")
	speed:SetTall(20)
	speed:Dock(TOP)
	speed:SetText( "Speed:" )
	speed:SetMin( 25 )
	speed:SetMax( 1000 )
	speed:SetDecimals( 0 )
	speed:SetValue( scroll_speed:GetFloat()*100 ) 
	function speed:OnValueChanged( val )
		scroll_speed:SetFloat(val/100)
	end
	function speed:Think()
		if self:GetValue() ~= scroll_speed:GetFloat()*100 then
			self:SetValue( scroll_speed:GetFloat()*100  ) 
		end
	end
	
	local help = Settings:Add("DButton")
	help:SetTall(20)
	help:Dock(TOP)
	help:SetText( "Help" )
	function help:DoClick()
		menu.PrintHelp()
	end
	
	
	local function update_pos_sca()
		te_sca:SetText( floor1000(ent.Data.SIZE.x)..", "..floor1000(ent.Data.SIZE.y)..", "..floor1000(ent.Data.SIZE.z) ) 
		te_pos:SetText( floor1000(ent.Data.POS.x)..", "..floor1000(ent.Data.POS.y)..", "..floor1000(ent.Data.POS.z) )
	end
	
	menu:hook("UCB_Setup_StopDragging","ucb_postextentry",update_pos_sca)
	menu:hook("UCB_Setup_OnDragging","ucb_postextentry",update_pos_sca)
	menu:hook("UCB_Setup_Load","ucb_postextentry",update_pos_sca)
	
end

UCombatBox.AddMenuPlugin(PLUG)