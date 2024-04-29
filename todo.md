# Minor
* Fix bug when deselecting help description and cannot reselect the same item
* Add sound effects to status menu
* Make set/get functions into actual variables
* Make certain resource properties read-only via getters
* Fix bug where units occupy space after dying
* Fix bug where unit palettes break when dying
* Rename "Magic" to "Intelligence" and "Constitution" to "Build"
* Remove "E" weapon rank
* Have unit end stats be interpolated from level 30 for all classes
* Have the PV and EV multipliers be set to √(4/3)

# Major
* Implement experience
	* Animate level up screen
	* Make level up screen multidirectional
	* Add sound effects to experience bar and level up screen
* Make certain scenes into objects that load the scenes to make the code less janky
* Add the remaining sub menus of the main map menu
* Make attack animations skippable
* Implement durability

# Long-term
* Implement FE6 Chapter 1
* Make game based on design document
