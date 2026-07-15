extends Node2D

@onready var casa_animated_sprite = $Casa

func _ready() -> void:
	if casa_animated_sprite != null:
		casa_animated_sprite.play("Parte1")
		# Conectar señal para cuando acabe la animación
		casa_animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	if casa_animated_sprite.animation == "Parte1":
		casa_animated_sprite.play("Parte2")
	elif casa_animated_sprite.animation == "Parte2":
		get_tree().change_scene_to_file("res://Escenas/story_intro.tscn")
