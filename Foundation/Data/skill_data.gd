class_name SkillData extends Resource

@export var skill_id: String = ""
@export var owner_character_id: String = ""
@export var skill_name: String = ""
@export var description: String = ""
@export var source_characteristic_ids: Array[String] = []
@export var editable_parameters: Dictionary = {}
@export var base_energy_cost: float = 0.0
@export var cost_factor: float = 1.0  # sum of characteristic modifiers
@export var calculated_cost: float = 0.0  # base * (1 + cost_factor)
@export var material_cost: float = 0.0
@export var validation_state: bool = false
@export var resource_version: int = 1

func recalculate_cost() -> void:
	calculated_cost = base_energy_cost * (1.0 + cost_factor)
