class_name Cell

var grid_position: Vector2
var visited: bool
var connects_to: Vector2
var connected_from: Vector2

func _init(coords: Vector2i) -> void:
	grid_position = coords
	visited = false

func print_details() -> void:
	print("Position: ", grid_position)
	print("Visited: ", visited)
	if (connects_to):
		print("Connects to: ", connects_to)
	else:
		print("Doesnt connect to anything")
	print("\n")
