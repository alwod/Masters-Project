class_name Astar

# To keep things consistent when testing pathfinding algorithms in random mazes,
# the start will always be the top left cell and the goal the bottom right cell for now.
var start: Vector2i = Vector2i(1, 1)
var goal: Vector2i

var maze: Array # A copy of the maze created by the maze generator
var maze_size: Vector2i
#var open_list: Array[Vector2i]
#var closed_list: Array[Vector2i]

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
	
	#open_list.resize(maze_size.x * maze_size.y)
	#closed_list.resize(maze_size.x * maze_size.y)


func pathfinding() -> void:
	print("Start: ", start)
	print("Goal: ", goal)
	var current_position: Vector2i = start
	# For some reason, using the open list array didnt work so now its a bool each cell has instead.
	maze[current_position.x][current_position.y].open_list = true
	#open_list[array_counter] = current_position
	
	# Variable for the completion condition
	var keep_looking = true
	while (keep_looking):
		#print(current_position)
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
	return h_cost * 1
