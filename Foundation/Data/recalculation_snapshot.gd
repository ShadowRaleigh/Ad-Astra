class_name RecalculationSnapshot extends Resource

@export var snapshot_time: String = ""
@export var characteristic_versions: Dictionary = {}  # id → version
@export var tree_versions: Dictionary = {}             # id → version
@export var app_version: String = ""
