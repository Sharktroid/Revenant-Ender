extends Control

var value: int = 0:
	set(new_value):
		value = new_value
		var value_label := $Value as Label
		var sign_label := $Sign as Label
		visible = false
		if value != 0:
			sign_label.visible = false
			const ARROW = preload("res://ui/level_up_screen/arrow.gd")
			var arrow := value_label.get_node("Control/Arrow") as ARROW
			await get_tree().create_timer(1.0/60).timeout
			visible = true
			arrow.position.y = -1
			arrow.set_shape(ARROW.shapes.SQUISHED)
			await get_tree().create_timer(1.0/60).timeout
			arrow.position.y = -4
			arrow.set_shape(ARROW.shapes.DEFAULT)
			await get_tree().create_timer(1.0/60).timeout
			arrow.position.y = -10
			arrow.set_shape(ARROW.shapes.TALL)
			await get_tree().create_timer(1.0/60).timeout
			arrow.position.y -= 3
			await get_tree().create_timer(2.0/60).timeout
			arrow.set_shape(ARROW.shapes.DEFAULT)
			await get_tree().create_timer(2.0/60).timeout
			arrow.set_shape(ARROW.shapes.SQUISHED)
			await get_tree().create_timer(3.0/60).timeout
			arrow.set_shape(ARROW.shapes.DEFAULT)
			await get_tree().create_timer(2.0/60).timeout
			arrow.position.y += 2
			await get_tree().create_timer(2.0/60).timeout
			arrow.position.y += 3
			arrow.set_shape(ARROW.shapes.SLIGHT_SQUISHED)
			await get_tree().create_timer(1.0/60).timeout
			arrow.position.y -= 2
			arrow.set_shape(ARROW.shapes.DEFAULT)
			sign_label.visible = true
			if value > 0:
				sign_label.text = "+"
			else:
				sign_label.text = "-"
			value_label.text = str(abs(value))
