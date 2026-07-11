class_name Beepath

var north: int = 0
var south: int = 1
var east: int = 2
var west: int = 3
#var delete: 4

var points: Array[Vector2i]
var direction_string: Array[int]

func _init() -> void:
	pass

func print_details() -> void:
	#print("Points:\n")
	#for point in points:
		#print(point, ", ")
	#print("Directions:\n")
	#for direction in direction_string:
		#print(direction, ", ")
	
	print("Number of points: ", points.size())
	print("Size of directionstring: ", direction_string.size())
	print("\n\n")

func calculate_fitness() -> int:
	var fitness: int = points.size()
	return fitness

# After mutate is called, the solution needs to be retested to see if it's still valid
func mutate(number_of_changes: int) -> void:
	var number_of_directions: int = direction_string.size()
	#print("num of directions: ", number_of_directions)
	var original_string: Array[int] = direction_string
	for i in number_of_changes:
		var current_direction: int = randi() % number_of_directions
		#print(current_direction)
		
		match (randi() % 5):
			0: # North
				direction_string[current_direction] = north
			1: # South
				direction_string[current_direction] = south
			2: # East
				direction_string[current_direction] = east
			3: # West
				direction_string[current_direction] = west
			4: # Delete
				direction_string.pop_at(current_direction)
				number_of_directions = direction_string.size()
