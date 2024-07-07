extends UnitMenu


static func instantiate(
	new_offset: Vector2, parent: MapMenu, unit_controller: SelectedUnitController, unit: Unit
) -> UnitMenu:
	const PACKED_SCENE = preload("res://ui/map_ui/map_menus/canto_menu/canto_menu.tscn")
	var scene: UnitMenu = _base_instantiate(PACKED_SCENE, new_offset, parent, unit_controller, unit)
	return scene


func update() -> void:
	pass


func _wait() -> void:
	(caller as CantoController).remove_tiles()
	super()
