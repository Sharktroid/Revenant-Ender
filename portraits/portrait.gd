class_name Portrait
extends Sprite2D

enum Emotions { NONE, DEFAULT, HAPPY }

var talking: bool = false:
	set(value):
		talking = value
		_current_mouth.visible = talking
		_talking_frame = 0
var emotion := Emotions.DEFAULT:
	set = set_emotion

var _talking_frame: int = 0:
	set(value):
		_talking_frame = value % 4
		if emotion != Emotions.NONE:
			_current_mouth.frame = 1 if _talking_frame == 3 else _talking_frame
var _current_mouth: Sprite2D


func _ready() -> void:
	if has_node("Mouth"):
		_current_mouth = $Mouth as Sprite2D
	else:
		_current_mouth = Sprite2D.new()
		_current_mouth.vframes = 3


func set_emotion(new_emotion: Emotions) -> void:
	emotion = new_emotion
	for mouth: Sprite2D in get_tree().get_nodes_in_group("mouth") as Array[Sprite2D]:
		mouth.visible = false
	match emotion:
		Emotions.HAPPY:
			_current_mouth = $MouthHappy as Sprite2D
		Emotions.NONE:
			_current_mouth = Sprite2D.new()
		_:
			_current_mouth = $Mouth as Sprite2D
	if emotion != Emotions.NONE:
		_current_mouth.visible = true


func flip() -> void:
	flip_h = not flip_h
	for child: Sprite2D in get_children() as Array[Sprite2D]:
		child.position.x = texture.get_size().x - child.position.x - child.texture.get_size().x
		child.flip_h = not child.flip_h


func _animate_mouth() -> void:
	while talking:
		# Based on values from FE8
		# FE6: 0x02024492 for frame, 0x02024493 for duration
		# FE8: 0x02025774 for frame, 0x02025776 for duration
		_talking_frame += 1
		await get_tree().create_timer(randf_range(2.0, 9.0) / 60).timeout
