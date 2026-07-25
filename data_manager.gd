class_name Datamanager

# This class' function is to store the data of a single pathfinding algorithm at a time across all of its runs
# A pathfinding algorithm is run X amount of times for various map sizes / types.
# After each iteration the data is stored in the various arrays here.
# So each array should have X amount of items

var save_path = "res://test_data/"
var file_name = "Data.json"

var algorithm_used: String # The name of the algorithm this has data for
var map_type: String # The map type it was used on: what's the map's size and was it changing?

var memory_usage: Array # An array which stores the amount of memory in bytes used during each individual run of a pathfinding algorithm
var path_length: Array # Stores the length of the path found
var time_to_complete: Array # How quickly the pathfinding algorithm solved the maze in microseconds
var number_of_iterations: Array # How many loop iterations the algorithm needed to solve the maze

func _init(name: String, map: String) -> void:
	algorithm_used = name
	map_type = map

func push_data(new_memory, new_length, new_time, new_iterations) -> void:
	memory_usage.push_front(new_memory)
	path_length.push_front(new_length)
	time_to_complete.push_front(new_time)
	number_of_iterations.push_front(new_iterations)

func create_json() -> void:
	var data: String = "[\n"
	for i in range(memory_usage.size()):
		data += "{\n"
		
		data += '"Name": ' + JSON.stringify(algorithm_used, " iteration ", i) + ",\n"
		data += '"Map Type": ' + JSON.stringify(map_type) + ",\n"
		data += '"Memory Usage (bytes)": ' + JSON.stringify(memory_usage[i]) + ",\n"
		data += '"Path Length": ' + JSON.stringify(path_length[i]) + ",\n"
		data += '"Time (microseconds)": ' + JSON.stringify(time_to_complete[i]) + ",\n"
		data += '"Loop Iterations": ' + JSON.stringify(number_of_iterations[i]) + "\n"
		
		if (i == memory_usage.size() - 1):
			data += "}"
		else:
			data += "},"
	
	data += "]"
	
	var json = JSON.new()
	var error = json.parse(data)
	if error == OK:
		var full_path = save_path + file_name
		if not DirAccess.dir_exists_absolute(save_path):
			DirAccess.make_dir_absolute(save_path)
			
		var file = FileAccess.open(full_path, FileAccess.WRITE)
		file.store_string(data)
		
	else:
		print("JSON Parse Error: ", json.get_error_message(), " int ", data, " at line ", json.get_error_line())
