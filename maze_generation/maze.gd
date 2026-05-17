class_name Maze extends Node

var grid_size: Vector2i

var maze_dictionary: Dictionary[Vector2i, Cell]

var test_scene: PackedScene = load("res://maze_generation/maze_block.tscn")

func _init() -> void:
	#grid_size = size
	
	var test = test_scene.instantiate()
	add_child(test)
	print("Got here!")
