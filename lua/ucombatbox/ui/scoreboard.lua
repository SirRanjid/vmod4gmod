UCombatBox.ScoreBoard = UCombatBox.ScoreBoard or vgui.Create("DPanel")

local scb = UCombatBox.ScoreBoard
function scb:Paint(w,h)
	surface.SetDrawColor(255,120,1,120)
	surface.DrawRect(0,0,w,h)
end

scb:SetSize(ScrW()*(2/5),ScrH()-100)
scb:Center()

function scb:update()
	for k,v in ipairs(scb:GetChildren()) do
		v:Remove()
	end

	local ucb = LocalPlayer().UCombatBox
	if not ucb or not istable(ucb.Data) then return end
	for stdid,v in pairs(ucb.Data._P) do
		if UCombatBox.STDID[stdid] and v.active then
			local ply = UCombatBox.STDID[stdid]
			 --print(ply)
			local Lply = self:Add("DLabel")
			Lply:SetText(ply:Name())
			Lply:Dock(TOP)
			Lply:SetTall(30)
		end
	end
end


hook.Add("ScoreboardShow","ucb_scoreboard_show",function()
	if LocalPlayer().UCombatBox then
		scb:SetSize(ScrW()*(2/5),ScrH()-100)
		scb:Center()
		scb:SetVisible(true)
		return false
	end
end)

hook.Add("ScoreboardHide","ucb_scoreboard_hide",function()
	scb:SetVisible(false)
end)

hook.Add("UCombatBox_Join","ucb_scoreboard_join",function()
	scb:update()
end)
hook.Add("UCombatBox_Leave","ucb_scoreboard_leave",function()
	scb:update()
end)
scb:update()
scb:SetVisible(false)