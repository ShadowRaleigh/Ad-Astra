class_name CharacteristicRestriction extends CharacteristicRule

## Instantiated by the ability creator to validate a skill's characteristics.
## `context` might contain "characteristics", "ability_type", "level", etc.
func _is_valid(_context: Dictionary) -> bool:
	return true
