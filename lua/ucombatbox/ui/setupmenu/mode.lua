local PLUG = {}
PLUG.Parent = "mode"
PLUG.Name = "Mode"


function PLUG:Setup(parent, menu, ent)
	
	function parent:Update()
		self:Clear()

		for k,v in pairs(UCombatBox.GameModes) do
			if v.PLAYABLE ~= false then
				local load_x = self:Add("DButton")
				load_x:SetTall(16)
				load_x:Dock(TOP)
				load_x:SetText( v.Title.." ("..v.ID..")" )
				function load_x:DoClick()
					parent:SetTextColor(Color(255,255,255))
					parent:SetLabel(PLUG.Name..": "..v.Title)
					ent:SetMode(v.ID)
					menu.AddSurfacePrint("Mode",Vector(255,255,255),1.8,v.Title,true)
				end

				/*function load_x:DoRightClick()

				end*/
			end
		end

		if UCombatBox.GameModes[ent.Data._R.mode] and ent.Data._R.mode != "base" then
			parent:SetLabel(PLUG.Name..": "..UCombatBox.GameModes[ent.Data._R.mode].Title)
			parent:SetTextColor(Color(255,255,255))
			menu.AddSurfacePrint("Mode",Vector(255,255,255),1.8,UCombatBox.GameModes[ent.Data._R.mode].Title,true)
		else
			parent:SetLabel(PLUG.Name..": "..UCombatBox.GameModes[ent.Data._R.mode].Title)
			parent:SetTextColor(Color(255,160,40))
		end
	end
	
	parent:SetTextColor(Color(255,160,40))
	
	menu:hook("UCB_Setup_Load","updatemodepnl",function()
		parent:Update()
	end)
	
	parent:Update()
	
end

UCombatBox.AddMenuPlugin(PLUG)