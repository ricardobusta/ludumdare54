extends BaseInteraction

class_name CollectInteraction

@export var required_item: String = ""
@export var consume_required: bool = true
@export var required_amount: int = 1
@export var collect_item: String = ""
@export var contains_amount: int = -1
@export var collect_amount: int = 1

@export var collect_message: String = "You got it"
@export var requirement_message: String = "You need something"
@export var emptied_message: String = "It's empty"

@export var destroy_on_emptied: Node3D = null

func interact() -> bool:
    if required_item != "":
        if inventory_controller.item_amount(required_item) < required_amount:
            message_controller.show_message(requirement_message)
            return false

        if consume_required:
            inventory_controller.remove_item(required_item, required_amount)

    if contains_amount != 0:
        if collect_item != "":
            inventory_controller.add_item(collect_item, collect_amount)
        message_controller.show_message(collect_message)

        if contains_amount > 0:
            contains_amount -= collect_amount

        if contains_amount == 0 and destroy_on_emptied:
            destroy_on_emptied.queue_free()
            return true

        return false
    else:
        message_controller.show_message(emptied_message)
        return false

