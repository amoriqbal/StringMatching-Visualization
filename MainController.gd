extends VBoxContainer

var Inputa:TextEdit
var Inputb:TextEdit
var Table:GridContainer
export(PackedScene) var TableCellResource

var algoObj:Algo
var thread
var semaphore
var should_stop
signal should_stop_signal
signal update_table(ca,cb,value)


class Algo:
	var signals
	var stra:String
	var strb:String
	var table
	var currenta
	var currentb
	var matched
	func _init(a:String ,b:String,signals):
		self.signals=signals
		self.stra=a
		self.strb=b
		self.table=[]

		for i in range(strb.length()):
			self.table.append([])
			for j in range(stra.length()):
				self.table[-1].append(0)
			
		self.currenta=0
		self.currentb=0
	
	func next_step():
		if self.currentb<self.strb.length():
			loop2()
		else:
			signals.emit_signal('should_stop_signal')
			print("TIMER STOP SIGNAL")
			
	func loop2():
		if self.currenta<self.stra.length():
			self.matched=false
			if self.currentb==0:
				if(self.currenta==0):
					if(self.stra[self.currenta]==self.strb[self.currentb]):
						self.table[self.currentb][self.currenta]=1
						self.matched=true
					else:
						self.table[self.currentb][self.currenta]=0
				else:
					if(self.stra[self.currenta]==self.strb[self.currentb]):
						self.table[self.currentb][self.currenta]=1+self.table[self.currentb][self.currenta-1]
						self.matched=true
					else:
						self.table[self.currentb][self.currenta]=self.table[self.currentb][self.currenta-1]
					
			else:
				if(self.currenta==0):
					if(self.stra[self.currenta]==self.strb[self.currentb]):
						self.table[self.currentb][self.currenta]=1
						self.matched=true
					else:
						self.table[self.currentb][self.currenta]=0
				else:
					if(self.stra[self.currenta]==self.strb[self.currentb]):
						self.matched=true
						self.table[self.currentb][self.currenta]=1+self.table[self.currentb-1][self.currenta-1]
					else:
						self.table[self.currentb][self.currenta]=max(self.table[self.currentb-1][self.currenta],self.table[self.currentb][self.currenta-1])
   
			print("iter A")
			print('currenta={ca} currentb={cb}'.format({"ca":self.currenta,"cb":self.currentb}))			
			signals.emit_signal('update_table',currenta, currentb,String(table[currentb][currenta]))
			self.currenta=(self.currenta+1)
			
		else:
			print("iterB")
			self.currentb=(self.currentb+1)
			self.currenta=0
			
		
func _ready():
	Inputa=$InputsMargin/InputsContainer/StrInputA
	Inputb=$InputsMargin/InputsContainer/StrInputB
	Table=$TableMargin/TableGrid
	

func _on_StartButton_pressed():
	for i in Table.get_children():
		Table.remove_child(i)
	
	algoObj=Algo.new(Inputa.text,Inputb.text,self)
	for i in range((Inputa.text.length()+1)*(Inputb.text.length()+1)):
		var nch=TableCellResource.instance()
		Table.add_child(nch)
		nch.rect_min_size=Vector2(60,50)
		
	for i in range(Inputa.text.length()):
		Table.get_child(i+1).text=Inputa.text[i]
		
	for i in range(Inputb.text.length()):
		Table.get_child((i+1)*(Inputa.text.length()+1)).text=Inputb.text[i]
	Table.columns=Inputa.text.length()+1
	$StepTimer.start()
	


func _on_StepTimer_timeout():
	print("Timer")
	if algoObj:
		algoObj.next_step()
		#$output.set_text(JSON.print(algoObj.table))
		

func _on_VBoxContainer_should_stop_signal():
	$StepTimer.stop()
	print("STOP SIGNAL REGISTERED")
	
	var fin=""
	var j=algoObj.table[0].size()-1
	var i=algoObj.table.size()-1
	while(true):
		if(j==0 or i==0):
			if algoObj.table[i][j] > 0:
				while(i>0 && algoObj.table[i-1][j]>0):
					i=i-1
				while(j>0 && algoObj.table[i][j-1]>0):
					j=j-1
				fin=algoObj.strb[i]+fin
			break
		
		if(algoObj.table[i-1][j]==algoObj.table[i][j]):
			i=i-1
			continue
			
		if(algoObj.table[i][j-1]==algoObj.table[i][j]):
			j=j-1
			continue
			
		fin=algoObj.strb[i]+fin
		i=i-1
		j=j-1
	$output.text=fin



func _on_VBoxContainer_update_table(ca,cb, value):
	var ci=(cb+1)*(algoObj.stra.length()+1)+(ca+1)
	if(ci<Table.get_child_count()):
		Table.get_child(ci).set_text(String(value if (typeof(value)==typeof("")) else 'null'))
