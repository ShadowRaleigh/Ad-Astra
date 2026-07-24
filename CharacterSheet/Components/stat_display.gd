extends VBoxContainer
# Read-only display for a derived stat (e.g. HP, Deflexão, SAN).
# Shows base value and optional modifier in a styled grid-like layout.

@export var stat_label: String = "Stat":
	set(v):
		stat_label = v
		if is_node_ready(): _refresh()

@export var base_value: int = 0:
	set(v):
		base_value = v
		if is_node_ready(): _refresh()

@export var modifier: int = 0:
	set(v):
		modifier = v
		if is_node_ready(): _refresh()

var _name_label: Label
var _value_label: Label
var _mod_label: Label

func _ready() -> void:
	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 11)
	_name_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	add_child(_name_label)

	var row := HBoxContainer.new()
	add_child(row)

	_value_label = Label.new()
	_value_label.add_theme_font_size_override("font_size", 18)
	row.add_child(_value_label)

	_mod_label = Label.new()
	_mod_label.add_theme_font_size_override("font_size", 12)
	_mod_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	row.add_child(_mod_label)

	_refresh()

func _refresh() -> void:
	if _name_label:
		_name_label.text = stat_label.to_upper()
	if _value_label:
		_value_label.text = str(base_value + modifier)
	if _mod_label:
		if modifier != 0:
			_mod_label.text = " (+%d)" % modifier if modifier > 0 else " (%d)" % modifier
			_mod_label.add_theme_color_override("font_color",
				Color(0.2, 0.9, 0.4) if modifier > 0 else Color(0.9, 0.3, 0.3))
			_mod_label.visible = true
		else:
			_mod_label.visible = false

func set_stat(stat_name: String, value: int, mod: int = 0) -> void:
	stat_label = stat_name
	base_value = value
	modifier = mod
