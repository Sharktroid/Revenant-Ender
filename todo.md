# Minor
* Have base stats be end stats - 20, multiplied by a coefficient to make max PVs and EVs with 30 base at level 1 have a stat of 10
	* HP is just HP/2
* Add DS font
* Replace map sprites with Thracia equivalents
* Have enemy sprites be horizontally swapped
* Use more node groups
* Make updating more efficient with setters
* Replace claws with shields
* Have debug constants use enums and have them not be called "constants"
* Fix canto jank
	* Add sfx
	* Disable waiting on allied units
	* Have the unit use the moving down animation
	* Add ghost unit
	* Disallow viewing unit's tiles
	* Fix canto menu position
* Fix crash when backing out of drop
* Fix EXP percent not being navigable with arrows
* Fix help menu expanding in the x-axis while closing a small popup
* Fix ranged units not being able to attack via attack tiles

# Major
* Make certain scenes into objects that load the scenes to make the code less janky
* Add the remaining sub menus of the main map menu
* Make attack Animations skippable
* Implement durability
* Implement authority
* Implement AI
* Implement staves
	* Duration = (staff might) + (mag - target res)/4

# Long-term
* Implement FE6 Chapter 1
* Make game based on design document
