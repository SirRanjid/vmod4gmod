local PLUG = {}
PLUG.Name = "Health"

local hp_mat = Material("icon16/heart.png")
local ScrW, ScrH, sqrt = ScrW, ScrH, math.sqrt

function PLUG:Init()
	self.x = ScrW()/2-220
	self.y = ScrH()*0.8
	self.w = 300
	self.h = 24
	self.ang = Angle(89,87,10)
	--self:Make3D(true,Angle(85,88,0))
	self:Make3D(true,Angle(-5,-2,0))

	self:hook( "HUDShouldDraw", "HideCHudHealth", function( name )
		if name == "CHudHealth" then return false end
	end )

	self:AddButton("test","test",4,6,10,10)
end
local chp = 0
local dhp = 0
local hp = 0
local up2 = {}
local SysTime = SysTime

function PLUG:Draw(x,y,w,h,mx,my)
	--surface.SetDrawColor(255,0,0,255)
	--surface.DrawOutlinedRect(0,0,ScrW(),ScrH())
	--surface.DrawOutlinedRect(ScrW()/4,ScrH()/4,ScrW()/2,ScrH()/2)
	if chp <= 0 then return end 
	self:DrawBar(up2,x,y,w,h,LocalPlayer():Health(),100,self.ang,hp_mat,Color(135,140,16),Color(25,25,25,150))
	--self:DrawBar(up,x,y,w,h,ammo,ammo_max,Angle(89,93,0),am_mat,Color(60,185,16),Color(25,25,25,150))
end

local flr = math.floor

function PLUG:Think()
	hp = LocalPlayer():Health()
	if hp <= 0 then if chp ~= hp then chp = hp end return end
	local w2,h2,scw2,sch2 = self.w/2,self.h/2,ScrW()/2,ScrH()/2
	if dhp-hp ~= 0 then
		local delta = hp-dhp
		local mdl = math.min(100,math.abs(delta))/100
		local min = math.min(hp,dhp)
		local mhp = math.max(100,hp)
		if dhp < hp then --gain hp
			self:BarAddChunk(up2,hp,delta,min,mhp,1.3+0.04*mdl)
		else --lose hp
			self:BarAddChunk(up2,hp,delta,min,mhp,0.2+0.06*mdl)
		end
		dhp = hp
		chp = hp
	end
end

UCombatBox.AddHudElement(PLUG)