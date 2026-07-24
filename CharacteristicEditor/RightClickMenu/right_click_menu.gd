extends PanelContainer

@onready var button_container: VBoxContainer = %ButtonContainer

signal delete_pressed
signal duplicate_pressed
signal show_in_file_system_pressed
signal rename_pressed
signal new_folder_pressed

enum Options {
	NEW_FOLDER,
	RENAME,
	DUPLICATE,
	SHOW_IN_FILE_SYSTEM,
	DELETE
}

var options: Array[Options] = [Options.NEW_FOLDER, Options.RENAME, Options.DUPLICATE, Options.SHOW_IN_FILE_SYSTEM, Options.DELETE]
var _buttons: Dictionary = {}

func _ready() -> void:
	for option in options:
		var button = Button.new()
		button.text = Options.keys()[option].capitalize()
		
		# Faz o botão expandir e preencher todo o espaço disponível do VBoxContainer
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		# Deixa o texto alinhado à esquerda e com um recuo (margem) para ficar mais elegante
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		# Define a cor do texto como preto para todos os estados
		button.add_theme_color_override("font_color", Color.BLACK)
		button.add_theme_color_override("font_hover_color", Color.BLACK)
		button.add_theme_color_override("font_pressed_color", Color.BLACK)
		button.add_theme_color_override("font_focus_color", Color.BLACK)
		
		# Cria fundo transparente para os estados base com padding interno
		var empty_style = StyleBoxEmpty.new()
		empty_style.content_margin_left = 12
		empty_style.content_margin_right = 12
		empty_style.content_margin_top = 8
		empty_style.content_margin_bottom = 8
		button.add_theme_stylebox_override("normal", empty_style)
		button.add_theme_stylebox_override("pressed", empty_style)
		button.add_theme_stylebox_override("focus", empty_style)
		
		# Cria fundo levemente escuro para o hover, herdando as mesmas margens e arredondando pontas
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color(0, 0, 0, 0.2) # Preto com 20% de opacidade
		hover_style.content_margin_left = 12
		hover_style.content_margin_right = 12
		hover_style.content_margin_top = 8
		hover_style.content_margin_bottom = 8
		hover_style.corner_radius_top_left = 4
		hover_style.corner_radius_top_right = 4
		hover_style.corner_radius_bottom_left = 4
		hover_style.corner_radius_bottom_right = 4
		button.add_theme_stylebox_override("hover", hover_style)
		
		if option == Options.DELETE:
			button.pressed.connect(_on_delete_pressed)
		elif option == Options.DUPLICATE:
			button.pressed.connect(_on_duplicate_pressed)
		elif option == Options.SHOW_IN_FILE_SYSTEM:
			button.pressed.connect(_on_show_in_file_system_pressed)
		elif option == Options.RENAME:
			button.pressed.connect(_on_rename_pressed)
		elif option == Options.NEW_FOLDER:
			button.pressed.connect(_on_new_folder_pressed)
			
		_buttons[Options.keys()[option]] = button
		button_container.add_child(button)

func setup_options(data: Variant) -> void:
	for b in _buttons.values():
		b.visible = false
		
	var type = "bg"
	if typeof(data) == TYPE_DICTIONARY:
		type = data.get("type", "bg")
		
	match type:
		"bg":
			if _buttons.has("NEW_FOLDER"): _buttons["NEW_FOLDER"].visible = true
		"dir":
			if _buttons.has("NEW_FOLDER"): _buttons["NEW_FOLDER"].visible = true
			if _buttons.has("RENAME"): _buttons["RENAME"].visible = true
			if _buttons.has("DELETE"): _buttons["DELETE"].visible = true
			if _buttons.has("SHOW_IN_FILE_SYSTEM"): _buttons["SHOW_IN_FILE_SYSTEM"].visible = true
		"file", _:
			if _buttons.has("DUPLICATE"): _buttons["DUPLICATE"].visible = true
			if _buttons.has("DELETE"): _buttons["DELETE"].visible = true
			if _buttons.has("SHOW_IN_FILE_SYSTEM"): _buttons["SHOW_IN_FILE_SYSTEM"].visible = true

func _on_delete_pressed() -> void:
	emit_signal("delete_pressed")

func _on_duplicate_pressed() -> void:
	emit_signal("duplicate_pressed")

func _on_show_in_file_system_pressed() -> void:
	emit_signal("show_in_file_system_pressed")

func _on_rename_pressed() -> void:
	emit_signal("rename_pressed")

func _on_new_folder_pressed() -> void:
	emit_signal("new_folder_pressed")
