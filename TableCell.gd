extends Label

var cols=[Color.teal,Color.crimson,Color.darkcyan,Color.maroon,Color.darkgreen,Color.seagreen]

func set_text(t:String):
	text=t
	$ColorRect.color=cols[t.hash()%cols.size()]
