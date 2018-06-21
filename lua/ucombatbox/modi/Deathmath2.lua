local MODE = {}

MODE.Title 	= "Deathmatchlol"
MODE.Author	= "Uke"

MODE.ID 	= "tdm2"			--id should be unique
MODE.DERIVE = "tdm"			--copy settings drom another mode(by it's id)
MODE.PLAYABLE = true		--can you play it or should it be a base for others, or both?

hook.Add("test","test2",function() end)

--DON'T EDIT THE MODE.SRC!
MODE.SRC = debug.getinfo(function() end).short_src	--for source determination in case you got a mode id twice it will show you.
return MODE