extends Area2D

@export var timeline_name := "timeline1"
@export var timeline_name_level2 := "timeline2"
@export var timeline_name_timeline3 := "timeline3"
@export var dialog_id := "npc_1"
@export var dialog_id_level2 := "npc_1_level2"
@export var dialog_id_timeline3 := "npc_1_timeline3"
@export var rotation_speed: float = 0.2
@export var visual_node: AnimatedSprite2D

var tween: Tween
var player_in_zone: bool = false
var dialog_active: bool = false
var current_dialog_node = null

func _ready() -> void:
	print("=== NPC ИНИЦИАЛИЗАЦИЯ ===")
	print("NPC: ", name)
	print("Dialog ID: ", dialog_id)
	print("Dialog ID Level 2: ", dialog_id_level2)
	print("Dialog ID Timeline3: ", dialog_id_timeline3)
	print("Timeline: ", timeline_name)
	print("Timeline Level 2: ", timeline_name_level2)
	print("Timeline3: ", timeline_name_timeline3)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if visual_node == null:
		for child in get_children():
			if child is AnimatedSprite2D:
				visual_node = child
				print("Найден AnimatedSprite2D: ", visual_node.name)
				break
	else:
		print("Visual node задан: ", visual_node.name)
	
	_check_global_state()
	print("=========================")

func _check_global_state():
	if not has_node("/root/GlobalVars"):
		print("❌ ОШИБКА: GlobalVars не найден в автозагрузке!")
		return
	
	var global = get_node("/root/GlobalVars")
	print("GlobalVars доступен")
	print("Завершенные диалоги: ", global.completed_dialogs)
	
	# Проверяем все ID
	print("Диалог 1 завершен: ", global.is_dialog_completed(dialog_id))
	print("Диалог 2 завершен: ", global.is_dialog_completed(dialog_id_level2))
	print("Диалог 3 завершен: ", global.is_dialog_completed(dialog_id_timeline3))
	print("Диалог активен: ", global.is_dialog_active(get_current_dialog_id()))

func _on_body_entered(body: Node2D) -> void:
	print("=== ТЕЛО ВОШЛО В ЗОНУ ===")
	print("Тело: ", body.name)
	print("Тип: ", body.get_class())
	
	if body.name == "Player":
		print("✅ Обнаружен игрок")
		player_in_zone = true
		
		# Сначала определяем уровень и ID
		var current_dialog_id = get_current_dialog_id()
		var current_timeline = get_timeline_for_current_level()
		print("🎯 ТЕКУЩИЙ УРОВЕНЬ: ", _get_level_name())
		print("🎯 БУДЕТ ИСПОЛЬЗОВАН: Timeline=", current_timeline, ", ID=", current_dialog_id)
		
		# ВСЕГДА поворачиваемся к игроку, даже если диалог завершен
		smooth_turn_towards_player(body)
		
		# Запускаем диалог только если он не завершен
		if _can_start_dialog():
			print("🚀 Запускаем диалог")
			start_dialog()
		else:
			print("⏸️ Диалог уже завершен или запущен")
	else:
		print("❌ Это не игрок")
	
	print("=========================")

func _on_body_exited(body: Node2D) -> void:
	print("=== ТЕЛО ВЫШЛО ИЗ ЗОНЫ ===")
	print("Тело: ", body.name)
	
	if body.name == "Player":
		print("✅ Игрок вышел из зоны")
		player_in_zone = false
		if tween:
			tween.kill()
			print("⏹️ Остановлен tween")
	
	print("=========================")

# ПРОВЕРКА ДЛЯ LEVEL1.TSCN И LEVEL2.TSCN
func is_allowed_scene() -> bool:
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.scene_file_path:
		var scene_path = current_scene.scene_file_path
		
		# ТОЧНОЕ СОВПАДЕНИЕ ПУТЕЙ ДЛЯ Level1 И Level2
		var allowed_scenes = [
			"res://Levels/Level1.tscn",
			"res://Levels/Level2.tscn"
		]
		
		for allowed_scene in allowed_scenes:
			if scene_path == allowed_scene:
				print("✅ Это разрешенная сцена: ", scene_path)
				return true
		
		print("❌ Это не разрешенная сцена: ", scene_path)
		return false
	
	print("❌ Не удалось определить путь сцены")
	return false

func _can_start_dialog() -> bool:
	if not has_node("/root/GlobalVars"):
		print("❌ GlobalVars недоступен")
		return false
	
	if dialog_active:
		print("❌ Диалог уже активен локально")
		return false
	
	var global = get_node("/root/GlobalVars")
	var current_dialog_id = get_current_dialog_id()
	var current_timeline = get_timeline_for_current_level()
	
	print("🔍 ПРОВЕРКА ДИАЛОГА: ", current_dialog_id)
	print("   Timeline: ", current_timeline)
	print("   Завершен: ", global.is_dialog_completed(current_dialog_id))
	print("   Активен: ", global.is_dialog_active(current_dialog_id))
	
	# ОСОБАЯ ЛОГИКА ДЛЯ TIMELINE3 - он может запускаться многократно на Level1 и Level2
	if current_dialog_id == dialog_id_timeline3:
		print("🎯 Это timeline3 - проверяем завершение диалога 1 и разрешенную сцену")
		var dialogue1_completed = global.is_dialog_completed(dialog_id) or global.is_dialog_completed("timeline1")
		if not dialogue1_completed:
			print("❌ Timeline3: диалог 1 не завершен")
			return false
		if not is_allowed_scene():
			print("❌ Timeline3: это не разрешенная сцена")
			return false
		print("✅ Timeline3: диалог 1 завершен и это разрешенная сцена, можно запускать")
		return true
	
	# СТАНДАРТНАЯ ПРОВЕРКА ДЛЯ ОСТАЛЬНЫХ ДИАЛОГОВ
	if global.is_dialog_completed(current_dialog_id):
		print("❌ Диалог уже завершен глобально: ", current_dialog_id)
		return false
	
	if global.is_dialog_active(current_dialog_id):
		print("❌ Диалог уже активен глобально: ", current_dialog_id)
		return false
	
	print("✅ Все условия для запуска диалога выполнены для: ", current_dialog_id)
	return true

func smooth_turn_towards_player(player: Node2D):
	print("=== НАЧАЛО ПОВОРОТА ===")
	
	if visual_node == null:
		print("❌ Visual node не найден")
		return
	
	var player_position = player.global_position
	var npc_position = global_position
	
	print("Позиция игрока: ", player_position)
	print("Позиция NPC: ", npc_position)
	
	var target_scale = visual_node.scale
	if player_position.x > npc_position.x:
		target_scale.x = abs(visual_node.scale.x)
		print("🔄 Поворот направо")
	else:
		target_scale.x = -abs(visual_node.scale.x)
		print("🔄 Поворот налево")
	
	print("Целевой scale: ", target_scale)
	
	if tween:
		tween.kill()
		print("⏹️ Остановлен предыдущий tween")
	
	tween = create_tween()
	tween.tween_property(visual_node, "scale", target_scale, rotation_speed)
	print("✅ Tween запущен")
	
	print("=========================")

func get_current_dialog_id() -> String:
	var global = get_node("/root/GlobalVars")
	
	# Проверяем завершен ли диалог 1
	var dialogue1_completed = global.is_dialog_completed(dialog_id) or global.is_dialog_completed("timeline1")
	
	# timeline3 доступен на Level1.tscn И Level2.tscn
	if is_allowed_scene() and dialogue1_completed:
		print("🎯 Разрешенная сцена + диалог 1 завершен, используем timeline3")
		return dialog_id_timeline3
	elif is_level_2():
		print("🎯 Используем ID для 2 уровня: ", dialog_id_level2)
		return dialog_id_level2
	elif is_allowed_scene():
		print("📁 Разрешенная сцена, используем стандартный ID: ", dialog_id)
		return dialog_id
	else:
		print("🚫 Не разрешенная сцена, диалог недоступен")
		return "disabled"

func get_timeline_for_current_level() -> String:
	var global = get_node("/root/GlobalVars")
	var dialogue1_completed = global.is_dialog_completed(dialog_id) or global.is_dialog_completed("timeline1")
	
	# timeline3 доступен на Level1.tscn И Level2.tscn
	if is_allowed_scene() and dialogue1_completed:
		print("🎯 Разрешенная сцена + диалог 1 завершен, используем timeline3")
		return timeline_name_timeline3
	elif is_level_2():
		print("🎯 Используем timeline для 2 уровня: ", timeline_name_level2)
		return timeline_name_level2
	elif is_allowed_scene():
		print("📁 Разрешенная сцена, используем стандартный timeline: ", timeline_name)
		return timeline_name
	else:
		print("🚫 Не разрешенная сцена, диалог недоступен")
		return ""

func _get_level_name() -> String:
	var current_scene = get_tree().current_scene
	if current_scene:
		return "Сцена: " + current_scene.name + " | Путь: " + str(current_scene.scene_file_path)
	return "Сцена не определена"

func is_level_2() -> bool:
	var current_scene = get_tree().current_scene
	if current_scene:
		var scene_name = current_scene.name
		var scene_filename = current_scene.scene_file_path
		
		print("🔍 ОПРЕДЕЛЕНИЕ УРОВНЯ:")
		print("   Имя сцены: ", scene_name)
		print("   Путь к сцене: ", scene_filename)
		
		# Более гибкая проверка для Level2
		var scene_info = str(scene_name) + " " + str(scene_filename)
		scene_info = scene_info.to_lower()
		
		if ("level2" in scene_info or 
			"level_2" in scene_info or 
			"2" in scene_info or
			"second" in scene_info):
			
			print("🎯 ОБНАРУЖЕН 2 УРОВЕНЬ!")
			return true
		else:
			print("📁 Обычный уровень (не Level2)")
			return false
	
	print("❌ Не удалось определить сцену")
	return false

func start_dialog():
	print("=== ПОПЫТКА ЗАПУСКА ДИАЛОГA ===")
	
	if not _can_start_dialog():
		print("❌ Не могу запустить диалог")
		return
	
	dialog_active = true
	
	# Регистрируем диалог в GlobalVars
	var global = get_node("/root/GlobalVars")
	var current_dialog_id = get_current_dialog_id()
	var current_timeline = get_timeline_for_current_level()
	
	global.start_dialog_session(current_dialog_id, self)
	
	print("🚀 Запускаем Dialogic:")
	print("   Timeline: ", current_timeline)
	print("   Dialog ID: ", current_dialog_id)
	
	current_dialog_node = Dialogic.start(current_timeline)
	if current_dialog_node:
		print("✅ Dialogic создан успешно")
		get_tree().current_scene.add_child(current_dialog_node)
		print("✅ Диалог добавлен на сцену")
		
		# Подключаем сигнал завершения диалога
		if current_dialog_node.has_signal("timeline_ended"):
			current_dialog_node.timeline_ended.connect(_on_dialog_finished)
		elif current_dialog_node.has_signal("dialog_finished"):
			current_dialog_node.dialog_finished.connect(_on_dialog_finished)
		
		# Запускаем мониторинг диалога
		_start_dialog_monitoring()
	else:
		print("❌ Ошибка создания Dialogic")
		dialog_active = false
		global.end_dialog_session(current_dialog_id)
	
	print("=========================")

func _start_dialog_monitoring():
	# Создаем таймер для проверки состояния диалога
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_check_dialog_status)
	add_child(timer)
	timer.start()
	print("⏰ Запущен мониторинг диалога")

func _check_dialog_status():
	if not is_instance_valid(current_dialog_node) or current_dialog_node.is_queued_for_deletion():
		print("✅ Диалог завершен (мониторинг)")
		_on_dialog_finished()
		
		# Удаляем таймер
		for child in get_children():
			if child is Timer:
				child.stop()
				child.queue_free()
				print("⏹️ Остановлен мониторинг диалога")

func _on_dialog_finished():
	print("=== ДИАЛОГ ЗАВЕРШЕН ===")
	var current_dialog_id = get_current_dialog_id()
	print("Диалог ID: ", current_dialog_id)
	
	var global = get_node("/root/GlobalVars")
	global.complete_dialog(current_dialog_id)
	global.end_dialog_session(current_dialog_id)
	print("✅ Диалог отмечен как завершенный в GlobalVars")
	
	player_in_zone = false
	dialog_active = false
	current_dialog_node = null
	print("✅ Состояние сброшено")
	print("=========================")

# Очистка при удалении NPC
func _exit_tree():
	var global = get_node("/root/GlobalVars")
	var current_dialog_id = get_current_dialog_id()
	if global and global.is_dialog_active(current_dialog_id):
		print("🧹 Очистка диалога при удалении NPC")
		global.end_dialog_session(current_dialog_id)

# Функция для принудительного сброса диалога на 2 уровне (для тестирования)
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Нажмите пробел для теста
		print("=== ТЕСТОВАЯ ИНФОРМАЦИЯ ===")
		print("Текущий уровень: ", _get_level_name())
		print("Это Level2: ", is_level_2())
		print("Это разрешенная сцена: ", is_allowed_scene())
		print("Будет использован ID: ", get_current_dialog_id())
		print("Будет использован Timeline: ", get_timeline_for_current_level())
		
		var global = get_node("/root/GlobalVars")
		print("Диалог npc_1 завершен: ", global.is_dialog_completed("npc_1"))
		print("Диалог npc_1_level2 завершен: ", global.is_dialog_completed("npc_1_level2"))
		print("Диалог npc_1_timeline3 завершен: ", global.is_dialog_completed("npc_1_timeline3"))
		print("=========================")
