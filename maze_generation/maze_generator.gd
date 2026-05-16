extends Node

const MAZE_WIDTH = 5
const MAZE_HEIGHT = 5
var unvisited_cells: int
var maze: Array

const NORTH: Vector2 = Vector2(0, 1)
const SOUTH: Vector2 = Vector2(0, -1)
const EAST: Vector2 = Vector2(1, 0)
const WEST: Vector2 = Vector2(-1, 0)

@export var block_scene: PackedScene

func _ready() -> void:
	seed(12345)
	initialise_grid()
	
	unvisited_cells = MAZE_HEIGHT * MAZE_WIDTH
	
	aldous_broder()
	
	visualise_maze()
	
	#for i in range(MAZE_HEIGHT):
		#for j in range(MAZE_WIDTH):
			#maze[i][j].print_details()

func initialise_grid():
	print("GRID INITIALISATION BEGINS")
	# Initialise the basic maze as a 2d array
	maze = Array()
	maze.resize(MAZE_WIDTH)
	for i in range(MAZE_WIDTH):
		maze[i] = Array()
		maze[i].resize(MAZE_HEIGHT)
		for j in range(MAZE_HEIGHT):
			maze[i][j] = Cell.new(Vector2(i, j))
			#maze[i][j].print_details()
	print("GRID INITIALISATION COMPLETE")

func aldous_broder() -> void:
	print("MAZE GENERATION BEGINS")
	# Start at a random cell
	var current_position: Vector2 = Vector2(randi() % MAZE_WIDTH, randi() % MAZE_HEIGHT)
	maze[current_position.x][current_position.y].visited = true
	unvisited_cells -= 1
	
	print("MAIN LOOP BEGINS")
	# The main loop. Repeat until every cell in the area has been visited
	while (unvisited_cells > 0):
		print("Unvisited cells: ", unvisited_cells)
		print("Currently at: ", current_position)
		var previous_position: Vector2 = current_position
		
		# Move in a random direction, using a hacky do-while loop
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
		
		# Check if this current cell has been visisted. If not, 'connect' it to previous cell
		if (!maze[current_position.x][current_position.y].visited):
			maze[current_position.x][current_position.y].visited = true
			unvisited_cells -=1
			maze[current_position.x][current_position.y].connects_to = previous_position
			
	print("MAZE GENERATION COMPLETE")

func visualise_maze() -> void:
	for i in range(MAZE_HEIGHT):
		for j in range(MAZE_WIDTH):
			var block_pos: Vector2 = maze[i][j].position
			block_pos = block_pos * 100
			var block = block_scene.instantiate()
			block.position = block_pos
			add_child(block)
