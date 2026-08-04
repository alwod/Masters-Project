class_name Astar

# To keep things consistent when testing pathfinding algorithms in random mazes,
# the start will always be the top left cell and the goal the bottom right cell for now.
var start: Vector2i
var goal: Vector2i

var maze: Array # A copy of the maze created by the maze generator
var maze_size: Vector2i

var open_list_dic: Dictionary[Vector2i, int]
var closed_list_dic: Dictionary[Vector2i, int]

#var diagonal_movement_cost: int = 14

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
		
		for neighbour in maze[current_node.x][current_node.y].neighbours:
			if(maze[neighbour.x][neighbour.y].is_wall || closed_list_dic.has(neighbour)):
				pass
			elif !open_list_dic.has(neighbour):
				var calculated_g_cost = maze[current_node.x][current_node.y].g_cost + maze[neighbour.x][neighbour.y].movement_cost
				var calculated_h_cost = manhattan_method(neighbour)
				var calculated_f_cost = calculated_g_cost + calculated_h_cost
				maze[neighbour.x][neighbour.y].g_cost = calculated_g_cost
				maze[neighbour.x][neighbour.y].h_cost = calculated_h_cost
				maze[neighbour.x][neighbour.y].f_cost = calculated_f_cost
				
				open_list_dic[neighbour] = calculated_f_cost
			else:
				var old_g = maze[neighbour.x][neighbour.y].g_cost
				if maze[current_node.x][current_node.y].g_cost + maze[neighbour.x][neighbour.y].movement_cost < old_g:
					maze[neighbour.x][neighbour.y].g_cost = maze[current_node.x][current_node.y].g_cost + maze[neighbour.x][neighbour.y].movement_cost
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

func manhattan_method(node: Vector2i) -> int:
	var distance_vector = goal - node
	# Normalise the distance vector's x and y. Using Godot's built-in normalising method didnt work for some reason
	if (distance_vector.x < 0):
		distance_vector.x *= -1
	if (distance_vector.y < 0):
		distance_vector.y *= -1
	var h_cost = distance_vector.x + distance_vector.y
	return h_cost
