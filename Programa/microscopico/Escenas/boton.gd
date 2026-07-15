extends Area2D

@export var next_scene: String = "res://Escenas/story_3.tscn"

var player_inside: bool = false  # Saber si el player está dentro del botón

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":  # Cambia "Player" por el nombre de tu personaje
		player_inside = true
		print("Player dentro del botón. Presiona E para continuar.")

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_inside = false
		print("Player salió del botón.")

func _process(delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("ui_accept"):  # ui_accept = E
		print("✅ E presionado. Cambiando escena...")
		get_tree().change_scene_to_file(next_scene)
