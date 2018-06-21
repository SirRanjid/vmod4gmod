local MODE = {}

MODE.Title 	= "1HP per shot"
MODE.Author	= "Uke"

MODE.ID 	= "shp"			--id should be unique
MODE.DERIVE = "base"			--copy settings drom another mode(by it's id)
MODE.PLAYABLE = true		--can you play it or should it be a base for others, or both?

--DON'T EDIT THE MODE.SRC!
MODE.SRC = debug.getinfo(function() end).short_src	--for source determination in case you got a mode id twice it will show you.
return MODE