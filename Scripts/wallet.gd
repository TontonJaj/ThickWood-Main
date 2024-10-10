extends ItemList

class_name wallet
var CP : int = 0
var SP : int = 0
var GP : int = 0
var PP : int = 0

func _ready():
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

	
