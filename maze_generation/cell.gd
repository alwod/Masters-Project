class_name Cell

var position: Vector2
var visited: bool
var connects_to: Vector2

func _init(coords) -> void:
	position = coords
	visited = false

func print_details() -> void:
	print("Position: ", position)
	print("Visited: ", visited)
	if (connects_to):
		print("Connects to: ", connects_to)
	else:
		print("Doesnt connect to anything")
	print("\n")
