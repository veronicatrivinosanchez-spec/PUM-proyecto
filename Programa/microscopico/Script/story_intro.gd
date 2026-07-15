extends Node2D

# Referencias a los nodos de la escena
@onready var player = $platform_player 
@onready var interaction_point = $InteractionPoint
@onready var prompt_label = $InteractionPoint/PromptLabel 
@onready var dialogue_ui = $DialogueUI 
@onready var dialogue_text_label = $DialogueUI/Panel/DialogueTextLabel
@onready var cilio_animated_sprite = $Cilio
@onready var flagelo_animated_sprite = $Flagelo
# e_button_anim está apuntando a $InteractionPoint/PromptLabel,
# lo cual es confuso si PromptLabel es también un AnimatedSprite (que asumo que es).
# Si PromptLabel es el AnimatedSprite, lo redefinimos aquí por claridad.
@onready var e_button_anim = $InteractionPoint/PromptLabel # Asumo que PromptLabel es el AnimatedSprite con las animaciones

# Variables de control de diálogo
var is_player_in_range: bool = false
var is_dialogue_active: bool = false
var current_dialogue_index: int = 0
var dialogue_lines: Array = [] 
var original_prompt_position: Vector2 # Guardará la posición original del botón

# --- Diccionario de Diálogo ---
var story_dialogue: Dictionary = {
	"inicio": [
		{ "speaker": "Cilio", "text": "¡Qué parte más extraña!" },
		{ "speaker": "Flagelo", "text": "¿Y si lo comemos?" },
		{ "speaker": "Oliver", "text": "¡¿Qué?! No, por favor. ¡No sé dónde estoy ni qué está pasando!" },
		{ "speaker": "Cilio", "text": "¡Tranquilo, chico perdido! Estás en una célula. Yo soy Cilio y él es mi hermano Flagelo." },
		{ "speaker": "Oliver", "text": "¿Una célula? ¿Y por qué todo tiembla y se mueve?" },
		{ "speaker": "Cilio", "text": "¡Ah, sí! ¡El temblor! Lo recordamos... pero luego todo se volvió raro." },
		{ "speaker": "Flagelo", "text": "¡Pero ahora ya no! Yo soy el Flagelo. ¡Un látigo que empuja la célula completa!" },
		{ "speaker": "Cilio", "text": "¡Y yo, Cilio, muevo el líquido alrededor! ¡Estamos siempre en constante movimiento!" },
		{ "speaker": "Oliver", "text": "¡Genial! Entonces, necesito pasar para ver qué desastre causó ese temblor... Pero con ustedes moviéndose..." },
		{ "speaker": "Flagelo", "text": "¡Jajaja! Somos Flagelo y Cilio, si quieres pasar, ¡tendrás que atraparnos!" },
		{ "speaker": "Cilio", "text": "¡Si nos atrapas, el movimiento para y puedes seguir tu camino!" }
	],
	"final": []
}


func _ready() -> void:
	# Ocultar UI al inicio
	dialogue_ui.hide()
	
	# La etiqueta (PromptLabel) no es necesaria si e_button_anim es el único indicador
	# prompt_label.hide() 
	
	if e_button_anim != null:
		e_button_anim.hide()
		# Guardar posición original (del AnimatedSprite dentro de InteractionPoint)
		original_prompt_position = e_button_anim.position 
	
	# Activar animaciones de personajes al inicio
	if cilio_animated_sprite != null:
		cilio_animated_sprite.play("idle") 
	if flagelo_animated_sprite != null:
		flagelo_animated_sprite.play("idle")

	# Activar Modo Historia en el jugador
	if player != null:
		player.is_story_mode = true # Deshabilita daño/salto


func _process(delta: float) -> void:
	# Control del prompt antes del diálogo
	if is_player_in_range and not is_dialogue_active:
		# Mostrar el AnimatedSprite con la animación de interacción ("flash")
		if e_button_anim != null:
			e_button_anim.show()
			if e_button_anim.animation != "flash":
				e_button_anim.play("flash")
			
		if Input.is_action_just_pressed("ui_accept"): 
			start_dialogue("inicio")
			
	elif not is_player_in_range or is_dialogue_active:
		# Ocultar el prompt si no está en rango o el diálogo está activo
		if e_button_anim != null and e_button_anim.is_playing() and e_button_anim.animation == "flash":
			e_button_anim.stop()
			e_button_anim.hide()
	
	# Avanzar diálogo con la tecla 'ui_select' (que asumo es la tecla de avance)
	if is_dialogue_active and Input.is_action_just_pressed("ui_select"): 
		advance_dialogue()


func start_dialogue(dialogue_key: String) -> void:
	is_dialogue_active = true
	dialogue_ui.show()
	current_dialogue_index = 0
	dialogue_lines = story_dialogue[dialogue_key] 
	
	# Deshabilita movimiento del jugador
	if player != null:
		player.set_physics_process(false)
		player.set_process(false)
		player.velocity = Vector2.ZERO 
		player.animated_sprite.play("idle_right") # Asegúrate de tener esta animación

	# 🔹 Lógica para mostrar y mantener "button2" durante el diálogo
	if e_button_anim != null:
		e_button_anim.show()
		# Detiene cualquier animación previa (como "flash")
		e_button_anim.stop() 
		# Inicia la animación "button2" para avanzar el diálogo
		e_button_anim.play("button2") 
		
		# Nota: Si el botón tiene que moverse a la UI de diálogo, hazlo aquí:
		# e_button_anim.position = Vector2(NUEVA_X, NUEVA_Y) 
	
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
	
	# 🔹 Detener la animación "button2" y devolverla a su lugar original
	if e_button_anim != null:
		e_button_anim.stop()
		e_button_anim.hide()
		# Vuelve a su posición original (dentro del InteractionPoint)
		e_button_anim.position = original_prompt_position 
	
	# Habilita movimiento del jugador de nuevo
	if player != null:
		player.set_physics_process(true)
		player.set_process(true)
		player.is_story_mode = false 
	
	# Cambia a la siguiente escena (juego de atrapar)
	get_tree().change_scene_to_file("res://Escenas/catch_game.tscn")


func _on_interaction_point_body_entered(body: Node2D) -> void:
	if body.name == "platform_player":
		is_player_in_range = true


func _on_interaction_point_body_exited(body: Node2D) -> void:
	if body.name == "platform_player":
		is_player_in_range = false
