@tool
class_name UnitSprite
extends Sprite2D

## The map animations that a unit can have.
enum Animations { IDLE, MOVING_DOWN, MOVING_UP, MOVING_LEFT, MOVING_RIGHT }

## The unit's class.
@export var unit_class: UnitClass

@export var _faction_id: int:
	set = _set_faction_id
@export_group("Hair")
@export var _custom_hair: bool = false:
	set(value):
		_custom_hair = value
		_update_palette()
@export_color_no_alpha var _hair_color_light: Color
@export_color_no_alpha var _hair_color_dark: Color

## The faction the unit belongs to.
var faction: Faction:
	get:
		if _get_map() and not _get_map().all_factions.is_empty():
			return _get_map().all_factions[_faction_id]
		return Faction.new("INVALID", Faction.Colors.BLUE, Faction.PlayerTypes.HUMAN, null)
	set(new_faction):
		_faction_id = _get_map().all_factions.find(new_faction)
## Whether the unit is animated on the map.
var sprite_animated: bool = true:
	set(value):
		sprite_animated = value
		var get_animation_name: Callable = func() -> StringName:
			if _get_animation_player().assigned_animation == "":
				return &"idle"
			else:
				return _get_animation_player().assigned_animation
		if sprite_animated:
			_get_animation_player().play(get_animation_name.call() as StringName)
		else:
			_get_animation_player().pause()
## Whether the unit is waiting.
var waiting: bool = false:
	set(value):
		waiting = value
		_update_palette()

var _map: Map
var test: bool = false


static func instantiate(
	new_unit_class: UnitClass,
	is_sprite_animated: bool,
	is_waiting: bool,
	new_faction: Faction,
	custom_hair: bool = false,
	hair_color_light := Color.BLACK,
	hair_color_dark := Color.BLACK
) -> UnitSprite:
	const PACKED_SCENE := preload("res://units/unit_sprite/unit_sprite.tscn") as PackedScene
	var unit_sprite := PACKED_SCENE.instantiate() as UnitSprite
	unit_sprite.unit_class = new_unit_class
	unit_sprite.sprite_animated = is_sprite_animated
	unit_sprite.waiting = is_waiting
	unit_sprite.faction = new_faction
	unit_sprite._custom_hair = custom_hair
	unit_sprite._hair_color_light = hair_color_light
	unit_sprite._hair_color_dark = hair_color_dark
	return unit_sprite


func _enter_tree() -> void:
	texture = unit_class.get_map_sprite()
	material = material.duplicate() as Material
	if _get_animation_player().current_animation == "":
		_get_animation_player().play("idle")
	_update_palette()
	if not Engine.is_editor_hint():
		Utilities.sync_animation(_get_animation_player())
	position = position.snapped(Vector2i(16, 16))


func _process(_delta: float) -> void:
	if _get_animation_player().current_animation == "idle":
		var anim_frame: int = floori((Engine.get_physics_frames() as float) / 16) % 4
		frame = 1 if anim_frame == 3 else anim_frame


## Sets the unit's map animation
func set_animation(animation: UnitSprite.Animations) -> void:
	_get_animation_player().play(&"RESET")
	_get_animation_player().advance(0)
	match animation:
		Animations.IDLE:
			_get_animation_player().play(&"idle")
		Animations.MOVING_LEFT:
			_get_animation_player().play(&"moving_left")
		Animations.MOVING_RIGHT:
			_get_animation_player().play(&"moving_right")
		Animations.MOVING_UP:
			_get_animation_player().play(&"moving_up")
		Animations.MOVING_DOWN:
			_get_animation_player().play(&"moving_down")
	if sprite_animated:
		Utilities.sync_animation(_get_animation_player())
	else:
		_get_animation_player().advance(0)
		_get_animation_player().pause()


func _set_faction_id(value: int) -> void:
	_faction_id = value


func _update_palette() -> void:
	if unit_class:
		var shader_material := material as ShaderMaterial
		shader_material.set_shader_parameter("old_colors", unit_class.get_palette_basis())
		var get_palette: Callable = func() -> Array[Color]:
			if waiting:
				return unit_class.get_wait_palette() + _get_grayscale_hair_palette()
			else:
				return (
					unit_class.get_palette(faction.color if faction else Faction.Colors.BLUE)
					+ _get_hair_palette()
				)
		shader_material.set_shader_parameter("new_colors", get_palette.call())


func _get_hair_palette() -> Array[Color]:
	var default_palette: Array[Color] = unit_class.get_default_hair_palette(
		faction.color if faction else Faction.Colors.BLUE
	)
	if _custom_hair:
		var palette_length: int = default_palette.size()
		var palette: Array[Color] = []
		var get_hair_color: Callable = func(index: int) -> Color:
			return _hair_color_light.lerp(
				_hair_color_dark, inverse_lerp(0, palette_length - 1, index)
			)
		palette.assign(range(palette_length).map(get_hair_color))
		return palette
	else:
		return default_palette


func _get_grayscale_hair_palette() -> Array[Color]:
	var default_palette: Array[Color] = unit_class.get_default_hair_palette(faction.color)
	if _custom_hair:
		var palette_length: int = default_palette.size()
		var palette: Array[Color] = []
		var get_grayscale_color: Callable = func(index: int) -> Color:
			var new_color := Color()
			new_color.v = remap(index, 0, palette_length, _hair_color_light.v, _hair_color_dark.v)
			return new_color
		palette.assign(range(palette_length).map(get_grayscale_color))
		return palette
	else:
		return default_palette


func _get_map() -> Map:
	if not _map:
		if Engine.is_editor_hint():
			var current_parent: Node = get_parent()
			while current_parent is not Map and current_parent:
				current_parent = current_parent.get_parent()
			return current_parent as Map
		else:
			return MapController.map
	return _map


func _get_animation_player() -> AnimationPlayer:
	return $AnimationPlayer as AnimationPlayer
