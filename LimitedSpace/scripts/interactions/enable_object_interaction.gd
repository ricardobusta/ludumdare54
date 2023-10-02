extends BaseInteraction

class_name EnableObjectInteraction

@export var required_item: String = ""

@export var object_to_enable: Node3D = null

func _ready():
    object_to_enable.visible = false
    object_to_enable.set_process(false)

func interact() -> bool:
    if inventory_controller.has_item(required_item):
        object_to_enable.visible = true
        object_to_enable.set_process(true)
    return false
