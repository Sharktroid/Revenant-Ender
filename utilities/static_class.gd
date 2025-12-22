class_name StaticClass
extends Resource

func _init() -> void:
	push_error("Cannot instantiate static class.")
	free()
