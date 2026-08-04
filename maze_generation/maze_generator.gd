extends Node

@export var MAZE_WIDTH: int
@export var MAZE_HEIGHT: int
var unvisited_cells: int
var og_unvisited_cells: int
var maze: Array

@export var use_random_seed: bool = false

var saved_nodes: Array[Vector2i] # Used for node merging

const NORTH: Vector2i = Vector2(0, 2)
const SOUTH: Vector2i = Vector2(0, -2)
const EAST: Vector2i = Vector2(2, 0)
const WEST: Vector2i = Vector2(-2, 0)

@export var block_scene: PackedScene
@export var line_scene: PackedScene

@export var maze_scale: int

var start_position
var goal_position

var number_of_pathfinding_iterations: int = 1000

func _ready() -> void:
	if (use_random_seed):
		randomize()
	else:
		seed(12345)
	
	unvisited_cells = MAZE_HEIGHT * MAZE_WIDTH
	og_unvisited_cells = unvisited_cells
	
	# Modify the grid size, so that each "walkable" cell is surrounded by "wall" cells.
	MAZE_HEIGHT = (MAZE_HEIGHT * 2) + 1
	MAZE_WIDTH = (MAZE_WIDTH * 2) + 1
	
	test_algorithms()
	
	## Run the Bees Algorithm on the given maze
	#var bees = Beesalgorithm.new(Vector2i(MAZE_HEIGHT - 1, MAZE_WIDTH - 1), maze)
	#maze = bees.maze
	
	#visualise_maze()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("regenerate"):
		test_algorithms()
		visualise_maze()

func generate_maze(maze_id: int) -> void:
	print("Generating maze ", maze_id)
	var maze_generation_start = Time.get_ticks_msec()
	initialise_grid()
	aldous_broder()
	reset_connecting_values()
	remove_random_walls()
	
	# Start position should be in the center
	start_position = Vector2i((MAZE_HEIGHT - 1) / 2, (MAZE_WIDTH - 1) / 2)
	maze[start_position.x][start_position.y].is_start = true
	print("Maze starting position: ", start_position)
	# Goal position should be a random corner
	var corners: Array[Vector2i] = [Vector2i(1, 1), Vector2i(MAZE_HEIGHT - 2, 1), Vector2i(1, MAZE_WIDTH - 2), Vector2i(MAZE_HEIGHT - 2, MAZE_WIDTH - 2)]
	goal_position = corners.pick_random()
	maze[goal_position.x][goal_position.y].is_goal = true
	print("Maze goal position: ", goal_position)
	
	merge_nodes()
	var maze_generation_end = Time.get_ticks_msec()
	print("Maze generation ", maze_id, " complete in ", maze_generation_end - maze_generation_start, "ms")

## Map sizes to test
# Very small: 3x3 -> 5x5=25 search area - Yes
# Small 5x5 -> 9x9=81 search area - Yes
# Medium 15x15 -> 29x29=841 search area - Yes
# Large 25x25 -> 49x49= 2401 search area - Yes
# Very large 45x45 -> 89x89 = 7921 search area
func test_algorithms() -> void:
	var test_data = Datamanager.new("Test", "100x100 Static")
	for i in range(number_of_pathfinding_iterations):
		generate_maze(i + 1)
		
		var adjusted_maze_size: Vector2i = Vector2i(MAZE_HEIGHT - 1, MAZE_WIDTH - 1)
		
		#print(maze[2][9].neighbours)
		
		# Pathfinding algorithm here
		## TODO When testing an algorithm, make sure unused variables in Cell are commented out temporarily
		#var dijkstra = Dijkstras.new(maze, adjusted_maze_size, start_position, goal_position)
		#dijkstra.pathfinding()
		#test_data.push_data(dijkstra.biggest_memory_use, dijkstra.path_length, dijkstra.time, dijkstra.iterations)
		
		var a_star = Astar.new(maze, adjusted_maze_size, start_position, goal_position)
		a_star.pathfinding_v2()
		test_data.push_data(a_star.biggest_memory_use, a_star.path_length, a_star.time, a_star.iterations)
		
		### 2 versions of IDA. One without the searched_nodes array takes forever. One with it is much faster
		#var idastar = Idastar.new(maze, adjusted_maze_size, start_position, goal_position)
		#idastar.pathfinding_v2()
		#test_data.push_data(idastar.biggest_memory_use, idastar.path_length, idastar.time, idastar.iterations)
		
		#var dstarlight = Dstarlight.new(maze, adjusted_maze_size, start_position, goal_position)
		#dstarlight.pathfinding()
		#test_data.push_data(dstarlight.biggest_memory_use, dstarlight.path_length, dstarlight.time, dstarlight.iterations)
		
	test_data.create_json()
	print("Test Done!!!")

func merge_nodes() -> void:
	# First, iterate through the maze and set each non-wall node's neighbours
	for i in range(MAZE_HEIGHT):
		for j in range(MAZE_WIDTH):
			if (!maze[i][j].is_wall):
				var node_position = maze[i][j].grid_position
				var north = node_position + Vector2i(0, -1)
				var west = node_position + Vector2i(-1, 0)
				var south = node_position + Vector2i(0, 1)
				var east = node_position + Vector2i(1, 0)
		
				var neighbours: Array[Vector2i] = [north, west, south, east]
				for neighbour in neighbours:
					if (!maze[neighbour.x][neighbour.y].is_wall):
						maze[i][j].neighbours.push_front(neighbour)
						
	# If a node isnt a wall, goal, or start, check if it has 1 or 2 neighbours
	# If the node does have 1 or 2 neighbours, add it to the saved nodes list and check its neighbours
	# If the neighbour isnt a goal or start, and has 1 or 2 neighbours, add it to the saved list and check its neighbours
	# Keep searching neighbours until a node has only the start or goal as neighbours, or it has more than 2 neighbours
	# After neighbour searching has stopped, go through each node in the saved list:
	# If the node has a neighbour that isnt in the saved list, mark that node as an end node
	# If the node has a neighbour that is in the saved list, remove that node from the current node's neighbour list
	# Of the end nodes, pick the one with the best f-cost. If there are other end nodes, their remaining neighbours are now neighbours to the chosen node
	#print(maze[1][1].is_goal)
	for i in range(MAZE_HEIGHT):
		for j in range(MAZE_WIDTH):
			search_neighbours(Vector2i(i, j))
			if saved_nodes.size() > 1:
				var end_nodes: Dictionary[Vector2i, int]
				var non_saved_nodes: Array[Vector2i]
				var chosen_end_node: Vector2i
				for node in saved_nodes:
					for neighbour in maze[node.x][node.y].neighbours:
						if (!saved_nodes.has(neighbour)):
							end_nodes[node] = manhattan_method(node)
							non_saved_nodes.push_front(neighbour)
				
				chosen_end_node = find_queue_min(end_nodes)
				if end_nodes.size() > 1:
					end_nodes.erase(chosen_end_node)
					
					for remaining_end_node in end_nodes:
						maze[chosen_end_node.x][chosen_end_node.y].neighbours.append_array(maze[remaining_end_node.x][remaining_end_node.y].neighbours)
					
					for neighbour in maze[chosen_end_node.x][chosen_end_node.y].neighbours:
						for remaining_end_node in end_nodes:
							if maze[neighbour.x][neighbour.y].neighbours.has(remaining_end_node):
								maze[neighbour.x][neighbour.y].neighbours.erase(remaining_end_node)
								maze[neighbour.x][neighbour.y].neighbours.push_front(chosen_end_node)
						if saved_nodes.has(neighbour):
							maze[chosen_end_node.x][chosen_end_node.y].neighbours.erase(neighbour)
					
					for node in non_saved_nodes:
						for neighbour in maze[node.x][node.y].neighbours:
							if saved_nodes.has(neighbour) && neighbour != chosen_end_node:
								maze[node.x][node.y].neighbours.erase(neighbour)
								maze[node.x][node.y].neighbours.push_front(chosen_end_node)
				
				maze[chosen_end_node.x][chosen_end_node.y].movement_cost = saved_nodes.size()
			
			saved_nodes.clear()

func search_neighbours(node: Vector2i) -> void:
	# If the node is a wall, ignore
	if (maze[node.x][node.y].is_wall):
		return
	# If the node is the goal or the start node or it has been visited already ignore as well
	elif (maze[node.x][node.y].is_start || maze[node.x][node.y].is_goal || maze[node.x][node.y].visited):
		return
	elif (maze[node.x][node.y].neighbours.size() > 2):
		return
	else:
		saved_nodes.push_front(node)
		maze[node.x][node.y].visited = true
		for neighbour in maze[node.x][node.y].neighbours:
			search_neighbours(neighbour)

func manhattan_method(node: Vector2i) -> int:
	var distance_vector = goal_position - node
	# Normalise the distance vector's x and y. Using Godot's built-in normalising method didnt work for some reason
	if (distance_vector.x < 0):
		distance_vector.x *= -1
	if (distance_vector.y < 0):
		distance_vector.y *= -1
	var h_cost = distance_vector.x + distance_vector.y
	return h_cost

func find_queue_min(queue: Dictionary) -> Vector2i:
	var smallest_cost = 100000000
	var smallest_node: Vector2i
	for node in queue:
		if (queue[node] < smallest_cost):
			smallest_cost = queue[node]
			smallest_node = node
	
	return smallest_node

func initialise_grid():
	# Initialise the basic maze as a 2d array
	maze = Array()
	maze.resize(MAZE_WIDTH)
	for i in range(MAZE_WIDTH):
		maze[i] = Array()
		maze[i].resize(MAZE_HEIGHT)
		for j in range(MAZE_HEIGHT):
			maze[i][j] = Cell.new(Vector2(i, j))

func aldous_broder() -> void:
	var current_position: Vector2i
	var previous_position: Vector2i
	
	unvisited_cells = og_unvisited_cells
	
	# Start at a random cell, making sure it's a walkable cell and not a wall cell
	var loop_2 = true
	while (loop_2):
		current_position = Vector2i(randi() % MAZE_WIDTH, randi() % MAZE_HEIGHT)
		if (!maze[current_position.x][current_position.y].is_wall):
			loop_2 = false
	
	maze[current_position.x][current_position.y].visited = true
	unvisited_cells -= 1
	
	# The main loop. Repeat until every cell in the area has been visited
	while (unvisited_cells > 0):
		#print("Unvisited cells: ", unvisited_cells)
		#print("Currently at: ", current_position)
		previous_position = current_position
		
		# Move in a random direction
		var loop = true
		while (loop):
			match (randi() % 4):
				0:
					current_position += NORTH 
				1:
					current_position += SOUTH 
				2:
					current_position += EAST 
				3:
					current_position += WEST 
			if ((current_position.x >= 0 && current_position.x < MAZE_WIDTH) && (current_position.y >= 0 && current_position.y < MAZE_HEIGHT)):
				loop = false
			else:
				current_position = previous_position
		
		# Check if this current cell has been visisted. If not, 'connect' it to previous cell
		if (!maze[current_position.x][current_position.y].visited):
			maze[current_position.x][current_position.y].visited = true
			unvisited_cells -=1
			maze[current_position.x][current_position.y].connects_to = previous_position
			find_connecting_walls(current_position, previous_position)
			maze[previous_position.x][previous_position.y].connected_from = current_position
			find_connecting_walls(previous_position, current_position)
			

func find_connecting_walls(position_1: Vector2i, position_2: Vector2i) -> void:
	# First, subtract the current cell from the cell position it connects to
	# Either X or Y should be equal to 0, not both.
	# Whichever value ends up being 0 should be kept the same.
	# Meanwhile the larger vector's non locked-in value is subtracted by 1
	# The resulting vector should be inbetween the original 2 vectors
	var middle_position: Vector2i
	
	var larger_position: Vector2i
	if (position_1 > position_2):
		larger_position = position_1
	else:
		larger_position = position_2
	
	var zero_checker = position_1 - position_2
	if (zero_checker.x == 0):
		larger_position.y -= 1
	else:
		larger_position.x -= 1
		
	maze[larger_position.x][larger_position.y].is_wall = false

# With aldous broder, there is only ever 1 path between 2 nodes. By removing random walls there's a chance for multiple paths to the goal.
func remove_random_walls() -> void:
	var number_to_remove: int = round(MAZE_HEIGHT / 2)
	
	var offset = 2
	
	var rand_x = randi_range(1, MAZE_HEIGHT - offset)
	var rand_y = randi_range(1, MAZE_WIDTH - offset)
	
	for n in range(number_to_remove - 1):
		while(!maze[rand_x][rand_y].is_wall):
			rand_x = randi_range(1, MAZE_HEIGHT - offset)
			rand_y = randi_range(1, MAZE_WIDTH - offset)
		maze[rand_x][rand_y].is_wall = false

# Used for dynamic maze testing
func modify_maze(start: Vector2i, goal: Vector2i) -> void:
	# Change X random non-wall nodes to wall nodes and X random wall nodes to non-wall nodes
	# Exclude the start and goal nodes
	var number_to_change: int = 2
	
	var rand_x = randi_range(1, MAZE_HEIGHT - 2)
	var rand_y = randi_range(1, MAZE_WIDTH - 2)
	
	var walls_to_become_nodes: Array[Vector2i]
	# Change wall nodes to non-wall nodes
	for n in range(number_to_change - 1):
		while(!maze[rand_x][rand_y].is_wall || Vector2i(rand_x, rand_y) == start || Vector2i(rand_x, rand_y) == goal):
			rand_x = randi_range(1, MAZE_HEIGHT - 2)
			rand_y = randi_range(1, MAZE_WIDTH - 2)
		walls_to_become_nodes.push_front(Vector2i(rand_x, rand_y))
	
	var nodes_to_become_walls: Array[Vector2i]
	# Change non-wall nodes to wall nodes
	for n in range(number_to_change - 1):
		while(maze[rand_x][rand_y].is_wall || Vector2i(rand_x, rand_y) == start || Vector2i(rand_x, rand_y) == goal):
			rand_x = randi_range(1, MAZE_HEIGHT - 2)
			rand_y = randi_range(1, MAZE_WIDTH - 2)
		nodes_to_become_walls.push_front(Vector2i(rand_x, rand_y))
	
	for node in walls_to_become_nodes:
		maze[node.x][node.y].is_wall = false
	
	for node in nodes_to_become_walls:
		maze[node.x][node.y].is_wall = true

func visualise_maze() -> void:
	# Make sure there arent any scenes already
	var children = get_children()
	for child in children:
		if child.get_groups().has("Camera"):
			pass
		else:
			child.queue_free()
	
	for i in range(MAZE_HEIGHT):
		for j in range(MAZE_WIDTH):
			if (maze[i][j].is_wall):
				var block_pos: Vector2i = maze[i][j].grid_position
				block_pos = block_pos * maze_scale
				var block: Sprite2D = block_scene.instantiate()
				block.position = block_pos
				add_child(block)
			if (maze[i][j].is_goal):
				var block_pos: Vector2i = maze[i][j].grid_position
				block_pos = block_pos * maze_scale
				var block: Sprite2D = block_scene.instantiate()
				block.position = block_pos
				block.texture = preload("uid://b532w2ibqhu8j")
				add_child(block)
			if (maze[i][j].is_start):
				var block_pos: Vector2i = maze[i][j].grid_position
				block_pos = block_pos * maze_scale
				var block: Sprite2D = block_scene.instantiate()
				block.position = block_pos
				block.texture = preload("uid://v30so2fvqn5i")
				add_child(block)

# Resets the variables connects_to and connected_from as they are needed by pathfinding algorithms
func reset_connecting_values() -> void:
	for i in range(MAZE_HEIGHT):
		for j in range (MAZE_WIDTH):
			maze[i][j].reset_values()

#func draw_path(next_position: Vector2i) -> void:
	##print(maze[next_position.x][next_position.y].connects_to)
	#if (!maze[next_position.x][next_position.y].is_start):
		## Draw line between next_position and next_position.connects_to
		#var line: Line2D = line_scene.instantiate()
		#line.add_point(next_position)
		#line.add_point(maze[next_position.x][next_position.y].connects_to)
		#add_child(line)
		## call draw_path and pass in next_position.connects_to
		#draw_path(maze[next_position.x][next_position.y].connects_to)
