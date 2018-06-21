--[[
--[[
	entities/ukes_combatbox/shared.lua
	
	SHARED:
	
	THINK functions:
		(use them instead of the actual Think function)
		Order in which they are called
		
		ENT:PreBrain()
		
		ENT:PrepBrain(remaining_time)
			--if a round start is delayed this is is called for the preparation phase
			--remaining_time is actually the remaining time in that phase
		
		ENT:RoundBrain(remaining_time)
			--if a round started this is being called instead of the PrepBrain function
			--remaining_time is actually the remaining time in that round

		ENT:PostBrain()

	
	Functions:
		ENT:ReInitiate()
			--reinitiates entities and players belonging to ENT
			--for newly connected players

		ENT:IsOwner(Player or SteamID)
			--Checks if input is the Owner

		ENT:IsOperator(Player or SteamID)
			--Checks if input is an Operator
			--Owner is also Operator

		ENT:IsModerator(Player or SteamID)
			--Checks if input is a Moderator
			--Operator is also Moderator

		ENT:AddOperator(stid)
			--Only the Owner can add Operators
			>>calls hook: UCB_Operator_Added(SteamID)

		ENT:RemoveOperator(stid)
			--Only the Owner can remove Operators
			>>calls hook: UCB_Operator_Removed(SteamID)

		ENT:AddModerator(stid)
			--Only the Owner can add Moderators
			>>calls hook: UCB_Moderator_Added(SteamID)

		ENT:RemoveModerator(stid)
			--Only the Owner can remove Moderators
			>>calls hook: UCB_Moderator_Removed(SteamID)

		ENT:AddEntity(ent)
			--called to add an entity to the arena (to let server and client know which entities belong to the arena for rendering and collision)
			--by default OnRemove would remove all those entities that are added this way
			--adds custom collision hook
			>>calls HookFunction: EntityAdded
			
		ENT:RemoveEntity(ent)
			--removes an entity from the arena and deletes it ('physically')
			>>calls HookFunction: ENT:EntityRemoved
		
		ENT:SetMode(mode)
			--change the gamemode of the arena
			>>calls hooks: UCombatBox_CanChangeMode, UCombatBox_OnModeChanged
		
		ENT:SetSize(x, y ,z)
			--change the size of the arena
			>>calls HookFunction: ENT:OnSizeChanged
			
		ENT:RegisterPlayerValueFunction(name,NetworkID,useAdd,isDefault)
			--useAdd: whether or not to create an Add<name>s(ply/stdid,num) function (if you're not networking numbers or dont need it)
			--isDefault: if yes this value gets reset on a new round by default
			--registers values that teams and players use (teamvalues are just the sum of the player values)
				--writes values in tables and makes networked add/set/get functions
				--networking only from server to client
			--functions: 
				--Add<name>s(ply/stdid,num) -negative decreases of course (set useAdd to false to not add an add function)
				--Set<name>s(ply/stdid,num) -sets the value
				--Get<name>s(ply/stdid) 	-gets the value
			--returns a table to be used by ENT:RemovePlayerValueFunction(tbl) to delete it all again
			--default values:
				--Add/Set/Get-Point-s (AddPoints, SetPoints, GetPoints)
				--Add/Set/Get-Kill-s (etc...)
				--Add/Set/Get-TeamKill-s
				--Add/Set/Get-Death-s
				--Add/Set/Get-Suicide-s
				
		ENT:RemovePlayerValueFunction(tbl)
			--removes everything of a value the RegisterPlayerValueFunction wrote
			--needs the table the registerfunction returned as input
		
		ENT:RegisterValueFunction(name,NetworkID,useAdd)
			--same as "RegisterPlayerValueFunction(name,NetworkID,isDefault)" except only one value per ENT
			--while above you can add values like kills for each player and team; here you can add values like maxkills for game rules
			--functions: 
				--Add<name>s(num) -negative decreases of course (set useAdd to false to not add an add function)
				--Set<name>s(num) -sets the value
				--Get<name>s() 	-gets the value

		ENT:RemoveValueFunction(tbl)
			--~~

		ENT:ResetPlayer(steamid)
			--resets a player (kills,teamkills,deaths,suicides)
			>>calls HookFunction: ENT:OnPlayerReset
			
		ENT:ResetAllPlayers()
			--resets all players (kills,teamkills,deaths,suicides)
			>>calls HookFunction: ENT:OnFullReset

		ENT:AddPlayer(stdid,team_name)
			--called to make a player join
			--stdid is the players steamid
			>>calls HookFunctions: ENT:PlayerJoining, ENT:PlayerJoined
		
		ENT:RemovePlayer(stdid, isKick, isBan, msg)
			--called to remove the player for whatever reason
			--stdid is the players steamid
			--isKick is if he was kicked from the arena
			--isBan is if he got banned from the arena (isKick will treated as true if this is true)
			--msg reason why he left, got kicked, etc.
			>>calls HookFunctions: ENT:PlayerLeaving, ENT:PlayerLeft
		
		ENT:AddTeam(team_name,col = Color(0,255,255))
			--adds team with a specific name and a color
			>>calls HookFunction: ENT:TeamAdded
		
		ENT:RemoveTeam(team_name)
			--removes team with a specific name
			>>calls HookFunction: ENT:TeamRemoved
			
		ENT:SetVis(isolateall,playeranyways)
			--isolateall: true = playern in the arena will only see stuff that belongs to it and players outside wont see the inside
			--playeranyways: true = show players anyways if isolateall is true
		
		ENT:HandleNetwork( mode, data )
			--mode as from the Handle table here
			--data is the table the function takes containing the arguments to pass the Handle functions
	
	HookFunctions:
		ENT:OnRoundStart()
			--called when a Round is about to start.
			--return false to stop the round (maybe if preperation phase is over but the teams are uneven)
	
		ENT:OnRemove()
			--when the arena gets removed
		
		ENT:EntityAdded (ent)
			--when an entity got added to the arena
			
		ENT:EntityRemoved ()
			--when an entity got removed from the arena
			--but since its removed no entity parameter
		
		ENT:CanChangeMode (mode)
			--when attempted to change the mode
			--return false to prevent a change
			--default prevents from changing mid-round
	
		ENT:OnModeChanged (mode)
			--when the mode changed
			
		ENT:OnSizeChanged()
			--when the size of the arena changed
	
		ENT:OnPlayerReset (steamid)
			--when a plyer gets reset
			
		ENT:OnFullReset
			--when all players got reset
		
		
		For overriding: (basic joining functionality is provided incl. kick/ban.)
		
		ENT:PlayerJoining (steamid,team_name)  [SERVERSIDE]
			--when a player attempts to join
			--return false to prevent a change (wanna exclude a player by their steamid?)
		
		ENT:PlayerJoined (steamid,team_name,rejoined)
			--when a player successfully joined
			--rejoined: if he already joined one but left and now comes back
			
		ENT:PlayerLeaving (steamid,isKick,isBan,msg)  [SERVERSIDE]
			--when a player attempts to leave
			--return false to prevent a change (trap them inside your arena muhahaha / noob-cage? / no rage-quits mid-round)
		
		ENT:PlayerLeft (steamid,isKick,isBan,msg)
			--when a player successfully left
		
		
		ENT:TeamAdded (teamname)
			--when team got added
			
		ENT:TeamRemoved (teamname)
			--when team got removed ]]

ENT.PrintName		= "Uke's CombatBox"
ENT.SpawnName		= "ucbox"
ENT.Author			= "Uke"
ENT.Contact			= "why would you"
ENT.Purpose			= "Duke it out against each other without disturbing everybody else."
ENT.Instructions	= "Spawn. Press E and set it up."

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"

ENT.Category 		= string.char(1).."Uke's Stuff   "..string.char(198).. string.char(184).. string.char(204).. string.char(181).. string.char(204).. string.char(161).. string.char(211).. string.char(156).. string.char(204).. string.char(181).. string.char(204).. string.char(168).. string.char(204).. string.char(132).. string.char(198).. string.char(183)

ENT.Spawnable			= true
ENT.AdminOnly			= false
ENT.AdminSpawnable		= false
ENT.Editable			= true

ENT.MinScale = Vector(0,0,0)

ENT.MaxScale = Vector(32768,32768,32768)

local serverissued = SERVER

function ENT:PreBrain()

end

function ENT:PrepBrain(remaining_time)

end

function ENT:RoundBrain(remaining_time)
	
end

function ENT:PostBrain()

end

function ENT:OnRoundStart()

end

function ENT:RemoveInactivePlayers()
	for k,v in pairs(self.Data._P) do
		if not v.active and not v.banned then self.Data._P[k] = nil end --also not remove banned players lol
	end
end

do
	local CurTime = CurTime
	
	function ENT:CheckRoundStart()
		local CT = CurTime()
		if self.Data._R.start <= CT then
			if self:OnRoundStart() == false then self:StopRound() return end
			
			self.Data._R.started = true
			if SERVER then self:RespawnAllPlayers(); self:ResetAllPlayers() end
			
			return 0
		else
			return self.Data._R.start - CT
		end
	end
	
	function ENT:StartRound(len,ct)
		if serverissued or (CLIENT and self:IsModerator(LocalPlayer())) then --#make all serverissued include clientside sendfunct
			local len = len or 300
			 --print("rq rst")
			self.Data._R.start = ct or CurTime()
			self.Data._R.len = len
			
			self.Data._R.started = true
			
			if SERVER then self:NetWorkMode("$s+",time,self.Data._R.start) self:RespawnAllPlayers()
			elseif not serverissued then self:NetWorkMode("$s+",time,self.Data._R.start) end
			UCombatBox.DOSEND = false
				self:ResetAllPlayers()
			UCombatBox.DOSEND = true
		end
	end

	function ENT:StopRound()
		if serverissued or (CLIENT and self:IsModerator(LocalPlayer())) then
			self.Data._R.start = ct or CurTime()
			self.Data._R.len = len
			
			self.Data._R.started = false

			self:RemoveInactivePlayers()
			
			if SERVER then self:NetWorkMode("$s-",time) 
			elseif not serverissued then self:NetWorkMode("$s-",time)  end
		end
	end
	
	function ENT:Think()	--use the brain functions instead
		local CT = CurTime()
		
		self:PreBrain()
		if not self.Data._R.started then 
			self:PrepBrain(self:CheckRoundStart())
		else
			self:RoundBrain((self.Data._R.start+self.Data._R.len)-CT)
		end
		self:RoundBrain()
	end
end

function ENT:ReInitialize()
end

function ENT:Initialize()
	UCombatBox.ents[self] = UCombatBox --'register' (better store the combatboxes in a table than filter all ents for them)
	self.UCombatBox = self --for vis-checks
	-- --print("Entity(548)",self.UCombatBox, self, EntIndex(self))
	self.Data = {	--relevant data for playing
		["_SETUP"] = false, --ready?
		["_N"] = "",	--name
		["_P"] = {},	--players
		["_C"] = {}, 	--classes --#
		["_M"] = {v = {}, f = {}}, 	--mesh for level making--#
		["_VAL"] = {},	--values all players and teams should have
		["_R"] = {		--rules
			["mode"] = "base",	--game mode
			["start"] = 0,	--start time
			["len"] = 0,	--round length (0 = inf)
			["started"] =false,	--round started?
			["maxp"] = 0,	--max points (0 = inf)
			["forceteam"] = false,	--force players to choose a team if available, else they can be alone against teams
			["noclip"] = true,	--allow noclip
			["god"] = false,		--enable godmode
			["spawnmenu"] = false,		--enable spawnmenu
			["spawning"] = false		--enable spawning of entities
		},
		["_CT"] = {		--table for custom networked values
		},
		["_T"] = { --Teams
			--[<ID>] = {"<TeamName>",Color(r, g, b, a)[,maxplayers]}, --teamdefinition
			--...
			--["<SteamID>"] = "<TeamName>",	--team assingment

		},
		["_E"] = {	--entities that belong to this ent
			--_X_ = {pos,ang,class,model,scale,...?--#} --definition
			--[ENT] = {?} (= _X_?)						--entities added to this box
		},
		["_S"] = {	--spawn positions spawn
			--{pos, ang},	--pos is relative to the box's position, ang is not relative
			--{pos2, ang2},
		},
		["_V"] = true,	-- isolate the view
		["_VP"] = false,	-- show players anyways
		["_SB"] = true,	-- solid boundaries --#add to save whitelist+backwardscompatibility for saves!
		
		--["av"] = {}, --for values a gamemode added that should get restored/removed on change
		--["_av"] = {}, --same but for the _VAL table
		--s["_M"] = false, --magnetic
		
		["_O"] = {"", self}, --owner
		["_OP"] = {/*"<SteamID>",...*/}, --operators
		["_MOD"] = {/*"<SteamID>",...*/}, --moderators

		["POS"] = self:GetPos(),
		["SIZE"] = Vector(500,500,200),
	}
	 --print("init",self,self.Data._O[2])
	/*NOTE:
		ents (_E):
			{Vector Pos,...}
		spawns (_S):
			{Vector Pos,...}
		mesh (_M):
			{Vector Pos,...}
	*/
	
	self.av = {} --for values a gamemode added that should get restored/removed on change

	self.MESH = {} --the bounding box
	--self.Data.POS = self:GetPos()
	--self.Data.SIZE = Vector(500,500,200)
	self.MIN = self.Data.POS
	self.MAX = self.MIN + self.Data.SIZE
	self.CENTER = self.MIN + self.Data.SIZE*0.5
	self.MAG = 50	--magnetic position check-distance
	self.IsMag = false	--magnetic position check-distance
	
	self:SetModel( "models/Items/item_item_crate.mdl" )
	
	self:PhysicsInit(SOLID_CUSTOM)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	
	--self:SetModel( "models/props_junk/garbage_takeoutcarton001a.mdl" )

	if CLIENT then
		if self:HasCache() then print("pre-decached",self,self.Data._O[2]) self:DeCache() print("decached",self,self.Data._O[2]) end

		local function decachemeregularily()
			if not self or (self and not self.HasCache) then return end
			if self:HasCache() then 
				 --print("autodecache")
				-- --print(util.Decompress(self:GetCache()[1][2]))
				self:DeCache()
			else
				timer.Simple(LocalPlayer():Ping()/1000+0.1,decachemeregularily)
				-- --print("--decache")
			end
		end
		timer.Simple(LocalPlayer():Ping()/1000+0.1,decachemeregularily)

		self.Data._N = LocalPlayer():Name()

		self:CheckShouldDraw()
	else
		self:SetUseType( SIMPLE_USE )
		local scale = 30
		
		self.Entity.txt = "test"
		
		local mins = self.Entity:OBBMins()
		local maxs = self.Entity:OBBMaxs()
		
		--self:SetModelScale( scale, 0 )
		self:SetCollisionBounds(mins,maxs)
		
		
		local original = undo.SetCustomUndoText

		self.UndoTable = {}
		function undo.SetCustomUndoText(txt)
			--original("You've undone a CombatBox Arena.")
			local tab, found = {}, false
			for I = 0, 64 do
				local key, val = debug.getupvalue( original, I )
				if key == "Current_Undo" then self.UndoTable = val found = true end
			end
			original( txt )
			undo.SetCustomUndoText = original --the unefficient one-time-replace-it-with-anything-ticket
			
			if found then
				function self:SetRemoveText(txt) 
					if not self.UndoTable then return end
					self.UndoTable.CustomUndoText = txt
				end
			end
		end
	end

	self:SetCustomCollisionCheck( true )

	self:OnSizeChanged()
	self:ReInitiate()

	hook.Call("UCB_Init",GAMEMODE,self)
end

function ENT:IsOwner(ply_stid)
	if IsEntity(ply_stid) then ply_stid = ply_stid:SteamID() end
	if self.Data._O[1] == ply_stid or self.Data._O[2] == UCombatBox.STDID[ply_stid] then return true end
	return false
end

function ENT:IsOperator(ply_stid)
	if IsEntity(ply_stid) then ply_stid = ply_stid:SteamID() end
	if self:IsOwner(ply_stid) then return true end
	if self.Data._OP[ply_stid] then return true end

	return false
end

function ENT:IsModerator(ply_stid)
	if IsEntity(ply_stid) then ply_stid = ply_stid:SteamID() end
	if self:IsOperator(ply_stid) then return true end
	if self.Data._MOD[ply_stid] then return true end
	return false
end

function ENT:AddOperator(stid)
	if CLIENT and not self:IsOwner(LocalPlayer()) then return end
	if SERVER then self:NetWorkMode("+op",stid) end
	hook.Call("UCB_Operator_Added",GAMEMODE,stid)
end

function ENT:RemoveOperator(stid)
	if CLIENT and not self:IsOwner(LocalPlayer()) then return end
	if SERVER then self:NetWorkMode("-op",stid) end
	hook.Call("UCB_Operator_Removed",GAMEMODE,stid)
end

function ENT:AddModerator(stid)
	if CLIENT and not self:IsOwner(LocalPlayer()) then return end
	if SERVER then self:NetWorkMode("+mod",stid) end
	hook.Call("UCB_Operator_Added",GAMEMODE,stid)
end

function ENT:RemoveModerator(stid)
	if CLIENT and not self:IsOwner(LocalPlayer()) then return end
	if SERVER then self:NetWorkMode("-mod",stid) end
	hook.Call("UCB_Operator_Removed",GAMEMODE,stid)
end

--location translation
function ENT:tanslateLocation(vec)
	if not vec then return self.MIN end
	return self.MIN + vec
end

function ENT:SetRemoveText(txt) 
	if not self.UndoTable then return end
	self.UndoTable.CustomUndoText = txt
end

function ENT:tanslateLocation(vec)
	if not vec then return self.MIN end
	return self.MIN + vec
end

function ENT:tanslateRelativeLocation(vec)
	if not vec then return self.MIN end
	return self.MIN + self.Data.SIZE*vec
end

function ENT:tanslateRelativeLocationMargin(vec,margin)
	if not vec then return self.MIN end
	return self.MIN+margin/2 + (self.Data.SIZE-margin)*vec
end

function ENT:tanslateRelativeLocationCentered(vec)
	if not vec then return self.MIN end
	return self.CENTER + self.Data.SIZE*0.5*vec
end
--/location translation

function ENT:EntityAdded(ent)

end

function ENT:AddEntity(ent)
	if serverissued or (CLIENT and self:IsOperator(LocalPlayer())) then
		if not IsValid(ent) then return end
		self.Data._E[ent] = true
		
		ent.UCombatBox = self
		hook.Call("UCombatBox_Entity",nil,ent)
		
		if SERVER then self:NetWorkMode("+e",ent) --must arrive after entities are loaded to work
		--if SERVER then timer.Simple(0.5,function() self:NetWorkMode("+e",ent) end) --must arrive after entities are loaded to work
		elseif not serverissued then self:NetWorkMode("+e",ent) end

		if CLIENT then ent:CheckShouldDraw() end
		ent:SetCustomCollisionCheck( true )
		self:EntityAdded(ent)
	end
end

function ENT:EntityRemoved()

end

function ENT:RemoveEntity(ent)
	if serverissued or (CLIENT and self:IsOperator(LocalPlayer())) then
		if not IsValid(ent) then return end
		self.Data._E[ent] = nil
		
		ent.UCombatBox = nil
		
		if SERVER then self:NetWorkMode("-e",ent) ent:Remove()  
		elseif not serverissued then self:NetWorkMode("-e",ent) end

		self:EntityRemoved()
	end
end

local function checkOutPly(self,ply,stdid)	--make player leave an arena and reset him to where he was before the way he was
	if self and ply and ply.UCombatBox and ply.UCombatBox == self then 
		ply.UCombatBox = nil
		ply:SetCustomCollisionCheck( false )
		
		if SERVER then 
			ply:Spawn()
			if self.Data._P[stdid].prepos then
				ply:SetPos(self.Data._P[stdid].prepos)
				ply:SetEyeAngles(self.Data._P[stdid].preang)
				if not ply:HasWeapon(self.Data._P[stdid].preweap) then ply:Give(self.Data._P[stdid].preweap) end
				ply:SelectWeapon(self.Data._P[stdid].preweap)
				ply:SetMoveType(self.Data._P[stdid].premove)
			end
		end
		hook.Call("UCombatBox_Leave",GAMEMODE,ply,stdid)	--clientside for vischecks, serverside no function yet
	end
end

function ENT:OnRemove()
	--clean up
	
	UCombatBox.ents[self] = nil
	
	for stdid,_ in pairs(self.Data._P) do
		if UCombatBox.STDID[stdid] then
			local ply = UCombatBox.STDID[stdid]
			checkOutPly(self,ply,stdid)
		else
			local ply = player.GetBySteamID( stdid )
			checkOutPly(self,ply,stdid)
		end
	end
	
	if SERVER then
		for e,v in pairs(self.Data._E) do
			if v == true and IsValid(e) then e:Remove() end
		end
		--self:RespawnAllPlayers()
	end
end

function ENT:CanChangeMode(mode)
	if self.Data._R.started then return false end --cant start when a round is already running
end

function ENT:OnModeChanged(mode)

end

do
	local copy = table.Copy
	
	local dontoverrideoradd = {
		["Data"] = "table",	--the Data table
		
		["Title"] = "string",	--and the values a mode has by default
		["Teams"] = "table",
		["ID"] = "string",
		["DERIVE"] = "string",
		["Author"] = "string",
		["SRC"] = "string",
		["PLAYABLE"] = "boolean",
	}
	
	function ENT:SetMode(mode,del)
		if serverissued or (CLIENT and self:IsModerator(LocalPlayer())) then
			if not UCombatBox.GameModes[mode] and not del then return end
		
			for k,v in ipairs(self.av) do --delete the values the last gamemode had
				if v == NULL then
					self[k] = nil	--delete the function if we dont have it by default
				else
					self[k] = v		--get back the original functions
				end
			end
			
			self.av = {}
			
			if not UCombatBox.GameModes[mode] then return end
			if UCombatBox.GameModes[mode] == UCombatBox.GameModes[self.Data._R.mode] then return end --don't change to the current mode
			if self:CanChangeMode(mode) == false then return end
			
			self.Data._R.mode = mode
			
			for k,v in pairs(UCombatBox.GameModes[mode]) do
				if not (dontoverrideoradd[k] and dontoverrideoradd[k] == type(v)) then	--don't override or add certain information
					
					self.av[k] = self[k] or NULL	--save original functions
					
					if type(v) == "table" then
						self[k] = copy(v)	--don't mess with the original table
					else
						self[k] = v
					end
				end
			end
			--self.Data._N = UCombatBox.GameModes[mode].Title or ""
			self.Data._T = UCombatBox.GameModes[mode].Teams or self.Data._T or {}
			self.Data._C = UCombatBox.GameModes[mode].Classes or self.Data._C or {}
			
			--UCombatBox.GameModes[mode]
			/*if SERVER then 
				self:NetWorkMode(">M",mode)
				--self:SetRemoveText("rstgrtrtetertertertertertertre")
				if self.SetRemoveText then self:SetRemoveText("Undone "..self.PrintName.." ["..(UCombatBox.GameModes[mode].Title or "?").."]") end
			end*/
			self:OnModeChanged(mode)
		end
	end
end

do
	local rnd = math.Rand
	function ENT:SetupSpawns() --# remove this piece of shit or make it better
		self.Data._S = {}
		for i = 1, 20 do
			local pos = self:tanslateRelativeLocationMargin(Vector(rnd(0,1),rnd(0,1),1),Vector(60,60,60))
			local ang = Angle(0,(self.CENTER - pos):Angle().y+rnd(-90,90),0)
			self.Data._S[i] = {pos, ang}
		end
	end
end

function ENT:OnDeployed()
end

function ENT:OnCollapsed()

end

function ENT:ReloadPhys()
	if self.Data._SETUP then
		if CLIENT then self:SetRenderBounds( self.MIN, self.MAX ) end
		self:SetAngles( Angle( 0, 0, 0 ) )
		self:EnableCustomCollisions( true )
		self:PhysicsFromMesh( self.MESH, true )

		local phys = self:GetPhysicsObject()
		if phys then
			phys:EnableMotion( false )	--this is actually important at this position
			if CLIENT then phys:SetMaterial( "default_silent" ) end --it will break the physics on shared but i just need it for the effects so...
		end
		self:SetCustomCollisionCheck(true)
		self:DrawShadow( false )
	elseif CLIENT then
		if self:IsOperator(LocalPlayer()) then --renderbounds for operators+
			self:SetRenderBounds( self:OBBMins(), self:OBBMins()+self.Data.SIZE )
		else
			self:SetRenderBounds( self:OBBMins(), self:OBBMaxs() )
		end
	end
end

function ENT:Deploy(sv)
	print("deploy",serverissued)
	if serverissued then -- or (CLIENT and self:IsOperator(LocalPlayer())) then
		self.prepos = self:GetPos()
		self.preang = self:GetAngles()
		
		self:OnSizeChanged()

		if SERVER then
			for k,v in ipairs(self.Data._E) do
				self:SpawnChildEntity(v[3],v[4],v[1]+self.Data.POS,v[2],v[5],v[6])
			end
			sound.Play( "buttons/latchunlocked2.wav", self.CENTER, 100, 100, 1 )
			self:SetPos(self:GetMagneticPos())
			self:NetWorkMode("@d")
		else
			--self:SetRenderBounds( self.MIN, self.MAX )
			self.DPT = CurTime()+0.5
			self.Anim = true
		end
		
		

		UCombatBox.DOSEND = false	--since collapse is networked we dont need to network setsetup
			self:SetSetup(true)
		UCombatBox.DOSEND = true

		self:ReloadPhys()
		self:OnDeployed()
	elseif not serverissued and CLIENT and self:IsOperator(LocalPlayer()) then
		self:NetWorkMode("@d")
	end
end

function ENT:Collapse()	--making it movable again
	if serverissued or (CLIENT and self:IsOperator(LocalPlayer())) then
		if SERVER then 
			self:NetWorkMode("@c") 
			
			if self.prepos then self:SetPos(self.prepos) end
			if self.preang then self:SetAngles(self.preang) end
		
			self:SetModel( "models/Items/item_item_crate.mdl" )
			self:PhysicsInit(SOLID_CUSTOM)
			self:SetMoveType(MOVETYPE_NONE)
			self:SetSolid(SOLID_VPHYSICS)
			
			self:EnableCustomCollisions(false)
			self:SetCustomCollisionCheck(false)
			
			self:DrawShadow( true )
		
		else 
			if self:IsOperator(LocalPlayer()) then --renderbounds for operators+
				if not serverissued then self:NetWorkMode("@c") end
				self:SetRenderBounds( self:OBBMins(), self:OBBMins()+self.Data.SIZE )
			else
				self:SetRenderBounds( self:OBBMins(), self:OBBMaxs() )
			end
		end
		
		if SERVER then
			for e,v in pairs(self.Data._E) do
				if v == true and IsValid(e) then e:Remove() end
			end
		end
		
		local np = #player.GetAll() --dont let players get stuck
		for I = 1, np do
			local spos = self.Data.POS
			local tr = util.TraceEntity( { start = spos, endpos = spos, filter = function(a) return a.IsPlayer and a:IsPlayer() end }, self )
			if tr.Hit then
				local ppos = tr.Entity:GetPos()
				local tgn  = ppos - spos
				tgn.z = 0
				local dpos = self.Data.POS + (tgn):GetNormalized() * (self:OBBMaxs()-self:OBBMins()):Length()
				dpos.z = ppos.z
				tr.Entity:SetPos(dpos)
			else
				break
			end
		end
		
		UCombatBox.DOSEND = false	--since collapse is networked we dont need to network setsetup
			self:SetSetup(false)
			/*for stdid,_ in pairs(self.Data._P) do
				self:RemovePlayer(stdid,false,false,"")
			end*/ --#kick on collapse: not kick for new loading: amke deploy menu option
		UCombatBox.DOSEND = true

		self:OnCollapsed()
	end
end

function ENT:OnSizeChanged()
	local x,y,z = self.Data.SIZE.x, self.Data.SIZE.y, self.Data.SIZE.z
	
	self.MESH = {}
	
	local O		= {pos = Vector(0,0,0), u  = 0, v  = 0}
	local F		= {pos = Vector(x,0,0), u  = 1, v  = 0}
	local R		= {pos = Vector(0,y,0), u  = 0, v  = 1}
	local FR	= {pos = Vector(x,y,0), u  = 1, v  = 1}
	
	local TO	= {pos = Vector(0,0,z), u  = 0, v  = 0}
	local TF	= {pos = Vector(x,0,z), u  = 1, v  = 0}
	local TR	= {pos = Vector(0,y,z), u  = 0, v  = 1}
	local TFR	= {pos = Vector(x,y,z), u  = 1, v  = 1}
	
	self.POINTS = {O.pos,F.pos,R.pos,FR.pos,TO.pos,TF.pos,TR.pos,TFR.pos}
	
	self.CENTER = self.Data.POS + Vector(x*0.5,y*0.5,z*0.5)
	self.MIN = self.Data.POS
	self.MAX = TFR.pos
	
	self.MESH = {	--box made of 12 triangle faces
		--[[BOTTOM]]O,F,R,
		--[[BOTTOM]]R,F,FR,
		
		--[[TOP]]TFR,TF,TR,
		--[[TOP]]TO,TR,TF,
		
		--[[BACK]]O,R,TO,
		--[[BACK]]TO,R,TR,
		
		--[[FRONT]]FR,F,TF,
		--[[FRONT]]TFR,FR,TF,
		
		--[[RIGHT]]TFR,TR,FR,
		--[[RIGHT]]TR,R,FR,
		
		--[[LEFT]]O,TO,F,
		--[[LEFT]]TO,TF,F,
	}
	--self:SetSetup(false)
	--self:BuildMesh()
end

do
	local clamp = math.Clamp
	local type = type
	
	function ENT:SetSize(x,y,z)
		if serverissued or (CLIENT and self:IsOperator(LocalPlayer())) then
			if type(x) == "table" or type(x) == "Vector" then
				x,y,z = clamp(x.x,self.MinScale.X,self.MaxScale.X), clamp(x.y,self.MinScale.Y,self.MaxScale.Y), clamp(x.z,self.MinScale.Z,self.MaxScale.Z)
			else
				x,y,z = clamp(x,self.MinScale.X,self.MaxScale.X), clamp(y,self.MinScale.Y,self.MaxScale.Y), clamp(z,self.MinScale.Z,self.MaxScale.Z)
			end
			
			self.Data.SIZE = Vector(x,y,z)
			
			if SERVER then self:NetWorkMode("wh",x,y,z) 
			elseif not serverissued then self:NetWorkMode("wh",x,y,z) end
			
			self:OnSizeChanged()
		end
	end
end

function ENT:UpdateSize()
	if serverissued or (CLIENT and self:IsOperator(LocalPlayer())) then
		if SERVER then self:NetWorkMode("~wh") 
		elseif not serverissued then self:NetWorkMode("~wh") end
		self:OnSizeChanged()
	end
end

function ENT:OnPlayerReset(ply)
	
end

function ENT:ResetPlayer(ply)
	if serverissued or (CLIENT and self:IsModerator(LocalPlayer())) then
		if type(ply) != "string" then ply = ply:SteamID() end
		
		local _P = self.Data._P
		
		if not _P[ply] then return end
		_P = _P[ply]
		local old = {}
		for k,v in pairs(self.Data._VAL) do
			old[k] = _P[k] or 0
			if _P[k] then _P[k] = 0 end
		end
		
		/*local _T = self.Data._T --?subtract his score from the teams score then?
		if not _P.team or _P.team == "" then return end
		if not _T[_P.team] then return end
		_T = _T[_P.team]
		if not _T then return end
		for k,v in pairs(self.Data._VAL) do
			old[k] = _P[k] or 0
			if _P[k] then _T[k] = _T[k] - old[k] end
		end*/

		if SERVER then self:NetWorkMode("##",ply) 
		elseif not serverissued then self:NetWorkMode("##",ply)  end

		self:OnPlayerReset(ply)
	end
end

function ENT:OnFullReset()

end

function ENT:ResetAllPlayers()
	if serverissued or (CLIENT and self:IsModerator(LocalPlayer())) then
		for k,stdid in ipairs(self.Data._P) do
			--if not self.Data._P[stdid] then return end
			self.Data._P[stdid].kill = 0
			self.Data._P[stdid].teamkill = 0
			self.Data._P[stdid].death = 0
			self.Data._P[stdid].suicide = 0
		end
		
		for k,v in ipairs(self.Data._T) do
			--if not self.Data._P[ply] then return end
			self.Data._T[k].kill = 0
			self.Data._T[k].teamkill = 0
			self.Data._T[k].death = 0
			self.Data._T[k].suicide = 0
		end
		
		if SERVER then self:NetWorkMode("_#",ply) 
		elseif not serverissued then self:NetWorkMode("_#",ply)  end
		self:OnFullReset()
	end
end


function ENT:PlayerJoining(stdid,team_name,rejoined)
	
end

function ENT:PlayerJoined(stdid,team_name,rejoined)

end

function ENT:CountActivePlayers()
	local ret = 0
	for k,v in pairs(self.Data._P) do
		if v.active then ret = ret+1 end
	end
	return ret
end

function ENT:CanJoin(stdid,ply)	--more internal for unified conditions
	if not ply then return false end	--what player?
	if not self.Data._SETUP and not self:IsOperator(stdid) then return false, self.Data._N.." is not setup and you're no Operator." end	--not setup
	if ply.UCombatBox != nil and ply.UCombatBox.Data then return false, "Already connected to "..ply.UCombatBox.Data._N.."." end	--already member of an arena
	if self.Data._P[stdid] and self.Data._P[stdid].banned then return false, "You're banned from this server. ("..self.Data._N..")" end	--you've been banned ingame on a server but not from the server just fomr one that doesnt like you
	if self.Data._R.maxp > 0 and self:CountActivePlayers() > self.Data._R.maxp then return false, "Server full." end --cant join when full
	return true	--can attempt to join now
end

function ENT:AddPlayer(stdid,team_name)
	print("addplayer, serverissued",stdid,team_name,serverissued)
	if serverissued then
		if type(stdid) != "string" then stdid = stdid:SteamID() end
		
		local ply
		if UCombatBox.STDID[stdid] then ply = UCombatBox.STDID[stdid]
		else ply = player.GetBySteamID( stdid ) end
		
		if not ply then return end

		local canjoin, msg = self:CanJoin(stdid,ply)
		if not canjoin then print(ply,"Connection failed:",msg) return end
		
		--preventt players from joining
		if SERVER and self:PlayerJoining(stdid,team_name) == false then return end
		
		ply.UCombatBox = self
		-- --print("AddPlayer",ply,ply.UCombatBox,self)
		
		if SERVER then
			print("+p",stdid,team_name)
			self:NetWorkMode("+p",stdid,team_name)
			self:RespawnPlayer(ply)
		end
		print("addply",ply,self.Data._P[stdid])

		if self.Data._P[stdid] then --just reactivate old session
			self.Data._P[stdid].active = true
			self:PlayerJoined(stdid,team_name,true)

			if self.Data._T[team_name] then
				self.Data._P[stdid].team = self.Data._T[team_name]
				self.Data._P[stdid].teamn = team_name
				self.Data._T[team_name].ply[stdid] = self.Data._P[stdid]
			end
		else 						--create new session
			self.Data._P[stdid] = {
				active = true,
				banned = false,	--banned for only this arena
				kill = 0,
				death = 0,
				suicide = 0,
				teamkill = 0,
			}

			if self.Data._T[team_name] then
				self.Data._P[stdid].team = self.Data._T[team_name]
				self.Data._P[stdid].teamn = team_name
				self.Data._T[team_name].ply[stdid] = self.Data._P[stdid]
			end
			self:PlayerJoined(stdid,team_name,false)
		end
		
		--for resetting the player after he left not 100% but enough to quickly get them back to work after playing ;) 
		if SERVER then
			self.Data._P[stdid].prepos = ply:GetPos()
			self.Data._P[stdid].preang = ply:EyeAngles()
			self.Data._P[stdid].preweap = ply:GetActiveWeapon() and ply:GetActiveWeapon():GetClass() or ""
			self.Data._P[stdid].premove = ply:GetMoveType() --wanna respawn mid-air falling? me neither.
		end
		if CLIENT and stdid == LocalPlayer():SteamID() then
			print("Joined:",self.Data._N,self)
		end
		hook.Call("UCombatBox_Join",GAMEMODE,ply,stdid)
	end
end

function ENT:PlayerLeaving(stdid,isKick,isBan,msg)

end

function ENT:PlayerLeft(stdid,isKick,isBan,msg)

end

function ENT:RemovePlayer(stdid, isKick, isBan, msg) --remove it from the
	if serverissued or (CLIENT and stdid == LocalPlayer():SteamID()) then --oneself can only remove oneself
		if not isstring(stdid) then stdid = stdid:SteamID() end
		
		if stdid and self.Data._P[stdid] then
			local isKick = isBan or isKick --a ban implies the kick no matter what
		
			--preventt players from leaving? (no ragequit allowed?)
			if SERVER and self:PlayerLeaving(stdid,isKick,isBan,msg) == false then return end
			
			self.Data._P[stdid].active = false
			
			if UCombatBox.STDID[stdid] then
				local ply = UCombatBox.STDID[stdid]
				checkOutPly(self,ply,stdid)
			else
				local ply = player.GetBySteamID( stdid )
				checkOutPly(self,ply,stdid)
			end
			
			if SERVER then self:NetWorkMode("-p",stdid,isKick,isBan,msg) 
			elseif not serverissued then self:NetWorkMode("-p",stdid,isKick,isBan,msg)  end

			self:PlayerLeft(stdid,isKick,isBan,msg)

			if CLIENT and stdid == LocalPlayer():SteamID() then
				if msg and msg ~= "" then msg = '"'..msg..'"' else msg = nil end
				
				if isBan then
					print("Banned from:",self.Data._N,self)
				elseif isKick then
					print("Kicked from:",self.Data._N,self)
				else
					print("Disconnected from:",self.Data._N,self,msg)
				end
				if msg then print(msg) end
			end
		end
	end
end

--[[
	Team Functions:
]]

function ENT:TeamAdded(team_name)

end

function ENT:AddTeam(team_name,col) --do i really need it? since a left player will leave nil
	if serverissued or (CLIENT and self:IsOperator(LocalPlayer())) then
		if self.Data._T[team_name] then return end
		
		self.Data._T[team_name] = {
			color = col or Color(0,255,255),
			kill = 0,
			death = 0,
			suicide = 0,
			teamkill = 0,
			_S = {},	--team spawns (as references to the spawns table)
			ply = {},
		}

		if SERVER then self:NetWorkMode("+t",team_name,col or Color(0,255,255)) 
		elseif not serverissued then self:NetWorkMode("+t",team_name,col or Color(0,255,255))  end
		
		self:TeamAdded(team_name)
		hook.Call("UCB_TeamAdded",GAMEMODE,team_name,self.Data._T[team_name])
	end
end

function ENT:TeamRemoved(team_name)
	--automatically migrate players to another team? maybe even midgame?
end

function ENT:RemoveTeam(team_name)
	if serverissued or (CLIENT and self:IsOperator(LocalPlayer())) then
		if not self.Data._T[team_name] then return end
		
		self.Data._T[team_name] = nil
		
		for v,tn in pairs(self.Data._T[1].ply) do
			v.team = nil
			v.teamn = nil
			self.Data._T[tn].ply = nil
		end

		if SERVER then self:NetWorkMode("-t",team_name) 
		elseif not serverissued then self:NetWorkMode("-t",team_name) end
		
		self:TeamRemoved(team_name)
		hook.Call("UCB_TeamRemoved",GAMEMODE,team_name)
	end
end

/*function ENT:RemoveTeam(team_name)	--why did i double it?
	if not self.Data._T[team_name] then return end
	
	self.Data._T[team_name] = nil
	
	if SERVER then self:NetWorkMode("-t",ply,num) end
	
	self:TeamRemoved(team_name)
end*/

function ENT:SetSetup(bool)
	if serverissued or (CLIENT and self:IsOperator(LocalPlayer())) then
		self.Data._SETUP = bool
		
		if SERVER then self:NetWorkMode(">S",bool) 
		elseif not serverissued then self:NetWorkMode(">S",bool) end
	end
end

function ENT:GetMagneticPos()	--make the combatbox hug walls
	if not self.IsMag then return self.Data.POS, self.Data.POS, 0, {} end
	local mpos = self:GetPos()
	
	local pos = mpos + Vector(0,0,self.Data.SIZE.z/2)
	local add = 0
	
	--if not self.IsMag then return mpos, pos, 0, {} end

	local hit = {}
	
	local epos = mpos + Vector(0,0,self.Data.SIZE.z+self.MAG)
	local up = util.TraceLine( {--------------------------------------up-
		start = mpos,
		endpos = epos,
		filter = self,
		mask = MASK_NPCWORLDSTATIC,
	} )
	
	add = up.Fraction * (self.Data.SIZE.z+self.MAG)
	
	if up.Hit and mpos:Distance(epos)-mpos:Distance(up.HitPos) < self.MAG and not up.StartSolid then
		pos.z = up.HitPos.z - add/2
		mpos.z = up.HitPos.z-self.Data.SIZE.z+1
		
		hit[#hit+1] = {up.HitPos,Angle(0,0,0),up.HitNormal}
	end
	
	
	
	epos = pos - Vector(0,0,(self.Data.SIZE.z/2)+self.MAG)
	local dn = util.TraceLine( {-----------------------------------------------down+
		start = pos,
		endpos = epos,
		filter = self,
		mask = MASK_NPCWORLDSTATIC,
	} )
	if dn.Hit and mpos:Distance(epos)-mpos:Distance(dn.HitPos) < self.MAG then	--floor is priorized over ceiling
		mpos.z = dn.HitPos.z-1
		hit[#hit+1] = {dn.HitPos,Angle(180,0,0),dn.HitNormal}
	end
	
	--
	
	epos = pos - Vector(self.MAG,0,0)
	local ba = util.TraceLine( { -------------------------------------back+
		start = pos,
		endpos = epos,
		filter = function(ent) return ent != self and ent != Entity(0) end
	} )
	if ba.Hit and mpos:Distance(epos)-mpos:Distance(ba.HitPos) < self.MAG then
		mpos.x = ba.HitPos.x-1
		hit[#hit+1] = {ba.HitPos,Angle(-90,0,0),ba.HitNormal}
	else
		epos = pos + Vector(self.Data.SIZE.x+self.MAG,0,0)
		local fw = util.TraceLine( {----------------------------------front-
			start = pos,
			endpos = epos,
			filter = self,
			mask = MASK_NPCWORLDSTATIC,
		} )
		if fw.Hit and mpos:Distance(epos)-mpos:Distance(fw.HitPos) < self.MAG then
			mpos.x = fw.HitPos.x+1-self.Data.SIZE.x
			hit[#hit+1] = {fw.HitPos,Angle(90,0,0),fw.HitNormal}
		end
	end
	
	epos = pos - Vector(0,self.MAG,0)
	local li = util.TraceLine( {--------------------------------------left+
		start = pos,
		endpos = epos,
		filter = self,
		mask = MASK_NPCWORLDSTATIC,
	} )
	if li.Hit and mpos:Distance(epos)-mpos:Distance(li.HitPos) < self.MAG then			
		mpos.y = li.HitPos.y-1
		hit[#hit+1] = {li.HitPos,Angle(0,0,90),li.HitNormal}
	else
		epos = pos + Vector(0,self.Data.SIZE.y+self.MAG,0)
		local ri = util.TraceLine( {----------------------------------right-
			start = pos,
			endpos = epos,
			filter = self,
			mask = MASK_NPCWORLDSTATIC,
		} )
		if ri.Hit and mpos:Distance(epos)-mpos:Distance(ri.HitPos) < self.MAG then
			mpos.y = ri.HitPos.y+1-self.Data.SIZE.y
			hit[#hit+1] = {ri.HitPos,Angle(0,0,-90),ri.HitNormal}
		end
	end
	
	return mpos, pos, add, hit
end

do
	local merge = table.Merge
	
	function ENT:UpdatePlayer(stdid,tbl)
		if type(stdid) != "string" then stdid = stdid:SteamID() end
		
		if self.Data[stdid] then
			merge(self.Data[stdid],tbl)	--this way we can update specific data instead havingto send all data
										--useful when hes only getting unbanned
		else
			self.Data[stdid] = tbl
		end
		
		if SERVER then self:NetWorkMode("~p",stdid,tbl) end
	end
end
do
	local encode = UCombatBox.pon.encode
	--local decode = UCombatBox.pon.decode
	function ENT:UpdateTeams(tbl)
		if SERVER then 
			self:NetWorkMode("~t",self.Data._T)
		else
			self.Data._T = tbl	--teams only full updates
		end
	end

	local add = table.Add

	function ENT:UpdateSpawns(tbl)
		if SERVER then 
			self:NetWorkMode("~s",self.Data._S)
		else
			self.Data._S = tbl	--spawns only full updates
		end
	end
end

function ENT:SetVis(isolateall,playeranyways)
	if serverissued or (CLIENT and self:IsOperator(LocalPlayer())) then
		if type(stdid) != "string" then stdid = stdid:SteamID() end
		
		if CLIENT then
			if self.Data._V != isolateall then
				local all = ents.GetAll()
				for k,ent in next, all do
					ent:CheckShouldDraw()
				end
				all = nil
			elseif self.Data._VP != playeranyways then
				local all = player.GetAll()
				for k,ent in next, all do
					ent:CheckShouldDraw()
				end
				all = nil
			end
			--#not only players! add check for all ents here
		end
		
		self.Data._V = isolateall
		self.Data._VP = playeranyways
		
		if SERVER then self:NetWorkMode(">V",isolateall,playeranyways) 
		elseif not serverissued then self:NetWorkMode(">V",isolateall,playeranyways)  end
	end
end

function ENT:ReInitiate()
	serverissued = true
	for k,v in pairs(self.Data._E) do --Entities
		if IsEntity(k) then self:AddEntity(k) end
	end

	for k,v in pairs(self.Data._P) do --Active Players
		if isstring(k) then if v.active then self:AddPlayer(k,v.teamn) end end
	end
	serverissued = SERVER
end

do
	local function subtbl(dest, source) --merge, except it deletes the entries
		for k,v in pairs(source) do
			if ( type(v) == 'table' && type(dest[k]) == 'table' ) then
				subtbl(dest[k], v)
			else
				dest[k] = nil
			end
		end
		
		return dest
	end
	
	local merge = table.Merge
	
	local function updatein(ENT,tbl)
		if tbl._R then
			if tbl._R.mode ~= ENT.Data._R.mode then
				ENT:SetMode(tbl._R.mode)
			end
			
			ENT.Data = tbl
		elseif tbl[1] and tbl[1]._R then
			if tbl[1]._R.mode ~= ENT.Data._R.mode then
				ENT:SetMode(tbl[1]._R.mode)
			end
			
			ENT.Data = tbl[1]
		end
	end

	--[[------------------------------------------------------
		The Handle table is basically the core of the netcode.
		Each index is a networked string that calls the functions
		attached to them in order to sync server and client more efficiently
		in terms of resources and sourcecode length. (like networked hooks)
		Each UCombatBox has it's own in order to address them directly.
	--------------------------------------------------------]]

	ENT.HandleAssert = { --is a netmessage fails the assertcheck here it will be cached on th client until it passes the check like when an entity isn't ready before the netmessage arrives
		["+e"]	= function(self, tbl) return (tbl and IsValid(tbl[1]))	end,	--entity added
	}

	ENT.Handle = {
		["m"]	= function(self, tbl) merge(self.Data,tbl[1]);	self:ReInitiate() end,			--combine information
		["r"]	= function(self, tbl) subtbl(self.Data,tbl[1])	end,			--player left?
		["u"]	= function(self, tbl) if CLIENT then self:DumpCache() end self.Data = tbl[1]	or tbl;	self:ReInitiate() end,			--dumps cache since an update contains all information and replace old with new data table then reinitiates child entities,
		
		["o"]	= function(self, tbl) self.Data._O = tbl 		end,			--owner steamid+ent
		["o1"]	= function(self, tbl) 							--register owner by steamid
				if tbl then
					local ID
					if isstring(tbl) then ID = tbl else ID = tbl[1] end
					self.Data._O[1] = ID
					if UCombatBox.STDID[ID] then
						self.Data._O[2] = UCombatBox.STDID[ID]
					end
				end
		end,			--owner steamid
	
		--setup
		[">M"]	= function(self, tbl) self:SetMode(tbl[1])				end,
		[">S"]	= function(self, tbl) self:SetSetup(tbl[1])				end,
		[">V"]	= function(self, tbl) self:SetVis(tbl[1],tbl[2])			end,
		["wh"]	= function(self, tbl) self:SetSize(tbl[1],tbl[2],tbl[3])	end,
		["~wh"]	= function(self) self:UpdateSize()						end,
		
		["@d"]	= function(self) self:Deploy()							end,
		["@c"]	= function(self) self:Collapse()							end,
		
		["~t"]	= function(self, tbl) self:UpdateTeams(tbl[1])	end,
		["~s"]	= function(self, tbl) self:UpdateSpawns(tbl[1])	end,

		["+t"]	= function(self, tbl) self:AddTeam(tbl[1],tbl[2])	end,
		["-t"]	= function(self, tbl) self:RemoveTeam(tbl[1],tbl[2])	end,

		--entities
		["+p"]	= function(self, tbl) self:AddPlayer(tbl[1],tbl[2])					end,	--player joined
		["-p"]	= function(self, tbl) self:RemovePlayer(tbl[1],tbl[2],tbl[3],tbl[4])	end,	--player left
		["~p"]	= function(self, tbl) self:UpdatePlayer(tbl[1],tbl[2])				end,	--player edited
		
		["+e"]	= function(self, tbl) self:AddEntity(tbl[1])		end,	--entity added
		["-e"]	= function(self, tbl) self:RemoveEntity(tbl[1])	end,	--entity removed
		
		["_p"]	= function(self, tbl) self:ResetPlayer(tbl[1])	end,
		["_#"]	= function(self, tbl) self:ResetAllPlayers() end,
		
		--rounds
		["$s+"]	= function(self, tbl) self:StartRound(tbl[1],tbl[2])	end,
		["$s-"]	= function(self) 	 self:StopRound()		end,

		--ops and mods
		["+op"]	= function(self, tbl) self:AddOperator(tbl[1]) self.Data._OP[stid] = true	end,
		["-op"]	= function(self, tbl) self:RemoveOperator(tbl[1]) self.Data._OP[stid] = nil end,

		["+mod"]	= function(self, tbl) self:AddModerator(tbl[1]) self.Data._MOD[stid] = true	end,
		["-mod"]	= function(self, tbl) self:RemoveModerator(tbl[1]) self.Data._MOD[stid] = nil	end,

	}

	ENT.HandlePermission = { --shared permission whitelist
		["m"]	= function(self, ply) return self:IsOperator(ply) 	end,			--combine information
		["r"]	= function(self, ply) return self:IsOperator(ply) 	end,			--player left?
		["u"]	= function(self, ply) return self:IsOperator(ply) 	end,			--replace old with new then reinitiates child entities
		
		["o"]	= function(self, ply) return serverissued  	end,			--owner steamid+ent
		["o1"]	= function(self, ply) return serverissued 	end,			--owner steamid

		[">M"]	= function(self, ply) return self:IsModerator(ply) 	end,
		[">S"]	= function(self, ply) return self:IsOperator(ply) 	end,
		[">V"]	= function(self, ply) return self:IsOperator(ply) 	end,
		["wh"]	= function(self, ply) return self:IsOperator(ply) 	end,
		["~wh"]	= function(self, ply) return self:IsOperator(ply) 	end,
		
		["@d"]	= function(self, ply) return self:IsOperator(ply) 	end,
		["@c"]	= function(self, ply) return self:IsOperator(ply) 	end,
		
		["~t"]	= function(self, ply) return self:IsOperator(ply) 	end,
		["~s"]	= function(self, ply) return self:IsOperator(ply) 	end,

		["+t"]	= function(self, ply) return self:IsOperator(ply) 	end,	--player joined
		["-t"]	= function(self, ply) return self:IsOperator(ply) 	end,	--player left

		--entities
		["+p"]	= function(self, ply) return self:IsModerator(ply) 	end,	--player joined
		["-p"]	= function(self, ply) return self:IsModerator(ply) 	end,	--player left
		["~p"]	= function(self, ply) return self:IsModerator(ply) 	end,	--player edited
		
		["+e"]	= function(self, ply) return self:IsOperator(ply) 	end,	--entity added
		["-e"]	= function(self, ply) return self:IsOperator(ply) 	end,	--entity removed
		
		["_p"]	= function(self, ply) return self:IsModerator(ply) 	end,
		["_#"]	= function(self, ply) return self:IsModerator(ply) 	end,
		
		--rounds
		["$s+"]	= function(self, ply) return self:IsModerator(ply) 	end,
		["$s-"]	= function(self, ply) return self:IsModerator(ply) 	end,

		--ops and mods
		["+op"]	= function(self, ply) return self:IsOwner(ply) 	end,
		["-op"]	= function(self, ply) return self:IsOwner(ply) 	end,

		["+mod"]	= function(self, ply) return self:IsOwner(ply) 	end,
		["-mod"]	= function(self, ply) return self:IsOwner(ply) 	end,

	}

	function ENT:HandleNetwork( mode, data )
		if CLIENT then serverissued = true end
		print("ENT:HandleNetwork( mode, data )",mode,data)
		if self.Handle[mode] then
			self.Handle[mode](self, data)
		end
		if CLIENT then serverissued = false end
	end
end

function ENT:RegisterPlayerValueFunction(name,NW_ID,useAdd,isDefault)
	if self.Handle[NW_ID] then return end --no error for stupidity lol
	
	local addn = "Add"..name.."s"
	local setn = "Set"..name.."s"
	local getn = "Get"..name.."s"
	
	local _P = self.Data._P
	local _T = self.Data._T
	
	if useAdd then
		self[addn] = function(self,ply,num)
			if serverissued or (CLIENT and self:IsModerator(LocalPlayer())) then
				if type(ply) != "string" then if not ply.SteamID then return else ply = ply:SteamID() end end

				if not _P[ply] then return end
				local _P2 = _P[ply]
				if not _P2[name] then return end
				
				_P2[name] = _P2[name] + num
				
				if SERVER then self:NetWorkMode(NW_ID,ply,num)
				elseif not serverissued then self:NetWorkMode(NW_ID,ply,num) end
				
				if not _P2.team or _P2.team == "" then return end
				_P2.team  = _T[team]
				if not _P2.team or not _P2.team[name] then return end
				_P2.team[name] = _P2.team[name] + num
			end
		end
	end
	
	self[setn] = function(self,ply,num)
		if serverissued or (CLIENT and self:IsModerator(LocalPlayer())) then
			if type(ply) != "string" then if not ply.SteamID then return else ply = ply:SteamID() end end
		
			if not _P[ply] then return end
			local _P2 = _P[ply]
			if not _P2[name] then return end
			local old = _P2[name]
			_P2[name] = num
			
			if SERVER then self:NetWorkMode("#"..NW_ID,ply,num)
			elseif not serverissued then self:NetWorkMode(NW_ID,ply,num) end

			if not _P2.team or _P2.team == "" then return end
			if not _T[_P2.team] then return end
			
			_T = _T[_P2.team]
			if not _T then return end
			_T[name] = _T[name] - old + num
		end
	end
	
	self[getn] = function(self,ply)
		if type(ply) != "string" then if not ply.SteamID then return else ply = ply:SteamID() end end
	
		if not _P[ply] then return end
		local _P2 = _P[ply]
		
		if _P2.team and _P2.team != "" and _T[team_P.team] then
			return _P2[name], _T[team_P.team][name]
		else
			return _P2[ply][name]
		end
	end
	
	self.Handle[NW_ID] = function(self,in_tbl)  self[addn](self,in_tbl[1],in_tbl[2])		end
	self.Handle["#"..NW_ID] = function(self,in_tbl)  self[setn](self,in_tbl[1],in_tbl[2])	end

	self.HandlePermission[NW_ID] = function(self, ply) return self:IsModerator(ply)		end
	self.HandlePermission["#"..NW_ID] = function(self, ply) return self:IsModerator(ply)	end

	local ret = {addn,setn,getn,NW_ID,"#"..NW_ID,name}
	self.Data["_VAL"][name] = ret --register the value
	
	--in case you add them at runtime:
	for k,v in pairs(self.Data._P) do
		self.Data._P[k][tbl] = 0
	end
	for k,v in pairs(self.Data._T) do
		self.Data._T[k][tbl] = 0
	end
	
	if not isDefault then
		self.data._av[#self.data._av+1]=ret
	end
	
	return ret --return the names for deletion when loading a different gamemode
end


function ENT:RemovePlayerValueFunction(tbl)
	if #tbl != 6 then return end
	if not self[tbl[1]] then return end
	if not self[tbl[2]] then return end
	if not self[tbl[3]] then return end
	
	if not self.Handle[tbl[4]] then return end
	if not self.Handle[tbl[5]] then return end
	
	if not self.Data._VAL[tbl[6]] then return end
	
	self[tbl[1]] = nil
	self[tbl[2]] = nil
	self[tbl[3]] = nil
	self.Handle[tbl[4]] = nil
	self.Handle[tbl[5]] = nil
	self.Data._VAL[tbl[6]] = nil
	
	for k,v in pairs(self.Data._P) do
		self.Data._P[k][tbl[6]] = nil
	end
	for k,v in pairs(self.Data._T) do
		self.Data._T[k][tbl[6]] = nil
	end

	return true
end

function ENT:RegisterValueFunction(name,NW_ID,useAdd)
	if self.Handle[NW_ID] then return end --no error for stupidity lol
	
	local addn = "Add"..name.."s"
	local setn = "Set"..name.."s"
	local getn = "Get"..name.."s"
	
	local _CT = self.Data._CT --_CT table gets reset when loading a new gamemode
	
	if useAdd then
		self[addn] = function(self,num)
			if serverissued or (CLIENT and self:IsOperator(LocalPlayer())) then
				if SERVER then self:NetWorkMode(NW_ID,ply,num)
				elseif not serverissued then self:NetWorkMode(NW_ID,ply,num) end

				_CT[NW_ID] = _CT[NW_ID] + num

			end
		end
	else
		addn = nil
	end
	
	self[setn] = function(self,num)
		if serverissued or (CLIENT and self:IsOperator(LocalPlayer())) then

			if SERVER then self:NetWorkMode("#"..NW_ID,ply,num)
			elseif not serverissued then self:NetWorkMode(NW_ID,ply,num) end

			_CT[NW_ID] = num

		end
	end
	
	self[getn] = function(self)
		return _CT[NW_ID]
	end
	
	self.Handle[NW_ID] = function(self,in_tbl)  self[addn](self,in_tbl[1],in_tbl[2])		end
	self.Handle["#"..NW_ID] = function(self,in_tbl)  self[setn](self,in_tbl[1],in_tbl[2])	end

	self.HandlePermission[NW_ID] = function(self, ply) return self:IsModerator(ply)		end
	self.HandlePermission["#"..NW_ID] = function(self, ply) return self:IsModerator(ply)	end
end


function ENT:RemoveValueFunction(tbl)
	if #tbl != 6 then return end
	if not self[tbl[1]] then return end
	if not self[tbl[2]] then return end
	if not self[tbl[3]] then return end
	
	if not self.Handle[tbl[4]] then return end
	if not self.Handle[tbl[5]] then return end
	
	if not self.Data._VAL[tbl[6]] then return end
	
	self[tbl[1]] = nil
	self[tbl[2]] = nil
	self[tbl[3]] = nil
	self.Handle[tbl[4]] = nil
	self.Handle[tbl[5]] = nil
	self.Data._VAL[tbl[6]] = nil
	
	return true
end

concommand.Add( "vmod_servers",
	function(ply, cmd, args, argstr)

		print("Servers:")
		print("\t[ID]",'"Name"',"SteamID (Owner)")
		

		if table.Count(UCombatBox.ents) > 0 then
			print("\t-----","---","---","---")
			for ent, content in pairs( UCombatBox.ents ) do
				if ent.Data._SETUP then
					print("","["..ent:EntIndex().."]",'"'..ent.Data._N..'"',ent.Data._O[1])
				else
					print("","%"..ent:EntIndex().."%",'"'..ent.Data._N..'"',ent.Data._O[1])
				end
			end
			print("\t-----","---","---","---")
		else
			print("\tNone here.")
		end
	end,
	function(cmd, argstr)
		return {"nothing to complete here"}
	end,
"tetset", 0 )
