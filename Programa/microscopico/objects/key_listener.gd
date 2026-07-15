extends Sprite2D

@onready var falling_key = preload("res://objects/falling_key.tscn")
@onready var score_text = preload("res://objects/score_press_text.tscn")
@export var key_name: String = ""

var falling_key_queue = []

# Distancias para puntaje
var perfect_press_threshold: float = 30
var great_press_threshold: float = 50
var good_press_threshold: float = 60
var ok_press_threshold: float = 80

# Puntos por nivel de precisión
var perfect_press_score: float = 250
var great_press_score: float = 100
var good_press_score: float = 50
var ok_press_score: float = 20

func _ready():
	$GlowOverlay.frame = frame + 4
	Signals.CreateFallingKey.connect(CreateFallingKey)

func _process(delta):
	if Input.is_action_just_pressed(key_name):
		Signals.KeyListenerPress.emit(key_name, frame)

	if falling_key_queue.size() > 0:
		var fk = falling_key_queue.front()
		if is_instance_valid(fk) and fk.has_passed:
			falling_key_queue.pop_front()
			_show_score_text("MISS")
			Signals.ResetCombo.emit()

	if Input.is_action_just_pressed(key_name) and falling_key_queue.size() > 0:
		var key_to_pop = falling_key_queue.pop_front()
		if not is_instance_valid(key_to_pop):
			return

		var distance_from_pass = abs(key_to_pop.pass_threshold - key_to_pop.global_position.y)
		$AnimationPlayer.stop()
		$AnimationPlayer.play("key_hit")

		var press_score_text := ""
		if distance_from_pass < perfect_press_threshold:
			Signals.IncrementScore.emit(perfect_press_score)
			press_score_text = "PERFECT"
			Signals.IncrementCombo.emit()
		elif distance_from_pass < great_press_threshold:
			Signals.IncrementScore.emit(great_press_score)
			press_score_text = "GREAT"
			Signals.IncrementCombo.emit()
		elif distance_from_pass < good_press_threshold:
			Signals.IncrementScore.emit(good_press_score)
			press_score_text = "GOOD"
			Signals.IncrementCombo.emit()
		elif distance_from_pass < ok_press_threshold:
			Signals.IncrementScore.emit(ok_press_score)
			press_score_text = "OK"
			Signals.IncrementCombo.emit()
		else:
			press_score_text = "MISS"
			Signals.ResetCombo.emit()

		key_to_pop.queue_free()
		_show_score_text(press_score_text)

# Crea las teclas que caen (esto se activa en ritmo con la música desde level_editor.gd)
func CreateFallingKey(button_name: String):
	if button_name == key_name:
		var fk_inst = falling_key.instantiate()
		get_tree().get_root().call_deferred("add_child", fk_inst)

		var frame_value = _get_frame_for_button(button_name)
		fk_inst.Setup(position.x, frame_value)

		falling_key_queue.push_back(fk_inst)

# Frames personalizados según tu cuadrícula 2x4
func _get_frame_for_button(button_name: String) -> int:
	match button_name:
		"button_Q": return 6 # izquierda
		"button_W": return 4 # abajo
		"button_E": return 5 # arriba
		"button_R": return 7 # derecha
		_: return 0

# Muestra el texto del resultado
func _show_score_text(text: String):
	var st_inst = score_text.instantiate()
	get_tree().get_root().call_deferred("add_child", st_inst)
	st_inst.SetTextInfo(text)
	st_inst.global_position = global_position + Vector2(0, -20)
