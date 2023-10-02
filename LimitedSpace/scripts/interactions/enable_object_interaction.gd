extends BaseInteraction

class_name EnableObjectInteraction

@export var required_item: String = ""

@export var object_to_enable: Node3D = null
@export var enable: bool = true
@export var max_times: int = -1

var times: int = 0

func interact() -> bool:
    if required_item == "" or inventory_controller.has_item(required_item):
        if max_times < 0 or times < max_times:
            object_to_enable.visible = enable
            object_to_enable.set_process(enable)
            object_to_enable.set_physics_process(enable)
    return false