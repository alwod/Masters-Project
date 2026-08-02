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

#var searched_nodes: Array[Vector2i]
#var array_index_counter: int

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
	maze[start.x][start.y].h_cost = limit
	maze[start.x][start.y].g_cost = 0
	var done = false
	while (!done):
		#searched_nodes.clear()
	
		iterations += 1
		#print("Iteration ", iterations)
		#print("Limit ", limit)
		
		done = recursive_search(start, 0)
		if (!done):
			pruned_list_v2.sort()
			limit = pruned_list_v2.front()
			pruned_list_v2.clear()
	
	var end_time = Time.get_ticks_usec()
	time = end_time - start_time
	memory_use = biggest_memory_use - start_memory_use
	
	path_length = limit
	
	print("Final Limit ", limit)

func recursive_search(node: Vector2i, g: int) -> bool:
	iterations += 1
	var h = manhattan_method(node)
	if (h == 0):
		return true # The goal was found
	#searched_nodes.push_front(node)
	
	
	var f: int = g + h
	if (f > limit):
		# Add this value of F to the pruned list
		pruned_list_v2.push_front(f)
		
		var temp_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
		if (temp_memory_use > biggest_memory_use):
			biggest_memory_use = temp_memory_use
		return false
	
	var north = node + Vector2i(0, -1)
	var west = node + Vector2i(-1, 0)
	var south = node + Vector2i(0, 1)
	var east = node + Vector2i(1, 0)
			
	var neighbours: Array[Vector2i] = [north, west, south, east]
	for neighbour in maze[node.x][node.y].neighbours:
		if (maze[neighbour.x][neighbour.y].is_wall):
			pass
		#elif searched_nodes.has(neighbour):
			#if (g + movement_cost < maze[neighbour.x][neighbour.y].g_cost):
				#searched_nodes.erase(neighbour)
				##searched_nodes[array_index_counter] = Vector2i(0, 0)
				#maze[neighbour.x][neighbour.y].g_cost = g + movement_cost
				#var done = recursive_search(neighbour, g + movement_cost)
				#if (done):
					#var temp_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
					#if (temp_memory_use > biggest_memory_use):
						#biggest_memory_use = temp_memory_use
					#return true
		else:
			maze[neighbour.x][neighbour.y].g_cost = g + maze[node.x][node.y].movement_cost
			var done = recursive_search(neighbour, g + maze[node.x][node.y].movement_cost)
			if (done):
				var temp_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
				if (temp_memory_use > biggest_memory_use):
					biggest_memory_use = temp_memory_use
				return true
	var temp_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
	if (temp_memory_use > biggest_memory_use):
		biggest_memory_use = temp_memory_use
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
