extends RigidBody2D

signal obstacle_removed

const JUMP_STOMP_VELOCITY: float = -500.0
const GRAVITY: float = 900.0

@export var move_speed: float = 150.0
@export var fall_speed: float = 320.0
@export var scale_factor: float = 2.2
@export var fall_chance: float = 0.30
@export var skip_chance: float = 0.15

var direction := 1
var can_fall := false
var viewport_size: Vector2

@onready var score_area = $ScoreArea
@onready var fall_timer = Timer.new()

func _ready():
	randomize()
	scale = Vector2(scale_factor, scale_factor)
	viewport_size = get_viewport_rect().size
	linear_velocity.x = move_speed * direction

	if is_instance_valid(score_area):
		score_area.body_entered.connect(_on_score_area_body_entered)

	fall_timer.wait_time = randf_range(1.5, 3.0)
	fall_timer.autostart = true
	fall_timer.one_shot = false
	add_child(fall_timer)
	fall_timer.timeout.connect(_on_fall_timer_timeout)

func _physics_process(delta):
	if can_fall:
		linear_velocity.y = fall_speed
	else:
		linear_velocity.x = move_speed * direction
		linear_velocity.y += GRAVITY * delta * 0.2

	var pos = global_position
	if pos.x <= 30:
		direction = 1
	elif pos.x >= viewport_size.x - 30:
		direction = -1
	global_position.x = clamp(pos.x, 30, viewport_size.x - 30)

	if has_node("Sprite2D"):
		$Sprite2D.flip_h = direction < 0

func _on_fall_timer_timeout():
	if randf() < fall_chance:
		can_fall = true
		linear_velocity.y = fall_speed
	elif randf() < skip_chance:
		can_fall = true
		linear_velocity.y = fall_speed * 1.4
	fall_timer.wait_time = randf_range(1.5, 3.5)
	fall_timer.start()

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if body.velocity.y < 0:
			if body.has_method("report_damage"):
				body.report_damage()
			obstacle_removed.emit()
			queue_free()

func _on_score_area_body_entered(body: Node2D):
	if body.is_in_group("player") and body.velocity.y > 0:
		if body.has_method("apply_stomp_bounce"):
			body.apply_stomp_bounce(JUMP_STOMP_VELOCITY)
		if body.has_method("report_score"):
			body.report_score()
		obstacle_removed.emit()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	obstacle_removed.emit()
	queue_free()
