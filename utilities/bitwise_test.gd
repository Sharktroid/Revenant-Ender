@tool
extends EditorScript

# Notes:
# a = bit array; f = flag
# a ^ f = a with flag toggled on/off
# a | f = a with flag on
# a & ~f = a with flag off
# a & f = f if a has f else 0
# --
# 1 << x = 2 ** x

func _run() -> void:
	print(1 << 1 & 2)
