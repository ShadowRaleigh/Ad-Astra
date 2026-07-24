class_name InventoryItemData extends Resource

@export var item_id: String = ""
@export var item_name: String = ""
@export var description: String = ""
@export var type: String = ""
@export var rarity: Enums.ItemRarity = Enums.ItemRarity.COMMON

enum ItemSize { DESPREZIVEL = 0, PEQUENO = 1, MEDIO = 2, GRANDE = 4, MUITO_GRANDE = 8 }
@export var item_size: ItemSize = ItemSize.PEQUENO

@export var quantity: int = 1
@export var effects: Array[Dictionary] = []
@export var durability: int = -1  # -1 = unbreakable
@export var icon_path: String = ""
@export var is_stackable: bool = false
@export var requires_use_confirmation: bool = false
@export var equipment_category: Enums.EquipmentCategory = Enums.EquipmentCategory.CAT_1

# Equipment fields
@export var equipment_slot: String = ""   # e.g. "capacete", "peitoral", "anel"
@export var is_equipped: bool = false
# Stat modifiers when equipped. Key = StatsData property name, Value = int delta.
# Example: {"def_deflexao": 3, "precision": 2}
@export var stat_modifiers: Dictionary = {}

@export var resource_version: int = 1
