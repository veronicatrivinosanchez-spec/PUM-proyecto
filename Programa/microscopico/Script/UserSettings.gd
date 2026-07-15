# UserSettings.gd
extends Node

var high_scores_data: Dictionary = {} # Ahora guardaremos un diccionario
const SAVE_PATH = "user://user_data.dat"

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(high_scores_data) # Guarda el diccionario completo
		file.close()
	else:
		push_error("Error al guardar el archivo: ", SAVE_PATH)

func load_settings() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		high_scores_data = file.get_var()
		file.close()
		# Asegúrate de que sea un diccionario si el archivo estaba vacío o era viejo
		if not high_scores_data is Dictionary:
			high_scores_data = {}
	else:
		print("No se encontró archivo de puntajes máximos. Se creará uno nuevo al guardar.")
		high_scores_data = {} # Inicializa como diccionario vacío si no hay archivo

# NUEVA VERSIÓN: Obtener el puntaje máximo para un juego específico
func get_high_score(game_name: String) -> int:
	return high_scores_data.get(game_name, 0) # Devuelve el puntaje o 0 si no existe

# NUEVA VERSIÓN: Establecer el puntaje máximo para un juego específico
func set_high_score(game_name: String, score_to_save: int) -> void:
	if score_to_save > high_scores_data.get(game_name, 0): # Compara con el puntaje actual del juego
		high_scores_data[game_name] = score_to_save
		save_settings() # Guarda automáticamente cuando se actualiza
