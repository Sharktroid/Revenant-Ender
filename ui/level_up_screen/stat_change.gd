extends HBoxContainer

var value: int = 0:
	set(new_value):
		value = new_value
		($Value as Label).text = str(abs(value))
		var sign_label := $Sign as Label
		if value == 0:
			visible = false
		else:
			visible = true
			if value > 0:
				sign_label.text = "+"
			else:
				sign_label.text = "-"
