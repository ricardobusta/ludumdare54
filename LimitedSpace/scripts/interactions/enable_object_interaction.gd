extends BaseInteraction

class_name EnableObjectInteraction

@export var required_item: String = ""

@export var object_to_enable: Node3D = null
@export var enable: bool = true
@export var max_times: int = -1

var times: int = 0

var _parent: Node = null

func _ready():
    _parent = object_to_enable.get_parent()

func interact() -> bool:
    if required_item == "" or inventory_controller.has_item(required_item):
        if max_times < 0 or times < max_times:
            times += 1
            object_to_enable.visible = enable
            object_to_enable.set_process(enable)
            if enable:
                _parent.add_child(object_to_enable)
                print("add %s to %s" % [object_to_enable.name, _parent.name])
            else:
                _parent.remove_child.call_deferred(object_to_enable)
    return false
