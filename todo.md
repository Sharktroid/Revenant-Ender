Before you commit
* Format
* Spell check
* Document everything you touched
* Make sure it all works

# Minor
* Use TODO notation to store these as well.
* Fix the combat panel arrows when pressing attack
* Fix bug where clicking on an item container of the same position of the last closed one doesn't work.
* Have hand in options menu for the bars be based on the cursor position.
* Add universal swap and give draw back to all infantry classes and give it the same formula as shove.
* Fix status menu scrolling while help menu is active.
* Fix broken arrow key scrolling in Status Screen.
* Revamp effective weapons to be more specific to class/weapon type.
* System for multiple sources to try to pause the tree.
* Trim rewind if turn count is getting too high.

# Major
* BITMAPS!
* Implement activated skills
	* Something for dealing with multiple copies of the same skill
* Tomes can't initate at 1-range.
* Have help bubble be a fixed position thing.
* Make it possible to attack preview with any unit at any time
* Add testing mode
	* Allow the player to manually rig via an option
* Display effective damage on status screen.
* Implement terrain stars and a terrain status menu.
	* Does not affect tomes
* Implement durability
	* Weapon debuffs when at low durability.
* Implement staves
	* Duration = (staff might) + (mag - target res)/4
	* Automatically hover over a unit if they are the only one that needs healing
	* Add an option to disable support map animations
* Dual Wielding
* Add unit hover display
* Document classes (roll this out gradually so I don't burn out)
* Add DS Font
* Investigate particles.
* Replace movement/attack tile calls with units having different ActionTileStates
	* display_current_attack_tiles should allow displaying support tiles
* Make movement and related tiles behave more like in AW:DoR
* Add rescue when clicking on an ally
* Have level up play sfx even when volume is muted
* Add the remaining sub menus of the main map menu
* Make attack Animations skippable
* Guide
* Combine statistic and item screens
* Implement AI
* Add grenades.
* Implement split screen like in demo
* Replace test map with Thracia chapter 1
* Replace map attack animations with Thracia counterparts
* Implement a project system
* Implement gaining EVs
	* Have units gain +0.02 movement EVs per tile traversed
* Palette the status screen for each unit
* Add simple and extended scripts
* Add Berwick-style unit moving
* Shields
* Can parry via combat art if shield weight > opponent's weapon weight (costs 3 durability)
	* Cannot parry tomes
* 5D FE.

# Possible
* Add testing suite
	* Add tests for previous and future bugs/regressions
		* Empty inventory.
		* Moving and waiting.
		* Attacking.
* Add game settings (can't be changed on map)
	* Include options for RNG
		* Battle hit rates can't go below weapon's hit rates in dampened mode.
* Add stats for performing kills on certain terrain and units of categories

# Long-term
* Make game based on design document
	* Demo for first few chapters
