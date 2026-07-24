extends GraphNode

@onready var char_label: Label = %CharacteristicLabel
@onready var floor_spinbox: SpinBox = %FloorSpinBox
@onready var assign_button: Button = %AssignCharButton
@onready var desc_label: Label = %DescLabel
@onready var cost_factor_label: Label = %CostFactorLabel
@onready var material_cost_label: Label = %MaterialCostLabel

signal assign_characteristic_requested(node: GraphNode)

var node_data: TreeNodeData:
	set(value):
		node_data = value
		if is_node_ready():
			_update_display()

func _ready() -> void:
	# Set up slots for GraphEdit to connect to
	# Slot 0: left (input), right (output)
	set_slot(0, true, 0, Color.GREEN, true, 0, Color.YELLOW)
	
	assign_button.pressed.connect(_on_assign_pressed)
	floor_spinbox.value_changed.connect(_on_floor_changed)
	_update_display()

func _update_display() -> void:
	if node_data and node_data.characteristic:
		var c_name = node_data.characteristic.characteristic_name.capitalize()
		char_label.text = c_name
		title = c_name
		desc_label.text = node_data.characteristic.description
		cost_factor_label.text = "Fator de Custo: " + str(node_data.characteristic.cost_factor)
		material_cost_label.text = "Custo Material: " + str(node_data.characteristic.material_cost)
		desc_label.show()
		cost_factor_label.show()
		material_cost_label.show()
	else:
		char_label.text = "(Sem Característica)"
		title = "(Vazio)"
		desc_label.hide()
		cost_factor_label.hide()
		material_cost_label.hide()
	if node_data:
		floor_spinbox.value = node_data.floor_index

func _on_assign_pressed() -> void:
	emit_signal("assign_characteristic_requested", self )

func _on_floor_changed(value: float) -> void:
	if node_data:
		node_data.floor_index = int(value)
