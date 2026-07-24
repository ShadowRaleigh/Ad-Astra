class_name TreeData extends Resource

@export var tree_id: String = ""
@export var tree_name: String = ""
@export var nodes: Array[TreeNodeData] = []
@export var resource_version: int = 1

func get_node_by_id(id: String) -> TreeNodeData:
	for node in nodes:
		if node.node_id == id: return node
	return null

func validate() -> Array[String]:
	var errors: Array[String] = []
	var ids := {}
	for node in nodes:
		if node.node_id in ids:
			errors.append("ID duplicado: %s" % node.node_id)
			
		ids[node.node_id] = true
		if not node.characteristic:
			errors.append("Nó %s sem característica" % node.node_id)
		for conn_id in node.connections_out:
			var target_node = get_node_by_id(conn_id)
			if not target_node:
				errors.append("Conexão inválida: %s → %s" % [node.node_id, conn_id])
			else:
				if node.floor_index == target_node.floor_index:
					var name1 = node.characteristic.characteristic_name if node.characteristic else node.node_id
					var name2 = target_node.characteristic.characteristic_name if target_node.characteristic else target_node.node_id
					errors.append("Conexão na mesma altura de Andar detectada: %s → %s" % [name1, name2])
	return errors
