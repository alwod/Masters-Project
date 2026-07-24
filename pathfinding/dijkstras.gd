class_name Dijkstras

# To keep things consistent when testing pathfinding algorithms in random mazes,
# the start will always be the top left cell and the goal the bottom right cell for now.
var start: Vector2i = Vector2i(1, 1)
var goal: Vector2i

var maze: Array # A copy of the maze created by the maze generator
var maze_size: Vector2i

var movement_cost: int = 1

var priority_queue: Dictionary[Vector2i, int]

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
	
	maze[start.x][start.y].g_cost = 0
	maze[start.x][start.y].closed_list = true
	
	for i in range(maze_size.x):
		for j in range(maze_size.y):
			if(maze[i][j].is_start || maze[i][j].is_wall):
				pass
			else:
				maze[i][j].g_cost = 100000000
	
	priority_queue[start] = 0

# First, set starting f cost to 0 and all other f costs to INF
# Add first point to priority queue
# Get the lowest cost node from the priority queue
# Check this node's neighbours
# Calculate each neighbour's g_cost and set thier connects_to to the current node
# Add each neighbour to the priority queue
# Get the lowest cost node from the queue
func pathfinding() -> void:
	var start_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
	var start_time = Time.get_ticks_usec()
	
	while(!priority_queue.is_empty()):
		# Count loop iterations for data
		iterations += 1
		
		var current_node = find_queue_min()
		priority_queue.erase(current_node)
		
		var north = current_node + Vector2i(0, -1)
		var west = current_node + Vector2i(-1, 0)
		var south = current_node + Vector2i(0, 1)
		var east = current_node + Vector2i(1, 0)
		
		var neighbours: Array[Vector2i] = [north, west, south, east]
		
		for neighbour in neighbours:
			if(!maze[neighbour.x][neighbour.y].is_wall):
				var calculated_g_cost = maze[current_node.x][current_node.y].g_cost + movement_cost
				if (calculated_g_cost < maze[neighbour.x][neighbour.y].g_cost):
					maze[neighbour.x][neighbour.y].g_cost = calculated_g_cost
					maze[neighbour.x][neighbour.y].connects_to = current_node
					priority_queue[neighbour] = maze[neighbour.x][neighbour.y].g_cost
					
		var temp_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
		if (temp_memory_use > biggest_memory_use):
			biggest_memory_use = temp_memory_use
	
	#var end_memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
	var end_time = Time.get_ticks_usec()
	time = end_time - start_time
	memory_use = biggest_memory_use - start_memory_use
	
	path_length = maze[goal.x][goal.y].g_cost
	
	print("Time (us): ", time, " Iterations: ", iterations, " Memory use (bytes): ", memory_use, " Path length: ", path_length)

func find_queue_min():
	var smallest_cost = 100000000
	var smallest_node: Vector2i
	for node in priority_queue:
		if (priority_queue[node] < smallest_cost):
			smallest_cost = priority_queue[node]
			smallest_node = node
	
	return smallest_node
