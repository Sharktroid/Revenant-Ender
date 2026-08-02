extends Node

var _panel: CombatPanel
var _selected_unit: Unit:
	set = _set_selected_unit
var _sprite: UnitSprite
var _probability_sprites: Dictionary[Unit, Label] = {}
var _probabilities: Dictionary[Unit, Array]


func _enter_tree() -> void:
	CursorController.enable()


func _exit_tree() -> void:
	if _sprite:
		_sprite.queue_free()
	for sprite: Label in _probability_sprites.values():
		sprite.queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		if CursorController.get_hovered_unit():
			get_tree().root.set_input_as_handled()
			if _selected_unit:
				if CursorController.get_hovered_unit():
					_panel = CombatPanel.instantiate(
						_selected_unit,
						_display_probabilities,
						_close_panel,
						CursorController.get_hovered_unit(),
						false,
						true
					)
					_panel.focus()
					MapController.get_ui().add_child(_panel)
					CursorController.disable()
			else:
				_selected_unit = CursorController.get_hovered_unit()
		else:
			get_tree().root.set_input_as_handled()
	if event.is_action_pressed("back"):
		get_tree().root.set_input_as_handled()
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
		if _selected_unit:
			_selected_unit = null
			if _probability_sprites.has(_selected_unit):
				print_stack()
				_probability_sprites[_selected_unit].queue_free()
		else:
			queue_free()


func _process(_delta: float) -> void:
	if _selected_unit:
		var terrain_cost: float = MapController.map.get_terrain_cost(
			_selected_unit.unit_class.get_movement_type(), CursorController.map_position
		)
		if terrain_cost < INF:
			_sprite.position = CursorController.map_position


func _display_probabilities() -> void:
	var hovered_unit: Unit = CursorController.get_hovered_unit()
	var sprite: Label = _probability_sprites.get_or_add(hovered_unit, Label.new())
	var combat := Combat.new(
		_selected_unit,
		hovered_unit,
		_selected_unit.get_weapon().get_min_range(),
		_panel.get_combat_art()
	)
	sprite.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_get_probabilities(hovered_unit).append(combat.get_outcomes()[hovered_unit])
	var current_probabilities: Dictionary[int, float] = (
		(_get_probabilities(hovered_unit)[0] as Dictionary[int, float]).duplicate()
	)
	for additional_probabilities: Dictionary[int, float] in _get_probabilities(hovered_unit).slice(1):
		current_probabilities = Combat.combine_probabilities(
			current_probabilities, additional_probabilities, hovered_unit.get_hit_points()
		)
	sprite.text = Utilities.float_to_string(current_probabilities[0] * 100) + "%"
	sprite.position = hovered_unit.position
	MapController.map.get_child(0).add_child(sprite)
	_selected_unit = null
	_close_panel()


func _close_panel() -> void:
	_panel.queue_free()
	CursorController.enable()


func _set_selected_unit(unit: Unit) -> void:
	_selected_unit = unit
	if _sprite:
		_sprite.queue_free()
	if _selected_unit:
		_sprite = _selected_unit.get_sprite()
		_sprite.modulate.a = 0.5
		MapController.map.get_child(0).add_child(_sprite)
		_sprite.set_animation(UnitSprite.Animations.MOVING_DOWN)


func _get_probabilities(unit: Unit) -> Array[Dictionary]:
	return _probabilities.get_or_add(unit, [] as Array[Dictionary])
