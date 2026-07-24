class_name Idastar

# To keep things consistent when testing pathfinding algorithms in random mazes,
# the start will always be the top left cell and the goal the bottom right cell for now.
var start: Vector2i = Vector2i(1, 1)
var goal: Vector2i

var maze: Array # A copy of the maze created by the maze generator
var maze_size: Vector2i

var movement_cost: int = 10

var limit: int
var pruned_list: Dictionary[Vector2i, int]
var searching: bool = true

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

func pathfinding() -> void:
	var start_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
	var start_time = Time.get_ticks_usec()
	
	maze[start.x][start.y].h_cost = manhattan_method(start)
	maze[start.x][start.y].g_cost = 0
	maze[start.x][start.y].f_cost = maze[start.x][start.y].g_cost + maze[start.x][start.y].h_cost
	limit = maze[start.x][start.y].f_cost
	
	var current_position = start
	
	# Every loop here counts as one iteration. The pruned_list dictionary should be reset each time
	var iteration_count = 0
	while(searching):
		iterations += 1
		
		# Iteration is done, reset info
		for i in range(maze_size.x):
			for j in range (maze_size.y):
				maze[i][j].reset_values()
		
		maze[current_position.x][current_position.y].visited = true
		iteration_count += 1
		#print("Iteration ", iteration_count, " Limit: ", limit)
		# Find the lowest F cost in the pruned_list dictionary, set it as the limit
		var costs = pruned_list.values()
		#print(pruned_list)
		costs.sort()
		if (!costs.is_empty()):
			limit = costs.front()
		# Clear the pruned list now that a new limit is set
		pruned_list.clear()
		
		# Check the neighbours of the starting node
		check_neighbours(current_position)
		
		var temp_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
		if (temp_memory_use > biggest_memory_use):
			biggest_memory_use = temp_memory_use
	
	var end_time = Time.get_ticks_usec()
	time = end_time - start_time
	memory_use = biggest_memory_use - start_memory_use
	
	path_length = maze[goal.x][goal.y].f_cost

func check_neighbours(current_position: Vector2i) -> void:
	#print(current_position, " ", maze[current_position.x][current_position.y].f_cost)
	var north = current_position + Vector2i(0, -1)
	var west = current_position + Vector2i(-1, 0)
	var south = current_position + Vector2i(0, 1)
	var east = current_position + Vector2i(1, 0)
		
	var neighbours: Array[Vector2i] = [north, west, south, east]
	for neighbour in neighbours:
		if (maze[neighbour.x][neighbour.y].is_wall || pruned_list.has(neighbour) || maze[neighbour.x][neighbour.y].visited):
			pass # This neighbour is a wall, has been pruned, or has been visited in this iteration, no need to check it
		else:
			# Found a neighbour that hasn't been pruned yet
			# Calculate neighbour's f cost
			maze[neighbour.x][neighbour.y].connects_to = current_position
			calculate_costs(neighbour, current_position)
			#var h_cost = manhattan_method(neighbour)
			#maze[neighbour.x][neighbour.y].f_cost = h_cost + movement_cost
			
			if (maze[neighbour.x][neighbour.y].f_cost > limit):
				#print("Pruned a node")
				# The F cost of this neighbour excedes the limit, so add this neighbour and its f value to the pruned list dictionary
				pruned_list[neighbour] = maze[neighbour.x][neighbour.y].f_cost
			elif (!maze[neighbour.x][neighbour.y].is_goal):
				#print("Searching more neighbours")
				# It isnt the goal and the f cost isnt bigger than the limit, so need to search this neighbour's neighbours
				maze[neighbour.x][neighbour.y].visited = true
				check_neighbours(neighbour)
			else:
				# The algorithm is complete when it gets here
				print("Goal: ", neighbour)
				print(maze[neighbour.x][neighbour.y].f_cost)
				searching = false

func calculate_costs(node: Vector2i, current_position: Vector2i) -> void:
	# Calculate the node's G cost
	maze[node.x][node.y].g_cost = maze[current_position.x][current_position.y].g_cost + movement_cost
	# Calculate h cost using manhattan method
	maze[node.x][node.y].h_cost = manhattan_method(node)
	# Calculate f cost
	maze[node.x][node.y].f_cost = maze[node.x][node.y].g_cost + maze[node.x][node.y].h_cost

func manhattan_method(node: Vector2i) -> int:
	var distance_vector = goal - node
	# Normalise distance vector's x and y
	if (distance_vector.x < 0):
		distance_vector.x *= -1
	if (distance_vector.y < 0):
		distance_vector.y *= -1
	var h_cost = distance_vector.x + distance_vector.y
	return h_cost * 10
