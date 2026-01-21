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
FKT_0	loadc	1	# nvar
	call	RAM_UP	# stackframe anlegen
	read
	loadr	0	# adr a (0/0)
	dec	2	# p - 2 - offset
	stores	# store input
	loadr	0	# adr a (0/0)
	dec	2	# p - 2 - offset
	loads
	loadc	0	# const
	cmplt
	jumpz	L_107088993360320	# if 0 -> jump
	loadr	0	# adr a (0/0)
	dec	2	# p - 2 - offset
	loads
	chs
	loadr	0	# adr a (0/0)
	dec	2	# p - 2 - offset
	stores	# assign
L_107088993360320	nop
	loadr	0	# adr a (0/0)
	dec	2	# p - 2 - offset
	loads
	write
	call	RAM_DOWN	# stackframe loeschen
	return
