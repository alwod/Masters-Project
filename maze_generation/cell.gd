class_name Cell

var grid_position: Vector2i # Used for maze generation
var visited: bool # Used for maze generation
var connected_from: Vector2i # Used for maze generation

var connects_to: Vector2i # Used for maze generation and A*
var is_wall: bool # Used for maze generation A*

# Used for A*
var f_cost: int = 0
var g_cost: int = 0
var h_cost: int = 0
var is_start: bool = false
var is_goal: bool = false
var open_list: bool = false
var closed_list: bool = false

# Used for D* Lite
var rhs: int # The Right-Hand-Side is the minimum cost from this node to its neighbours

func _init(coords: Vector2i) -> void:
	grid_position = coords
	visited = false
	
	# Check if the cell is a wall cell or path cell
	if ((grid_position.x % 2 == 0) || (grid_position.y % 2 == 0)):
		is_wall = true
	elif ((grid_position.x == 0) || (grid_position.y == 0)):
		is_wall = true
	else:
		is_wall = false

func reset_values() -> void:
	visited = false
	connected_from = Vector2i(-1, -1)
	connects_to = Vector2i(-1, -1)
	f_cost = 0
	g_cost = 0
	h_cost = 0
	#is_start = false
	#is_goal = false
	open_list = false
	closed_list = false
	

func print_details() -> void:
	print("Position: ", grid_position)
	print("Visited: ", visited)
	if (connects_to):
		print("Connects to: ", connects_to)
	else:
		print("Doesnt connect to anything")
	print("\n")
