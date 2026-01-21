	loadc	0	# RAM-INIT
	storer	0
	loadc	0	# Pseudo-SL fuer main
	jump	FKT_0
RAM_UP	loadr	0
	add
	inc	2	# Neuer TOS
	dup
	dec	1
	loadr	0
	swap
	stores	# DL
	dup
	storer	0	# Neuer TOS gesetzt
	stores	# SL gesetzt
	return
RAM_DOWN	loadr	0	# RAM-Abbau
	dec	1
	loads
	storer	0
	return
FKT_0	nop	# main
	loadc	1	# n_var
	call	RAM_UP
140229353668672		read
	loadr	0	# (a l=0 n=0)
	dec	2	#Adresse fertig
	stores
140229353668960		loadr	0	# ( l=0 n=0)
	dec	2	#Adresse fertig
	loads
	loadc	0
	cmplt
	jumpz	140229353669120
140229353668896		loadr	0	# ( l=0 n=0)
	dec	2	#Adresse fertig
	loads
	chs
	loadr	0	# (a l=0 n=0)
	dec	2	#Adresse fertig
	stores
140229353669120		loadr	0	# ( l=0 n=0)
	dec	2	#Adresse fertig
	loads
	write
140229353668608		nop
	call	RAM_DOWN
	return		# Ende Funktion main
