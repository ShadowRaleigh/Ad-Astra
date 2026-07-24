class_name StatusEffectData extends Resource

enum StackingRule { REPLACE, STACK, REFRESH }

@export var effect_id: String = ""
@export var effect_name: String = ""
@export var description: String = ""

# Which stats are modified and by how much. Key = stat property name, Value = delta.
# Example: {"def_deflexao": -10, "hp_max": 20}
@export var affected_stats: Dictionary = {}

@export var duration_turns: int = 1  # -1 = permanent until removed
@export var is_buff: bool = true
@export var stacking_rule: StackingRule = StackingRule.REFRESH

@export var resource_version: int = 1
