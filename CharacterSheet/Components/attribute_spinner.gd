extends HBoxContainer
# A labelled SpinBox for a single character attribute.
# Usage: set attribute_name and value, connect to value_changed signal.

signal value_changed(attribute_name: String, new_value: int)

@export var attribute_name: String = "POD":
	set(v):
		attribute_name = v
		if is_node_ready(): _update_label()

@export var min_value: int = 1
@export var max_value: int = 30
@export var bonus_hint: String = ""  # e.g. "+2 Fortitude" — shown as tooltip/label

var _label: Label
var _spin: SpinBox
var _bonus_label: Label

func _ready() -> void:
	_label = Label.new()
	_label.custom_minimum_size = Vector2(50, 0)
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_label)

	_spin = SpinBox.new()
	_spin.min_value = min_value
	_spin.max_value = max_value
	_spin.custom_minimum_size = Vector2(80, 0)
	_spin.value_changed.connect(_on_spin_changed)
	add_child(_spin)

	_bonus_label = Label.new()
	_bonus_label.custom_minimum_size = Vector2(80, 0)
	_bonus_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	_bonus_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_bonus_label)

	_update_label()

func _update_label() -> void:
	if _label:
		_label.text = attribute_name
	if _bonus_label:
		_bonus_label.text = bonus_hint

func set_value(v: int) -> void:
	if _spin:
		_spin.set_value_no_signal(v)

func get_value() -> int:
	return int(_spin.value) if _spin else 0

func set_editable(editable: bool) -> void:
	if _spin:
		_spin.editable = editable

func _on_spin_changed(v: float) -> void:
	emit_signal("value_changed", attribute_name, int(v))
