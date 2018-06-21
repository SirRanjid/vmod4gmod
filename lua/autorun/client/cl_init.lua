--[[How it will look on the client]]


include("../shared.lua")

UCombatBox.ViewOrigins = {}

local mat2 = Material( "models/debug/debugwhite" )
local trail = Material( "trails/laser" )
local sprite = Material( "sprites/grip" )

local sin, ct, clmp = math.sin, CurTime, math.Clamp
local SuppressEngineLighting, Start3D, DrawWireframeBox, DrawBox, DrawLine, SetMaterial, DrawSprite, End3D = render.SuppressEngineLighting, cam.Start3D, render.DrawWireframeBox, render.DrawBox, render.DrawLine, render.SetMaterial, render.DrawSprite, cam.End3D
local LocalPlayer = LocalPlayer

local IgnoreZ = cam.IgnoreZ

local render = render

local mat1 = Material("models/debug/debugwhite")

hook.Add( "PreDrawTranslucentRenderables", "FixEyePos", function() EyePos() EyeAngles() EyeVector() end )
--http://wiki.garrysmod.com/page/Global/EyePos

hook.Add("DrawPhysgunBeam","UCombatBox_PGBeam",function(ply, wep, bool, target, bone, pos)
	if UCombatBox.ents[target] then --because the physgun beam fails anyways with drawing at the right location
		Start3D()
			local ti = ct()%1
			local thepos = target:LocalToWorld(pos)
			DrawWireframeBox( target:GetPos(), target:GetAngles(), target:OBBMins(), target:OBBMaxs(), Color(255*ti,0,0), true )
		End3D()
		return false
	end
end)

local lpos = Vector()
local pos = Vector()

local DMat = Material("depthteststt2")

--[[hook.Add("HUDPaint","UCombatBox_DrawBoxes_TEST",function(a,b)
	/*render.UpdateFullScreenDepthTexture() 
	DMat:SetTexture( "$BASETEXTURE", render.GetPowerOfTwoTexture() )
	DMat:SetTexture( "$DEPTHTEXTURE", render.GetResolvedFullFrameDepth() )
	DMat:SetFloat( "$distancealpha", 1 )
	surface.SetMaterial(DMat)
	surface.SetDrawColor(255,255,255,150)
	surface.DrawTexturedRect(0,0,ScrW(),ScrH())*/
end)]]

hook.Add("HUDPaint","ucb_overlay",function()
	for k,v in ipairs(ents.GetAll()) do
		if IsValid(v) and not v:IsWorld() then
			local tbl= v:GetPos():ToScreen()
			if tbl.visible and not v:IsWorld() and (v == LocalPlayer() or v:GetOwnerEnt() ~= NULL) then
				surface.SetFont("BudgetLabel")
				surface.SetTextColor(255,255,255,255)
				surface.SetTextPos(tbl.x,tbl.y)
				surface.DrawText("["..v:EntIndex().."]: "..tostring(v.UCombatBox))
				surface.SetTextPos(tbl.x,tbl.y+12)
				surface.DrawText("O:"..tostring(v:GetOwnerEnt()))

				if UCombatBox.ents[v] then
					surface.SetTextColor(1,255,180,255)
					surface.SetTextPos(tbl.x,tbl.y+24)
					surface.DrawText("UCB "..tostring(v.Data._SETUP))
				end
				surface.SetTextPos(tbl.x,tbl.y+36)
				surface.DrawText("C:"..tostring(v:GetUCBShouldCollide(LocalPlayer(),"alt")).." C2:"..tostring(LocalPlayer():GetUCBShouldCollide(v,"alt")))
				-- --print(v,tostring(v.UCombatBox))
			end
		end

	end
end)

hook.Add("PostDrawTranslucentRenderables","UCombatBox_DrawBoxes",function(a,b)
	if a or b then return end

	for ent,_ in pairs(UCombatBox.ents) do
		
		if ent.Data._SETUP then --when deployed
			--#+clientside variable for suppressing rendering of boxes
			lpos = pos
			pos = ent.Data.POS
			local distd = 1-clmp(((ent.CENTER - LocalPlayer():GetPos()):Length()-ent.Data.SIZE:Length())/1000,0,1)
			if ent.Anim then
				local ti = ent.DPT-ct()
				Start3D()
				if ti > 0 then
					local frac = (ti*2)^1.5
					local scale  = 1-frac
					local bl  = (sin(ct()*50)+1)*0.5
					DrawWireframeBox( ent.prepos*Vector(frac,frac,frac)+pos*Vector(scale,scale,scale), Angle(0,0,0), Vector(0,0,0), ent.Data.SIZE*scale, Color(255*distd*scale,255*frac,255*frac), true )
				else
					ent.Anim =false
					DrawWireframeBox( pos, Angle(0,0,0), Vector(0,0,0), ent.Data.SIZE, Color(255*distd,0,0), true )
				end
				End3D()
			else

				Start3D()
					if ent == LocalPlayer().UCombatBox then
						DrawWireframeBox( pos, Angle(0,0,0), Vector(0,0,0), ent.Data.SIZE, Color(0,255*distd,160*distd), true )
					else
						DrawWireframeBox( pos, Angle(0,0,0), Vector(0,0,0), ent.Data.SIZE, Color(255*distd,0,0,255*distd), true )
					end
				End3D()
			end


		elseif ent:IsOperator(LocalPlayer(),true) then --# -,true
			Start3D()
				--render.SetMaterial( mat2 )
				--render.DrawBox( pos, ent:GetAngles(), Vector(0,0,0), ent.Data.SIZE, Color(255,160,0), true )
				
				local mpos, pos2, add, hit = ent:GetMagneticPos()
				local posz = pos2 -- + Vector(0,0,ent.Data.SIZE.z/2)
				DrawWireframeBox( mpos , Angle(0,0,0), Vector(0,0,0), ent.Data.SIZE, Color(0,0,255,150), false )
				DrawWireframeBox( mpos , Angle(0,0,0), Vector(0,0,0), ent.Data.SIZE, Color(0,255,100,255), true )
				

				DrawLine( posz, posz - Vector(0,0,(ent.Data.SIZE.z/2)+ent.MAG), Color(150,150,255), true )
				DrawLine( posz, posz + Vector(0,0,(ent.Data.SIZE.z/2)+ent.MAG), Color(0,0,255), true )
				
				DrawLine( posz, posz - Vector(0,ent.MAG,0), Color(150,255,150), true )
				DrawLine( posz, posz + Vector(0,ent.Data.SIZE.y+ent.MAG,0), Color(0,255,0), true )
				
				DrawLine( posz, posz - Vector(ent.MAG,0,0), Color(255,150,150), true )
				DrawLine( posz, posz + Vector(ent.Data.SIZE.x+ent.MAG,0,0), Color(255,0,0), true )
				
				SetMaterial( sprite )
				DrawSprite( pos2, 14,14, Color(255,255,255) )
				SetMaterial( trail )
				for i, v in next, hit do
					local len = (posz-v[1]):Length()
					DrawWireframeBox( posz, v[2], Vector(-1,-1,1), Vector(1,1,len), Color(0,255,255), true )
					DrawWireframeBox( v[1], v[3]:Angle(), Vector(-1,-10,-10), Vector(1,10,10), Color(0,255,160), true )
					
					--render.DrawBeam(posz, v[1], 20, 0, len/20, Color(0,255,255))
				end
			End3D()
		end
		
		if not ent.Data._SETUP then
			cam.Start3D2D(ent:LocalToWorld( Vector( -14, 0, 25 ) ), ent:GetAngles(),0.2)
				surface.SetFont("BudgetLabel")
				surface.SetTextColor(255,255,255,255)
				surface.SetTextPos(0,-12)
				surface.DrawText("VMod Box:")
				surface.SetTextPos(0,0)
				surface.DrawText("["..ent:EntIndex().."] "..ent.Data._N)
				surface.SetTextPos(0,16)
				if ent:GetOwnerEnt() and ent:GetOwnerEnt().Name then surface.DrawText("["..tostring(ent:GetOwnerEnt()).."]") end
				surface.SetTextPos(0,28)
				-- --print(ent:GetOwnerStdID())
				surface.DrawText("["..ent:GetOwnerStdID().."]")
				
				if ent:GetOwnerEnt() == LocalPlayer() then
					surface.SetTextColor(0,255,200,255)
					surface.SetTextPos(0,46)
					surface.DrawText("Press Use to Edit")
				end
			
			cam.End3D2D()
		end
	end
end)