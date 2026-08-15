extends "res://Scripts/hand_ss.gd"

func firsttime():
	Global.firstBook = 1
	Global.events_done += 1
	Global.books_done += 1
	if Global.books_done >= Global.books_total:
		Global.objectives_done[0] = true
