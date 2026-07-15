extends Node2D

@export var adn: PackedScene
@export var bacteria: PackedScene
@export var spawn_interval: float = 0.7
@export var spawn_margin_top: float = -100
@export var fall_velocity: Vector2 = Vector2(0, 150)

# Variables de puntaje y vidas
var vidas = 3
var puntaje = 0
var tiempo_restante = 30  # segundos del juego

# Referencias a la UI (Labels existentes)
@onready var label_vidas = $CanvasLayer/LabelVidas
@onready var label_puntaje = $CanvasLayer/LabelPuntaje
@onready var label_tiempo = $CanvasLayer/LabelTiempo
@onready var label_game_over = $CanvasLayer/LabelGameOver

# Música de fondo
@onready var music_player = $AudioStreamPlayer

func _ready() -> void:
	randomize()
	music_player.play()
	actualizar_ui()
	label_game_over.visible = false

	# Timer para generar objetos
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_spawn_object)
	add_child(timer)

	# Timer para contar el tiempo
	var tiempo_timer = Timer.new()
	tiempo_timer.wait_time = 1.0
	tiempo_timer.autostart = true
	tiempo_timer.one_shot = false
	tiempo_timer.timeout.connect(_actualizar_tiempo)
	add_child(tiempo_timer)

func actualizar_ui():
	label_vidas.text = "Vidas: %d" % vidas
	label_puntaje.text = "Puntaje: %d" % puntaje
	label_tiempo.text = "Tiempo: %d" % tiempo_restante

func _actualizar_tiempo():
	if tiempo_restante > 0:
		tiempo_restante -= 1
		actualizar_ui()
	if tiempo_restante <= 0:
		terminar_juego()

func _spawn_object() -> void:
	if vidas <= 0 or tiempo_restante <= 0:
		return

	var screen_width = get_viewport_rect().size.x
	var number_of_objects = randi() % 3 + 2  # 2 a 4 objetos por spawn

	# Probabilidad de ADN según tiempo restante
	var adn_prob = 0.5
	if tiempo_restante <= 5:
		adn_prob = 0.05
	elif tiempo_restante <= 10:
		adn_prob = 0.10
	elif tiempo_restante <= 15:
		adn_prob = 0.20
	elif tiempo_restante <= 20:
		adn_prob = 0.30
	elif tiempo_restante <= 25:
		adn_prob = 0.40

	# Generar posiciones disponibles con separación mínima
	var margin = 20
	var min_spacing = 70  # distancia mínima entre objetos
	var posiciones_disponibles = []
	for x in range(margin, int(screen_width) - margin, min_spacing):
		posiciones_disponibles.append(x)
	posiciones_disponibles.shuffle()
	var posiciones_finales = posiciones_disponibles.slice(0, number_of_objects)

	# Alternar ADN/Bacteria
	var tipos = []
	var tipo_actual = "bacteria" if randf() > adn_prob else "adn"
	for i in range(number_of_objects):
		tipos.append(tipo_actual)
		tipo_actual = "adn" if tipo_actual == "bacteria" else "bacteria"

	# Instanciamos los objetos
	for i in range(number_of_objects):
		var object_scene: PackedScene = adn if tipos[i] == "adn" else bacteria
		if object_scene == null:
			push_error("Faltan asignar las escenas 'adn' o 'bacteria'.")
			return

		var obj = object_scene.instantiate()
		add_child(obj)
		obj.set("fondo", self)

		# Tamaño del objeto para no salirse de los bordes
		var obj_width = 32
		if obj.has_node("Sprite"):
			obj_width = obj.get_node("Sprite").texture.get_width()
		var x = clamp(posiciones_finales[i], obj_width / 2, screen_width - obj_width / 2)
		obj.position = Vector2(x, spawn_margin_top)

		# Velocidad aleatoria
		var speed_multiplier = randf_range(0.8, 1.2)
		obj.velocity = Vector2(fall_velocity.x, fall_velocity.y * speed_multiplier)

# --- Funciones puntaje y vidas ---
func ganar_punto():
	if vidas > 0 and tiempo_restante > 0:
		puntaje += 1
		actualizar_ui()

func perder_vida():
	if vidas > 0 and tiempo_restante > 0:
		vidas -= 1
		actualizar_ui()
		if vidas <= 0:
			terminar_juego()

func terminar_juego():
	var texto_final = "FIN" if puntaje >= 6 else "¡Game Over!"
	label_game_over.text = texto_final
	label_game_over.visible = true
	label_game_over.add_theme_font_size_override("font_size", 72)
	label_game_over.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_game_over.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	music_player.stop()
	await get_tree().create_timer(2.0).timeout
	get_tree().paused = true
	if puntaje >= 6:
		get_tree().change_scene_to_file("res://Escenas/story_two.tscn")
	else:
		get_tree().reload_current_scene()
