extends CanvasLayer

@onready var animation_player = $AnimationPlayer

func change_scene(target_scene: String):
	# 1. เล่นแอนิเมชันเฟดให้จอมืด
	animation_player.play("Fade")
	
	# 2. รอจนกว่าแอนิเมชันจะเล่นจบ
	await animation_player.animation_finished 
	
	# 3. สั่งเปลี่ยนฉาก
	get_tree().change_scene_to_file(target_scene)
	
	# 4. เล่นแอนิเมชันย้อนกลับ (ค่อยๆ สว่างขึ้น)
	animation_player.play_backwards("Fade")
