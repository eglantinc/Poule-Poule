# TP1 - Programmation du jeu Poule-Poule
# Églantine Anne Clervil - CLEE89530109 (groupe 011)
# Nawal Tatari - TATN21598407 (groupe 011)
#
# Ce programme est un jeu inspiré du concept du jeu poule-poule. 
# Les règles du jeu impliquent l'utilisation de cartes représentées par des 
# caractères (lettres minuscules et chiffres). Une carte œuf (lettre 'o')
# ajoute un œuf au jeu. Le jeu commence avec aucun œuf.
# Une carte d'affichage (lettre 'a') affiche le nombre d'œufs disponibles.
# Une carte coq (lettre 'q') termine le programme. Chaque lettre peut être
# préfixée par un multiplicateur (0 à 9) indiquant la quantité de cartes. 
# Une carte poule (lettre 'p') couve un œuf le rendant indisponible. 
# Sinon, elle ne fait rien. Une carte renard (lettre 'r') chasse une des poules
# qui couvent un œuf. Si aucune poule n'est en jeu, le renard fait rien.
# Une carte chien (lettre 'c') poursuit un renard s'il apparaît. Les autres
# chiens restent en jeu. Une carte ver (lettre 'v') reste en jeu et est 
# ignorée par les chiens, les renards et les poules. Une nouvelle poule 
# le poursuit sans considérer la disponibilité des œufs. Si un caractère
# autre que ceux mentionnés est entré, le programme affiche 'Err' et se termine.
# Le code Extra: grand multiplicateur n'a pas été implémenté.

	.eqv PrintInt, 1
	.eqv PrintChar, 11
	.eqv ReadChar, 12
	.eqv Exit, 10
	
	li s0, 0			# compteur d'oeufs
	li s1, 0			# compteur de poules
	li s2, 0			# compteur de chiens
	li s3, 0			# compteur de vers	
	
	# Initialiser le chiffre courant à 1, pour gérer les cas multiple et non multiple
	li t1, 1
  	li s4, 1			# Variable pour réinitialiser t1

loop:
	li a7, ReadChar
	ecall
 	
	li t0, 'q' 
	beq a0, t0, fin			# Si le caractère lu est 'q', le jeu se termine		

	li t0, 'a'
	bne a0, t0, case_multip		# Si le caractère lu est 'a', affiche
	beqz t1, loop			# Si dans le cas multiple aucun affichage n'est demandé
	j affiche_oeuf
	
case_multip:
	# Vérification des chiffres
	li t0, '0'
	blt a0, t0, case_erreur		# Si le caractère est inférieur à '0', erreur
	li t0, '9'
	bgt a0, t0, case_oeuf		# Si le caractère est supérieur à '9', aller au cas suivant
	addi a0, a0, -48		# Convertir de la représentation ASCII à la valeur décimale
	mv t1, a0			# Stocker le chiffre courant
	j loop	

case_oeuf:
	li t0, 'o'
	bne t0, a0, case_poule		# Si a0 != 'o', verifier le prochain caractère
	j ajouter_oeuf

case_poule:
	li t0, 'p'
	bne t0, a0, case_renard		# Si a0 != 'p', verifier le prochain caractère
	bgtz s3, diminuer_ver		# S'il y a des vers dans le jeu, les diminuer
	bgtz s0, diminuer_oeuf		# Sinon s'il y a des oeufs, diminuer
	mv t1, s4			# Réinitialiser t1 a 1
	j loop
	
case_renard:
	li t0 'r'
	bne t0, a0, case_chien		# Si a0 != 'r', verifier le prochain caractère
	bgtz s2, diminuer_chien
	bgtz s1, diminuer_poule		# S'il y a des poules couvrant des oeufs, decrementer les cartes poule
	mv t1, s4
	j loop

case_chien:
	li t0, 'c'
	bne t0, a0, case_ver		# Si a0 != 'c', verifier le prochain caractère	
	add s2, s2, t1			# Incrémenter le nombre de cartes de chien
	mv t1, s4
	j loop
	
case_ver:
	li t0, 'v'
	bne t0, a0, case_erreur		# Si a0 != 'v', affiche erreur
	add s3, s3, t1			# Incrémenter le nombre de cartes de ver
	mv t1, s4
	j loop

ajouter_oeuf:
	add s0, s0, t1			# Incrémenter le nombre d'oeufs avec le chiffre courant
	bltz s1, reinitialiser_poule 
	mv t1, s4			# Réinitialiser le chiffre courant a 1
	j loop   

ajouter_poule:
	add s1, s1, t1			# Incrémenter le nombre de poules avec le chiffre courant
	bltz s0, reinitialiser_oeuf	# Si le nombre d'oeufs est négatif, réinitialiser oeuf
	mv t1, s4
	j loop
	
diminuer_oeuf:
	sub s0, s0, t1			# Diminuer le nombre d'oeufs avec le chiffre courant
	j ajouter_poule

diminuer_poule:
	sub s1, s1, t1
	j ajouter_oeuf
	
diminuer_chien:
	sub s2, s2, t1
	bltz s2, reinitialiser_chien
	mv t1, s4
	j loop

diminuer_ver:
	sub s3, s3, t1
	bltz s3, reinitialiser_ver
	mv t1, s4
	j loop  

reinitialiser_oeuf:
	add s1, s0, s1			# Tenir compte seulement des poules qui couvrent des oeufs
	sub s0, s0, s0			# Reinitialiser le nombre d'oeufs a 0
	mv t1, s4
	j loop

reinitialiser_poule:
	# Ajuster le nombre d'oeuf, enlever les excédents engendrés par t1
	add s0, s0, s1			
	sub s1, s1, s1			# Réinitialiser le nombre de poules à 0
	mv t1, s4
	j loop

reinitialiser_chien:
	add s1, s1, s2			# Ajuster le nombre de poules, enlever les excédents engendrés par t1
	sub s0, s0, s2			# Ajuster le nombre d'oeufs, gérer les excédents
	sub s2, s2, s2			# Réinitialise à 0
	bltz s1, diminuer_poule		# Si le nombre de poule est négatif, ajuster la valeur
	mv t1, s4
	j loop
	
reinitialiser_ver:
	add s0, s0, s3			
	sub s1, s1, s3 			# Ajuster le nombre de poules total apres diminution
	sub s3, s3, s3			
	bltz s0, diminuer_oeuf		
	mv t1, s4
	j loop
 					
case_erreur:
	li a7, PrintChar
	li a0, 'E'
	ecall
	li a0, 'r'
	ecall
	li a0, 'r'
	ecall
	j fin

affiche_oeuf:
	addi t1, t1, -1			# Décrementer le t1
	li a7, PrintInt
	mv a0, s0
	ecall
	
	li a7, PrintChar
	li a0, '\n'
	ecall
	
	bgtz t1, affiche_oeuf		# Tant qu'on a besoin d'afficher les oeufs
	mv t1, s4
	j loop

fin:	li a7, Exit
	ecall
