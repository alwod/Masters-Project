class_name Dijkstras

# To keep things consistent when testing pathfinding algorithms in random mazes,
# the start will always be the top left cell and the goal the bottom right cell for now.
var start: Vector2i = Vector2i(1, 1)
var goal: Vector2i

var maze: Array # A copy of the maze created by the maze generator
var maze_size: Vector2i

var movement_cost: int = 1

func _init(size: Vector2i, new_maze: Array) -> void:
	maze = new_maze
	maze_size = size
	goal = maze_size - start
	maze[start.x][start.y].is_start = true
	maze[goal.x][goal.y].is_goal = true
	
	maze[start.x][start.y].f_cost = 0
	maze[start.x][start.y].closed_list = true
	
	var current_position = start
	
	var number_of_nodes: int = 0
	for i in range(maze_size.x):
		for j in range(maze_size.y):
			if (!maze[i][j].is_wall):
				number_of_nodes += 1
			else:
				maze[i][j].closed_list = true
				
				
	for count in range(number_of_nodes):
		var north = current_position + Vector2i(0, -1)
		var west = current_position + Vector2i(-1, 0)
		var south = current_position + Vector2i(0, 1)
		var east = current_position + Vector2i(1, 0)
		
		var neighbours: Array[Vector2i] = [north, west, south, east]
		
		var lowest_cost: float = INF
		var lowest_cost_neighbour: Vector2i
		
		# Calculate the f costs of the current position's unchecked neighbours
		for neighbour in neighbours:
			#print(current_position, " ", neighbour)
			if (!maze[neighbour.x][neighbour.y].closed_list):
				var new_f_cost = maze[current_position.x][current_position.y].f_cost + movement_cost
				# The cost of this neighbour hasnt been set to anything yet
				if (!maze[neighbour.x][neighbour.y].is_start && maze[neighbour.x][neighbour.y].f_cost == 0):
					maze[neighbour.x][neighbour.y].f_cost = new_f_cost
				# The cost of this neighbour has been set, but the new cost is better
				elif (!maze[neighbour.x][neighbour.y].is_start && maze[neighbour.x][neighbour.y].f_cost > new_f_cost):
					maze[neighbour.x][neighbour.y].f_cost = new_f_cost
				
				# Check to see if this neighbour has the lowest cost of the bunch
				if (maze[neighbour.x][neighbour.y].f_cost < lowest_cost):
					lowest_cost = maze[neighbour.x][neighbour.y].f_cost
					lowest_cost_neighbour = neighbour
					
		
		maze[current_position.x][current_position.y].closed_list = true
		
		# Next, pick the unchecked neighbour with the lowest cost and set it as the new current position
		# If all neighbours are already visited, and the for loop isnt complete, need to search the maze array again to make sure there arent any unvisited nodes that arent walls
		if (lowest_cost_neighbour):
			current_position = lowest_cost_neighbour
		else:
			for i in range(maze_size.x):
				for j in range(maze_size.y):
					if (!maze[i][j].closed_list && maze[i][j].f_cost != 0):
						current_position = maze[i][j].grid_position
						break
	
	# Print details
	for i in range(maze_size.x):
		for j in range(maze_size.y):
			if (!maze[i][j].is_wall):
				print("Node: ", maze[i][j].grid_position)
				print("Distance: ", maze[i][j].f_cost)
				print("\n")
	
	# First, pick a random neighbour of the current position
	
	# Calculate this neighbours f-cost, by adding the movement cost to the current position's f_cost
	# If this new cost is lower than the neighbour's is lower than the neighbours f_cost and isnt 0, set it to the neighbours f_cost
	
	# Repeat above for all 4 non-wall neighbours of the current position
	
	# After all the current position's neighbours are checked, pick the next unvisited neighbour with the lowest f_cost and mark it as visited
	# Marking a neighbour as visited is done in this case by setting closed list to true
	
	# Repeat above for all nodes 
