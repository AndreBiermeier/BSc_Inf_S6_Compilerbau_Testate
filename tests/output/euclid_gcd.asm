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
FKT_0	loadc	2	# nvar
	call	RAM_UP	# stackframe anlegen
	read
	loadr	0	# adr a (0/0)
	dec	2	# p - 2 - offset
	stores	# store input
	read
	loadr	0	# adr b (0/1)
	dec	3	# p - 2 - offset
	stores	# store input
	loadr	0	# new SL for GCD
	call	FKT_1	# call GCD
	loadr	0	# adr a (0/0)
	dec	2	# p - 2 - offset
	loads
	write
	call	RAM_DOWN	# stackframe loeschen
	return
FKT_1	loadc	1	# nvar
	call	RAM_UP	# stackframe anlegen
L_108834096059632	nop
	loadr	0	# adr b (1/1)
	loads	# follow SL
	dec	3	# p - 2 - offset
	loads
	loadc	0	# const
	cmpgt
	jumpz	L_108834096060864	# if 0 -> jump
	loadr	0	# adr a (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	loadr	0	# adr a (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	loadr	0	# adr b (1/1)
	loads	# follow SL
	dec	3	# p - 2 - offset
	loads
	div
	loadr	0	# adr b (1/1)
	loads	# follow SL
	dec	3	# p - 2 - offset
	loads
	mult
	sub
	loadr	0	# adr t (0/0)
	dec	2	# p - 2 - offset
	stores	# assign
	loadr	0	# adr b (1/1)
	loads	# follow SL
	dec	3	# p - 2 - offset
	loads
	loadr	0	# adr a (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	stores	# assign
	loadr	0	# adr t (0/0)
	dec	2	# p - 2 - offset
	loads
	loadr	0	# adr b (1/1)
	loads	# follow SL
	dec	3	# p - 2 - offset
	stores	# assign
	jump	L_108834096059632	# goto
L_108834096060864	nop
	call	RAM_DOWN	# stackframe loeschen
	return
