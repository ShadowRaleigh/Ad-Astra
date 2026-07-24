class_name Enums

enum SheetType {CHARACTER, CREATURE}
enum Origin {TECNOLOGICA, MISTICA, MARCIAL, TRANSCENDENTAL}
enum EnergyType {BATERIA, MANA, QI, PE}
enum CharacteristicType {OFENSIVA, TATICA, SUPORTE}
enum CharacteristicTag {MAGIC}

const ORIGIN_ENERGY := {
	Origin.TECNOLOGICA: EnergyType.BATERIA,
	Origin.MISTICA: EnergyType.MANA,
	Origin.MARCIAL: EnergyType.QI,
	Origin.TRANSCENDENTAL: EnergyType.PE,
}

# Energy per level: d10 for most, flat 2 for Transcendental
const ENERGY_DIE := {Origin.TECNOLOGICA: 10, Origin.MISTICA: 10, Origin.MARCIAL: 10, Origin.TRANSCENDENTAL: 0}
const PE_PER_LEVEL := 2

enum Archetype {
	VANGUARDA, INICIADOR, ADAPTADOR, ARTIFICE,
	SENTINELA, VINCULADOR, INTERVENTOR, PROJETOR
}

const ARCHETYPE_HIT_DIE := {
	Archetype.VANGUARDA: 12, Archetype.INICIADOR: 10, Archetype.ADAPTADOR: 10,
	Archetype.ARTIFICE: 10, Archetype.SENTINELA: 8, Archetype.VINCULADOR: 8,
	Archetype.INTERVENTOR: 8, Archetype.PROJETOR: 6,
}

# Archetype base defense values: { Deflexão, Fortitude, Reflexos, Mental }
const ARCHETYPE_BASE_DEF := {
	Archetype.VANGUARDA: {"deflexao": 40, "fortitude": 15, "reflexos": 5, "mental": 10},
	Archetype.INICIADOR: {"deflexao": 25, "fortitude": 10, "reflexos": 15, "mental": 10},
	Archetype.ADAPTADOR: {"deflexao": 35, "fortitude": 5, "reflexos": 10, "mental": 10},
	Archetype.ARTIFICE: {"deflexao": 30, "fortitude": 10, "reflexos": 10, "mental": 10},
	Archetype.SENTINELA: {"deflexao": 25, "fortitude": 10, "reflexos": 15, "mental": 10},
	Archetype.VINCULADOR: {"deflexao": 25, "fortitude": 10, "reflexos": 10, "mental": 15},
	Archetype.INTERVENTOR: {"deflexao": 30, "fortitude": 10, "reflexos": 10, "mental": 10},
	Archetype.PROJETOR: {"deflexao": 20, "fortitude": 10, "reflexos": 20, "mental": 20},
}

# Syncronia slots: { level: [common, special] }
const ARCHETYPE_SYNCRONIA := {
	Archetype.VANGUARDA: {1: [2, 0], 10: [3, 1], 50: [4, 2], 80: [6, 2]},
	Archetype.INICIADOR: {1: [2, 0], 10: [4, 0], 50: [5, 1], 80: [6, 2]},
	Archetype.ADAPTADOR: {1: [2, 0], 10: [3, 1], 50: [4, 2], 80: [5, 3]},
	Archetype.ARTIFICE: {1: [1, 1], 10: [2, 2], 50: [3, 3], 80: [4, 4]},
	Archetype.SENTINELA: {1: [2, 0], 10: [3, 1], 50: [4, 2], 80: [5, 3]},
	Archetype.VINCULADOR: {1: [1, 1], 10: [3, 1], 50: [4, 2], 80: [5, 3]},
	Archetype.INTERVENTOR: {1: [2, 0], 10: [3, 1], 50: [4, 2], 80: [5, 3]},
	Archetype.PROJETOR: {1: [2, 0], 10: [3, 1], 50: [5, 1], 80: [6, 2]},
}

enum Tier {TIER_1 = 1, TIER_2 = 2, TIER_3 = 3, TIER_4 = 4, TIER_5 = 5}
const TIER_MIN_LEVELS := {Tier.TIER_1: 1, Tier.TIER_2: 10, Tier.TIER_3: 30, Tier.TIER_4: 60, Tier.TIER_5: 80}

static func get_tier(level: int) -> Tier:
	if level >= 80: return Tier.TIER_5
	if level >= 60: return Tier.TIER_4
	if level >= 30: return Tier.TIER_3
	if level >= 10: return Tier.TIER_2
	return Tier.TIER_1

static func get_ql_count(level: int) -> int:
	return int(level / 10.0)

# PH: 1 at levels ending in 5 (5,15,25...) + 2 at each QL (10,20,30...) = 30 at Lv100
static func get_total_ph(level: int) -> int:
	var ph := 0
	for lv in range(1, level + 1):
		if lv % 10 == 5:
			ph += 1
		elif lv % 10 == 0:
			ph += 2
	return ph

# Ability base costs (exact from docs)
const ABILITY_BASE_COST_SIMPLE := {
	Tier.TIER_1: 8, Tier.TIER_2: 20, Tier.TIER_3: 40, Tier.TIER_4: 65, Tier.TIER_5: 80,
}
const ABILITY_BASE_COST_SPECIAL := {
	Tier.TIER_1: 16, Tier.TIER_2: 35, Tier.TIER_3: 60, Tier.TIER_4: 100, Tier.TIER_5: 125,
}

# Effects per tier: [simple, special]
const EFFECTS_PER_TIER := {
	Tier.TIER_1: [1, 2], Tier.TIER_2: [2, 3], Tier.TIER_3: [3, 5],
	Tier.TIER_4: [4, 6], Tier.TIER_5: [5, 8],
}

# Area by tier: { circle_radius, square_side, cone_length }
const AREA_BY_TIER := {
	Tier.TIER_1: {"circle": 2, "square": 3, "cone": 2},
	Tier.TIER_2: {"circle": 4, "square": 7, "cone": 6},
	Tier.TIER_3: {"circle": 6, "square": 11, "cone": 10},
	Tier.TIER_4: {"circle": 9, "square": 16, "cone": 16},
	Tier.TIER_5: {"circle": 11, "square": 18, "cone": 20},
}

enum EquipmentCategory {CAT_1, CAT_2, CAT_3, CAT_4, CAT_5}
const EQUIP_CAT_MIN_LEVEL := {
	EquipmentCategory.CAT_1: 1, EquipmentCategory.CAT_2: 10,
	EquipmentCategory.CAT_3: 30, EquipmentCategory.CAT_4: 60, EquipmentCategory.CAT_5: 80,
}

enum ItemRarity {COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}

# Weapon damage by category
const WEAPON_DAMAGE := {
	EquipmentCategory.CAT_1: "1d8", EquipmentCategory.CAT_2: "2d10",
	EquipmentCategory.CAT_3: "2d12", EquipmentCategory.CAT_4: "4d8", EquipmentCategory.CAT_5: "4d10",
}

# Weapon precision: [Common, Uncommon, Rare, Epic, Legendary]
const WEAPON_PRECISION := {
	EquipmentCategory.CAT_1: [0, 5, 10, 15, 20],
	EquipmentCategory.CAT_2: [5, 10, 15, 20, 25],
	EquipmentCategory.CAT_3: [10, 15, 20, 25, 30],
	EquipmentCategory.CAT_4: [15, 20, 25, 30, 35],
	EquipmentCategory.CAT_5: [20, 25, 30, 35, 40],
}

# Armor deflection: [Common, Uncommon, Rare, Epic, Legendary]
const ARMOR_DEFLECTION := {
	EquipmentCategory.CAT_1: [0, 1, 2, 3, 4],
	EquipmentCategory.CAT_2: [1, 2, 3, 4, 5],
	EquipmentCategory.CAT_3: [2, 3, 4, 5, 6],
	EquipmentCategory.CAT_4: [3, 4, 5, 6, 7],
	EquipmentCategory.CAT_5: [4, 5, 6, 7, 8],
}

enum D100Result {ERRO, DE_RASPAO, ACERTO, CRITICO, CRITICO_DUPLO}
const D100_DAMAGE_MULT := {
	D100Result.ERRO: 0.0, D100Result.DE_RASPAO: 0.5, D100Result.ACERTO: 1.0,
	D100Result.CRITICO: 1.5, D100Result.CRITICO_DUPLO: 2.0,
}
