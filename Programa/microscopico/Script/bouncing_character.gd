extends Area2D

@export var speed: float = 200.0 # Asegúrate de que esta variable sea @export
@export var evade_distance: float = 150.0
@export var evade_strength: float = 0.25 # Asegúrate de que esta variable sea @export y el valor inicial sea el que deseas

var direction: Vector2 = Vector2.ZERO

signal caught_by_player

func _ready() -> void:
	if direction == Vector2.ZERO:
		randomize()
		direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		if direction == Vector2.ZERO:
			direction = Vector2(1, 0)

func _process(delta: float) -> void:
	var desired_direction = direction
	var current_player_node = get_tree().get_first_node_in_group("player_group")

	if current_player_node != null:
		var vector_to_player = current_player_node.position - position
		var distance_to_player = vector_to_player.length()

		if distance_to_player < evade_distance:
			var evade_vector = -vector_to_player.normalized()
			desired_direction = desired_direction.lerp(evade_vector, evade_strength)
			desired_direction = desired_direction.normalized()

	position += desired_direction * speed * delta # Usa 'speed' aquí

	var screen_size = get_viewport_rect().size

	if position.x < 0 or position.x > screen_size.x:
		direction.x *= -1
		position.x = clamp(position.x, 0.0, screen_size.x)

	if position.y < 0 or position.y > screen_size.y:
		direction.y *= -1
		position.y = clamp(position.y, 0.0, screen_size.y)

func _on_BouncingCharacter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		emit_signal("caught_by_player")
		queue_free()
		return

	if body is StaticBody2D:
		var contact_normal = (position - body.position).normalized()
		if contact_normal.length_squared() < 0.0001:
			contact_normal = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()

		direction = direction.bounce(contact_normal)
		direction = direction.normalized()
