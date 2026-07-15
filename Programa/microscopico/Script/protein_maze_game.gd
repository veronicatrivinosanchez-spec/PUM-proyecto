extends Node2D

# --- CONFIGURACIÓN ---
@export var protein_scene: PackedScene
@export var spawn_interval: float = 3.0
@export var max_proteins: int = 4

# --- VARIABLES DE JUEGO ---
var score: int = 0
var lives: int = 3
var proteins_on_screen: int = 0
var time_since_last_spawn: float = 0.5
var game_active: bool = true

# --- REFERENCIAS ---
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var lives_label = $CanvasLayer/LivesLabel
@onready var player_node = $Panel/platform_player

func _ready() -> void:
	randomize()
	_update_ui()
	
	# Genera las primeras proteínas
	for i in range(2):
		_spawn_protein()

func _process(delta: float) -> void:
	if not game_active:
		return

	time_since_last_spawn += delta
	if time_since_last_spawn >= spawn_interval and proteins_on_screen < max_proteins:
		_spawn_protein()
		time_since_last_spawn = 0.0

# --- CREAR PROTEÍNA ---
func _spawn_protein() -> void:
	if protein_scene == null:
		push_error("⚠️ No se asignó la escena ProteinObstacle.tscn")
		return

	var protein = protein_scene.instantiate()
	protein.position = Vector2(randi_range(40, 280), 40)
	add_child(protein)
	proteins_on_screen += 1

	if protein.has_signal("obstacle_removed"):
		protein.obstacle_removed.connect(_on_protein_removed)

# --- GESTIÓN DE PROTEÍNAS ---
func _on_protein_removed():
	proteins_on_screen -= 1

# --- SUMAR PUNTAJE ---
func add_score() -> void:
	if not game_active:
		return
	score += 1
	_update_ui()
	print("Punto ganado. Score:", score)

# --- RESTAR VIDA ---
func lose_life() -> void:
	if not game_active:
		return
	lives -= 1
	_update_ui()
	print("Daño recibido. Vidas:", lives)

	if lives <= 0:
		_game_over()
	else:
		_restart_level()

# --- ACTUALIZAR LABELS ---
func _update_ui() -> void:
	score_label.text = "PUNTOS: " + str(score)
	lives_label.text = "VIDAS: " + str(lives)

# --- REINICIAR ---
func _restart_level() -> void:
	get_tree().reload_current_scene()

# --- FIN DEL JUEGO ---
func _game_over() -> void:
	game_active = false
	print("💀 Juego terminado. Puntaje final:", score)
	get_tree().change_scene_to_file("res://Escenas/menu.tscn")
