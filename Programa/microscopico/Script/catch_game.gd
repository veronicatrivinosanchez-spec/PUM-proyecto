extends Node2D

@export var bouncing_character_scene: PackedScene
@export var spawn_interval: float = 1.5
@export var max_characters: int = 5
@export var game_duration: float = 30.0

# --- Nuevas Variables de Dificultad ---
@export var initial_player_speed: float = 188.0 # Coincide con tu player.gd
@export var initial_bouncing_speed: float = 200.0 # Velocidad inicial de los cilicios
@export var initial_evade_strength: float = 0.25 # Fuerza de evasión inicial de los cilicios

@export var difficulty_increase_interval: float = 10.0 # Cada cuántos segundos aumenta la dificultad
@export var player_speed_increase_factor: float = 1.2 # Multiplicador para la velocidad del jugador (ej: 1.1 = +10%)
@export var bouncing_speed_increase_factor: float = 1.1 # Multiplicador para la velocidad de los cilicios
@export var evade_strength_increase_amount: float = 0.07 # Cantidad fija para aumentar evade_strength (ej: 0.1)
# -----------------------------------

var score: int = 0
var characters_on_screen: int = 0
var time_since_last_spawn: float = 0.0
var time_remaining: float
var game_active: bool = true
var time_since_last_difficulty_increase: float = 0.0

@onready var score_label = $CanvasLayer/ScoreLabel
@onready var timer_label = $CanvasLayer/TimerLabel
@onready var game_over_label = $CanvasLayer/GameOverLabel
@onready var player_node = $player # Ruta correcta a tu nodo de jugador

func _ready() -> void:
	randomize()
	update_score_display()
	time_remaining = game_duration
	game_over_label.hide()

	# Inicializa la velocidad del jugador
	if player_node != null:
		player_node.set_speed(initial_player_speed) # Llama a la nueva función en player.gd
	else:
		push_error("ERROR: El nodo 'player' no se encontró en CatchGame.gd.")

	# Genera los personajes iniciales
	for i in range(max_characters):
		spawn_bouncing_character()

func _process(delta: float) -> void:
	if not game_active:
		return

	time_remaining -= delta
	timer_label.text = "Time: " + str(int(time_remaining))

	# Lógica de aumento de dificultad basada en el tiempo
	time_since_last_difficulty_increase += delta
	if time_since_last_difficulty_increase >= difficulty_increase_interval:
		increase_difficulty()
		time_since_last_difficulty_increase = 0.0 # Resetea el contador

	if time_remaining <= 0:
		time_remaining = 0
		end_game()
		return

	time_since_last_spawn += delta
	if time_since_last_spawn >= spawn_interval and characters_on_screen < max_characters:
		spawn_bouncing_character()
		time_since_last_spawn = 0.0

func spawn_bouncing_character() -> void:
	if bouncing_character_scene == null:
		push_error("¡ERROR! 'bouncing_character_scene' no está asignado. Asígnalo en el Inspector.")
		return

	var new_character = bouncing_character_scene.instantiate()
	
	# --- CAMBIO CLAVE AQUÍ: Usar call_deferred() para añadir el nodo ---
	call_deferred("add_child", new_character)
	# ------------------------------------------------------------------

	var screen_size = get_viewport_rect().size
	var spawn_x = randf_range(0, screen_size.x)
	var spawn_y = randf_range(0, screen_size.y)
	new_character.position = Vector2(spawn_x, spawn_y)

	# Asigna las propiedades iniciales a los nuevos cilicios.
	new_character.speed = initial_bouncing_speed
	new_character.evade_strength = initial_evade_strength

	# Conectar la señal DEFERRED también para evitar problemas de orden
	# Aunque el error era en add_child, es buena práctica si la conexión depende de ello.
	if new_character.has_signal("caught_by_player"):
		new_character.caught_by_player.connect(on_character_caught_by_player)
	else:
		push_warning("La señal 'caught_by_player' no está declarada en bouncing_character.gd.")

	characters_on_screen += 1

func increase_difficulty() -> void:
	# Aumentar velocidad del jugador
	if player_node != null:
		var current_player_speed = player_node.get_speed() # Llama a la nueva función en player.gd
		player_node.set_speed(current_player_speed * player_speed_increase_factor)
		print("Dificultad aumentada: Velocidad del jugador ahora es ", player_node.get_speed())

	# Aumentar velocidad y evasión de los cilicios
	for child in get_children():
		# Verifica que sea un cilicio antes de intentar cambiar sus propiedades
		if child is Area2D and child.get_scene_file_path() == bouncing_character_scene.resource_path:
			child.speed *= bouncing_speed_increase_factor
			child.evade_strength += evade_strength_increase_amount
			# Clamp evade_strength para que no supere 1.0 (o el valor máximo deseado)
			child.evade_strength = min(child.evade_strength, 1.0)
			print(str(child.name) + ": Velocidad de cilicio ahora es ", child.speed, ", Evasión: ", child.evade_strength)

	# También actualiza las propiedades iniciales para los nuevos cilicios que se generen
	initial_bouncing_speed *= bouncing_speed_increase_factor
	initial_evade_strength += evade_strength_increase_amount
	initial_evade_strength = min(initial_evade_strength, 1.0)
	print("Propiedades iniciales actualizadas para nuevos cilicios: Velocidad: ", initial_bouncing_speed, ", Evasión: ", initial_evade_strength, ")")


func on_character_caught_by_player() -> void:
	if not game_active:
		return

	score += 1
	characters_on_screen -= 1
	update_score_display()
	print("Cilicio atrapado por Pepito. Puntuación: ", score)
	spawn_bouncing_character()

func update_score_display() -> void:
	score_label.text = "Score: " + str(score)

const GAME_NAME: String = "CatchGame" # <--- Añade esta línea
func end_game() -> void:
	game_active = false
	print("¡Juego Terminado! Puntuación final: ", score)

	# --- DESCOMENTA ESTAS LÍNEAS ---
	var current_high_score = UserSettings.get_high_score(GAME_NAME)
	if score > current_high_score:
		UserSettings.set_high_score(GAME_NAME, score)
		print("¡Nuevo puntaje máximo para ", GAME_NAME, ": ", score, "!")
	# --------------------------------

	score_label.hide()
	timer_label.hide()
	game_over_label.show()

	for child in get_children():
		if child is Area2D and child.get_parent() != null and not child.is_queued_for_deletion():
			if child.get_scene_file_path() == bouncing_character_scene.resource_path:
				child.queue_free()

	if player_node != null:
		player_node.set_physics_process(false)
		player_node.set_process(false)

	var return_timer = Timer.new()
	return_timer.one_shot = true
	return_timer.wait_time = 3.0
	add_child(return_timer)
	return_timer.timeout.connect(func(): get_tree().change_scene_to_file("res://Escenas/story_two.tscn"))
	return_timer.start()
