Before you commit
* Format
* Spell check
* Document everything you touched
* Make sure it all works

# Minor
* Rename "canto" to "canter"
* Fix canto tiles.
* Hide map cursor when scrolling
* Have weapon rank increases on level up be linked to skill
* Pallette the status screen for each unit
* Rename Combat Display to Combat Panel and revamp the scene tree to be less hacky
	* Expand the center labels
* Fix bug with combat display menu
* Add TRS markers
* Clean up debug map borders
* Have combat panel display green damage if unit can one-round
* Show hp preview on combat panel
* Have movement ranges display even for waited units
* Change authority to +5 * (allied authority - enemy authority) hit and
+1 * authority stars damage dealt and -1 * authority stars damage taken if within authority giver
* Rewrite "_on_area2d_area_entered" in Unit
* Make 1 skill and luck +4 hit and 1 speed and luck +4 avoid.
* Add option for having the equipped weapon change if you use the attack preview with it.
* Fix cursor not scrolling when mouse is still
* Make static var tween to control unit map idle animation
* Fix hover tiles not showing up after canto.
* Add option to make cursor return to unit upon deselecting.
* Add universal actionable swap
* Add shove
* Add Accost

# Major
* Renovate debug menu
	* Split into debug options and the others.
	* Add debug constant to control whether the setting is displayed in the main map menu
* Replace recieving input with pausing/unpausing via process_mode = ProcessMode.PROCESS_MODE_DISABLED
* Implement dual weapons
* Have option to display stat details all at once
* Add undoing a non-combat command
* Add stats for performing kills on certain terrain and when units of categories
* Add unit hover display
* Document classes (roll this out gradually so I don't burn out)
* Add DS Font
* Implement effective damage
	* Display effective damage on status screen.
* Implement weapon rank bonuses
* Investigate particles.
* Implement terrain stars and a terrain status menu.
* Make movement and related tiles behave more like in AW:DoR
* Add combat preview even if attacking is not possible
* Add rescue when clicking on an ally
* Replace movement/attack tile calls with units having different ActionTileStates
	* display_current_attack_tiles should allow displaying support tiles
* Have level up play sfx even when volume is muted
* Add the remaining sub menus of the main map menu
* Make GhostUnit a child of Unit and remove jankiness
* Make attack Animations skippable
* Dual Wielding
* Implement durability
* Implement authority
* Implement AI
* Implement staves
	* Duration = (staff might) + (mag - target res)/4
	* Automatically hover over a unit if they are the only one that needs healing
	* Add an option to disable support map animations
* Implement split screen like in demo
* Replace test map with Thracia chapter 1
* Replace map attack animations with Thracia counterparts
* Implement a project system
* Do something about the way input works
* Implement gaining EVs
	* Have units gain +0.02 movement EVs per tile traversed

# Long-term
* Scrub Emblem
	* Feautres scrub FE3 units
* Dungeon crawler thing.
* FERemix/Age of Emblem?
* Implement FE5 Chapter 1
* Make game based on design document
