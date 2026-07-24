class_name InventoryData extends Resource

signal inventory_changed

@export var slots: Array[InventorySlotData] = []
@export var max_slots: int = 6  # Base 6 + equipment bonuses

func get_used_slots() -> int:
	var used := 0
	for slot in slots:
		if slot and slot.item:
			used += slot.item.item_size  # ItemSize value IS slot count
	return used

func get_available_slots() -> int:
	return max_slots - get_used_slots()

func add_item(item: InventoryItemData) -> bool:
	if item.item_size > get_available_slots(): return false
	var slot := InventorySlotData.new()
	slot.item = item
	slots.append(slot)
	emit_signal("inventory_changed")
	return true

func remove_item(slot_index: int) -> InventoryItemData:
	if slot_index < 0 or slot_index >= slots.size(): return null
	var item := slots[slot_index].item
	slots.remove_at(slot_index)
	emit_signal("inventory_changed")
	return item

func equip_item(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= slots.size(): return false
	var item := slots[slot_index].item
	if not item or item.equipment_slot.is_empty(): return false
	item.is_equipped = true
	emit_signal("inventory_changed")
	return true

func unequip_item(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= slots.size(): return false
	var item := slots[slot_index].item
	if not item: return false
	item.is_equipped = false
	emit_signal("inventory_changed")
	return true

func split_stack(slot_index: int, amount: int) -> bool:
	if slot_index < 0 or slot_index >= slots.size(): return false
	var item := slots[slot_index].item
	if not item or not item.is_stackable: return false
	if amount <= 0 or amount >= item.quantity: return false
	# Check if the split half fits (same size)
	if item.item_size > get_available_slots(): return false
	var new_item := item.duplicate(true) as InventoryItemData
	new_item.quantity = amount
	item.quantity -= amount
	var new_slot := InventorySlotData.new()
	new_slot.item = new_item
	slots.append(new_slot)
	emit_signal("inventory_changed")
	return true

func use_consumable(slot_index: int) -> InventoryItemData:
	if slot_index < 0 or slot_index >= slots.size(): return null
	var item := slots[slot_index].item
	if not item: return null
	item.quantity -= 1
	if item.quantity <= 0:
		slots.remove_at(slot_index)
	emit_signal("inventory_changed")
	return item

func sort_items() -> void:
	slots.sort_custom(func(a: InventorySlotData, b: InventorySlotData) -> bool:
		if not a.item: return false
		if not b.item: return true
		if a.item.type != b.item.type:
			return a.item.type < b.item.type
		if a.item.rarity != b.item.rarity:
			return a.item.rarity > b.item.rarity
		return a.item.item_name < b.item.item_name
	)
	emit_signal("inventory_changed")

# Returns a flat dict of combined stat_modifiers from all equipped items.
func get_equipment_stat_modifiers() -> Dictionary:
	var result: Dictionary = {}
	for slot in slots:
		if slot and slot.item and slot.item.is_equipped:
			for key in slot.item.stat_modifiers:
				if result.has(key):
					result[key] += slot.item.stat_modifiers[key]
				else:
					result[key] = slot.item.stat_modifiers[key]
	return result
