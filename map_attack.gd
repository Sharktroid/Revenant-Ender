class_name MapAttack
extends Node2D

signal deal_damage
signal complete
signal arrived
signal proceed

var new_pos: Vector2i
var target_tile: Vector2i
var unit: Unit


func _init(connected_unit: Unit = null, targeted_tile: Vector2i = Vector2i(0, 16)) -> void:
	self.unit = connected_unit
	self.target_tile = targeted_tile


func _ready() -> void:
	var combat_sprite: Unit = unit.duplicate()
	for child in combat_sprite.get_children():
		(child as Node).queue_free()
	combat_sprite.position = Vector2i()
	add_child(combat_sprite)
	position = unit.position
	new_pos = position
	wait()


func _physics_process(delta: float) -> void:
	position = position.move_toward(new_pos, 1)


func play_animation() -> void:
	var movement: Vector2 = (target_tile as Vector2 - position).normalized() * 4
	await _move(movement)
	emit_signal("deal_damage")
#	await proceed
	await _move(-movement)
	emit_signal("complete")


func wait() -> void:
	pass


func _move(pos: Vector2i) -> void:
	new_pos += pos
	while (position != (new_pos as Vector2)):
		await (get_tree() as SceneTree).process_frame
	emit_signal("arrived")

