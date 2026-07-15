extends CharacterBody2D

@export var speed = 188.0 # Esta será la velocidad inicial que definiremos desde catch_game.gd
@onready var animated_sprite = $AnimatedSprite2D

var last_direction: Vector2 = Vector2.DOWN

func _physics_process(_delta: float) -> void:
	var input_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1
	input_direction = input_direction.normalized()
	velocity = input_direction * speed
	
	move_and_slide()

	if input_direction.x != 0 or input_direction.y != 0:
		if input_direction.y < 0:
			animated_sprite.play("up")
			last_direction = Vector2.UP
		elif input_direction.y > 0:
			animated_sprite.play("down")
			last_direction = Vector2.DOWN
		elif input_direction.x < 0:
			animated_sprite.play("left")
			last_direction = Vector2.LEFT
		elif input_direction.x > 0:
			animated_sprite.play("right")
			last_direction = Vector2.RIGHT
	else:
		var idle_animation_name = ""

		if last_direction == Vector2.UP:
			idle_animation_name = "idle_up"
		elif last_direction == Vector2.DOWN:
			idle_animation_name = "idle_down"
		elif last_direction == Vector2.LEFT:
			idle_animation_name = "idle_left"
		elif last_direction == Vector2.RIGHT:
			idle_animation_name = "idle_right"
		if animated_sprite.animation != idle_animation_name:
			animated_sprite.play(idle_animation_name)

	# --- LIMITAR AL PERSONAJE DENTRO DE LA PANTALLA ---
	var viewport_size = get_viewport_rect().size
	var new_position = position
	
	# clamp para limitar la posición del personaje entre 0 y el ancho/alto de la pantalla.
	new_position.x = clamp(new_position.x, 0, viewport_size.x)
	new_position.y = clamp(new_position.y, 0, viewport_size.y)
	
	position = new_position

# --- Nuevas funciones para controlar la velocidad desde CatchGame.gd ---
func set_speed(new_speed: float) -> void:
	speed = new_speed

func get_speed() -> float:
	return speed
# ---------------------------------------------------------------------
