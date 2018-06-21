local PLUG = {}
PLUG.Name = "Armor"

local ar_mat = Material("icon16/shield.png")
local ScrW, ScrH, sqrt = ScrW, ScrH, math.sqrt

function PLUG:Init()
	--self.x = ScrW()/2-220
	--self.y = ScrH() - 220
	self.x = ScrW()/2-220
	self.y = ScrH()*0.8
	self.w = 300
	self.h = 24

	--self:Make3D(false,Angle(87,90,0))
	self:Make3D(true,Angle(-8,-3,0))


	self:hook( "HUDShouldDraw", "HideCHudBattery", function( name )
		if name == "CHudBattery" then return false end
	end )

	self:AddButton("test","test",4,6,10,10)
end
local car = 0
local dar = 0
local ar = 0
local up = {}
local SysTime = SysTime

function PLUG:Draw(x,y,w,h,mx,my)
	if car <= 0 then return end
	self:DrawBar(up,x,y,w,h,LocalPlayer():Armor(),100,Angle(89,87,0),ar_mat,Color(240,190,33),Color(25,25,25,150))
end

local flr = math.floor
function PLUG:Think()
	ar = math.Clamp(LocalPlayer():Armor(),0,100)
	if car <= 0 then if car ~= ar then car = ar end return end
	if dar != ar then
		local delta = ar-dar
		local min = math.min(ar,dar)
		if dar < ar then --gain ar
			self:BarAddChunk(up,ar,delta,min,math.max(100,ar),0.2)
		else --lose hp
			self:BarAddChunk(up,ar,delta,min,math.max(100,ar),0.2)
		end
		dar = ar
		car = ar
	end
end

UCombatBox.AddHudElement(PLUG)