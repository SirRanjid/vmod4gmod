local PLUGM = {}
local bcol = Color(0,0,0,0)
local ncol = Color(0,0,0,0)
local col = Color(0,0,0,0)

local pos, ang,scw,sch,scw2,sch2,dist,flr,cil = EyePos(), EyeAngles(), ScrW(),ScrH(), ScrW()/2,ScrH()/2,math.sqrt(ScrW()*ScrH())/2,math.floor,math.ceil

	hook.Add("UCB_HUD_UpdtRes","BarUpdateRes",function(sw,sh)
		scw,sch,scw2,sch2,dist = sw,sh,sw/2,sh/2,math.sqrt(sw*sh)/2
	end)

function PLUGM:DrawBar(tbl,x,y,w,h,val,max,ang,mat,ca,col_bg)
	col = HSVToColor(ca.r,0.5,0.9)
	bcol = HSVToColor(ca.g,0.8,1)
	ncol = HSVToColor(ca.b,0.8,1)

	local w2,h2 = w/2,h/2

	if self.is3d then
		x,y = scw2-w2, sch2-h2 --3d is centered
	else
		x,y = x-w2, y-h2
	end

	surface.SetDrawColor(col_bg)
	surface.DrawRect(x,y,w,h)
	
	if LocalPlayer().UCombatBox and LocalPlayer().UCombatBox.Data._R.god then
		surface.SetTextColor(255,225,21,120)
	else
		surface.SetTextColor(255,255,255,255)
	end
	surface.SetDrawColor(col.r,col.g,col.b,180)

	local co = math.Clamp(val/max,0,1)

	local mpx,mpy = 2+(w-4)*co+x,y+h2
	surface.DrawRect(2+x,2+y,flr((w-4)*co),h-4)
	surface.SetFont("ChatFont")
	--surface.DrawRect(0,0,1920,1080)
	local txt = ""
	local tsx, tsy = 0,0
	for i,v in ipairs(tbl) do
		local add = math.abs(v[8]*0.004)
		local t = v[2] + add
		local dt = v[9]
		if t > SysTime() then		
			if v[1] then --gain
				local dpl = (math.max(t - SysTime(),0)/(dt+add))^2
				surface.SetDrawColor(bcol.r,bcol.g,bcol.b,255*dpl)
				surface.SetTextColor(bcol.r,bcol.g,bcol.b,255)
				surface.DrawRect(flr(v[3]),v[4],flr(v[5]+1),v[6])
				txt = " [+"..v[8].."]"
				--tsx, tsy = surface.GetTextSize(txt)
				--surface.SetTextPos(v[3]+math.Clamp(v[5],14,30),mpy+dpl*v[6]*dt)
				if val < v[7] then v[2] = v[2] - FrameTime()*3 end
			else --loss
				local dpl = (math.max(t - SysTime(),0)/(dt+add))
				surface.SetDrawColor(ncol.r,ncol.g,ncol.b,255*dpl)
				surface.SetTextColor(ncol.r,ncol.g,ncol.b,255)
				surface.DrawRect(flr(v[3]),v[4]-math.Clamp(1-dpl,0,1)*v[6]*dt,flr(math.abs(v[5])),v[6])
				txt = " [-"..v[8].."]"
				--tsx, tsy = surface.GetTextSize(txt)
				--surface.SetTextPos(v[3]+math.Clamp(v[5],14,30),mpy-(1-dpl)*v[6]*dt)
				if val > v[7] then v[2] = v[2] - FrameTime()*3 end
			end
			--surface.DrawText(txt)
		else
			table.remove(tbl,i)
		end
	end

	if mat then
		surface.SetMaterial(mat)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(math.Clamp(mpx-18,x+4,x+w-20),mpy-8,16,16)
	end

	surface.SetFont("ChatFont")
	txt = val .. txt
	tsx, tsy = surface.GetTextSize(val)
	surface.SetTextPos(x+w-tsx-4,mpy-tsy/2)
	surface.DrawText(txt)
end

function PLUGM:DrawBarInv(tbl,x,y,w,h,val,max,ang,mat,ca,col_bg)
	col = HSVToColor(ca.r,0.5,0.9)
	bcol = HSVToColor(ca.g,0.8,1)
	ncol = HSVToColor(ca.b,0.8,1)

	local w2,h2 = w/2,h/2

	if self.is3d then
		x,y = scw2-w2, sch2-h2
	else
		x,y = x-w2, y-h2
	end

	surface.SetDrawColor(col_bg)
	surface.DrawRect(x,y,w,h)
	
	if LocalPlayer().UCombatBox and LocalPlayer().UCombatBox.Data._R.god then
		surface.SetTextColor(255,225,21,120)
	else
		surface.SetTextColor(255,255,255,255)
	end
	surface.SetDrawColor(col.r,col.g,col.b,180)

	local co = math.Clamp(val/max,0,1)

	local mpx,mpy = 2+(w-4)*co+x,y+h2
	surface.DrawRect(2+x,2+y,flr((w-4)*co),h-4)
	surface.SetFont("ChatFont")
	--surface.DrawOutlinedRect(0,0,1920,1080)
	local txt = ""
	local tsx, tsy = 0,0
	for i,v in ipairs(tbl) do
		local add = math.abs(v[8]/max*0.4)
		local t = v[2] + add
		local dt = v[9]
		if t > SysTime() then		
			if v[1] then --gaim
				local dpl = (math.max(t - SysTime(),0)/(dt+add))^2
				surface.SetDrawColor(bcol.r,bcol.g,bcol.b,255*dpl)
				surface.SetTextColor(bcol.r,bcol.g,bcol.b,255)
				surface.DrawRect(flr(v[3]),flr(v[4]),flr(v[5]),flr(v[6]))
				txt = "[+"..v[8].."] "
				if val < v[7] then v[2] = v[2] - FrameTime() end
			else --loss
				local dpl = (math.max(t - SysTime(),0)/(dt+add))
				surface.SetDrawColor(ncol.r,ncol.g,ncol.b,255*dpl)
				surface.SetTextColor(ncol.r,ncol.g,ncol.b,255)
				surface.DrawRect(flr(v[3]),flr(v[4]-math.Clamp(1-dpl,0,1)*v[6]*dt),flr(math.abs(v[5])),flr(v[6]))
				txt = "[-"..v[8].."] "
				if val > v[7] then v[2] = v[2] - FrameTime() end 
			end
		else
			table.remove(tbl,i)
		end
	end

	if mat then
		surface.SetMaterial(mat)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(math.Clamp(mpx-18,x+4,x+w-20),mpy-8,16,16)
	end

	surface.SetFont("ChatFont")
	txt = txt .. val
	tsx, tsy = surface.GetTextSize(txt)
	tsx2  = surface.GetTextSize(val)
	surface.SetTextPos(x-tsx+tsx2+4,mpy-tsy/2)
	surface.DrawText(txt)
end

function PLUGM:BarAddChunk(tbl,val,delta,min,max,decay)

	--decay = decay + 3
	local w2,h2 = self.w/2,self.h/2
	local add = (delta >= 0) and true or false
	if (add and val-delta >= max) or (not add and val >= max) then return end

	if self.is3d then

		table.insert(tbl,{add,SysTime()+decay,2+scw2-w2+flr((self.w-4)*(min/max)),sch2-h2+2,flr((self.w-4)*(delta/max)),self.h-4,math.max(val,max),math.abs(delta),decay})
	else
		table.insert(tbl,{add,SysTime()+decay,2+self.x-w2+flr((self.w-4)*(min/max)),self.y-h2+2,flr((self.w-4)*(delta/max)),self.h-4,math.max(val,max),math.abs(delta),decay})
	end
end

return PLUGM