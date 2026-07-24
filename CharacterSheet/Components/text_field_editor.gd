extends VBoxContainer
# Expandable multiline text editor for narrative fields (backstory, appearance, etc.)

signal text_changed(new_text: String)

@export var field_label: String = "Campo":
	set(v):
		field_label = v
		if is_node_ready(): _label_node.text = v

@export var placeholder: String = "":
	set(v):
		placeholder = v
		if is_node_ready(): _text_edit.placeholder_text = v

@export var min_lines: int = 3

var _label_node: Label
var _text_edit: TextEdit

func _ready() -> void:
	_label_node = Label.new()
	_label_node.text = field_label
	_label_node.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_label_node.add_theme_font_size_override("font_size", 11)
	add_child(_label_node)

	_text_edit = TextEdit.new()
	_text_edit.placeholder_text = placeholder
	_text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_text_edit.custom_minimum_size = Vector2(0, min_lines * 22)
	_text_edit.size_flags_vertical = SIZE_EXPAND_FILL
	_text_edit.text_changed.connect(_on_text_changed)
	add_child(_text_edit)

func get_text() -> String:
	return _text_edit.text if _text_edit else ""

func set_text(t: String) -> void:
	if _text_edit:
		_text_edit.set_text(t)

func set_editable(editable: bool) -> void:
	if _text_edit:
		_text_edit.editable = editable

func _on_text_changed() -> void:
	emit_signal("text_changed", _text_edit.text)
