# menu.gd
extends Control

# Variables @onready para los nodos del menú.
# Asegúrate de que estas rutas coincidan exactamente con tu árbol de nodos en la escena menu.tscn
@onready var start_button = $Panel/VBoxContainer/Button
@onready var exit_button = $Panel/VBoxContainer/Button2
@onready var options_button = $Panel/VBoxContainer/Button3 # Si tienes este botón
@onready var scores_button = $Panel/VBoxContainer/ScoresButton

func _ready() -> void:
	# Conexión de las señales de los botones a sus funciones correspondientes.
	start_button.pressed.connect(_on_StartButton_pressed)
	exit_button.pressed.connect(_on_ExitButton_pressed)
	options_button.pressed.connect(_on_OptionsButton_pressed)
	scores_button.pressed.connect(_on_ScoresButton_pressed)
	

func _on_StartButton_pressed() -> void:
	# Esta función se ejecuta al presionar el botón de inicio.
	# Carga la escena del juego de atrapar.
	print("¡Botón de inicio presionado! Intentando cargar la escena...")
	get_tree().change_scene_to_file("res://Escenas/animacion.tscn")

func _on_ExitButton_pressed() -> void:
	# Esta función se ejecuta al presionar el botón de salir.
	# Cierra la aplicación.
	get_tree().quit()

func _on_OptionsButton_pressed() -> void:
	# Esta función se ejecuta al presionar el botón de opciones.
	# Por ahora, solo muestra un mensaje en la consola.
	print("Botón de Opciones presionado!")
	# Aquí podrías añadir la lógica para cargar una escena de opciones.

func _on_ScoresButton_pressed() -> void:
	# Esta función se ejecuta al presionar el botón de puntuación.
	# Carga la escena de las puntuaciones máximas.
	get_tree().change_scene_to_file("res://Escenas/high_scores.tscn")
