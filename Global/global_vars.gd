extends Node
var score : int
var hi_score : int

var config: ConfigFile
var path_to_save_file := "user://game.cfg"
var section_name := "game"

var starts_n = 0 
var deaths_n : int = 0 
var kills_n := 0 
var saves_n :=  0 
var player1_name : String
var last_level : String = ""
var completed_dialogs := {}
var active_dialogs := {}

# Переменные для здоровья игрока (всегда начинаем с полного здоровья)
var player_health := 100
var player_max_health := 100

# Переменная для хранения количества собранных душ
var collected_souls_count : int = 0
# Словарь для хранения ID собранных душ (для проверки уникальности)
var collected_souls_ids := {}

func _ready() -> void:	
	load_game()
	starts_n += 1
	
	# ВОССТАНАВЛИВАЕМ ЗДОРОВЬЕ ПРИ КАЖДОМ ЗАПУСКЕ
	reset_player_health_for_new_game()
	
	print("Диалоги загружены: ", completed_dialogs)
	print("Смертей: ", deaths_n, ", Убийств: ", kills_n)
	print("Здоровье игрока: ", player_health, "/", player_max_health)
	print("Собрано душ: ", collected_souls_count)

func load_game() -> void:
	config = ConfigFile.new()
	var error = config.load(path_to_save_file)
	
	if error == OK:
		print("Файл найден, загружаем данные...")
		player1_name = config.get_value(section_name, "player_name", "Ви")
		starts_n = config.get_value(section_name, "starts_n", 0)
		deaths_n = config.get_value(section_name, "deaths_n", 0)
		kills_n = config.get_value(section_name, "kills_n", 0)
		saves_n = config.get_value(section_name, "saves_n", 0)
		last_level = config.get_value(section_name, "last_level", "")
		completed_dialogs = config.get_value(section_name, "completed_dialogs", {})
		# ЗАГРУЖАЕМ ТЕКУЩЕЕ ЗДОРОВЬЕ (если есть) или используем максимум
		player_health = config.get_value(section_name, "player_health", player_max_health)
		player_max_health = config.get_value(section_name, "player_max_health", 100)
		# ЗАГРУЖАЕМ РЕКОРД
		hi_score = config.get_value(section_name, "hi_score", 0)
		# ЗАГРУЖАЕМ КОЛИЧЕСТВО СОБРАННЫХ ДУШ
		collected_souls_count = config.get_value(section_name, "collected_souls_count", 0)
		# ЗАГРУЖАЕМ ID СОБРАННЫХ ДУШ
		collected_souls_ids = config.get_value(section_name, "collected_souls_ids", {})
		print("Загружены диалоги: ", completed_dialogs)
	else:
		print("Файл не найден, создаем новые значения")
		player1_name = "Ви"
		starts_n = 0
		deaths_n = 0
		kills_n = 0
		saves_n = 0
		last_level = ""
		completed_dialogs = {}
		player_health = 100  # Начинаем с полного здоровья
		player_max_health = 100
		hi_score = 0
		collected_souls_count = 0
		collected_souls_ids = {}

# В функции save_game() сохраняем текущее здоровье и рекорд:
func save_game() -> void:
	saves_n += 1
	config = ConfigFile.new()
	
	config.set_value(section_name, "player_name", player1_name)
	config.set_value(section_name, "starts_n", starts_n)
	config.set_value(section_name, "deaths_n", deaths_n)
	config.set_value(section_name, "kills_n", kills_n)
	config.set_value(section_name, "saves_n", saves_n)
	config.set_value(section_name, "last_level", last_level)
	config.set_value(section_name, "completed_dialogs", completed_dialogs)
	# СОХРАНЯЕМ ТЕКУЩЕЕ ЗДОРОВЬЕ
	config.set_value(section_name, "player_health", player_health)
	config.set_value(section_name, "player_max_health", player_max_health)
	# СОХРАНЯЕМ РЕКОРД
	config.set_value(section_name, "hi_score", hi_score)
	# СОХРАНЯЕМ КОЛИЧЕСТВО СОБРАННЫХ ДУШ
	config.set_value(section_name, "collected_souls_count", collected_souls_count)
	# СОХРАНЯЕМ ID СОБРАННЫХ ДУШ
	config.set_value(section_name, "collected_souls_ids", collected_souls_ids)
	
	var error = config.save(path_to_save_file)
	if error != OK:
		print("Ошибка сохранения: ", error)
	else:
		print("Игра сохранена. Здоровье: ", player_health, "/", player_max_health, " Рекорд: ", hi_score, " Душ собрано: ", collected_souls_count)

# Метод для обновления рекорда
func update_hi_score(new_score: int) -> void:
	if new_score > hi_score:
		hi_score = new_score
		save_game()
		print("Новый рекорд: ", hi_score)

# Методы для работы с душами
func add_collected_soul(soul_id: String) -> void:
	# Проверяем, не собирали ли мы уже эту душу
	if not collected_souls_ids.has(soul_id):
		collected_souls_count += 1
		collected_souls_ids[soul_id] = true
		save_game()  # Сохраняем игру после сбора души
		print("Душа собрана: ", soul_id, ". Всего душ: ", collected_souls_count)
	else:
		print("Душа уже была собрана ранее: ", soul_id)

func is_soul_collected(soul_id: String) -> bool:
	return collected_souls_ids.get(soul_id, false)

func get_collected_souls_count() -> int:
	return collected_souls_count

func set_collected_souls_count(value: int):
	collected_souls_count = value
	save_game()

func reset_collected_souls():
	collected_souls_count = 0
	collected_souls_ids = {}
	save_game()
	print("Счетчик душ сброшен")

func is_dialog_completed(dialog_id: String) -> bool:
	return completed_dialogs.get(dialog_id, false)

func complete_dialog(dialog_id: String):
	completed_dialogs[dialog_id] = true
	save_game()
	print("Диалог ", dialog_id, " отмечен как завершенный")

# Методы для смертей
func add_death():
	deaths_n += 1
	save_game()
	print("Добавлена смерть. Всего смертей: ", deaths_n)

func get_deaths() -> int:
	return deaths_n

# Методы для убийств
func add_kill():
	kills_n += 1
	save_game()
	print("Добавлено убийство. Всего убийств: ", kills_n)

func get_kills() -> int:
	return kills_n

# Методы для диалогов
func start_dialog_session(dialog_id: String, npc_node: Node):
	if not active_dialogs.has(dialog_id):
		active_dialogs[dialog_id] = npc_node
		print("Начат диалог: ", dialog_id)

func end_dialog_session(dialog_id: String):
	if active_dialogs.has(dialog_id):
		active_dialogs.erase(dialog_id)
		print("Завершен диалог: ", dialog_id)

func is_dialog_active(dialog_id: String) -> bool:
	return active_dialogs.has(dialog_id)

func check_and_complete_dialogs():
	for dialog_id in active_dialogs.keys():
		print("Принудительное завершение диалога при переходе: ", dialog_id)
		complete_dialog(dialog_id)
	active_dialogs.clear()

# Методы для здоровья игрока
func set_player_health(health: int):
	player_health = health
	# НЕ сохраняем при изменении здоровья, только при сохранении игры

func get_player_health() -> int:
	return player_health

func set_player_max_health(max_health: int):
	player_max_health = max_health
	save_game()

func get_player_max_health() -> int:
	return player_max_health

# Восстановление здоровья при новом запуске игры
func reset_player_health_for_new_game():
	player_health = player_max_health
	print("Здоровье восстановлено: ", player_health, "/", player_max_health)

# Сброс здоровья (например, при начале новой игры)
func reset_player_health_completely():
	player_health = 100
	player_max_health = 100
	save_game()
	print("Здоровье полностью сброшено: ", player_health, "/", player_max_health)

# Сброс всех прогрессивных данных (для новой игры)
func reset_progress():
	collected_souls_count = 0
	collected_souls_ids = {}
	completed_dialogs = {}
	score = 0
	hi_score = 0
	save_game()
	print("Весь прогресс сброшен")

func print_dialog_state():
	print("=== СОСТОЯНИЕ ДИАЛОГОВ ===")
	print("Завершенные диалоги: ", completed_dialogs)
	print("Активные диалоги: ", active_dialogs)
	print("=========================")
