class_name CharacteristicModifier extends CharacteristicRule

## Override to alter the base cost calculations for an ability.
## Modify the dictionary values directly.
func _apply_cost(_cost_context: Dictionary) -> void:
	pass

## Override to assign tags that alter runtime characteristic behavior.
func _get_tags() -> Dictionary:
	return {}
