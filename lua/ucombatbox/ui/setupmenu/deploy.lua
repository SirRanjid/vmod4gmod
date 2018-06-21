local PLUG = {}
PLUG.Parent = "mode"
PLUG.Name = "Finish"
					--new,old(server request update),sub()
local function subtbl(t1,t2,tc)
	for k,v in pairs(t1) do
		if t2[k] then
			if istable(t1[k]) and istable(t2[k]) then
				tc[k] = tc[k] or {}
				subtbl(t1[k],t2[k],tc[k])
				if not next(tc[k]) then tc[k] = nil end
			elseif t1[k] ~= t2[k] then
				tc[k] = v
			end
		end
	end
end

/*do
	local t1 = {
		["a"] = {
			["a"] = {1,4,7},
			["b"] = {5,2},
		},
		["7"] = 7,
		["2"] = 6,
		["3"] = 6,
	}
	local t2 = {
		["a"] = {
			["a"] = {1,4,7},
			["b"] = {5,4,7},
		},
		["7"] = 5,
		["2"] = 6,
	}

	local test_ = {}
	subtbl(t1,t2,test_)
	PrintTable(test_)
	returns:
	7	=	7
	a:
			b:
					2	=	2

end*/


local function addcheck(parent,menu,tbl,key,name)
	local new = parent:Add("DCheckBoxLabel")
	new:Dock(TOP)
	new:SetText( name )
	new:SetChecked(tbl[key])
	function new:OnChange( val ) print(key,val) tbl[key] = val end
	function new:Think () if tbl[key] ~= self:GetChecked() then new:SetChecked(tbl[key]) end end

	return new
end

function PLUG:Setup(parent, menu, ent)
	local deploy = parent:Add("DButton")
	deploy:SetTall(20)
	deploy:Dock(TOP)
	
	if ent.Data._SETUP then
		deploy:SetText( "Collapse" )
	else
		deploy:SetText( "Deploy" )
	end
	
	function deploy:DoClick()
		if ent.Data._SETUP then
			--ent:NetWorkMode("@c")
			ent:Collapse()
			self:SetText( "Deploy" )
		else
			ent:NetWorkMode("u",ent.Data)
			--ent:NetWorkMode("@d")
			ent:Deploy()
			self:SetText( "Collapse" )
		end
	end

	local commit = parent:Add("DButton")
	commit:SetTall(20)
	commit:Dock(TOP)

	commit:SetText( "Merge-Update" )
	
	function commit:DoClick()
		if ent:IsOperator(LocalPlayer()) then
			 --print("^U",ent)
			UCombatBox.NetWorkBaseMode("^U",ent,ent.Data)
			self:SetText( "Merging..." )
			self:SetDisabled( true )
		end
	end

	menu:hook("UCB_ReceiveUpdate","RequestMerge",function(ent,tbl)  --print("update!!",ent)

		local merge_tbl = {}
		subtbl(ent.Data,tbl,merge_tbl)

		commit:SetText( "Merge-Update" )
		commit:SetDisabled( false )

		if merge_tbl and next(merge_tbl) then
			ent:HandleNetwork( "u", tbl )
			ent:NetWorkMode("m",table.Copy(merge_tbl))
			menu.AddSurfacePrint("Merge-Update",Vector(100,255,200),2,"Success.",true)
		else
			menu.AddSurfacePrint("Merge-Update",Vector(255,255,255),2,"Nothing to merge.",true)
		end

	end)

	local god 		= addcheck(parent,menu,ent.Data._R,"god","Local Godmode")
	god:DockMargin(0,10,0,0)
	local noclip 	= addcheck(parent,menu,ent.Data._R,"noclip","Allow Noclip")
	noclip:DockMargin(0,0,0,6)
	local spwnmn 	= addcheck(parent,menu,ent.Data._R,"spawnmenu","Allow Spawnmenu")
	local spwnn 	= addcheck(parent,menu,ent.Data._R,"spawning","Allow Spawning")
	spwnn:DockMargin(0,0,0,6)
	local isolatev 	= addcheck(parent,menu,ent.Data,"_V","Isolate View")
	local showpla 	= addcheck(parent,menu,ent.Data,"_VP","Always Show Players")
	local solidb 	= addcheck(parent,menu,ent.Data,"_SB","Solid Box")
	
	solidb:DockMargin(0,0,0,10)

	/*local owner = parent:Add("DLabel")
	owner:Dock(TOP)
	owner:SetText( "Owner: "..tostring(ent:GetOwnerEnt()) )
	
	local ostd = parent:Add("DLabel")
	ostd:Dock(TOP)
	ostd:SetText( "Owner: "..tostring(ent:GetOwnerStdID()) )*/
	
	local setup = parent:Add("DLabel")
	setup:Dock(TOP)
	setup:SetText( "Setup: "..tostring(ent.Data._SETUP) )
	setup.Think = function(self) self:SetText( "Setup: "..tostring(ent.Data._SETUP) ) end
	
	local ID = parent:Add("DLabel")
	ID:Dock(TOP)
	ID:SetText( "ID:"..tostring(ent:EntIndex()) )
end

UCombatBox.AddMenuPlugin(PLUG)