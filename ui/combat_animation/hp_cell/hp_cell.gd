extends TextureRect

var fast_layer: bool = false:
	set(value):
		fast_layer = value
		_fast_layer_node.visible = value
var slow_layer: bool = false

var _velocity: Vector2
var _break: bool = false
@onready var _fast_layer_node := $Fill/FastLayer as Sprite2D
@onready var _slow_layer_node := $Fill/SlowLayer as TextureProgressBar

func _ready() -> void:
	if slow_layer == false:
		_slow_layer_node.value = 0


func _physics_process(_delta: float) -> void:
	_slow_layer_node.value += 1 if slow_layer else -1
	if _break:
		($Fill as Node2D).position += _velocity
		_velocity.y += 1

func shatter() -> void:
	_break = true
	_velocity = Vector2.from_angle(randf() * 2 * PI) * 10
