extends Camera2D

@export var SPEED: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		offset.x += SPEED
	if Input.is_action_pressed("move_left"):
		offset.x -= SPEED
	if Input.is_action_pressed("move_down"):
		offset.y += SPEED
	if Input.is_action_pressed("move_up"):
		offset.y -= SPEED
		
	if Input.is_action_pressed("zoom_in"):
		zoom += Vector2(SPEED / 100, SPEED / 100)
	if Input.is_action_pressed("zoom_out"):
		zoom -= Vector2(SPEED / 100, SPEED / 100)
