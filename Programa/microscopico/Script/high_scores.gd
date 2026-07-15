# high_scores.gd
extends Control

# Variables @onready para los nodos de la escena de puntuaciones.
# Asegúrate de que estas rutas coincidan con tu árbol de nodos en high_scores.tscn
@onready var high_score_label = $Panel/CatchGameScoreLabel # O la ruta a tu Label
@onready var back_button = $VBoxContainer/BackButton # El botón para volver

func _ready() -> void:
	# Esta función se ejecuta al inicio de la escena.
	
	# Obtenemos la puntuación máxima del juego "CatchGame" usando el Singleton UserSettings.
	# Es crucial que el Singleton esté configurado correctamente.
	var catch_game_high_score = UserSettings.get_high_score("CatchGame")
	
	# Mostramos la puntuación máxima en el Label.
	high_score_label.text = "Puntuación Máxima: " + str(catch_game_high_score)

	# Conectamos la señal del botón "back_button" a su función.
	back_button.pressed.connect(_on_BackButton_pressed)

func _on_BackButton_pressed() -> void:
	# Esta función se ejecuta al presionar el botón de "Volver".
	# Cambia la escena de vuelta al menú principal.
	get_tree().change_scene_to_file("res://Escenas/menu.tscn")
