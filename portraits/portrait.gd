class_name Portrait
extends Sprite2D

enum emotions {NONE, DEFAULT, HAPPY}

var _talking: bool = false
var _talking_frame: int = 0
var _delay: int = 0
var _current_mouth: Sprite2D
var _emotion := emotions.DEFAULT


func _ready() -> void:
	if has_node("Mouth"):
		_current_mouth = $Mouth
	else:
		_current_mouth = Sprite2D.new()
		_current_mouth.vframes = 3


func _physics_process(_delta: float) -> void:
	# Based on values from FE8
	# FE6: 0x02024492 for frame, 0x02024493 for duration
	# FE8: 0x02025774 for frame, 0x02025776 for duration
	if _talking:
		if _delay == 0:
			_talking_frame += 1
			_talking_frame %= 4
			_delay = randi_range(2, 9)
		else:
			_delay -= 1
	if _emotion != emotions.NONE:
		if _talking_frame == 3:
			_current_mouth.frame = 1
		else:
			_current_mouth.frame = _talking_frame


func set_talking(talking: bool) -> void:
	_current_mouth.visible = true
	_talking = talking
	_talking_frame = 0


func set_emotion(emotion: emotions) -> void:
	_emotion = emotion
	for mouth: Sprite2D in get_tree().get_nodes_in_group("mouth"):
		mouth.visible = false
	match _emotion:
		emotions.HAPPY: _current_mouth = $"Mouth Happy"
		emotions.NONE: _current_mouth = Sprite2D.new()
		_: _current_mouth = $Mouth
	if _emotion != emotions.NONE:
		_current_mouth.visible = true


func flip() -> void:
	flip_h = not flip_h
	for child: Sprite2D in get_children():
		child.position.x = texture.get_size().x - child.position.x - child.texture.get_size().x
		child.flip_h = not child.flip_h
