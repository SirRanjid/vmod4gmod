local PLUG = {}
PLUG.Name = "Ammo Secondary"

local am_mat = Material("icon16/bomb.png")
local ScrW, ScrH, sqrt = ScrW, ScrH, math.sqrt

function PLUG:Init()
	self.x = ScrW()/2+220
	self.y = ScrH()*0.8
	self.w = 300
	self.h = 24
	
	self:Make3D(true,Angle(-2,1,0))

	self:hook( "HUDShouldDraw", "HideCHudSecondaryAmmo", function( name )
		if name == "CHudSecondaryAmmo" then return false end
	end )

	self:AddButton("test","test",4,6,10,10)
end
local cmm = 0
local dam = 0
local am = 0
local up = {}
local SysTime = SysTime

local function ammo_primary(ply)
	if not IsValid(ply) then return -1 end
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return -1 end
	return ply:GetAmmoCount( wep:GetSecondaryAmmoType() )
end

local function ammo_primary_reserve(ply)
	if not IsValid(ply) then return -1 end
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return -1 end
	return ply:GetAmmoCount( wep:GetSecondaryAmmoType() )
end --#returns 0?

local function ammo_primary_max(ply)
	return 6
end

function PLUG:Draw(x,y,w,h,mx,my)
	local ammo = ammo_primary(LocalPlayer())
	if ammo <= 0 then return end --Angle(0,ang.y-90,-ang.p-ang.r+80)
	local ammo_res, ammo_max = ammo_primary_reserve(LocalPlayer()), ammo_primary_max(LocalPlayer())
	self:DrawBarInv(up,x,y,w,h,ammo,ammo_max,Angle(89,93,0),am_mat,Color(60,185,16),Color(25,25,25,150),1.3)
end

local flr = math.floor
local lwep = LocalPlayer():GetActiveWeapon()
function PLUG:Think()
	am, ammo_max = ammo_primary(LocalPlayer()), ammo_primary_max(LocalPlayer())
	local w2,h2,scw2,sch2 = self.w/2,self.h/2,ScrW()/2,ScrH()/2
	if cmm <= 0 then if cmm ~= am then cmm = am end return end
	if dam != am then
		if lwep == LocalPlayer():GetActiveWeapon() then
			local delta = am-dam
			local min = math.min(am,dam)
			if dam < am then --gain am
				self:BarAddChunk(up,am,delta,min,ammo_max,0.25)
			else --lose hp
				self:BarAddChunk(up,am,delta,min,ammo_max,0.25)
			end
		else
			lwep = LocalPlayer():GetActiveWeapon()
		end
		dam = am
		cmm = am
	end
end

UCombatBox.AddHudElement(PLUG)