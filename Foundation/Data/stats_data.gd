class_name StatsData extends Resource

@export var hp_max: int = 0
@export var hp_current: int = 0
@export var hp_base: int = 0   # Editable base (rolled or assigned by user)

@export var san_max: int = 0
@export var san_current: int = 0

@export var energy_max: int = 0
@export var energy_current: int = 0
@export var energy_base: int = 0  # Editable base (rolled or assigned by user)

@export var precision: int = 0
@export var speed_pct: float = 100.0

# 4 Defense types (archetype base + attribute bonuses)
@export var def_deflexao: int = 0
@export var def_reflexos: int = 0
@export var def_mental: int = 0
@export var def_fortitude: int = 0

func recalculate(attrs: AttributesData, arch: Enums.Archetype, level: int, origin: Enums.Origin) -> void:
	var hit_die: int = Enums.ARCHETYPE_HIT_DIE.get(arch, 8)
	var base_def: Dictionary = Enums.ARCHETYPE_BASE_DEF.get(arch, {})

	# HP: uses hp_base if set by user, otherwise auto-calculate
	var res_factor := 1.0 + float(attrs.resistencia - 10) * 0.05
	if hp_base > 0:
		hp_max = int(float(hp_base) * res_factor)
	else:
		# Simplified auto: max die at Lv1 + average per subsequent level
		hp_max = int(float(hit_die + int(float(hit_die) / 2.0 + 1.0) * (level - 1)) * res_factor)

	# SAN: 100 + level ± (DET - 10)
	san_max = 100 + level + (attrs.determinacao - 10)
	# Precision: +1/level + PER bonus (+1 per point above 10)
	precision = level + (attrs.percepcao - 10)
	# Speed: base 100% ± DEX bonus (±2%/pt from 10)
	speed_pct = 100.0 + float(attrs.destreza - 10) * 2.0

	# Defenses: archetype base + attribute bonuses
	def_deflexao = base_def.get("deflexao", 0) + (attrs.determinacao - 10) * 1
	def_reflexos = base_def.get("reflexos", 0) + (attrs.destreza - 10) * 2 + (attrs.percepcao - 10) * 2
	def_mental = base_def.get("mental", 0) + (attrs.intelecto - 10) * 2 + (attrs.determinacao - 10) * 2
	def_fortitude = base_def.get("fortitude", 0) + (attrs.resistencia - 10) * 2 + (attrs.poder - 10) * 2

	# Energy: uses energy_base if set by user, otherwise auto-calculate
	if energy_base > 0:
		energy_max = energy_base
	else:
		if origin == Enums.Origin.TRANSCENDENTAL:
			energy_max = Enums.PE_PER_LEVEL * level
		else:
			var avg_energy_die := float(Enums.ENERGY_DIE.get(origin, 10)) / 2.0 + 0.5
			energy_max = int(avg_energy_die * level)

	emit_changed()

# Apply status effects on top of base stats and return modified copy.
# Does NOT mutate this resource's permanent values.
func get_stats_with_effects(effects: Array) -> Dictionary:
	var result := {
		"hp_max": hp_max, "san_max": san_max, "energy_max": energy_max,
		"precision": precision, "speed_pct": speed_pct,
		"def_deflexao": def_deflexao, "def_reflexos": def_reflexos,
		"def_mental": def_mental, "def_fortitude": def_fortitude,
	}
	for effect in effects:
		if effect is StatusEffectData:
			for stat_key in effect.affected_stats:
				if result.has(stat_key):
					result[stat_key] += effect.affected_stats[stat_key]
	return result
