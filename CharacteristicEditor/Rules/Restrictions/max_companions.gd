extends CharacteristicRestriction

@export var max_count: int = 3

func _init() -> void:
	rule_name = "Máximo de Companheiras"
	description = "Limita quantas outras características podem acompanhar esta na mesma habilidade."

func _is_valid(context: Dictionary) -> bool:
	var companions = context.get("characteristics", []) as Array
	# Decrement 1 to not count itself, assuming it's in the list
	return max(0, companions.size() - 1) <= max_count
