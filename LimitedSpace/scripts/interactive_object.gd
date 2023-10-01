extends Node3D

class_name InteractiveObject

const OUTLINE_LAYER: int = 2

@export var object_name: String = ""
@export var object_description: String = ""

func set_outline(visible: bool):
    for child in get_children():
        if child is VisualInstance3D:
            child.set_layer_mask_value(OUTLINE_LAYER, visible)


