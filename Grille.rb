
# Classe représentant une grille de SlitherLink, avec le plateau correspondant et toutes les informations qui lui sont associées (voir variables d'instance).
class Grille 

	#@plateau : le plateau de jeu représentant la grille
	#@temps : le temps écoulé à résoudre la grille
	#@meilleurTemps : le meilleur temps de résolution de la grille
	#@nombreEtoiles : le nombre d'étoiles déjà gagnées
	#pointsAide : nombre de points d'aide restants
	#@nombreLignes : le nombre de lignes du plateau
	#@nombreColonnes : le nombre de colonnes du plateau
	
	# Méthode faisant appel au constructeur.
	def Grille.charger(contenuFichier)
		new(contenuFichier)
	end
	
	# Constructeur d'une grille chargée à partir d'un fichier.
	def initialize(contenuFichier)
	
		self.charger(contenuFichier)
		#self.afficher
	end
	
	# Méthode gérant le chargement des différentes informatioons concernant la grille (plateau, temps ...)
	def charger(contenuFichier)
		
		# Séparation des différentes informations du fichier (séparateur ";")
		contenu = contenuFichier.split(";")
		
		# Chargement des lignes du plateau (séparateur " ")
		lignesPlateau = contenu[0].split(" ")
		
		# Constitution de la matrice de cases à partir du tableau de lignes (séparateur ":")
		@nombreLignes = lignesPlateau.size
		casesPlateau = Array.new()
		0.upto(@nombreLignes - 1) do |i| # Insertion de chacune des lignes dans le tableau de lignes
			casesPlateau.push(lignesPlateau[i].split(":"))
		end
		@nombreColonnes = casesPlateau[0].size
		
		# Construction du plateau à partir de la matrice ainsi constituée
		self.construirePlateau(casesPlateau) 
		
		# Chargement du temps actuel, du meilleur temps, du nombre d'étoiles déjà obtenues, du nombre de points d'aides restants
		@temps = contenu[1]
		@meilleurTemps = contenu[2]
		@nombreEtoiles = contenu[3]
		@pointsAide = contenu[4]
	end
	
	# Méthode construisant le plateau à partir de la matrice contenant les cases chargées du fichier
	def construirePlateau(casesPlateau) 
		
		# Préparation du tableau de lignes du plateau
		@plateau = Array.new(@nombreLignes, nil)

		# Préparation de chacune des lignes du tableau de lignes du plateau
        0.upto(@nombreLignes - 1) do |i|
            @plateau[i] = Array.new(@nombreColonnes, nil)
        end

		# Remplissage de chaque case du plateau avec la matrice de cases (casesPlateau)
		# Pour chaque case du plateau, faire ...
        0.upto(@nombreColonnes - 1) do |j|
        
            0.upto(@nombreLignes - 1) do |i|
            
            	# Création de la table de hachage contenant les lignes de la case
                h = Hash.new(nil)
                
                # Création des lignes BAS et DROITE
				h[:DROITE] = Ligne.creer(self.toLigne(casesPlateau[i][j][2]))
				h[:BAS] = Ligne.creer(self.toLigne(casesPlateau[i][j][3]))
				
				# S'il existe une case en haut de cette case, les lignes HAUT de la case courante et BAS de la case du haut sont communes 
				if ( i != 0 ) then
                    h[:HAUT] = @plateau[i-1][j].getLigne(:BAS)
                else
                	h[:HAUT] = Ligne.creer(self.toLigne(casesPlateau[i][j][1]))
                end

				# S'il existe une case à gauche de cette case, les lignes GAUCHE de la case courante et DROITE de la case de gauche sont communes 
                if ( j != 0 ) then
                    h[:GAUCHE] = @plateau[i][j-1].getLigne(:DROITE)
                else
                	h[:GAUCHE] = Ligne.creer(self.toLigne(casesPlateau[i][j][4]))
                end
				
				# Récupération du nombre de lignes pleines autorisées de la case
				numero = casesPlateau[i][j][0].to_i

				# Création de la case et ajout dans le plateau
                @plateau[i][j] = Case.creer(numero, h)
            end
        end
	end
	
	# Méthode transformant une grille en une ligne de fichier.
	# Retourne la ligne de fichier ainsi créée.
	def toLigneFichier
	
		# La ligne de fichier correspondant à la grille
		contenuFichier = ""
		
		# La traduction d'une case en code pour être sauvé dans le fichier
		motCase = ""
		
		# Pour chaque case du plateau, faire...
		0.upto(@nombreLignes - 1) do |i|
		
			0.upto(@nombreColonnes - 1) do |j|
			
				# Traduction de la case (lignes + numéro) en mot de fichier
				motCase += @plateau[i][j].nbLigneDevantEtrePleine.to_s
				motCase += self.toCaractere(@plateau[i][j].getLigne(:HAUT).etat)
				motCase += self.toCaractere(@plateau[i][j].getLigne(:DROITE).etat)
				motCase += self.toCaractere(@plateau[i][j].getLigne(:BAS).etat)
				motCase += self.toCaractere(@plateau[i][j].getLigne(:GAUCHE).etat)
				
				# Ajout du séparateur ":" entre 2 cases (sauf pour la dernière d'une ligne)
				if j < @nombreColonnes - 1
					motCase += ":"
				end	
			end
			
			# Ajout du mot à la ligne de fichier
			contenuFichier += motCase
			motCase = ""
			
			# Ajout du séparateur " " entre 2 lignes (sauf pour la dernière)
			if i < @nombreLignes - 1
				contenuFichier += " "
			end
		end	
		
		# Ajout des autres champs de la grille
		contenuFichier += ";" + @temps
		contenuFichier += ";" + @meilleurTemps
		contenuFichier += ";" + @nombreEtoiles
		contenuFichier += ";" + @pointsAide
		
		# Retour de la ligne de fichier
		return contenuFichier			
	end
	
	# Méthode d'affichage du plateau (si besoin pour débuger)
	def afficher
        
        tailleX = @nombreLignes
        tailleY = @nombreColonnes

        0.upto( tailleY - 1 ) { |j|
            print "  #{j} "
        }

        print "\n"
        0.upto( tailleX - 1 ) { |i|
            0.upto( tailleY - 1 ) { |j|
                print ". ", @plateau[i][j].getLigne(:HAUT), " "
            }

            print ".\n"

            0.upto( tailleY - 1 ) { |j|
                print @plateau[i][j].getLigne(:GAUCHE), " ", @plateau[i][j].nbLigneDevantEtrePleine, " "
            }
            
            print @plateau[i][tailleY - 1].getLigne(:DROITE)

            print "  ", i, "\n"
        }

        0.upto( tailleY - 1 ) { |j|
            print ". ", @plateau[tailleX - 1][j].getLigne(:BAS), " "
        }

        print ".\n"
        puts "Temps actuel = #{@temps}"
        puts "Meilleur temps = #{@meilleurTemps}"
        puts "Nombre d'étoiles déjà gagnées = #{@nombreEtoiles}"
        puts "Points d'aide restants = #{@pointsAide}"
    end
	
	# Méthode transformant le caractère reçu du fichier en état de ligne
	def toLigne(caractere) 
		
		case caractere 
			when "v"
				return :VIDE
			when "p"
				return :PLEINE
			when "b"
				return :BLOQUE
			else
				return :VIDE
			end
	end
	
	# Méthode transformant l'état de ligne d'une ligne en caractère pour être inséré dans le fichier
	def toCaractere(etatLigne) 
		
		case etatLigne
			when :VIDE
				return "v"
			when :PLEINE
				return "p"
			when :BLOQUE
				return "b"
			else
				return "v"
			end
	end
end
