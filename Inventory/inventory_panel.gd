extends ScrollContainer
# Main inventory panel — embeds inside the character sheet editor's Equipment tab.
# Usage: call load_inventory(inventory_data) to bind.

var _inventory: InventoryData = null
var _grid: GridContainer
var _detail_popup: Node  # item_detail_popup instance
var _creator_popup: Node  # item_creator instance
var _available_label: Label
var _add_btn: Button
var _sort_btn: Button

const SLOT_UI_SCRIPT := preload("res://Inventory/Components/inventory_slot_ui.gd")
const DETAIL_POPUP_SCRIPT := preload("res://Inventory/Components/item_detail_popup.gd")
const CREATOR_POPUP_SCRIPT := preload("res://Inventory/Components/item_creator.gd")

func _ready() -> void:
	size_flags_vertical = SIZE_EXPAND_FILL

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(vbox)

	# Header bar
	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title_lbl := Label.new()
	title_lbl.text = "Inventário"
	title_lbl.add_theme_font_size_override("font_size", 14)
	title_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(title_lbl)

	_available_label = Label.new()
	_available_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7))
	header.add_child(_available_label)

	_add_btn = Button.new()
	_add_btn.text = "+ Item"
	_add_btn.pressed.connect(_on_add_item)
	header.add_child(_add_btn)

	_sort_btn = Button.new()
	_sort_btn.text = "Ordenar"
	_sort_btn.pressed.connect(_on_sort)
	header.add_child(_sort_btn)

	# Slot grid
	_grid = GridContainer.new()
	_grid.columns = 5
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 6)
	vbox.add_child(_grid)

	# Popup windows (added as children so they exist in tree)
	_detail_popup = DETAIL_POPUP_SCRIPT.new()
	_connect_detail_signals()
	add_child(_detail_popup)

	_creator_popup = CREATOR_POPUP_SCRIPT.new()
	_creator_popup.item_saved.connect(_on_item_saved)
	add_child(_creator_popup)

func _connect_detail_signals() -> void:
	_detail_popup.equip_requested.connect(func(idx: int) -> void:
		if _inventory: _inventory.equip_item(idx); _refresh_grid())
	_detail_popup.unequip_requested.connect(func(idx: int) -> void:
		if _inventory: _inventory.unequip_item(idx); _refresh_grid())
	_detail_popup.use_requested.connect(func(idx: int) -> void:
		if _inventory: _inventory.use_consumable(idx); _refresh_grid())
	_detail_popup.split_requested.connect(func(idx: int) -> void:
		if _inventory: _inventory.split_stack(idx, int(_inventory.slots[idx].item.quantity / 2.0)); _refresh_grid())
	_detail_popup.discard_requested.connect(func(idx: int) -> void:
		if _inventory: _inventory.remove_item(idx); _refresh_grid())

func load_inventory(inventory: InventoryData) -> void:
	if _inventory and _inventory.inventory_changed.is_connected(_refresh_grid):
		_inventory.inventory_changed.disconnect(_refresh_grid)
	_inventory = inventory
	if _inventory:
		_inventory.inventory_changed.connect(_refresh_grid)
	_refresh_grid()

func _refresh_grid() -> void:
	for child in _grid.get_children():
		child.queue_free()

	if not _inventory:
		_available_label.text = ""
		return

	_available_label.text = "%d/%d slots" % [_inventory.get_available_slots(), _inventory.max_slots]

	for i in range(_inventory.slots.size()):
		var slot_data := _inventory.slots[i]
		var slot_ui := SLOT_UI_SCRIPT.new()
		_grid.add_child(slot_ui)
		if slot_data and slot_data.item:
			slot_ui.set_slot(slot_data.item, i)
			var idx := i  # capture
			slot_ui.slot_clicked.connect(func(_s: Node) -> void: _on_slot_clicked(idx))
			slot_ui.slot_right_clicked.connect(func(_s: Node) -> void: _on_slot_clicked(idx))

func _on_slot_clicked(idx: int) -> void:
	if not _inventory or idx >= _inventory.slots.size(): return
	if _inventory.slots[idx] and _inventory.slots[idx].item:
		_detail_popup.show_item(_inventory.slots[idx].item, idx, _inventory)

func _on_add_item() -> void:
	_creator_popup.show_empty()

func _on_sort() -> void:
	if _inventory:
		_inventory.sort_items()

func _on_item_saved(item: InventoryItemData) -> void:
	if not _inventory: return
	# Check if editing an existing item (match by item_id)
	var found := false
	for slot in _inventory.slots:
		if slot and slot.item and slot.item.item_id == item.item_id:
			slot.item = item
			found = true
			break
	if not found:
		_inventory.add_item(item)
	_refresh_grid()
