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
FKT_0	loadc	3	# nvar
	call	RAM_UP	# stackframe anlegen
	read
	loadr	0	# adr n (0/0)
	dec	2	# p - 2 - offset
	stores	# store input
	loadr	0	# new SL for Outer
	call	FKT_1	# call Outer
	loadr	0	# adr fact (0/1)
	dec	3	# p - 2 - offset
	loads
	loadr	0	# adr checksum (0/2)
	dec	4	# p - 2 - offset
	loads
	add
	write
	call	RAM_DOWN	# stackframe loeschen
	return
FKT_1	loadc	1	# nvar
	call	RAM_UP	# stackframe anlegen
	loadc	1	# const
	loadr	0	# adr fact (1/1)
	loads	# follow SL
	dec	3	# p - 2 - offset
	stores	# assign
	loadr	0	# new SL for Fak
	call	FKT_2	# call Fak
	loadr	0	# new SL for LoopChecksum
	call	FKT_3	# call LoopChecksum
	call	RAM_DOWN	# stackframe loeschen
	return
FKT_2	loadc	0	# nvar
	call	RAM_UP	# stackframe anlegen
	loadr	0	# adr n (2/0)
	loads	# follow SL
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	loadc	1	# const
	cmpgt
	jumpz	L_94850576730000	# if 0 -> jump
	loadr	0	# adr fact (2/1)
	loads	# follow SL
	loads	# follow SL
	dec	3	# p - 2 - offset
	loads
	loadr	0	# adr n (2/0)
	loads	# follow SL
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	mult
	loadr	0	# adr fact (2/1)
	loads	# follow SL
	loads	# follow SL
	dec	3	# p - 2 - offset
	stores	# assign
	loadr	0	# adr n (2/0)
	loads	# follow SL
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	loadc	1	# const
	sub
	loadr	0	# adr n (2/0)
	loads	# follow SL
	loads	# follow SL
	dec	2	# p - 2 - offset
	stores	# assign
	loadr	0	# new SL for Fak
	loads
	call	FKT_2	# call Fak
L_94850576730000	nop
	call	RAM_DOWN	# stackframe loeschen
	return
FKT_3	loadc	0	# nvar
	call	RAM_UP	# stackframe anlegen
	loadc	1	# const
	loadr	0	# adr tmp (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	stores	# assign
	loadc	0	# const
	loadr	0	# adr checksum (2/2)
	loads	# follow SL
	loads	# follow SL
	dec	4	# p - 2 - offset
	stores	# assign
L_94850576730384	nop
	loadr	0	# adr tmp (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	loadc	10	# const
	cmple
	jumpz	L_94850576731648	# if 0 -> jump
	loadr	0	# adr tmp (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	loadc	2	# const
	mod
	loadc	0	# const
	cmpne
	jumpz	L_94850576731280	# if 0 -> jump
	loadr	0	# adr checksum (2/2)
	loads	# follow SL
	loads	# follow SL
	dec	4	# p - 2 - offset
	loads
	loadr	0	# adr tmp (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	add
	loadr	0	# adr checksum (2/2)
	loads	# follow SL
	loads	# follow SL
	dec	4	# p - 2 - offset
	stores	# assign
L_94850576731280	nop
	loadr	0	# adr tmp (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	loads
	loadc	1	# const
	add
	loadr	0	# adr tmp (1/0)
	loads	# follow SL
	dec	2	# p - 2 - offset
	stores	# assign
	jump	L_94850576730384	# goto
L_94850576731648	nop
	call	RAM_DOWN	# stackframe loeschen
	return
