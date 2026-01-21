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
	loadc	0	# const
	loadr	0	# adr x (0/0)
	dec	2	# p - 2 - offset
	stores	# assign
	loadr	0	# new SL for Outer
	call	FKT_1	# call Outer
	loadr	0	# adr x (0/0)
	dec	2	# p - 2 - offset
	loads
	write
	call	RAM_DOWN	# stackframe loeschen
	return
FKT_1	loadc	1	# nvar
	call	RAM_UP	# stackframe anlegen
	loadc	1	# const
	loadr	0	# adr i (0/0)
	dec	2	# p - 2 - offset
	stores	# assign
L_104179147789056	nop
	loadr	0	# adr i (0/0)
	dec	2	# p - 2 - offset
	loads
	loadc	7	# const
	cmple
	jumpz	L_104179147790000	# if 0 -> jump
	loadr	0	# adr i (0/0)
	dec	2	# p - 2 - offset
	loads
	loadc	3	# const
	cmpge
	jumpz	L_104179147789632	# if 0 -> jump
	loadr	0	# new SL for IncBy
	call	FKT_2	# call IncBy
L_104179147789632	nop
	loadr	0	# adr i (0/0)
	dec	2	# p - 2 - offset
	loads
	loadc	1	# const
	add
	loadr	0	# adr i (0/0)
	dec	2	# p - 2 - offset
	stores	# assign
	jump	L_104179147789056	# goto
L_104179147790000	nop
	call	RAM_DOWN	# stackframe loeschen
	return
FKT_2	loadc	1	# nvar
	call	RAM_UP	# stackframe anlegen
	loadr	0	# adr i (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	loadr	0	# adr k (0/0)
	dec	2	# p - 2 - offset
	stores	# assign
	loadr	0	# adr x (2/0)
	loads	# follow SL
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	loadr	0	# adr k (0/0)
	dec	2	# p - 2 - offset
	loads
	add
	loadr	0	# adr x (2/0)
	loads	# follow SL
	loads	# follow SL
	dec	2	# p - 2 - offset
	stores	# assign
	call	RAM_DOWN	# stackframe loeschen
	return
