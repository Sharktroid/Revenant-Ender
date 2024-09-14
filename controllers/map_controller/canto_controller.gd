## [Node] that handles unit control during Canto.
class_name CantoController
extends SelectedUnitController

var _movement_tiles: Node2D


func _init(unit: Unit) -> void:
	_movement_tiles = MapController.map.display_tiles(
		unit.get_movement_tiles(), Map.TileTypes.MOVEMENT, 1.0
	)
	unit.selected = true
	super(unit)
	unit.hide_movement_tiles()


## Removes the displayed unit tiles.
func remove_tiles() -> void:
	if is_instance_valid(_movement_tiles):
		_movement_tiles.queue_free()


func _exit_tree() -> void:
	remove_tiles()
	_unit.selected = false
	super()


func _position_selected() -> void:
	if CursorController.map_position in _unit.get_actionable_movement_tiles():
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)
		const CantoMenu = preload("res://ui/map_ui/map_menus/canto_menu/canto_menu.gd")
		var menu := CantoMenu.instantiate(
			CursorController.screen_position + Vector2i(16, -8), null, self, _unit
		)
		CursorController.disable()
		MapController.get_ui().add_child(menu)


func _canceled() -> void:
	pass
