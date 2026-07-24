extends Window
# Form for creating or editing an InventoryItemData resource.
# Usage: call edit_item(item) to pre-fill, or show_empty() to create new.
# Connect to item_saved signal to receive the result.

signal item_saved(item: InventoryItemData)

var _editing_item: InventoryItemData = null

var _name_edit: LineEdit
var _desc_edit: TextEdit
var _type_edit: LineEdit
var _rarity_opt: OptionButton
var _size_opt: OptionButton
var _stack_check: CheckBox
var _confirm_check: CheckBox
var _equip_slot_edit: LineEdit
var _dur_spin: SpinBox
var _modifiers_edit: TextEdit  # JSON-style input
var _save_btn: Button
var _error_label: Label

func _ready() -> void:
	title = "Criar/Editar Item"
	exclusive = false
	min_size = Vector2(380, 520)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	vbox.add_child(_make_section("Nome *"))
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Nome do item"
	vbox.add_child(_name_edit)

	vbox.add_child(_make_section("Descrição"))
	_desc_edit = TextEdit.new()
	_desc_edit.custom_minimum_size = Vector2(0, 70)
	vbox.add_child(_desc_edit)

	vbox.add_child(_make_section("Tipo"))
	_type_edit = LineEdit.new()
	_type_edit.placeholder_text = "ex: Arma, Armadura, Consumível"
	vbox.add_child(_type_edit)

	vbox.add_child(_make_section("Raridade"))
	_rarity_opt = OptionButton.new()
	for key in Enums.ItemRarity.keys():
		_rarity_opt.add_item(key)
	vbox.add_child(_rarity_opt)

	vbox.add_child(_make_section("Tamanho"))
	_size_opt = OptionButton.new()
	_size_opt.add_item("Desprezível (0)"); _size_opt.add_item("Pequeno (1)")
	_size_opt.add_item("Médio (2)"); _size_opt.add_item("Grande (4)"); _size_opt.add_item("Muito Grande (8)")
	vbox.add_child(_size_opt)

	_stack_check = CheckBox.new()
	_stack_check.text = "Stackable"
	vbox.add_child(_stack_check)

	_confirm_check = CheckBox.new()
	_confirm_check.text = "Confirmação ao usar"
	vbox.add_child(_confirm_check)

	vbox.add_child(_make_section("Slot de Equipamento"))
	_equip_slot_edit = LineEdit.new()
	_equip_slot_edit.placeholder_text = "ex: capacete, peitoral, anel (vazio = não equipável)"
	vbox.add_child(_equip_slot_edit)

	vbox.add_child(_make_section("Durabilidade (-1 = Indestrutível)"))
	_dur_spin = SpinBox.new()
	_dur_spin.min_value = -1
	_dur_spin.max_value = 9999
	_dur_spin.value = -1
	vbox.add_child(_dur_spin)

	vbox.add_child(_make_section("Modificadores de Stat (JSON)"))
	var mod_hint := Label.new()
	mod_hint.text = "ex: {\"def_deflexao\": 3, \"precision\": 2}"
	mod_hint.add_theme_font_size_override("font_size", 10)
	mod_hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	vbox.add_child(mod_hint)
	_modifiers_edit = TextEdit.new()
	_modifiers_edit.custom_minimum_size = Vector2(0, 60)
	_modifiers_edit.text = "{}"
	vbox.add_child(_modifiers_edit)

	_error_label = Label.new()
	_error_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	_error_label.visible = false
	vbox.add_child(_error_label)

	_save_btn = Button.new()
	_save_btn.text = "Salvar Item"
	_save_btn.pressed.connect(_on_save)
	vbox.add_child(_save_btn)

func _make_section(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	return l

func show_empty() -> void:
	_editing_item = null
	_clear_form()
	popup_centered()

func edit_item(item: InventoryItemData) -> void:
	_editing_item = item
	_populate_form(item)
	popup_centered()

func _clear_form() -> void:
	_name_edit.text = ""
	_desc_edit.text = ""
	_type_edit.text = ""
	_rarity_opt.select(0)
	_size_opt.select(1)
	_stack_check.button_pressed = false
	_confirm_check.button_pressed = false
	_equip_slot_edit.text = ""
	_dur_spin.value = -1
	_modifiers_edit.text = "{}"
	_error_label.visible = false

func _populate_form(item: InventoryItemData) -> void:
	_name_edit.text = item.item_name
	_desc_edit.text = item.description
	_type_edit.text = item.type
	_rarity_opt.select(item.rarity)
	var size_map := {0: 0, 1: 1, 2: 2, 4: 3, 8: 4}
	_size_opt.select(size_map.get(item.item_size, 1))
	_stack_check.button_pressed = item.is_stackable
	_confirm_check.button_pressed = item.requires_use_confirmation
	_equip_slot_edit.text = item.equipment_slot
	_dur_spin.value = item.durability
	_modifiers_edit.text = JSON.stringify(item.stat_modifiers) if not item.stat_modifiers.is_empty() else "{}"
	_error_label.visible = false

func _on_save() -> void:
	if _name_edit.text.strip_edges().is_empty():
		_error_label.text = "Nome é obrigatório."
		_error_label.visible = true
		return

	var parsed_mods := {}
	if not _modifiers_edit.text.strip_edges().is_empty() and _modifiers_edit.text.strip_edges() != "{}":
		var json := JSON.new()
		if json.parse(_modifiers_edit.text) != OK:
			_error_label.text = "JSON de modificadores inválido."
			_error_label.visible = true
			return
		parsed_mods = json.get_data()

	var item: InventoryItemData = _editing_item if _editing_item else InventoryItemData.new()
	item.item_name = _name_edit.text.strip_edges()
	item.description = _desc_edit.text
	item.type = _type_edit.text.strip_edges()
	item.rarity = _rarity_opt.selected as Enums.ItemRarity
	var size_values := [0, 1, 2, 4, 8]
	item.item_size = size_values[_size_opt.selected] as InventoryItemData.ItemSize
	item.is_stackable = _stack_check.button_pressed
	item.requires_use_confirmation = _confirm_check.button_pressed
	item.equipment_slot = _equip_slot_edit.text.strip_edges()
	item.durability = int(_dur_spin.value)
	item.stat_modifiers = parsed_mods

	if item.item_id.is_empty():
		item.item_id = DataManager.generate_id()

	emit_signal("item_saved", item)
	hide()
