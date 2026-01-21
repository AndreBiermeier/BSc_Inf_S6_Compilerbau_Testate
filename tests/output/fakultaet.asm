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
	loadr	0	# adr n (0/0)
	dec	2	# p - 2 - offset
	stores	# store input
	loadc	1	# const
	loadr	0	# adr f (0/1)
	dec	3	# p - 2 - offset
	stores	# assign
	loadr	0	# new SL for fak
	call	FKT_1	# call fak
	loadr	0	# adr f (0/1)
	dec	3	# p - 2 - offset
	loads
	write
	call	RAM_DOWN	# stackframe loeschen
	return
FKT_1	loadc	0	# nvar
	call	RAM_UP	# stackframe anlegen
	loadr	0	# adr n (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	loadc	0	# const
	cmpgt
	jumpz	L_104134032890512	# if 0 -> jump
	loadr	0	# adr f (1/1)
	loads	# follow SL
	dec	3	# p - 2 - offset
	loads
	loadr	0	# adr n (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	mult
	loadr	0	# adr f (1/1)
	loads	# follow SL
	dec	3	# p - 2 - offset
	stores	# assign
	loadr	0	# adr n (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	loadc	1	# const
	sub
	loadr	0	# adr n (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	stores	# assign
	loadr	0	# new SL for fak
	loads
	call	FKT_1	# call fak
	loadr	0	# adr n (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	loadc	1	# const
	add
	loadr	0	# adr n (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	stores	# assign
L_104134032890512	nop
	call	RAM_DOWN	# stackframe loeschen
	return
