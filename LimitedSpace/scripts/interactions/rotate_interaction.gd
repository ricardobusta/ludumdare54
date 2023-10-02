extends BaseInteraction

class_name RotateInteraction

@export var required_item: String = ""

@export var angle: Vector3 = Vector3.ZERO
@export var object_to_rotate: Node3D = null
@export var max_times: int = -1

@export var using_message: String = "You got it"
@export var requirement_message: String = "You need something"
@export var used_message: String = "It's empty"

var times: int = 0

func interact() -> bool:
    if required_item == "" or inventory_controller.has_item(required_item):
        if max_times < 0 or times < max_times:
            times += 1
            message_controller.show_message(using_message)
            var tween = get_tree().create_tween()
            tween.tween_property(object_to_rotate, "rotation_degrees", angle, 1)
            tween.play()
        else:
            message_controller.show_message(used_message)
    else:
        message_controller.show_message(requirement_message)
    return false
