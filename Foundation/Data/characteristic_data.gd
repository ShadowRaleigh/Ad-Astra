class_name CharacteristicData extends Resource

@export var characteristic_id: String = ""
@export var characteristic_name: String = ""
@export var description: String = ""
@export var type: Enums.CharacteristicType = Enums.CharacteristicType.OFENSIVA
@export var min_tier: int = 1
@export var max_tier: int = 5
@export var material_cost: String = ""
@export var cost_factor: float = 1.0
@export var tags: Array[Enums.CharacteristicTag] = []
@export var restrictions: Array[CharacteristicRestriction] = []
@export var modifiers: Array[CharacteristicModifier] = []
@export var custom_fields: Dictionary = {}

@export var resource_version: int = 1
