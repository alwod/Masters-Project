extends Node

@export var MAZE_WIDTH: int
@export var MAZE_HEIGHT: int
var unvisited_cells: int
var maze: Array

@export var use_random_seed: bool = false

var first_cell: Vector2
var final_cell: Vector2

const NORTH: Vector2 = Vector2(0, 1)
const SOUTH: Vector2 = Vector2(0, -1)
const EAST: Vector2 = Vector2(1, 0)
const WEST: Vector2 = Vector2(-1, 0)

@export var block_scene: PackedScene
@export var line_scene: PackedScene

func _ready() -> void:
	if (use_random_seed):
		randomize()
	else:
		seed(12345)
	
	initialise_grid()
	
	unvisited_cells = MAZE_HEIGHT * MAZE_WIDTH

	aldous_broder()
		
	visualise_maze()
	
	for i in range(MAZE_HEIGHT):
		for j in range(MAZE_WIDTH):
			maze[i][j].print_details()
	print(first_cell, final_cell)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("regenerate"):
		get_tree().reload_current_scene()


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
	# Start at a random cell
	var current_position: Vector2 = Vector2(randi() % MAZE_WIDTH, randi() % MAZE_HEIGHT)
	var previous_position: Vector2
	first_cell = current_position
	maze[current_position.x][current_position.y].visited = true
	unvisited_cells -= 1
	
	# The main loop. Repeat until every cell in the area has been visited
	while (unvisited_cells > 0):
		print("Unvisited cells: ", unvisited_cells)
		print("Currently at: ", current_position)
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
			maze[previous_position.x][previous_position.y].connected_from = current_position
			
	final_cell = current_position

func visualise_maze() -> void:
	for i in range(MAZE_HEIGHT):
		for j in range(MAZE_WIDTH):
			var block_pos: Vector2 = maze[i][j].grid_position
			block_pos = block_pos * 100
			var block: Sprite2D = block_scene.instantiate()
			block.position = block_pos
			if (first_cell && (block_pos == first_cell * 100)):
				block.texture = load("res://maze_generation/start.png")
			if (final_cell && (block_pos == final_cell * 100)):
				block.texture = load("res://maze_generation/end.png")
			add_child(block)
			
			if (maze[i][j].connects_to):
				var line: Line2D = line_scene.instantiate()
				line.add_point(block_pos)
				line.add_point(maze[i][j].connects_to * 100)
				add_child(line)
			if (maze[i][j].connected_from):
				var line: Line2D = line_scene.instantiate()
				line.add_point(block_pos)
				line.add_point(maze[i][j].connected_from * 100)
				add_child(line)
