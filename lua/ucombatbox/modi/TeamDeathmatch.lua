local MODE = {}

MODE.Title 	= "Team Deathmatch"
MODE.Author	= "Uke"

MODE.ID 	= "tdm"			--id should be unique
MODE.DERIVE = "dm"			--copy settings drom another mode(by it's id)
MODE.PLAYABLE = true		--can you play it or should it be a base for others, or both?
MODE.DERIVETEST = "dasdafgdfgaeg"


--DON'T EDIT THE MODE.SRC! it will error if it's not a function or do nothing if theres code inside
MODE.SRC = debug.getinfo(function() end).short_src	--for source determination in case you got a mode id twice it will show you.
return MODE