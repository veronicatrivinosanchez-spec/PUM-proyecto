extends Node2D

# Referencias a los nodos de la escena
@onready var player = $platform_player 
@onready var interaction_point = $Interactuable
@onready var prompt_label = $Interactuable/Teclas
@onready var dialogue_ui = $Panel/Cuadro_texto
@onready var dialogue_text_label = $Panel/Cuadro_texto/Panel/Texto
@onready var golgi_animated_sprite = $Golgi
@onready var e_button_anim = $Interactuable/Teclas

# Variables de control de diálogo
var is_player_in_range: bool = false
var is_dialogue_active: bool = false
var current_dialogue_index: int = 0
var dialogue_lines: Array = [] 
var current_story_key: String = "" # Saber si estamos en "inicio" o "final"

# --- Diccionario de Diálogo ---
var story_dialogue: Dictionary = {
	"inicio": [
		{ "speaker": "Oliver", "text": "¿Eres el aparato de Golgi?" },
		{ "speaker": "Golgi", "text": "¡Sí! Pero necesito ayuda. Ribosoma está atrapado al otro lado." },
		{ "speaker": "Oliver", "text": "Bien, lo rescataré." }
	],
	"final": [
		{ "speaker": "Golgi", "text": "¡Gracias! Ya podemos seguir trabajando." },
		{ "speaker": "Ribosoma", "text": "¡Por fin! Estuve solo mucho tiempo." },
		{ "speaker": "Oliver", "text": "¿Qué hacen ustedes aquí?" },
		{ "speaker": "Golgi", "text": "Yo modifico y transporto proteínas." },
		{ "speaker": "Ribosoma", "text": "Y yo las fabrico." },
		{ "speaker": "Oliver", "text": "¡Genial! Pero… ¿qué causó el temblor?" },
		{ "speaker": "Golgi", "text": "Vi al peroxisoma ir al núcleo, luego todo se desordenó." },
		{ "speaker": "Oliver", "text": "Tal vez el núcleo tenga las respuestas." },
		{ "speaker": "Ribosoma", "text": "Sí, sigue con cuidado." }
	]
}


func _ready() -> void:
	dialogue_ui.hide()
	prompt_label.hide()
	if e_button_anim:
		e_button_anim.hide()
	if golgi_animated_sprite:
		golgi_animated_sprite.play("idle") 
	if player:
		player.is_story_mode = true


func _process(delta: float) -> void:
	if is_player_in_range and not is_dialogue_active:
		prompt_label.show()
		if e_button_anim and not e_button_anim.is_playing():
			e_button_anim.show()
			e_button_anim.play("flash")
		if Input.is_action_just_pressed("ui_accept"):
			start_dialogue("inicio")
	elif not is_player_in_range or is_dialogue_active:
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
	current_story_key = dialogue_key
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
	dialogue_text_label.text = current_line["speaker"] + ": " + current_line["text"]


func end_dialogue() -> void:
	is_dialogue_active = false
	dialogue_ui.hide()
	if player:
		player.set_physics_process(true)
		player.set_process(true)
		player.is_story_mode = false
	
	# Cambiar de escena según el diálogo actual
	if current_story_key == "inicio":
		get_tree().change_scene_to_file("res://Escenas/protein_maze_game.tscn")  # Va al minijuego
	elif current_story_key == "final":
		get_tree().change_scene_to_file("res://Escenas/story_three.tscn")  # Va a la siguiente parte


func _on_interactuable_body_entered(body: Node2D) -> void:
	if body.name == "platform_player":
		is_player_in_range = true


func _on_interactuable_body_exited(body: Node2D) -> void:
	if body.name == "platform_player":
		is_player_in_range = false
