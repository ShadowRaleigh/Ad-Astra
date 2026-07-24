extends CharacteristicModifier

func _init() -> void:
	rule_name = "Efeito no Usuário"
	description = "O efeito desta característica afeta o usuário ao invés do alvo."

func _get_tags() -> Dictionary:
	return { "effect_target": "self" }
