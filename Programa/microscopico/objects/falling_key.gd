extends Sprite2D

@export var fall_speed: float = 200.0
var init_y_pos: float = -360
var has_passed: bool = false
var pass_threshold: float = 300.0

func _ready():
	global_position.y = init_y_pos
	set_process(true)

func _process(delta):
	global_position.y += fall_speed * delta
	
	# Si ya pasó el punto de entrada
	if global_position.y > pass_threshold:
		has_passed = true
	
	# Si ya salió completamente de pantalla
	if global_position.y > 480:
		queue_free()

func Setup(target_x: float, target_frame: int):
	global_position = Vector2(target_x, init_y_pos)
	frame = target_frame
