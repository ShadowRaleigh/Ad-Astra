extends VBoxContainer
# Editable list of strings (titles, subclasses, proficiencies, etc.)

signal list_changed(new_list: Array[String])

@export var field_label: String = "Lista":
	set(v):
		field_label = v
		if is_node_ready(): _label_node.text = v

@export var max_items: int = -1   # -1 = unlimited
@export var item_placeholder: String = "Novo item..."

var _label_node: Label
var _list_container: VBoxContainer
var _add_button: Button
var _items: Array[String] = []

func _ready() -> void:
	_label_node = Label.new()
	_label_node.text = field_label
	_label_node.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_label_node.add_theme_font_size_override("font_size", 11)
	add_child(_label_node)

	_list_container = VBoxContainer.new()
	add_child(_list_container)

	_add_button = Button.new()
	_add_button.text = "+ Adicionar"
	_add_button.pressed.connect(_on_add_pressed)
	add_child(_add_button)

	_rebuild_ui()

func set_items(items: Array[String]) -> void:
	_items = items.duplicate()
	if is_node_ready():
		_rebuild_ui()

func get_items() -> Array[String]:
	return _items.duplicate()

func _rebuild_ui() -> void:
	for child in _list_container.get_children():
		child.queue_free()

	for i in range(_items.size()):
		var row := HBoxContainer.new()
		_list_container.add_child(row)

		var line := LineEdit.new()
		line.text = _items[i]
		line.placeholder_text = item_placeholder
		line.size_flags_horizontal = SIZE_EXPAND_FILL
		var idx := i  # capture
		line.text_submitted.connect(func(t: String) -> void: _on_item_edited(idx, t))
		line.focus_exited.connect(func() -> void: _on_item_edited(idx, line.text))
		row.add_child(line)

		var del_btn := Button.new()
		del_btn.text = "✕"
		del_btn.custom_minimum_size = Vector2(28, 0)
		del_btn.pressed.connect(func() -> void: _on_remove_pressed(idx))
		row.add_child(del_btn)

	_add_button.disabled = (max_items >= 0 and _items.size() >= max_items)

func _on_add_pressed() -> void:
	if max_items >= 0 and _items.size() >= max_items:
		return
	_items.append("")
	_rebuild_ui()
	emit_signal("list_changed", _items)

func _on_remove_pressed(index: int) -> void:
	if index < 0 or index >= _items.size(): return
	_items.remove_at(index)
	_rebuild_ui()
	emit_signal("list_changed", _items)

func _on_item_edited(index: int, value: String) -> void:
	if index < 0 or index >= _items.size(): return
	_items[index] = value
	emit_signal("list_changed", _items)
