extends Sprite2D


func _process(_delta):
	frame = int(GenVars.get_tick_timer()/3) % 16
