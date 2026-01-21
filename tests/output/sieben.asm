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
FKT_0	loadc	0	# nvar
	call	RAM_UP	# stackframe anlegen
	loadc	1	# const
	loadc	2	# const
	loadc	3	# const
	mult
	add
	write
	call	RAM_DOWN	# stackframe loeschen
	return
