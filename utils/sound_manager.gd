class_name SoundManager
extends Node

@onready var sounds : Array[AudioStreamPlayer2D] = [$SFXAttack1, $SFXAttack2, $SFXAttack3, $SFXPowerMove, $SFXHurt, $SFXFwehh, $SFXZoom]

enum Sound {ATTACK1, ATTACK2, ATTACK3, POWERMOVE, HURT, FWEHH, ZOOM}

func play(sfx: Sound, tweak_pitch :bool = false) -> void: 
	var added_pitch := 0 
	if tweak_pitch: 
		added_pitch = randf_range(-0.3, 0.3)
	sounds[sfx as int].pitch_scale = 1 + added_pitch
	sounds[sfx as int].play()
