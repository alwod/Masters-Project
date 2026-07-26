class_name Idastar

# To keep things consistent when testing pathfinding algorithms in random mazes,
# the start will always be the top left cell and the goal the bottom right cell for now.
var start: Vector2i
var goal: Vector2i

var maze: Array # A copy of the maze created by the maze generator
var maze_size: Vector2i

var movement_cost: int = 1

var limit: int
var pruned_list_v2: Array[int]
var searched_nodes: Array[Vector2i]

# Variables for data collection
var time: int = 0
var iterations: int = 0
var memory_use: float
var path_length: int = 0
var biggest_memory_use = 0

func _init(new_maze: Array, size: Vector2i, starting_position: Vector2i, goal_position: Vector2i) -> void:
	maze = new_maze
	maze_size = size
	start = starting_position
	goal = goal_position
	maze[start.x][start.y].is_start = true
	maze[goal.x][goal.y].is_goal = true


func pathfinding_v2() -> void:
	var start_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
	var start_time = Time.get_ticks_usec()
	
	limit = manhattan_method(start)
	var done = false
	while (!done):
		iterations += 1
		#print("Iteration ", iterations)
		#print("Limit ", limit)
		
		done = recursive_search(start, 0)
		if (!done):
			pruned_list_v2.sort()
			limit = pruned_list_v2.front()
			pruned_list_v2.clear()
			searched_nodes.clear()
		
		var temp_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
		if (temp_memory_use > biggest_memory_use):
			biggest_memory_use = temp_memory_use
	
	var end_time = Time.get_ticks_usec()
	time = end_time - start_time
	memory_use = biggest_memory_use - start_memory_use
	
	path_length = limit
	
	print("Limit ", limit)

func recursive_search(node: Vector2i, g: int) -> bool:
	searched_nodes.push_front(node)
	var h = manhattan_method(node)
	if (h == 0):
		return true # The goal was found
	
	var f: int = g + h
	if (f > limit):
		# Add this value of F to the pruned list
		pruned_list_v2.push_front(f)
		return false # Dead end found
	
	var north = node + Vector2i(0, -1)
	var west = node + Vector2i(-1, 0)
	var south = node + Vector2i(0, 1)
	var east = node + Vector2i(1, 0)
			
	var neighbours: Array[Vector2i] = [north, west, south, east]
	for neighbour in neighbours:
		if (maze[neighbour.x][neighbour.y].is_wall || searched_nodes.has(neighbour)):
			pass
		else:
			var done = recursive_search(neighbour, g + movement_cost)
			if (done):
				return true
	return false

func manhattan_method(node: Vector2i) -> int:
	var distance_vector = goal - node
	# Normalise distance vector's x and y
	if (distance_vector.x < 0):
		distance_vector.x *= -1
	if (distance_vector.y < 0):
		distance_vector.y *= -1
	var h_cost = distance_vector.x + distance_vector.y
	return h_cost
