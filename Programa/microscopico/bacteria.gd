extends Area2D

@export var velocity: Vector2 = Vector2(0, 150)
var fondo

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if body is CharacterBody2D:
		if fondo != null:
			fondo.perder_vida()
		queue_free()
