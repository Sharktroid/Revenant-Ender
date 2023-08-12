extends Label

const GROW_SHRINK_DURATION: float = 0.1


func _ready() -> void:
	var final_size = size
	var final_text: String = text
	text = ''
	await get_tree().process_frame
	var start_time: float = Time.get_ticks_msec()
	while size != final_size:
		var elapsed_time: float = Time.get_ticks_msec() - start_time
		size = custom_minimum_size.lerp(final_size, min(elapsed_time/GROW_SHRINK_DURATION/1000, 1))
		await get_tree().process_frame
	text = final_text
