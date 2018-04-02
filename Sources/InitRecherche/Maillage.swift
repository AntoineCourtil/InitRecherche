import Foundation
import Glibc

class Maillage {

	var WIDTH : Int = 640
	var HEIGHT : Int = 360
	var MAX_DISTANCE : Double = 0.01

	/*
	* return l'id de la ligne du pixel en x y
	* en SDP, il y a un point par ligne
	* vu qu'il y a une résolution de 640*360
	* il faut acceder à la ligne 640+1 pour avoir le premier
	* point de la deuxième ligne.
	*/
	func getIdforXY(x: Int, y: Int) -> Int {
		return (x + (y*WIDTH) )
	}

 /**
 * Analyse un fichier SDP de nuage de points
 * et récupère un tableau de tableau de coordonnées
 * composé des tableaux de chaque ligne du fichier
 *
 * prend seulement en compte les pixels valides
 *
 */
	func parseSdp(stringFile: String) -> [[Coordinate]] {
		var coordinates = [Coordinate]()
		var coordinatesByLine = [[Coordinate]]()
		//Chaque ligne dans un tableau line
		let line = stringFile.components(separatedBy: .newlines)
		for pixelY in 0...(HEIGHT-1) {
			for pixelX in 0...(WIDTH-1) {
				//On récupère la ligne du pixel dans le tableau
				var dataArr = line[ getIdforXY(x:pixelX, y:pixelY) ].components(separatedBy: " ")
				if(dataArr[5] == "1") {
					coordinates.append(Coordinate(x:dataArr[0], y:dataArr[1], z:dataArr[2], hauteur:dataArr[3], largeur:dataArr[4], isValid:true))
				} else {
					coordinates.append(Coordinate(x:dataArr[0], y:dataArr[1], z:dataArr[2], hauteur:dataArr[3], largeur:dataArr[4], isValid:false))
				}
			}
			coordinatesByLine.append(coordinates)
		}
		return coordinatesByLine;
	}

 /**
 * Récupère la liste des coordonnées
 * pour chaque fichier
 * @type {[type]}
 */
	func getlistPtsByFile(fileName: String, nbFile:Int) -> [[[Coordinate]]] {
		var listPtsByFile = [[[Coordinate]]]()
		for inbFile in 1...nbFile {
			if let path = Bundle.main.path(forResource: "../../../res/\(fileName)\(inbFile)", ofType: "sdp") {
				do {
						//Tout le fichier dans une string file
		        let file = try String(contentsOfFile: path, encoding: .utf8)
						listPtsByFile.append(parseSdp(stringFile:file))
						print("\(fileName)\(inbFile) captured")
				} catch {
					print(error)
				}
			}

		}
		return listPtsByFile
	}

 /**
 * Exporte un tableau de coordonnées ordonnées par ligne coordinates
 * dans un fichier de nom fileName et d'extension type
 *
 */
	func exportCoordinates(fileName:String, coordinates:[[Coordinate]], type:String) {
		var listPtsByLine = [String]()
		var cptPoints = 0
		var header = "OFF\n# \(fileName) off\n# median \(fileName)\n\n"
		for currentLine in 0...(HEIGHT-1) {
			var listPoints = ""
			for currentColumn in 0...(WIDTH-1) {
				let coordinate = coordinates[currentLine][currentColumn]
				//print("ok2")
				var valid = 1
				if(!coordinate.isValid) {
					valid=0
				}
				if(type == "off" || type=="sdp") {
					listPoints += "\(coordinate.X) \(coordinate.Y) \(coordinate.Z) \(coordinate.hauteur) \(coordinate.largeur) \(valid)\n"
				} else {
					listPoints += "\(coordinate.X);\(coordinate.Y);\(coordinate.Z);\(coordinate.hauteur);\(coordinate.largeur);\(valid)\n"
				}
				cptPoints+=1
			}
			listPtsByLine.append(listPoints)
		}

		var outputFileName = "csv/\(fileName)_median.\(type)"

		if(type=="sdp") {
			outputFileName = "res/\(fileName)_median.\(type)"
		}
		var outputText = ""
		if(type=="off") {
			outputFileName = "out/\(fileName)_median.\(type)"
			header+="\(cptPoints) 0 0\n\n"
			outputText = header
		}
		// on ajoute les points au fichier
		for line in 0...(HEIGHT-1) {
			outputText += listPtsByLine[line]
		}
		print("Writing to \(outputFileName)...")
		let url = URL(fileURLWithPath: outputFileName)
		// on exporte
		let outputData = Data(outputText.utf8)
		do {
				try outputData.write(to: url, options: .atomic)
		} catch {
				print("error: \(error)")
		}
	}

  /**
   * calcule un nuage de point
   * médian par rapport à une liste de fichiers
   *
   * (permet de mesurer la précision sur des captures
   * statiques d'un même objet)
   *
   */
	func calculerMedianne(fileName:String, nbFile:Int, type:String) -> [[Coordinate]] {
		var listPtsByFile = self.getlistPtsByFile(fileName:fileName, nbFile:nbFile)
		var medianneCoordinatesFile = [[Coordinate]]()
		var pourcentage = -10
		print("Calculating...")
		for currentLine in 0...(HEIGHT-1) {
			var medianneLine = [Coordinate]()
			var lineByFile = [[Coordinate]]()
			for inbFile in 0...nbFile-1 {
				let line = listPtsByFile[inbFile][currentLine]
				lineByFile.append(line)
			}

			for currentColumn in 0...(WIDTH-1) {
				//Init var du pixel
				var tabPixelX = [Double]()
				var valPixelX : Double? = nil
				var tabPixelY = [Double]()
				var valPixelY : Double? = nil
				var tabPixelZ = [Double]()
				var valPixelZ : Double? = nil
				var medianne = 0

				var mediannePointCoordinate : Coordinate? = nil

				// lecture pixel par pixel par fichier
				for inbFile in 0...nbFile-1 {
					let currentFilePixel = lineByFile[inbFile][currentColumn]
					tabPixelX.append(currentFilePixel.X)
					tabPixelY.append(currentFilePixel.Y)
					tabPixelZ.append(currentFilePixel.Z)
				}

				//Traitement valeur medianne
				if(tabPixelX.count > 0 && tabPixelY.count>0 && tabPixelZ.count>0) {
					tabPixelX.sort()
					tabPixelY.sort()
					tabPixelZ.sort()
					medianne = tabPixelX.count / 2
					valPixelX = tabPixelX[medianne]
					medianne = tabPixelY.count / 2
					valPixelY = tabPixelY[medianne]
					medianne = tabPixelZ.count / 2
					valPixelZ = tabPixelZ[medianne]

					mediannePointCoordinate = Coordinate(x:valPixelX!, y:valPixelY!, z:valPixelZ!, hauteur:currentLine, largeur:currentColumn, isValid:true)
				} else {
					mediannePointCoordinate = Coordinate(x:0,y:0,z:0,hauteur:currentLine, largeur:currentColumn, isValid:true)
				}
				medianneLine.append(mediannePointCoordinate!)
			}
				if(currentLine%((HEIGHT-1)/10) == 0){
					pourcentage += 10
					print("\( pourcentage )%")
				}
				medianneCoordinatesFile.append(medianneLine)
		}
		// on exporte en fichier type
		self.exportCoordinates(fileName:fileName, coordinates:medianneCoordinatesFile, type:type)
		return medianneCoordinatesFile
	}

/**
 * methode permettant de calculer le %
 * de difference entre un nuage de points
 * et un fichier median
 *
 * @type {[type]}
 */
func calculerPourcentageDifferenceMedian(fileName:String, medianFileName:String, typeMedian:String) {
	if let path = Bundle.main.path(forResource: "../../../res/\(fileName)", ofType: "sdp") {
		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)
			if let pathMedian = Bundle.main.path(forResource: "../../../res/\(medianFileName)", ofType: typeMedian) {
				do {
				let fileMedian = try String(contentsOfFile: pathMedian, encoding: .utf8)
				print("Récupèration informations fichier visé...")
				let targetFile = self.parseSdp(stringFile:file)
				print("Récupèration informations fichier médian...")
				let median = self.parseSdp(stringFile:fileMedian)
				var cptLignes : Double = 0
				var cptPointsLigne : Double = 0
				var sommeTaux : Double = 0
				var sommeTauxLigne : Double = 0
				var taux : Double = 0
				var tauxX : Double = 0
				var tauxY : Double = 0
				var tauxZ : Double = 0

				for ligne in 0...HEIGHT-1 {
					cptPointsLigne = 0
					sommeTauxLigne = 0
					for colonne in 0...WIDTH-1 {
						cptPointsLigne+=1
						var nbCoordinateConsidered : Double = 0
						if(median[ligne][colonne].X != 0) {
								nbCoordinateConsidered+=1
								tauxX = abs(abs(median[ligne][colonne].X - targetFile[ligne][colonne].X) / median[ligne][colonne].X)
						}
						if(median[ligne][colonne].Y != 0) {
							nbCoordinateConsidered+=1
							tauxY = abs(abs(median[ligne][colonne].Y - targetFile[ligne][colonne].Y) / median[ligne][colonne].Y)
						}
						if(median[ligne][colonne].Z != 0) {
							nbCoordinateConsidered+=1
							tauxZ = abs(abs(median[ligne][colonne].Z - targetFile[ligne][colonne].Z) / median[ligne][colonne].Z)
						}
						if(nbCoordinateConsidered != 0) {
							let tauxMoyen = (tauxX + tauxY + tauxZ) / nbCoordinateConsidered
							sommeTauxLigne+=tauxMoyen
						}
					}
					cptLignes+=1
					sommeTaux = sommeTaux + (sommeTauxLigne / cptPointsLigne)
				}
				taux = (sommeTaux / cptLignes) * 100
				print("Le fichier présente une différence de \(taux)% avec le fichier médian.")
				} catch {
					print("Ressource res/\(medianFileName).\(typeMedian) introuvable")
					print(error)
				}
			} else {
				print("Ressource res/\(medianFileName).\(typeMedian) introuvable")
			}
		} catch {
			print("Ressource res/\(fileName).sdp introuvable")
			print(error)
		}
	} else {
		print("Ressource res/\(fileName).sdp introuvable")
	}
}

/**
 *
 *
 */
func loopCalculerPourcentageDifferenceMedian(fileBaseName:String, medianFileName:String, nbFile:Int) {
	var currentFile : String? = nil
	for i in 1...nbFile {
		currentFile = "\(fileBaseName)\(i)"
		print("\(fileBaseName)\(i) : ")
		self.calculerPourcentageDifferenceMedian(fileName:currentFile!, medianFileName:medianFileName, typeMedian:"sdp")
	}
}

	/*
	* récupère un fichier SDP et effectue
	* un maillage en format OFF
	* @type {[type]}
	**/
	func maillage(stringFile: String, fileName: String, typeExport: String) -> String {
		var cptPoints = 0
		var cptTriangle = 0
		var listPtsByLine = [String]()
		var listPoints = ""
		var listTriangleByLine = [String]()
		var listTriangles = ""
		var nbListTriangle = 0
		var pourcentage = -10
		var header = "OFF\n# \(fileName).off\n# \(fileName)\n\n"
		//Chaque ligne dans un tableau line
		let line = stringFile.components(separatedBy: .newlines)

		for pixelY in 0...(self.HEIGHT-1) {
			listPoints = ""
			listTriangles = ""
			for pixelX in 0...(self.WIDTH-1) {
				cptPoints = cptPoints+1

				// On récupère la ligne du pixel dans le tableau
				// On récupère les données du pixel (X Y Z HAUTEUR LARGEUR isValid)
				let dataArr = line[ self.getIdforXY(x:pixelX, y:pixelY) ].components(separatedBy: " ")
				// ajouts des coordonnées en x y z
				switch(typeExport) {
				case "off":
					listPoints = listPoints+dataArr[0]+" "+dataArr[1]+" "+dataArr[2]+"\n"
				case "csv":
					listPoints = listPoints+dataArr[0]+";"+dataArr[1]+";"+dataArr[2]+";"+dataArr[3]+";"+dataArr[4]+";"+dataArr[5]+"\n"
				default:
					listPoints = listPoints+dataArr[0]+" "+dataArr[1]+" "+dataArr[2]+"\n"
				}
				let hauteur : Double = NSString(string: dataArr[2]).doubleValue

				// Si le Point est valide
				// on supprime le bruit en ne prenant pas en compte les pixels
				// de hauteur 0 ou > 0.3 && hauteur>0 && hauteur<0.3
				if(dataArr[5] == "1" && typeExport=="off") {

					// Si les voisins de droite et d'en bas sont dans l'image
					if( ((pixelX+1) < self.WIDTH) && ((pixelY+1) < self.HEIGHT) ) {
						let dataArrRIGHT = line[ self.getIdforXY(x:(pixelX+1), y:pixelY) ].components(separatedBy: " ")
						let dataArrDOWN = line[ self.getIdforXY(x:pixelX, y:(pixelY+1)) ].components(separatedBy: " ")

						////Si les voisins de droite et d'en bas sont valides
						if((dataArrRIGHT[5] == "1") && (dataArrDOWN[5] == "1")){
							var rZ, dZ, diffDroite, diffBas: Double
							rZ = Double(dataArrRIGHT[2])!
							dZ = Double(dataArrDOWN[2])!
							diffDroite = abs(hauteur - rZ)
							diffBas = abs(hauteur - dZ)
							if(diffDroite < MAX_DISTANCE && diffBas < MAX_DISTANCE ) {
								cptTriangle = cptTriangle+1
								listTriangles = listTriangles+"3 "+String(self.getIdforXY(x:pixelX,y:pixelY))+" "+String(self.getIdforXY(x:pixelX+1,y:pixelY))+" "+String(self.getIdforXY(x:pixelX,y:pixelY+1))+"\n"
							}
							//print("droite : \(diffDroite) | bas : \(diffBas)")
							//Alors on créé un triangle
						}
					}

					//Si les voisins de gauche et d'en haut sont dans l'image
					if( ((pixelX-1) >= 0) && ((pixelY-1) >= 0) ) {
						let dataArrLEFT = line[ self.getIdforXY(x:(pixelX-1), y:pixelY) ].components(separatedBy: " ")
						let dataArrUP = line[ self.getIdforXY(x:pixelX, y:(pixelY-1)) ].components(separatedBy: " ")

						////Si les voisins de droite et d'en bas sont valides
						if((dataArrLEFT[5] == "1") && (dataArrUP[5] == "1")){
							var lZ, uZ, diffGauche, diffHaut: Double
							lZ = Double(dataArrLEFT[2])!
							uZ = Double(dataArrUP[2])!
							diffGauche = abs(hauteur - lZ)
							diffHaut = abs(hauteur - uZ)
							if(diffGauche < MAX_DISTANCE && diffHaut < MAX_DISTANCE ) {
								//Alors on créé un triangle
								cptTriangle = cptTriangle+1
								listTriangles = listTriangles+"3 "+String(self.getIdforXY(x:pixelX,y:pixelY))+" "+String(self.getIdforXY(x:pixelX-1,y:pixelY))+" "+String(self.getIdforXY(x:pixelX,y:pixelY-1))+"\n"
							}

						}
					}
				}
			}
			if(pixelY%((HEIGHT-1)/10) == 0){
				pourcentage += 10
				if(pourcentage != 100) {
					print("\( pourcentage )%\r", terminator:"")
					fflush(stdout)
				} else {
					print("\( pourcentage )%\r\n")
				}

			}
			listPtsByLine.append(listPoints)
			listTriangleByLine.append(listTriangles)
			nbListTriangle = nbListTriangle + 1
		}


		var outputText = ""
		if(typeExport=="off") {
			header+="\(cptPoints) \(cptTriangle) 0\n\n"
			outputText = header
		}

		for pixelY in 0...(self.HEIGHT-1){
			outputText = outputText+listPtsByLine[pixelY]
		}

		if(typeExport=="off") {
			outputText = outputText+"\n"
			for i in 0...(nbListTriangle-1){
				outputText = outputText+listTriangleByLine[i]
			}
	  }
		return outputText
	}

	/*
	* Convertis une capture depuis Camera True-Depth
	* sous format SDP vers le format précisé (type)
	* et effectue un maillage triangle
	*
	*/
	func sdpMaillageExport(fileName : String, type: String) {

		let fileManager = FileManager()
		let path = fileManager.currentDirectoryPath
		if let path = Bundle.main.path(forResource: "../../../res/\(fileName)", ofType: "sdp") {
			do {
				let outputFileName = "out/\(fileName).\(type)"
				let url = URL(fileURLWithPath: "").appendingPathComponent(outputFileName)
				let file = try String(contentsOfFile: path, encoding: .utf8)
				let maillage = self.maillage(stringFile:file, fileName:fileName, typeExport:type)
				/*
				* Write result in .type file
				*/
				let outputData = Data(maillage.utf8)
				do {
					try outputData.write(to: url, options: .atomic)
				} catch {
					print(error)
				}
				//print(url)
			} catch {
				print(error)
				print("res/\(fileName) n'est pas un fichier SDP.")
			}
		}
	}
	/**
	 * Convertis les fichiers commençant par la valeur de
	 * fileBaseName (de 1 jusqu'à numberOfFiles) dans le type voulu
	 * avec un maillage triangle
	 *
	 * @type {[type]}
	 */
	func loopSdpMaillageToType(fileBaseName: String, numberOfFiles: Int, type: String) {
			if(!fileBaseName.isEmpty && numberOfFiles>0 && (type=="off" || type=="csv")) {
				for nbFile in 1...numberOfFiles {
					if let path = Bundle.main.path(forResource: "../../../res/\(fileName)\(nbFile)", ofType: "sdp") {
							do {
								var dir = "csv"
								if(type == "off") { dir = "out"}
								let outputFileName = "../../../\(dir)/\(fileName)\(nbFile).\(type)"
								print("Generating [\(outputFileName)]")
								let url = URL(fileURLWithPath: "").appendingPathComponent(outputFileName)
								let file = try String(contentsOfFile: path, encoding: .utf8)
								let maillage = self.maillage(stringFile:file, fileName:"../../../res/\(fileName)\(nbFile)", typeExport:type)
								let outputData = Data(maillage.utf8)
								do {
								    try outputData.write(to: url, options: .atomic)
								} catch {
								    print("error: \(error)")
								}
							} catch {
								print(error)
								print("res/\(fileName) n'est pas un fichier SDP.")
							}
						}
				}
			}
	}
}
