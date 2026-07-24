class_name CharacterSheetData extends Resource

@export var sheet_type: Enums.SheetType = Enums.SheetType.CHARACTER
@export var character_id: String = ""

# Identity
@export var character_name: String = ""
@export var level: int = 1
@export var race: String = ""
@export var archetype: Enums.Archetype = Enums.Archetype.VANGUARDA
@export var origin: Enums.Origin = Enums.Origin.TECNOLOGICA
@export var class_name_custom: String = ""
@export var history: String = ""

# Core data
@export var attributes: AttributesData = AttributesData.new()
@export var stats: StatsData = StatsData.new()

# Narrative
@export var appearance: String = ""
@export var backstory: String = ""
@export var affiliations: String = ""
@export var objectives: String = ""
@export var personality: String = ""
@export var fears: String = ""

# Progression
@export var subclasses: Array[String] = []
@export var subraces: Array[String] = []
@export var titles: Array[String] = []      # Max 3 active
@export var proficiencies: Array[String] = []
@export var skills: Array[String] = []
@export var talents: Array[String] = []

# References
@export var equipped_ability_ids: Array[String] = []
@export var equipment_ids: Array[String] = []
@export var companion_ids: Array[String] = []
@export var inventory: InventoryData = InventoryData.new()

# Display & Metadata
@export var portrait_path: String = ""
@export var description: String = ""
@export var custom_fields: Dictionary = {}
@export var resource_version: int = 1
@export var app_version: String = ""
@export var created_at: String = ""
@export var updated_at: String = ""

func recalculate_stats() -> void:
	if attributes and stats:
		stats.recalculate(attributes, archetype, level, origin)

# Returns a StatsData-equivalent dict with base stats + equipment modifiers applied.
# Use this for display; does NOT mutate stats permanently.
func get_total_stats() -> Dictionary:
	if not stats:
		return {}
	var base := {
		"hp_max": stats.hp_max, "hp_current": stats.hp_current,
		"san_max": stats.san_max, "san_current": stats.san_current,
		"energy_max": stats.energy_max, "energy_current": stats.energy_current,
		"precision": stats.precision, "speed_pct": stats.speed_pct,
		"def_deflexao": stats.def_deflexao, "def_reflexos": stats.def_reflexos,
		"def_mental": stats.def_mental, "def_fortitude": stats.def_fortitude,
	}
	if inventory:
		var modifiers := inventory.get_equipment_stat_modifiers()
		for key in modifiers:
			if base.has(key):
				base[key] += modifiers[key]
	return base

func validate() -> Array[String]:
	var errors: Array[String] = []
	if sheet_type == Enums.SheetType.CHARACTER:
		if character_name.is_empty(): errors.append("Nome é obrigatório")
		if level < 1: errors.append("Nível mínimo é 1")
		if race.is_empty(): errors.append("Raça é obrigatória")
		if history.is_empty(): errors.append("Histórico é obrigatório")
	return errors
