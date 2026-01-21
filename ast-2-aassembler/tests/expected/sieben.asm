	loadc	0	# RAM-INIT
	storer	0	# TOS setzen
	loadc	0	# Pseudo-SL fuer main
	jump	FKT_0	# ==> Startfunktion
	
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
FKT_0	loadc	0	# main n_var=0
	call	RAM_UP
	loadc	1
	loadc	2
	loadc	3
	mult
	add
	write
	call	RAM_DOWN
	return
