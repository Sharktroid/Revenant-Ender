Before you commit
* Format
* Spell check
* Document everything you touched
* Make sure it all works

# Minor

# Major
* Renovate debug menu
	* Split into debug options and the others.
	* Add debug constant to control whether the setting is displayed in the main map menu
* Implement dual weapons
* Have option to display stat details all at once
* Add turnwheel
* Add stats for performing kills on certain terrain and units of categories
* Add unit hover display
* Document classes (roll this out gradually so I don't burn out)
* Add DS Font
* Implement effective damage
	* Display effective damage on status screen.
* Implement weapon rank bonuses
* Investigate particles.
* Implement terrain stars and a terrain status menu.
	* Does not affect tomes
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
* Shields
	* Can parry via combat art if shield weight > opponent's weapon weight (costs 3 durability)
		* Cannot parry tomes
* Implement durability
	* Physical weapons have Berwick-style breaking
		* Good, Decent, Bad, and Critical
			* -5 Crit penalty when below Good
			* -2 might penalty when below decent
			* Critical means weapon has a chance of breaking
		* Durability decreases based on condition and rng
* Combine statistic and item screens
* Implement AI
* Implement activated skills
	* Add Accost
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
* Palette the status screen for each unit
* Add simple and extended scripts
* Add Berwick-style 0 range
* Add Berwick-style unit moving

# Long-term
* Make game based on design document
	* Demo for first few chapters
<!-- * Scrub Emblem
	* Features scrub FE3 units
* Dungeon crawler thing.
* FERemix/Age of Emblem?
* Implement FE5 Chapter 1 -->
