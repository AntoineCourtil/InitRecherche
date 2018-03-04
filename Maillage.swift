import Foundation
import Glibc

class Maillage {

	var WIDTH : Int = 640
	var HEIGHT : Int = 360

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

	/*
	* récupère un fichier SDP et effectue
	* un maillage en format OFF
	* @type {[type]}
	**/
	func maillage(stringFile: String, fileName: String) -> String {
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
				listPoints = listPoints+dataArr[0]+" "+dataArr[1]+" "+dataArr[2]+"\n"
				let hauteur : Double = NSString(string: dataArr[2]).doubleValue

				// Si le Point est valide
				// on supprime le bruit en ne prenant pas en compte les pixels
				// de hauteur 0 ou > 0.3
				print("pixelValide")
				print(pixelX+1)
				print(self.WIDTH)
				print("hauteur : \(hauteur)")
				if(dataArr[5] == "1" && hauteur>0 && hauteur<0.3) {

					// Si les voisins de droite et d'en bas sont dans l'image
					if( ((pixelX+1) < self.WIDTH) && ((pixelY+1) < self.HEIGHT) ) {
						print("Voisin de droite et en bas OK")
						let dataArrRIGHT = line[ self.getIdforXY(x:(pixelX+1), y:pixelY) ].components(separatedBy: " ")
						let dataArrDOWN = line[ self.getIdforXY(x:pixelX, y:(pixelY+1)) ].components(separatedBy: " ")

						////Si les voisins de droite et d'en bas sont valides
						if((dataArrRIGHT[5] == "1") && (dataArrDOWN[5] == "1")){
							//Alors on créé un triangle
							cptTriangle = cptTriangle+1
							print(cptTriangle)
							listTriangles = listTriangles+"3 "+String(self.getIdforXY(x:pixelX,y:pixelY))+" "+String(self.getIdforXY(x:pixelX+1,y:pixelY))+" "+String(self.getIdforXY(x:pixelX,y:pixelY+1))+"\n"
						}
					}

					//Si les voisins de gauche et d'en haut sont dans l'image
					if( ((pixelX-1) >= 0) && ((pixelY-1) >= 0) ) {
						print("Voisin de gauche et haut OK")
						let dataArrLEFT = line[ self.getIdforXY(x:(pixelX-1), y:pixelY) ].components(separatedBy: " ")
						let dataArrUP = line[ self.getIdforXY(x:pixelX, y:(pixelY-1)) ].components(separatedBy: " ")

						////Si les voisins de droite et d'en bas sont valides
						if((dataArrLEFT[5] == "1") && (dataArrUP[5] == "1")){

							//Alors on créé un triangle
							cptTriangle = cptTriangle+1
							print(cptTriangle)
							listTriangles = listTriangles+"3 "+String(self.getIdforXY(x:pixelX,y:pixelY))+" "+String(self.getIdforXY(x:pixelX-1,y:pixelY))+" "+String(self.getIdforXY(x:pixelX,y:pixelY-1))+"\n"
						}
					}
				}
			}

			if(pixelY%((HEIGHT-1)/10) == 0){
				pourcentage += 10
				print("\( pourcentage )%")
			}
			listPtsByLine.append(listPoints)
			listTriangleByLine.append(listTriangles)
			nbListTriangle = nbListTriangle + 1
		}

		header+="\(cptPoints) \(cptTriangle) 0\n\n"

		var outputText = header

		for pixelY in 0...(self.HEIGHT-1){
			outputText = outputText+listPtsByLine[pixelY]
		}

		outputText = outputText+"\n"

		for i in 0...(nbListTriangle-1){
			outputText = outputText+listTriangleByLine[i]
		}


		return outputText
	}

	/*
	* Convertis une capture depuis Camera True-Depth
	* sous format SDP vers le format OFF
	* et effectue un maillage triangle
	*
	*/
	func SdpMaillageToOff(fileName : String) {
		if let path = Bundle.main.path(forResource: "res/\(fileName)", ofType: "sdp") {
			do {
				let outputFileName = "out/\(fileName).off"
				let url = URL(fileURLWithPath: "").appendingPathComponent(outputFileName)
				let file = try String(contentsOfFile: path, encoding: .utf8)
				let maillageOff = maillage(stringFile:file, fileName:fileName)
				/*
				* Write result in .off file
				*/
				let outputData = Data(maillageOff.utf8)
				do {
					try outputData.write(to: url, options: .atomic)
				} catch {
					print(error)
				}
				print(url)
			} catch {
				print(error)
				print("res/\(fileName) n'est pas un fichier SDP.")
			}
		}

	}
}

var fileName = ""

if CommandLine.argc < 2 {
	//    print("No arguments are passed.")
	let firstArgument = CommandLine.arguments[0]
	print("Usage : \(firstArgument) fileName")
} else {
	let arguments = CommandLine.arguments
	var cpt = 0
	for argument in arguments {
		//print(argument)
		if(cpt == 1){
			fileName = argument
		}
		cpt += 1
	}
	let maillageObjet = Maillage()
	maillageObjet.SdpMaillageToOff(fileName:fileName)
}
