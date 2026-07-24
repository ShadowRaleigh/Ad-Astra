extends Window
# Popup showing full item details with action buttons.
# Usage: call show_item(item, slot_index, inventory_data) then connect to action signals.

signal equip_requested(slot_index: int)
signal unequip_requested(slot_index: int)
signal use_requested(slot_index: int)
signal split_requested(slot_index: int)
signal discard_requested(slot_index: int)

var _item: InventoryItemData = null
var _slot_index: int = -1
var _inventory: InventoryData = null

var _name_label: Label
var _desc_label: Label
var _rarity_label: Label
var _type_label: Label
var _size_label: Label
var _dur_label: Label
var _effects_label: Label
var _equip_btn: Button
var _use_btn: Button
var _split_btn: Button
var _discard_btn: Button

func _ready() -> void:
	title = "Detalhes do Item"
	exclusive = false
	min_size = Vector2(320, 400)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)
	add_child(vbox)

	# Info labels
	_name_label = _make_label("", 16)
	_desc_label = _make_label("", 12)
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rarity_label = _make_label("", 11)
	_type_label = _make_label("", 11)
	_size_label = _make_label("", 11)
	_dur_label = _make_label("", 11)
	_effects_label = _make_label("", 11)
	_effects_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	for lbl in [_name_label, _desc_label, _rarity_label, _type_label, _size_label, _dur_label, _effects_label]:
		vbox.add_child(lbl)

	vbox.add_child(HSeparator.new())

	# Action buttons
	var btn_box := HBoxContainer.new()
	vbox.add_child(btn_box)

	_equip_btn = Button.new()
	_equip_btn.pressed.connect(_on_equip)
	btn_box.add_child(_equip_btn)

	_use_btn = Button.new()
	_use_btn.text = "Usar"
	_use_btn.pressed.connect(_on_use)
	btn_box.add_child(_use_btn)

	_split_btn = Button.new()
	_split_btn.text = "Dividir Stack"
	_split_btn.pressed.connect(_on_split)
	btn_box.add_child(_split_btn)

	_discard_btn = Button.new()
	_discard_btn.text = "Descartar"
	_discard_btn.pressed.connect(_on_discard)
	btn_box.add_child(_discard_btn)

func _make_label(t: String, font_size_val: int) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", font_size_val)
	return l

func show_item(item: InventoryItemData, slot_index: int, inventory: InventoryData) -> void:
	_item = item
	_slot_index = slot_index
	_inventory = inventory
	_refresh_ui()
	popup_centered()

func _refresh_ui() -> void:
	if not _item: return
	_name_label.text = _item.item_name
	_desc_label.text = _item.description
	_rarity_label.text = "Raridade: %s" % Enums.ItemRarity.keys()[_item.rarity]
	_type_label.text = "Tipo: %s" % _item.type
	_size_label.text = "Tamanho: %d slot(s)" % _item.item_size
	_dur_label.text = "Durabilidade: %s" % ("Indestrutível" if _item.durability < 0 else str(_item.durability))

	var effects_text := "Efeitos: "
	if _item.stat_modifiers.is_empty():
		effects_text += "Nenhum"
	else:
		var parts: Array[String] = []
		for key in _item.stat_modifiers:
			var val: int = _item.stat_modifiers[key]
			parts.append("%s %+d" % [key, val])
		effects_text += ", ".join(parts)
	_effects_label.text = effects_text

	_equip_btn.text = "Desequipar" if _item.is_equipped else "Equipar"
	_equip_btn.visible = not _item.equipment_slot.is_empty()
	_use_btn.visible = _item.requires_use_confirmation
	_split_btn.visible = _item.is_stackable and _item.quantity > 1
	_discard_btn.visible = true

func _on_equip() -> void:
	if _item.is_equipped:
		emit_signal("unequip_requested", _slot_index)
	else:
		emit_signal("equip_requested", _slot_index)
	hide()

func _on_use() -> void:
	emit_signal("use_requested", _slot_index)
	hide()

func _on_split() -> void:
	emit_signal("split_requested", _slot_index)
	hide()

func _on_discard() -> void:
	emit_signal("discard_requested", _slot_index)
	hide()
