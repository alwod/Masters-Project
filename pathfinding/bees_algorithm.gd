class_name Beesalgorithm

#TODO:
# - Limit solution sizes to the area of the maze
# - Rather than completely blocking solutions that pass through walls or don't contain the goal,
# just have these solutions decrease the fitness
# - After doing this do some testing, maybe I can group the starting solutions by similarity rather
# than mutating a solution to find its similar solutions?

# Parameters
var iterations: int
var scout_bees: int
var elite_sites: int
var best_sites: int
var recruited_bees_for_elite_sites: int
var recruited_bees_for_remaining_best_sites: int
var neighbourhood_size: int
var stagnation_limit: int

# If a solution intersects a wall or doesnt lead to the goal, the cost should be increased
var wall_cost: int = 100
var no_goal_cost: int = 200

# Starting solutions
var starting_solutions: Array[Beepath]
var starting_solution_size: int = 1

# A copy of the maze, and other usefull variables for the maze
var start: Vector2i = Vector2i(1, 1)
var goal: Vector2i

var maze: Array
var maze_size: Vector2i
var maze_area: int

# Directions - North: 0, South: 1, East: 2, West: 3
const NORTH: Vector2i = Vector2(0, 1)
const SOUTH: Vector2i = Vector2(0, -1)
const EAST: Vector2i = Vector2(1, 0)
const WEST: Vector2i = Vector2(-1, 0)

# Initialise parameters, the initial population
func _init(size: Vector2i, new_maze: Array) -> void:
	# Get the maze, set the start and goal positions, and store the maze size.
	maze = new_maze
	maze_size = size
	maze_area = maze_size.x * maze_size.y
	goal = maze_size - start
	maze[start.x][start.y].is_start = true
	maze[goal.x][goal.y].is_goal = true
	
	generate_random_solutions()
	
	starting_solutions.front().print_details() 
	
	#starting_solutions[0].mutate(100)
	#starting_solutions[0] = mutate_and_validate(starting_solutions[0], 1)
	
	starting_solutions.front().print_details()

func generate_random_solutions() -> void:
	# Set the array size for the array storing all the solutions
	starting_solutions.resize(starting_solution_size)
	
	# Create the needed number of solutions. 
	# Each solution is just a random path through the maze, and can pass through walls and not have the goal
	for solution_number in range(starting_solution_size):
		# Initialise a new path. This object just stores the coordinates of each cell in the path, the directions needed to create the path, and a function to print all the details.
		var solution: Beepath = Beepath.new(maze_area)
		# Additional costs for intersecting walls and not having goals is stored in this.
		# This then needs to be passed into the bee path object
		var solution_cost: int = 0
		
		# Add the start of the maze as the start of the bee path
		solution.points.push_front(start)
		
		# Go in a random direction, if its within the maze store it and go in another random direction
		# Repeat this until the goal cell is in the solution or the max size is reached
		var current_direction: int
		var current_position = start
		
		for i in range(maze_area):
			var previous_position = current_position
			var looking_for_neighbour = true
			while (looking_for_neighbour):
				match (randi() % 4):
					0: # North
						current_position += NORTH
						current_direction = 0
					1: # South
						current_position += SOUTH
						current_direction = 1
					2: # East
						current_position += EAST
						current_direction = 2
					3: # West
						current_position += WEST
						current_direction = 3
				if (current_position > Vector2i(0, 0) && current_position < maze_size):
					looking_for_neighbour = false
				else:
					current_position = previous_position
					
			# A neighbour within the maze has been found. If the new location is a wall, increase the solution's cost
			if (maze[current_position.x][current_position.y].is_wall):
				solution_cost += wall_cost
			
			# If the current position is the goal, there's no need to keep the for loop going
			# If the current position isnt the goal, and we're at the end of the for loop, add a cost for not finding the goal
			if (current_position == goal):
				break
			elif (i == maze_area - 1):
				solution_cost += no_goal_cost
			
			# Update the solution with a new point, direction, and a potential additional cost
			solution.points.push_back(current_position)
			solution.direction_string.push_back(current_direction)
			solution.calculate_fitness(solution_cost)
		
		# Add solution to the array of solutions
		starting_solutions[solution_number - 1] = solution

# Recursive function to make both mutating and validating solutions easyer
func mutate_and_validate(solution: Beepath, number_of_mutations: int) -> Beepath:
	var original_solution: Beepath = solution
	solution.mutate(number_of_mutations)
	print("Finished a mutation")
	var limiter: int = 0
	while(!validate_solution(solution)):
		limiter+= 1
		solution.mutate(number_of_mutations)
		print("Finished a mutation")
		
		if (limiter >= 100):
			return original_solution
	
	return solution
	
	#if (!validate_solution(solution)):
		#mutate_and_validate(solution, number_of_mutations)

# After mutating a solution, it needs to be re-tested here to make sure the path is still valid
func validate_solution(solution: Beepath) -> bool:
	var current_position = solution.points[0]
	
	# Make sure the new path doesnt intersect any walls. 
	# This for loop should only complete if no walls are found
	for i in solution.direction_string.size():
		match (solution.direction_string[i]):
			0: # North
				current_position += NORTH
			1: # South
				current_position += SOUTH
			2: # East
				current_position += EAST
			3: # West
				current_position += WEST
		if (maze[current_position.x][current_position.y].is_wall):
			return false
		
		# Not a wall, so replace the old position with the new one
		solution.points[i+1] = current_position
	
	# Check if the maze has the solution
	if (!solution.points.has(goal)):
		return false
	
	# If the function gets here the path must be valid
	return true

# The main loop
func main_loop() -> void:
	pass

func waggle_dance() -> void:
	pass

func local_search() -> void:
	pass

func global_search() -> void:
	pass

func population_update() -> void:
	pass
