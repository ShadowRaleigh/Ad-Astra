class_name TreeNodeData extends Resource

@export var node_id: String = ""
@export var characteristic: CharacteristicData = null
@export var floor_index: int = 0
@export var grid_position: Vector2i = Vector2i.ZERO
@export var connections_out: Array[String] = []  # node_ids this connects TO
