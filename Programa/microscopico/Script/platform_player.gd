extends CharacterBody2D

# --- PROPIEDADES ---
@export var speed: float = 100.0
@export var jump_velocity: float = -250.0
@export var lives: int = 3
@export var is_story_mode: bool = false  # cambia a true cuando se usa en modo historia
@export var ladder_speed: float = 75.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- ESTADO ---
var is_on_ladder: bool = false
var last_direction_right: bool = true
var jumped_over: Array = []

# --- REFERENCIAS ---
@onready var animated_sprite = $AnimatedSprite2D

# --- PROCESO PRINCIPAL ---
func _physics_process(delta: float) -> void:
	# 🌟 Si está en modo historia: solo puede caminar a los lados (sin saltar, sin caer)
	if is_story_mode:
		_process_story_mode(delta)
		return
	
	# 🌟 Si está en modo juego normal (Donkey Kong)
	_process_game_mode(delta)


# --- MODO HISTORIA ---
func _process_story_mode(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Movimiento lateral simple (sin gravedad ni salto)
	velocity.x = direction * speed
	velocity.y = 0
	
	move_and_slide()
	
	# Animaciones básicas
	if direction == 0:
		animated_sprite.play("idle_right" if last_direction_right else "idle_left")
	else:
		last_direction_right = direction > 0
		animated_sprite.play("right" if direction > 0 else "left")


# --- MODO JUEGO ---
func _process_game_mode(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	var vertical_climb = -Input.get_axis("ui_down", "ui_up")
	
	# ESCALERAS
	if is_on_ladder:
		velocity.y = vertical_climb * ladder_speed
		velocity.x = direction * speed
	else:
		# Gravedad
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			# Salto
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = jump_velocity
		
		# Movimiento lateral
		if direction:
			velocity.x = direction * speed
			last_direction_right = direction > 0
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	
	# DETECCIÓN DE SALTO SOBRE PROTEÍNAS
	for protein in get_tree().get_nodes_in_group("proteins"):
		if protein.position.y > position.y and abs(protein.position.x - position.x) < 30:
			if protein not in jumped_over:
				var main = get_tree().get_current_scene()
				if main.has_method("add_score"):
					main.add_score()
				jumped_over.append(protein)
	
	# ANIMACIONES
	if is_on_ladder:
		if vertical_climb != 0:
			animated_sprite.play("climb")
		else:
			animated_sprite.stop()
	elif not is_on_floor():
		if velocity.y > 0:
			animated_sprite.play("fall_right" if last_direction_right else "fall_left")
		else:
			animated_sprite.play("jump_right" if last_direction_right else "jump_left")
	elif direction == 0:
		animated_sprite.play("idle_right" if last_direction_right else "idle_left")
	else:
		animated_sprite.play("right" if direction > 0 else "left")


# --- FUNCIONES LLAMADAS DESDE LAS PROTEÍNAS ---
func report_damage():
	var main = get_tree().get_current_scene()
	if main.has_method("lose_life"):
		main.lose_life()

func report_score():
	var main = get_tree().get_current_scene()
	if main.has_method("add_score"):
		main.add_score()

func apply_stomp_bounce(force: float):
	velocity.y = force
