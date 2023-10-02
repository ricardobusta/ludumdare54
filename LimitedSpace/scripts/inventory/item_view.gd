extends Node

class_name ItemView

@export var icon_texture_rect: TextureRect = null
@export var amount_label: Label = null

func set_amount(amount: int):
    amount_label.text = "x%s" % amount

func set_icon(texture: Texture2D):
    icon_texture_rect.texture = texture
