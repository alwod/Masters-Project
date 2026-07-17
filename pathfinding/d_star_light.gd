class_name Dstarlight

# To keep things consistent when testing pathfinding algorithms in random mazes,
# the start will always be the top left cell and the goal the bottom right cell for now.
var start: Vector2i = Vector2i(1, 1)
var goal: Vector2i

var maze: Array # A copy of the maze created by the maze generator
var maze_size: Vector2i
#var open_list: Array[Vector2i]
#var closed_list: Array[Vector2i]

var movement_cost: int = 1

var key_modifier: int

# Priority Queue
var priority_queue: Dictionary[Vector2i, DKey]

# "D* Lite Key" There is already a Key object so I'm calling this a DKey instead to avoid confusion
class DKey:
	var key_p: int
	var key_s: int
	
	func _init(key_primary, key_secondary) -> void:
		key_p = key_primary
		key_s = key_secondary

func _init(size: Vector2i, new_maze: Array) -> void:
	maze = new_maze
	maze_size = size
	goal = maze_size - start
	maze[start.x][start.y].is_start = true
	maze[goal.x][goal.y].is_goal = true

func pathfinding() -> void:
	# First, make sure priority queue is empty
	priority_queue.clear()
	# Also make sure the key modifier is 0
	key_modifier = 0
	# Make sure every node has a g and rhs value of infinite
	for i in range(maze_size.x):
		for j in range(maze_size.y):
			maze[i][j].g_cost = 100000
			maze[i][j].rhs = 100000
		
	# Add the goal node to the priority queue. Its rhs should always be 0
	maze[goal.x][goal.y].rhs = 0
	var key: DKey = calculate_key(goal)
	priority_queue[goal] = key

func compute_shortest_path() -> void:
	pass

func update_vertex(node: Vector2i) -> void:
	var key: DKey = calculate_key(node)
	# First, if the node's g and rhs are not equal AND it isnt in the priority queue, add it to the queue
	# Else if the node's g and rhs are equal and it's in the queue, remove it from the queue
	# Else, if the nodes in the queue but g and rhs are not equal, update the queue with the new key

func calculate_key(node: Vector2i) -> DKey:
	var key_secondary: int = mini(maze[node.x][node.y].g_cost, maze[node.x][node.y].rhs)
	var key_primary: int = key_secondary + manhattan_method(node) + key_modifier
	var new_key: DKey = DKey.new(key_primary, key_secondary)
	return new_key

func compare_keys(key_a: DKey, key_b: DKey) -> int:
	if (key_a.key_p < key_b.key_p):
		return -1
	elif (key_a.key_p > key_b.key_p):
		return 1
	else:
		return 0

func manhattan_method(node: Vector2i) -> int:
	var distance_vector = goal - node
	# Normalise the distance vector's x and y. Using Godot's built-in normalising method didnt work for some reason
	if (distance_vector.x < 0):
		distance_vector.x *= -1
	if (distance_vector.y < 0):
		distance_vector.y *= -1
	var h_cost = distance_vector.x + distance_vector.y
	return h_cost
