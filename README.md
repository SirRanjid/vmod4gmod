# VMod
Virtual isolated sub-server environments (multiverse) for Garry's Mod. Lets you load and play custom game modes.

It's an entity that lets you specify an optionally solid bordered area as isolated environment to play in.
You can fill that environment(or the entire map if you like) with props and other obstacles, save and load them for fast setup.
Saves are color coded in green if they were saved on your current map but you can load all anyways.

It was initially only intended to let you have an environment with administrative rights for disturbance free playing/building but I kept adding.

Serverbrowser is included in the contextmenu (C by default) with a tab for your's and one for servers hosted by other players. It's rather small above the button to customize your player.

The gamemodes included are mostly placeholder files for ideas I want to ship it with.

__Requirements:__
- Sandbox Mode loaded



__What it has:__
- editor mode to specify the dimensions, obstacles, spawns, gamemode, teams(customizable color&names), save/load
- numeric textfields with integrated calculation (4/2 =[enter]=> 2)
- custom admin/moderator ranks
- custom customizable(heh) animated hud (movable,rotatable, 3d or 2d, adapts brightness to surrounding light conditions)



__What not:__
- clean, commented code



__Planned features:__
- mesh creation to really customize the environment with walls, ramps , etc. (not only props)
- custom scoreboard (also 3d projected to the outside wall of your arena)
- loadout options
- class system
- team spawns
- proper documentation of my interface to replace need of reverse engineering (most functions are already documented in the files themselves (most inside the entities subfolder ../shared.lua))
- (replace the cutomized pON (ucombatbox_pon.lua, https://gmod.facepunch.com/f/gmoddev/mfhs/pON-Penguin-s-Object-Notation-Developer-Release/1/) with  serpent (https://github.com/pkulchenko/serpent) )- (sound isolation as soon as gmod supports it in vanilla, or does it already?)
- (maybe cleanup my code)

__Known Issue:__
- the second time you load an environment data is mixed with the previously loaded environment (save-file remains intact)

__Timeframe:__
- unlimited as it's a hobby based project


Why can't github just view this readme raw by deault.
