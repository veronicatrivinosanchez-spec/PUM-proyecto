extends CharacterBody2D
@export var speed = 300.0 # Velocidad inicial del personaje
@onready var animated_sprite = $AnimatedSprite2D # Referencia a tu AnimatedSprite2D

var last_direction: Vector2 = Vector2.RIGHT

func _physics_process(_delta: float) -> void:
	# --- 1. PROCESAR ENTRADA Y CALCULAR MOVIMIENTO ---
	var input_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	
	# 🔹 Forzar que no haya movimiento vertical aunque se presione ↑ o ↓
	input_direction.y = 0
	
	# Normaliza el vector para mantener velocidad constante
	input_direction = input_direction.normalized() 
	
	# Aplica la velocidad al CharacterBody2D
	velocity = input_direction * speed
	
	# Mueve el personaje y gestiona colisiones
	move_and_slide()

	# --- 2. LÓGICA DE ANIMACIÓN ---
	if input_direction.x != 0:
		# Personaje en movimiento horizontal
		if input_direction.x < 0:
			animated_sprite.play("ui_left")
			last_direction = Vector2.LEFT
		else:
			animated_sprite.play("ui_right")
			last_direction = Vector2.RIGHT
	else:
		# Personaje en reposo (IDLE)
		var idle_animation_name = ""
		if last_direction == Vector2.LEFT:
			idle_animation_name = "idle_left"
		elif last_direction == Vector2.RIGHT:
			idle_animation_name = "idle_right"
		
		# Solo cambia a la animación de reposo si no está ya reproduciéndose
		if animated_sprite.animation != idle_animation_name:
			animated_sprite.play(idle_animation_name)

# --- 3. FUNCIONES AUXILIARES (Para el control desde el tutorial) ---
func set_speed(new_speed: float) -> void:
	"""Establece una nueva velocidad para Pepito."""
	speed = new_speed

func get_speed() -> float:
	"""Devuelve la velocidad actual de Pepito."""
	return speed
