# Minor
* Fix bug where a unit doesn't display their tiles if selected before the tiles are displayed
* Fix bug where clicking on an enemy while a unit is moving to attack brings up a new combat display
* Have map hp bar show units from left-to-right
* Adjust shield icon
* Experiment with _gui_input to possibly replace _receive_input
* Replace close() functions with _exit_tree() calls.
* Move FPS code to GameController and make part of standard UI
	* Also move get_map_camera to Map.
* Have 100% rates and effecitive damage in green, and 0% rates and 0 damage in gray
* Display Effective damage on status screen
* Add EarhBound SMASH!!! SFX for mortal crits
* Have units gain +0.02 movement EVs per tile traversed

# Major
* Document classes (roll this out gradually so I don't burn out)
* Investigate particles
* Make tiles behave more like in AW:DoR
* Add combat preview even if attacking is not possible
* Add rescue when clicking on an ally
* Replace movement/attack tile calls with units having different ActionTileStates
	* display_current_attack_tiles should allow displaying support tiles
* Have level up play sfx even when volume is muted
* Add class relative power
* Add options config for volume
* Add the remaining sub menus of the main map menu
* Make GhostUnit a child of Unit and remove jankiness
* Make attack Animations skippable
* Dual Wielding
* Implement durability
* Implement authority
* Implement AI
* Implement staves
	* Duration = (staff might) + (mag - target res)/4
* Implement split screen like in demo
* Replace test map with Thracia chapter 1
* Replace map attack animations with Thracia counterparts
* Implement a project system

# Long-term
* FERemix/Age of Emblem?
* Implement FE5 Chapter 1
* Make game based on design document
