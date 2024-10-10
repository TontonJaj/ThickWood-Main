extends ItemList

class_name wallet
var CP : int = 0
var SP : int = 0
var GP : int = 0
var PP : int = 0

func _on_ready():
	#why no nice ? i dont get it its fucked up maybe onready dont work when in wallet ? anyway me tired i did a thing so good night
	print("nice")
	update_money_wallet()
	
		
func update_money_wallet():
	
	#Money declaraction
	var cp = $".".CP
	var sp = $".".SP
	var gp = $".".GP
	var pp = $".".PP
	#Update the number of coins seen on screen
	$CPQTY.text = str(cp)
	$SPQTY.text = str(sp)
	$GPQTY.text = str(gp)
	$PPQTY.text = str(pp)

	
