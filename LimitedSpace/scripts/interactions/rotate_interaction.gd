extends BaseInteraction

class_name RotateInteraction

@export var required_item: String = ""

@export var angle: Vector3 = Vector3.ZERO
@export var object_to_rotate: Node3D = null
@export var max_times: int = -1

var times: int = 0

func interact() -> bool:
    if required_item == "" or inventory_controller.has_item(required_item):
        if max_times < 0 or times < max_times:
            var tween = get_tree().create_tween()
            tween.tween_property(object_to_rotate, "rotation_degrees", angle, 1)
            tween.play()
    return false
