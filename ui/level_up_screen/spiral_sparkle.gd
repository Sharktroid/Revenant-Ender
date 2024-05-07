extends Sprite2D

const _DURATION: float = 2.0 / 60


func play() -> void:
	visible = true
	while frame < 10:
		await get_tree().create_timer(_DURATION).timeout
		frame += 1
	await get_tree().create_timer(_DURATION).timeout
	visible = false
