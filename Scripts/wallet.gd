extends ItemList

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

#Update money
func update_money(revenue):
	#Money declaraction
	var cp = CP
	var sp = SP
	var gp = GP
	var pp = PP
			
	cp += revenue
	if cp > 99:
		@warning_ignore("integer_division") #IT IS INTENDED TO DISCARD THE DECIMAL PART IN THIS CASE
		sp += int(cp/100)
		cp = fmod(cp,100)
	if sp > 99:
		@warning_ignore("integer_division") #IT IS INTENDED TO DISCARD THE DECIMAL PART IN THIS CASE
		gp += int(sp/100)
		sp = fmod(sp,100)
	if gp > 99:
		@warning_ignore("integer_division") #IT IS INTENDED TO DISCARD THE DECIMAL PART IN THIS CASE
		pp += int(gp/100)
		gp = fmod(gp,100)
	
	CP = cp
	SP = sp
	GP = gp
	PP = pp
	update_money_wallet()
	

	#print("CP: ",CP,"SP: ",SP ,"GP: ",GP, "PP: ",pp)
	
