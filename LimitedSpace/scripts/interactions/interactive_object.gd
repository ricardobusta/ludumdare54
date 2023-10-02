extends Node3D

class_name InteractiveObject

const OUTLINE_LAYER_MASK: int = 2

@export var object_name: String = ""
@export var alternative_text: String = "It's an object"

@export var start_disabled: bool = false

@onready var message_controller: MessageController = $"/root/Gameplay/MessageController"

var _interactions: Array[BaseInteraction] = []

func _ready():
    for child in get_children():
        if child is BaseInteraction:
            _interactions.append(child)

    if start_disabled:
        self.visible = false
        self.set_process(false)

func set_outline(outline: bool):
    for child in get_children():
        if child is VisualInstance3D:
            child.set_layer_mask_value(OUTLINE_LAYER_MASK, outline)

func interact() -> bool:
    var result = false

    if _interactions.size() == 0:
        message_controller.show_message(alternative_text)
        return result

    for interaction in _interactions:
        if interaction is BaseInteraction:
            result = result or interaction.interact()

    return result
