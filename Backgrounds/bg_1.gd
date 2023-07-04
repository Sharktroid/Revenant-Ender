extends Control

@export var alt: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if alt:
		$"Gradient Squares BG2".queue_free()
		($"Gradient Squares BG".material as ShaderMaterial).set_shader_parameter('split', true)
