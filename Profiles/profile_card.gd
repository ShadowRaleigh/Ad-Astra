extends PanelContainer
# Profile card — compact visual card for a single CharacterSheetData.
# Usage: call load_card(sheet_data, char_id) then connect signals.

signal card_clicked(character_id: String)
signal card_right_clicked(character_id: String)

var _character_id: String = ""
var _portrait: TextureRect
var _name_label: Label
var _sub_label: Label
var _fav_label: Label

func _ready() -> void:
	custom_minimum_size = Vector2(180, 200)
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.13, 0.18, 0.98)
	style.set_border_width_all(1)
	style.border_color = Color(0.35, 0.35, 0.5)
	style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	add_child(vbox)

	_portrait = TextureRect.new()
	_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.custom_minimum_size = Vector2(0, 110)
	_portrait.clip_contents = true
	vbox.add_child(_portrait)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 13)
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.clip_text = true
	vbox.add_child(_name_label)

	_sub_label = Label.new()
	_sub_label.add_theme_font_size_override("font_size", 10)
	_sub_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.75))
	_sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub_label.clip_text = true
	vbox.add_child(_sub_label)

	_fav_label = Label.new()
	_fav_label.text = "★"
	_fav_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	_fav_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_fav_label.visible = false
	vbox.add_child(_fav_label)

func load_card(sheet: CharacterSheetData, char_id: String) -> void:
	_character_id = char_id
	_name_label.text = sheet.character_name if not sheet.character_name.is_empty() else "(Sem Nome)"
	_sub_label.text = "Lv%d %s | %s" % [
		sheet.level,
		Enums.Archetype.keys()[sheet.archetype],
		sheet.race if not sheet.race.is_empty() else "??"
	]
	var is_fav: bool = sheet.custom_fields.get("favorite", false)
	_fav_label.visible = is_fav
	if not sheet.portrait_path.is_empty() and ResourceLoader.exists(sheet.portrait_path):
		_portrait.texture = load(sheet.portrait_path)
	else:
		_portrait.texture = null

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("card_clicked", _character_id)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			emit_signal("card_right_clicked", _character_id)
