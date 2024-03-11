extends Node2D

class_name PopUpAnimation

export(NodePath) onready var text_label = get_node(text_label) as RichTextLabel
export(NodePath) onready var animation_player = get_node(animation_player) as AnimationPlayer


func stop_animation():
	""""""
	self.text_label.visible = false
	self.animation_player.stop()


func start_animation(pop_up_text, color: Color):
	self.text_label.visible = true
	self.text_label.text = pop_up_text
	self.text_label.modulate = color
	self.animation_player.play("pop")

	var stop_timer = Timer.new()
	stop_timer.set_wait_time(.4)
	stop_timer.one_shot = true
	stop_timer.connect("timeout", self, "stop_animation")
	add_child(stop_timer)
	stop_timer.start()
