# story_golgi.gd
extends Node2D

@onready var player = $platform_player 
@onready var interaction_point = $Interactuable
@onready var prompt_label = $Interactuable/Teclas
@onready var dialogue_ui = $Panel/Cuadro_texto
@onready var dialogue_text_label = $Panel/Cuadro_texto/Panel/Texto
@onready var golgi_animated_sprite = $Golgi
@onready var e_button_anim = $Interactuable/Teclas

var is_player_in_range := false
var is_dialogue_active := false
var current_dialogue_index := 0
var dialogue_lines: Array = [] 

var story_dialogue := {
	"inicio": [
		{ "speaker": "Oliver", "text": "—¡Vaya! Estas paredes enormes se ven muy extrañas..." },
		{ "speaker": "Golgi", "text": "—Bienvenido, pequeño visitante. Soy el Aparato de Golgi." },
		{ "speaker": "Oliver", "text": "—¿Aparato de Golgi? ¿Y qué haces aquí dentro?" },
		{ "speaker": "Golgi", "text": "—Yo me encargo de modificar, empaquetar y enviar proteínas a donde deben ir. Soy como la oficina de correos de la célula." },
		{ "speaker": "Oliver", "text": "—¡Qué interesante! Entonces, ¿puedes ayudarme a entender qué pasó con la célula?" },
		{ "speaker": "Golgi", "text": "—Hubo un temblor extraño... varias proteínas quedaron fuera de lugar. Si las encuentras, tráelas aquí para que yo las organice." },
		{ "speaker": "Oliver", "text": "—Está bien, haré todo lo posible por ayudar." },
		{ "speaker": "Golgi", "text": "—Muy bien. Pero no estás solo, el ribosoma y otros organelos también podrán guiarte en tu camino." },
		{ "speaker": "Narrador", "text": "Pepito se despidió del Golgi y siguió avanzando, decidido a restaurar el orden en la célula." }
	],
	"final": []
}

func _ready() -> void:
	dialogue_ui.hide()
	prompt_label.hide()
	if e_button_anim:
		e_button_anim.hide()
	set_process(false)

	if golgi_animated_sprite:
		golgi_animated_sprite.play("idle")

	if player:
		player.is_story_mode = true


func _process(_delta: float) -> void:
	if is_player_in_range and not is_dialogue_active:
		prompt_label.show()
		if e_button_anim and not e_button_anim.is_playing():
			e_button_anim.show()
			e_button_anim.play("flash")

		if Input.is_action_just_pressed("ui_accept"):
			start_dialogue("inicio")
	else:
		prompt_label.hide()
		if e_button_anim:
			e_button_anim.stop()
			e_button_anim.hide()

	if is_dialogue_active and Input.is_action_just_pressed("ui_select"):
		advance_dialogue()


func start_dialogue(dialogue_key: String) -> void:
	is_dialogue_active = true
	dialogue_ui.show()
	current_dialogue_index = 0
	dialogue_lines = story_dialogue[dialogue_key]

	if player:
		player.set_physics_process(false)
		player.set_process(false)
		player.velocity = Vector2.ZERO
		player.animated_sprite.play("idle_right")

	update_dialogue_text()


func advance_dialogue() -> void:
	current_dialogue_index += 1
	if current_dialogue_index < dialogue_lines.size():
		update_dialogue_text()
	else:
		end_dialogue()


func update_dialogue_text() -> void:
	var current_line = dialogue_lines[current_dialogue_index]
	dialogue_text_label.text = "%s: %s" % [current_line["speaker"], current_line["text"]]


func end_dialogue() -> void:
	is_dialogue_active = false
	dialogue_ui.hide()

	if player:
		player.set_physics_process(true)
		player.set_process(true)
		player.is_story_mode = false

	# Llamamos la carga asíncrona (no bloqueante en lo posible)
	await load_next_scene_async("res://Escenas/protein_maze_game.tscn")


func load_next_scene_async(scene_path: String) -> void:
	# 1) Inicia la carga en background (threaded)
	ResourceLoader.load_threaded_request(scene_path)

	# 2) Espera hasta que termine o haga timeout
	var timeout := 10.0  # segundos máximos para esperar la carga en hilo
	var elapsed := 0.0

	while true:
		var status := ResourceLoader.load_threaded_get_status(scene_path)

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			# cargó correctamente en el hilo
			break
		elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			printerr("Error: carga asíncrona inválida para: ", scene_path)
			break

		# espera un frame
		await get_tree().process_frame
		elapsed += 0.016
		if elapsed > timeout:
			printerr("Timeout cargando escena: ", scene_path, " — se usará fallback de carga normal.")
			break

	# 3) Intenta recuperar la escena ya cargada
	var packed_scene: PackedScene = null
	if ResourceLoader.load_threaded_get_status(scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
		packed_scene = ResourceLoader.load_threaded_get(scene_path) as PackedScene

	# 4) Fallback seguro: si no hay packed_scene, forzamos carga normal ignorando cache
	if packed_scene == null:
		# CACHE_MODE_IGNORE evita usar la versión cacheada (útil si quieres refrescar)
		var fallback := ResourceLoader.load(scene_path, "", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
		if fallback:
			get_tree().change_scene_to_packed(fallback)
		else:
			printerr("No se pudo cargar la escena (fallback): ", scene_path)
	else:
		get_tree().change_scene_to_packed(packed_scene)


func _on_interactuable_body_entered(body: Node2D) -> void:
	if body.name == "platform_player":
		is_player_in_range = true
		set_process(true)
		if e_button_anim and not e_button_anim.is_playing():
			e_button_anim.show()
			e_button_anim.play("flash")


func _on_interactuable_body_exited(body: Node2D) -> void:
	if body.name == "platform_player":
		is_player_in_range = false
		set_process(false)
		if e_button_anim:
			e_button_anim.stop()
			e_button_anim.hide()
