extends PanelContainer
# Visual representation of one inventory slot.
# Usage: call set_slot(item) to populate, or clear() to show as empty.

signal slot_clicked(slot_ui: Node)
signal slot_right_clicked(slot_ui: Node)

const RARITY_COLORS := {
	Enums.ItemRarity.COMMON:    Color(0.8, 0.8, 0.8),
	Enums.ItemRarity.UNCOMMON:  Color(0.3, 0.9, 0.3),
	Enums.ItemRarity.RARE:      Color(0.3, 0.5, 1.0),
	Enums.ItemRarity.EPIC:      Color(0.7, 0.2, 0.9),
	Enums.ItemRarity.LEGENDARY: Color(1.0, 0.65, 0.0),
}

var item_data: InventoryItemData = null
var slot_index: int = -1

var _icon: TextureRect
var _name_label: Label
var _qty_label: Label
var _equipped_badge: Label
var _size_label: Label

func _ready() -> void:
	custom_minimum_size = Vector2(80, 80)
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)

	_icon = TextureRect.new()
	_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.custom_minimum_size = Vector2(48, 48)
	_icon.size_flags_horizontal = SIZE_SHRINK_CENTER
	vbox.add_child(_icon)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 10)
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.clip_text = true
	vbox.add_child(_name_label)

	_qty_label = Label.new()
	_qty_label.add_theme_font_size_override("font_size", 9)
	_qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_qty_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.6))
	vbox.add_child(_qty_label)

	_equipped_badge = Label.new()
	_equipped_badge.text = "✓"
	_equipped_badge.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	_equipped_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_equipped_badge.visible = false
	vbox.add_child(_equipped_badge)

	_size_label = Label.new()
	_size_label.add_theme_font_size_override("font_size", 9)
	_size_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	_size_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(_size_label)

func set_slot(item: InventoryItemData, index: int) -> void:
	item_data = item
	slot_index = index
	_refresh()

func clear() -> void:
	item_data = null
	slot_index = -1
	_name_label.text = ""
	_qty_label.text = ""
	_size_label.text = ""
	_equipped_badge.visible = false
	_icon.texture = null
	_apply_border(Color(0.3, 0.3, 0.3))

func _refresh() -> void:
	if not item_data:
		clear()
		return

	_name_label.text = item_data.item_name
	_qty_label.text = "x%d" % item_data.quantity if item_data.is_stackable and item_data.quantity > 1 else ""
	_size_label.text = "%d sl" % item_data.item_size
	_equipped_badge.visible = item_data.is_equipped

	var border_color: Color = RARITY_COLORS.get(item_data.rarity, Color(0.3, 0.3, 0.3))
	_apply_border(border_color)

	tooltip_text = "%s\n%s\nTamanho: %d slots" % [item_data.item_name, item_data.description, item_data.item_size]

func _apply_border(color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	style.border_color = color
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	add_theme_stylebox_override("panel", style)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("slot_clicked", self)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			emit_signal("slot_right_clicked", self)
