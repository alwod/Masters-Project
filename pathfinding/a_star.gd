class_name Astar

# To keep things consistent when testing pathfinding algorithms in random mazes,
# the start will always be the top left cell and the goal the bottom right cell for now.
var start: Vector2i = Vector2i(1, 1)
var goal: Vector2i

var maze: Array # A copy of the maze created by the maze generator
var maze_size: Vector2i

var open_list_dic: Dictionary[Vector2i, int]
var closed_list_dic: Dictionary[Vector2i, int]

var diagonal_movement_cost: int = 14
var movement_cost: int = 1

# Variables for data collection
var time: int = 0
var iterations: int = 0
var memory_use: float
var path_length: int = 0
var biggest_memory_use = 0

func _init(size: Vector2i, new_maze: Array) -> void:
	maze = new_maze
	maze_size = size
	goal = maze_size - start
	maze[start.x][start.y].is_start = true
	maze[goal.x][goal.y].is_goal = true

func pathfinding_v2() -> void:
	var start_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
	var start_time = Time.get_ticks_usec()
	open_list_dic[start] = 0
	maze[start.x][start.y].f_cost = 0
	
	while !open_list_dic.is_empty():
		iterations += 1
		
		var current_node = find_queue_min()
		open_list_dic.erase(current_node)
		closed_list_dic[current_node] = maze[current_node.x][current_node.y].f_cost
		
		if (closed_list_dic.has(goal)):
			break
		
		var north = current_node + Vector2i(0, -1)
		var west = current_node + Vector2i(-1, 0)
		var south = current_node + Vector2i(0, 1)
		var east = current_node + Vector2i(1, 0)
		
		var neighbours: Array[Vector2i] = [north, west, south, east]
		
		for neighbour in neighbours:
			if(maze[neighbour.x][neighbour.y].is_wall || closed_list_dic.has(neighbour)):
				pass
			elif !open_list_dic.has(neighbour):
				var calculated_g_cost = maze[current_node.x][current_node.y].g_cost + movement_cost
				var calculated_h_cost = manhattan_method(neighbour)
				var calculated_f_cost = calculated_g_cost + calculated_h_cost
				maze[neighbour.x][neighbour.y].g_cost = calculated_g_cost
				maze[neighbour.x][neighbour.y].h_cost = calculated_h_cost
				maze[neighbour.x][neighbour.y].f_cost = calculated_f_cost
				
				open_list_dic[neighbour] = calculated_f_cost
			else:
				var old_g = maze[neighbour.x][neighbour.y].g_cost
				if maze[current_node.x][current_node.y].g_cost + movement_cost < old_g:
					maze[neighbour.x][neighbour.y].g_cost = maze[current_node.x][current_node.y].g_cost + movement_cost
					maze[neighbour.x][neighbour.y].f_cost = maze[neighbour.x][neighbour.y].g_cost + maze[neighbour.x][neighbour.y].h_cost
					
					open_list_dic[neighbour] = maze[neighbour.x][neighbour.y].f_cost
					
		var temp_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
		if (temp_memory_use > biggest_memory_use):
			biggest_memory_use = temp_memory_use
			
	var end_time = Time.get_ticks_usec()
	time = end_time - start_time
	memory_use = biggest_memory_use - start_memory_use
	path_length = maze[goal.x][goal.y].f_cost
	print(path_length)

func find_queue_min():
	var smallest_cost = 100000000
	var smallest_node: Vector2i
	for node in open_list_dic:
		if (open_list_dic[node] < smallest_cost):
			smallest_cost = open_list_dic[node]
			smallest_node = node
	
	return smallest_node

func pathfinding() -> void:
	print("Start: ", start)
	print("Goal: ", goal)
	
	var start_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
	var start_time = Time.get_ticks_usec()
	
	var current_position: Vector2i = start
	# For some reason, using the open list array didnt work so now its a bool each cell has instead.
	maze[current_position.x][current_position.y].open_list = true
	#open_list[array_counter] = current_position
	
	# Variable for the completion condition
	var keep_looking = true
	while (keep_looking):
		# Count loop iterations for data
		iterations += 1
		
		print(current_position)
		if (!maze[goal.x][goal.y].closed_list):
			#open_list.erase(current_position)
			#closed_list.push_front(current_position)
			
			var lowest_cost_neighbour: Vector2i 
			var tester: bool = false
			# Find lowest F cost neighbour
			for i in range(maze_size.x):
				for j in range(maze_size.y):
					if (maze[i][j].open_list):
						if (!tester):
							lowest_cost_neighbour = maze[i][j].grid_position
							tester = true
						if (maze[i][j].f_cost < maze[lowest_cost_neighbour.x][lowest_cost_neighbour.y].f_cost):
							lowest_cost_neighbour = maze[i][j].grid_position
			maze[lowest_cost_neighbour.x][lowest_cost_neighbour.y].open_list = false
			maze[lowest_cost_neighbour.x][lowest_cost_neighbour.y].closed_list = true
			
			
			#for node in open_list:
				#if (maze[node.x][node.y].f_cost < maze[lowest_cost_neighbour.x][lowest_cost_neighbour.y].f_cost):
					#lowest_cost_neighbour = node
			#open_list.erase(lowest_cost_neighbour)
			#closed_list.push_front(lowest_cost_neighbour)
			
			current_position = lowest_cost_neighbour
			
			# Add neighbours of current position to the open list if not already, ignoring walls
			check_neighbour_positions(current_position)
			
		# This else statement executes when a path has been found
		else:
			keep_looking = false
			
		var temp_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
		if (temp_memory_use > biggest_memory_use):
			biggest_memory_use = temp_memory_use
	
	var end_time = Time.get_ticks_usec()
	time = end_time - start_time
	memory_use = biggest_memory_use - start_memory_use
	path_length = maze[goal.x][goal.y].f_cost

func check_neighbour_positions(current_position: Vector2i) -> void:
	var north = current_position + Vector2i(0, -1)
	#var north_west = current_position + Vector2i(-1, -1)
	var west = current_position + Vector2i(-1, 0)
	#var south_west = current_position + Vector2i(-1, 1)
	var south = current_position + Vector2i(0, 1)
	#var south_east = current_position + Vector2i(1, 1)
	var east = current_position + Vector2i(1, 0)
	#var north_east = current_position + Vector2i(1, -1)
	
	#var neighbours_with_diagonals: Array[Vector2i] = [north, north_west, west, south_west, south, south_east, east, north_east]
	var neighbours: Array[Vector2i] = [north, west, south, east]
	
	for node in neighbours:
		if (!(maze[node.x][node.y].is_wall) && !maze[node.x][node.y].closed_list):
			if (maze[node.x][node.y].open_list):
				if (maze[node.x][node.y].g_cost < maze[current_position.x][current_position.y].g_cost):
					maze[node.x][node.y].connects_to = current_position
					calculate_costs(node, current_position)
			else:
				maze[node.x][node.y].open_list = true
				maze[node.x][node.y].connects_to = current_position
				calculate_costs(node, current_position)

func calculate_costs(node: Vector2i, current_position: Vector2i) -> void:
	# Calculate the node's G cost
	# If it's diagonal
	if (current_position.x != node.x && current_position.y != node.y):
		maze[node.x][node.y].g_cost = maze[current_position.x][current_position.y].g_cost + diagonal_movement_cost
	else:
		maze[node.x][node.y].g_cost = maze[current_position.x][current_position.y].g_cost + movement_cost
	# Calculate h cost using manhattan method
	maze[node.x][node.y].h_cost = manhattan_method(node)
	# Calculate f cost
	maze[node.x][node.y].f_cost = maze[node.x][node.y].g_cost + maze[node.x][node.y].h_cost

func manhattan_method(node: Vector2i) -> int:
	var distance_vector = goal - node
	# Normalise the distance vector's x and y. Using Godot's built-in normalising method didnt work for some reason
	if (distance_vector.x < 0):
		distance_vector.x *= -1
	if (distance_vector.y < 0):
		distance_vector.y *= -1
	var h_cost = distance_vector.x + distance_vector.y
	return h_cost
