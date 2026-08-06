class_name Dstarlight

# To keep things consistent when testing pathfinding algorithms in random mazes,
# the start will always be the top left cell and the goal the bottom right cell for now.
var start: Vector2i = Vector2i(1, 1)
var goal: Vector2i

var maze: Array # A copy of the maze created by the maze generator
var maze_size: Vector2i

#var movement_cost: int = 1

var key_modifier: int

const MAX_CYCLES: int = 100000000

# Priority Queue
var priority_queue: Dictionary[Vector2i, DKey] # This could probably be improved, as the node position is the key and not the key, which is the value

# "D* Lite Key" There is already a Key object so I'm calling this a DKey instead to avoid confusion
class DKey:
	var key_p: int
	var key_s: int
	
	func _init(key_primary, key_secondary) -> void:
		key_p = key_primary
		key_s = key_secondary
		

# Variables for data collection
var time: int = 0
var iterations: int = 0
var memory_use: float
var path_length: int = 0
var biggest_memory_use = 0
var start_time
var start_memory_use

func _init(new_maze: Array, size: Vector2i, starting_position: Vector2i, goal_position: Vector2i) -> void:
	maze = new_maze
	maze_size = size
	start = starting_position
	goal = goal_position
	maze[start.x][start.y].is_start = true
	maze[goal.x][goal.y].is_goal = true

func pathfinding() -> void:
	start_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
	start_time = Time.get_ticks_usec()
	
	# First, make sure priority queue is empty
	priority_queue.clear()
	# Also make sure the key modifier is 0
	key_modifier = 0
	# Make sure every node has a g and rhs value of infinite
	for i in range(maze_size.x):
		for j in range(maze_size.y):
			maze[i][j].g_cost = 100000000
			maze[i][j].rhs = 100000000
		
	# Add the goal node to the priority queue. Its rhs should always be 0
	maze[goal.x][goal.y].rhs = 0
	var key: DKey = calculate_key(goal)
	priority_queue[goal] = key
	
	compute_shortest_path()

func compute_shortest_path() -> void:
	var max_steps = MAX_CYCLES
	while (priority_queue.size() > 0 && (compare_keys(find_queue_min().values().front(), calculate_key(start), "less_than") || maze[start.x][start.y].rhs > maze[start.x][start.y].g_cost)):
		iterations += 1
		max_steps -= 1
		if (max_steps <= 0):
			break # Didnt find a path
		
		var smallest_key = find_queue_min().values().front()
		var node = find_queue_min().keys().front()
		priority_queue.erase(node)
		if (compare_keys(smallest_key, calculate_key(node), "less_than")):
			var new_key = calculate_key(node)
			priority_queue[node] = new_key
		elif (maze[node.x][node.y].g_cost > maze[node.x][node.y].rhs):
			maze[node.x][node.y].g_cost = maze[node.x][node.y].rhs
			#print(node, " ", maze[node.x][node.y].g_cost, " ", maze[node.x][node.y].rhs)
			# Iterate through all this node's neighbours so their rhs values are up to date
			for neighbour in find_neighbours(node):
				if (!maze[neighbour.x][neighbour.y].is_goal):
					maze[neighbour.x][neighbour.y].rhs = mini(maze[neighbour.x][neighbour.y].rhs, maze[neighbour.x][neighbour.y].movement_cost + maze[node.x][node.y].g_cost)
					#print(neighbour, " ", maze[neighbour.x][neighbour.y].g_cost, " ", maze[neighbour.x][neighbour.y].rhs)
					if (maze[neighbour.x][neighbour.y].is_start):
						print("Found start")
				
				update_vertex(neighbour)
			#print("\n")
		else:
			var old_g = maze[node.x][node.y].g_cost
			maze[node.x][node.y].g_cost = 100000000
			
			# Check all neighbours of the node AND the node itself
			var neighbours_and_node = find_neighbours(node)
			neighbours_and_node.push_front(node)
			for neighbour in neighbours_and_node:
				if (maze[neighbour.x][neighbour.y].rhs == maze[neighbour.x][neighbour.y].movement_cost + old_g):
					if (!maze[neighbour.x][neighbour.y].is_goal):
						maze[neighbour.x][neighbour.y].rhs = 100000000
					
					for neighbour_prime in find_neighbours(neighbour):
						maze[neighbour.x][neighbour.y].rhs = mini(maze[neighbour.x][neighbour.y].rhs, maze[neighbour.x][neighbour.y].movement_cost + maze[neighbour_prime.x][neighbour_prime.y].g_cost)
						
				update_vertex(neighbour)
		
		#print(smallest_key.key_p)
		
		var temp_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
		if (temp_memory_use > biggest_memory_use):
			biggest_memory_use = temp_memory_use
	
	var end_time = Time.get_ticks_usec()
	time = end_time - start_time
	memory_use = biggest_memory_use - start_memory_use
	
	maze[start.x][start.y].g_cost = maze[start.x][start.y].rhs
	path_length = maze[start.x][start.y].g_cost
	print("Shortest path found in ", MAX_CYCLES - max_steps, " steps")
	print(maze[start.x][start.y].g_cost)

func find_neighbours(node: Vector2i) -> Array:
	var north = node + Vector2i(0, -1)
	var west = node + Vector2i(-1, 0)
	var south = node + Vector2i(0, 1)
	var east = node + Vector2i(1, 0)
	
	var neighbours: Array[Vector2i] = [north, west, south, east]
	var valid_neighbours: Array[Vector2i]
	for neighbour in maze[node.x][node.y].neighbours:
		if (!maze[neighbour.x][neighbour.y].is_wall):
			valid_neighbours.push_front(neighbour)
	
	return valid_neighbours

func update_vertex(node: Vector2i) -> void:
	var key: DKey = calculate_key(node)
	# First, if the node's g and rhs are not equal AND it isnt in the priority queue, add it to the queue
	# Else if the node's g and rhs are equal and it's in the queue, remove it from the queue
	# Else, if the nodes in the queue but g and rhs are not equal, update the queue with the new key
	if (maze[node.x][node.y].g_cost != maze[node.x][node.y].rhs && !priority_queue.has(node)):
		priority_queue[node] = key
	elif (maze[node.x][node.y].g_cost == maze[node.x][node.y].rhs && priority_queue.has(node)):
		priority_queue.erase(node)
	elif (priority_queue.has(node)):
		priority_queue.erase(node)
		priority_queue[node] = key

# Sorting a dictionary sorts it by key and not by value, so this function returns the smallest value 
func find_queue_min():
	var smallest_key: DKey = DKey.new(100000000, 100000000)
	var smallest_node: Vector2i
	for node in priority_queue:
		if (compare_keys(priority_queue[node], smallest_key, "less_than")):
			smallest_key = priority_queue[node]
			smallest_node = node
	
	var smallest_value: Dictionary = {smallest_node: smallest_key}
	
	return smallest_value

func calculate_key(node: Vector2i) -> DKey:
	var key_secondary: int = mini(maze[node.x][node.y].g_cost, maze[node.x][node.y].rhs)
	var key_primary: int = key_secondary + manhattan_method(node) + key_modifier
	var new_key: DKey = DKey.new(key_primary, key_secondary)
	return new_key

# Returns if key a is smaller than key b
func compare_keys(key_a: DKey, key_b: DKey, operand: String) -> bool:
	match operand:
		"less_than":
			if (key_a.key_p == key_b.key_p):
				return key_a.key_s < key_b.key_s
			else:
				return key_a.key_p < key_b.key_p
		"greater_than":
			if (key_a.key_p == key_b.key_p):
				return key_a.key_s > key_b.key_s
			else:
				return key_a.key_p > key_b.key_p
		"is_equal":
			return key_a.key_p == key_b.key_p && key_a.key_s == key_b.key_s
		"is_not_equal":
			return key_a.key_p != key_b.key_p && key_a.key_s != key_b.key_s
		_:
			print("No valid operand used")
			return false

#func compare_keys(key_a: DKey, key_b: DKey) -> int:
	#if (key_a.key_p < key_b.key_p):
		#return -1
	#elif (key_a.key_p > key_b.key_p):
		#return 1
	#else:
		#return 0

func manhattan_method(node: Vector2i) -> int:
	var distance_vector = start - node
	# Normalise the distance vector's x and y. Using Godot's built-in normalising method didnt work for some reason
	if (distance_vector.x < 0):
		distance_vector.x *= -1
	if (distance_vector.y < 0):
		distance_vector.y *= -1
	var h_cost = distance_vector.x + distance_vector.y
	return h_cost
