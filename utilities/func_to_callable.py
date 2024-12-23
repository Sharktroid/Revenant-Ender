import pyperclip
s = pyperclip.paste()
name = s.split("(")[0].replace("func _", "")
parameters = s.split("(")[1]
pyperclip.copy(f"var {name}: Callable = func({parameters}")
