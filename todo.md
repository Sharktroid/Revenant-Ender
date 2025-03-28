Before you commit
* Format
* Spell check
* Document everything you touched
* Make sure it all works

# Minor
* Fix stat bars when switching from item panel.
* Fix crashes with empty inventory
* Test keyboard ghosting with controllers
	* See if Input calls in _input functions can be removed

# Major
* Add testing suite
	* Add tests for previous and future bugs/regressions
* Add categories to options menu, and remove debug options menu
	* Add game settings (can't be changed on map)
		* Include options for RNG
			* Battle hit rates can't go below weapon's hit rates in dampened mode
* Make it possible to attack preview with any unit at any time
* Add testing mode
	* Allow the player to manually rig via an option
* Implement effective damage
	* Display effective damage on status screen.
* Implement terrain stars and a terrain status menu.
	* Does not affect tomes
* Implement durability
* Implement activated skills
	* Add Accost
* Implement staves
	* Duration = (staff might) + (mag - target res)/4
	* Automatically hover over a unit if they are the only one that needs healing
	* Add an option to disable support map animations
* Dual Wielding
* Implement dual weapons
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
* Implement split screen like in demo
* Replace test map with Thracia chapter 1
* Replace map attack animations with Thracia counterparts
* Implement a project system
* Implement gaining EVs
	* Have units gain +0.02 movement EVs per tile traversed
* Palette the status screen for each unit
* Add simple and extended scripts
* Add Berwick-style 0 range
* Add Berwick-style unit moving
* Shields
* Can parry via combat art if shield weight > opponent's weapon weight (costs 3 durability)
	* Cannot parry tomes

# Possible
* Add stats for performing kills on certain terrain and units of categories
* Physical weapons have Berwick-style breaking
	* Good, Decent, Bad, and Critical
		* -5 Crit penalty when below Good
		* -2 might penalty when below decent
		* Critical means weapon has a chance of breaking
	* Durability decreases based on condition and rng

# Long-term
* Make game based on design document
	* Demo for first few chapters
