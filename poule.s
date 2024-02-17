# TP1 - Programmation du jeu Poule-Poule
# Églantine Anne Clervil - CLEE89530109 (groupe 011)
# Nawal Tatari - TATN21598407 (groupe 011)
#
# Ce programme est un jeu inspiré du concept du jeu poule-poule. Les règles du jeu impliquent 
# l'utilisation de cartes représentées par des caractères (lettres minuscules et chiffres):
# Une carte œuf (lettre 'o') ajoute un œuf au jeu. Le jeu commence avec aucun œuf.
# Une carte d'affichage (lettre 'a') affiche le nombre d'œufs disponibles en jeu.
# Une carte coq (lettre 'q') fait chanter le coq et termine le programme.
# Chaque lettre peut être préfixée par un multiplicateur (chiffre de 0 à 9) indiquant la quantité de cartes jouées.
# Une carte poule (lettre 'p') couve un œuf si au moins un œuf est disponible, le rendant indisponible. Sinon, elle ne fait rien.
# Une carte renard (lettre 'r') chasse une des poules qui couvent un œuf. Si aucune poule n'est en jeu, 
# le renard passe sans rien faire.
# Une carte chien (lettre 'c') poursuit un renard s'il apparaît, le faisant fuir. Les autres chiens restent en jeu.
# Une carte ver (lettre 'v') reste en jeu et est ignorée par les chiens, les renards et les poules. 
# Cependant, une nouvelle poule le poursuit sans considérer la disponibilité des œufs.
	
	.eqv PrintInt, 1
	.eqv PrintChar, 11
	.eqv ReadChar, 12
	.eqv Exit, 10
	
	li s0, 0			# compteur d'oeufs
	li s1, 0			# compteur de poules
	li s2, 0			# compteur de renards
	li s3, 0			# compteur de chiens
	li s4, 0			# compteur de vers	
	li t1, 1			# Initialiser le chiffre courant a 1,
					# pour gerer les cas multiple et les cas non multiple
  	li s5,  1			# Variable pour reinitialiser t1

loop:
	li a7, ReadChar
	ecall
 	
	li t0, 'q' 
	beq a0, t0, fin			# Si le caractere lu est 'q', le jeu se termine		

	li t0, 'a'
	bne a0, t0, case_multip	# Si le caractere lu est 'a', affiche
	beqz t1, loop  # Si dans le cas multiple aucun affichage n'est demande
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
	bne t0, a0, case_poule		# Si a0 != 'o', verifier le prochain caractere
	j ajouter_oeuf

case_poule:
	li t0, 'p'
	bne t0, a0, case_renard		# Si a0 != 'p', verifier le prochain caractere
	bgtz s3, diminuer_ver
	bgtz s0, diminuer_oeuf
	mv t1, s5			# Reinitialiser t1  a 1
	j loop
	
case_renard:
	li t0 'r'
	bne t0, a0, case_chien		# Si a0 != 'r', verifier le prochain caractere
	bgtz s2, diminuer_chien
	bgtz s1, diminuer_poule		# S'il y a des poules couvrant des oeufs
	mv t1, s5
	j loop

case_chien:
	li t0, 'c'
	bne t0, a0, case_ver		# Si a0 != 'c', verifier le prochain caractere	
	add s2, s2, t1
	mv t1, s5
	j loop
	
case_ver:
	li t0, 'v'
	bne t0, a0, case_erreur		# Si a0 != 'v', affiche erreur
	add s3, s3, t1			# incrementer le nombre de cartes de ver au compteur de ver
	mv t1, s5
	j loop

ajouter_oeuf:
	add s0, s0, t1			# Incrementer le nombre d'oeufs
	bltz s1, reinitialiser_poule 
	mv t1, s5
	j loop   

ajouter_poule:
	add s1, s1, t1			# Incrementer le nombre de poules
	bltz s0, reinitialiser_oeuf	# Si le nombre d'oeuf est negatif, reinitialiser oeuf
	mv t1, s5
	j loop
	
diminuer_oeuf:
	sub s0, s0, t1			# Diminuer le nombre d'oeuf avec le chiffre courant
	j ajouter_poule

diminuer_poule:
	sub s1, s1, t1
	j ajouter_oeuf
	
diminuer_chien:
	sub s2, s2, t1
	bltz s2, reinitialiser_chien
	mv t1, s5
	j loop

diminuer_ver:
	sub s3, s3, t1
	bltz s3, reinitialiser_ver
	mv t1, s5
	j loop  

reinitialiser_oeuf:
	add s1, s0, s1			# Tenir compte seul des poules qui couvrent des oeufs
	sub s0, s0, s0
	mv t1, s5
	j loop

reinitialiser_poule:
	add s0, s0, s1			# Ajouter la valeur (negative) du nombre de poules aux oeufs
					# La valeur courante de chiffre ne nous interesse pas
	sub s1, s1, s1
	mv t1, s5
	j loop

reinitialiser_chien:
	
	add s1, s1, s2 # A ce stade, la valeur de chien est negative, puisqu'il y a plus de renard courant que de chien
			# Donc, s'il y a
	sub s0, s0, s2
	sub s2, s2, s2
	mv t1, s5
	j loop
	
reinitialiser_ver:
	add s0, s0, s3			# Si le nombre de ver est negatif, on additionne aux oeuf
	sub s1, s1, s3 
	sub s3, s3, s3
	mv t1, s5
	j loop

	
case_erreur:
	li a7, PrintChar
	li a0, '\n'
	ecall
	li a0, 'E'
	ecall
	li a0, 'r'
	ecall
	li a0, 'r'
	ecall
	j fin

affiche_oeuf:
	addi t1, t1, -1 # Decrementer le t1
	
	li a7, PrintInt
	mv a0, s0
	ecall
	
	li a7, PrintChar
	li a0, '\n'
	ecall
	
	bgtz t1, affiche_oeuf # Tant qu'on a besoin d'afficher les oeufs
	
	mv t1, s5
	j loop

 

fin:	li a7, Exit
	ecall
