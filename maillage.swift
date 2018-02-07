import Foundation
import Glibc

var WIDTH = 640
var HEIGHT = 360



/**
* return l'id de la ligne du pixel en x y
**/

func getIdforXY(x: Int, y: Int) -> Int {
	return (x + (y*WIDTH) )
}


/**
* MAIN
**/



let fileName = "output.off"
let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
print(url)




var header = "OFF\n# divers.off\n# divers\n\n"


var listPtsByLine = [String]()
var listPoints = ""


if let path = Bundle.main.path(forResource: "res/divers", ofType: "sdp") {
    do {
        
    	//Tout le fichier dans une string file
        let file = try String(contentsOfFile: path, encoding: .utf8)

        //Chaque ligne dans un tableau line
        let line = file.components(separatedBy: .newlines)



        for pixelY in 0...(HEIGHT-1){

        	listPoints = ""

	        for pixelX in 0...(WIDTH-1){



	        	//On récupère la ligne du pixel dans le tableau
				let dataArr = line[ getIdforXY(x:pixelX, y:pixelY) ].components(separatedBy: " ")

//				print(line[ getIdforXY(x:pixelX, y:pixelY) ])
//				print(dataArr[0])
//				print(dataArr[1])
//				print(dataArr[2])
//				print(dataArr[3])
//				print(dataArr[4])
//				print(dataArr[5])

				
				//Si le Point est valide
				if(dataArr[5] == "1") {

					listPoints = listPoints+dataArr[0]+" "+dataArr[1]+" "+dataArr[2]+"\n"

//					print("VALIDE")
					
					//Si les voisins de droite et d'en bas sont dans l'image
					if( ((pixelX+1) < WIDTH) && ((pixelY+1) < HEIGHT) ) {
						let dataArrRIGHT = line[ getIdforXY(x:(pixelX+1), y:pixelY) ].components(separatedBy: " ")
						let dataArrDOWN = line[ getIdforXY(x:pixelX, y:(pixelY+1)) ].components(separatedBy: " ")

						////Si les voisins de droite et d'en bas sont valides
						if((dataArrRIGHT[5] == "1") && (dataArrDOWN[5] == "1")){

							//Alors on créé un triangle
//							print("TRIANGLE 1")

							//outputText = outputText + "TRIANGLE1\n"
						}
					}


					//Si les voisins de gauche et d'en haut sont dans l'image
					if( ((pixelX-1) >= 0) && ((pixelY-1) >= 0) ) {
						let dataArrLEFT = line[ getIdforXY(x:(pixelX-1), y:pixelY) ].components(separatedBy: " ")
						let dataArrUP = line[ getIdforXY(x:pixelX, y:(pixelY-1)) ].components(separatedBy: " ")

						////Si les voisins de droite et d'en bas sont valides
						if((dataArrLEFT[5] == "1") && (dataArrUP[5] == "1")){

							//Alors on créé un triangle
//							print("TRIANGLE 2")
						}
					}

				}

			}



			listPtsByLine.append(listPoints)

			//print("Colonne : ", pixelY)
		}


		//print(listPtsByLine)

		var outputText = header

		for pixelY in 0...(HEIGHT-1){
			outputText = outputText+listPtsByLine[pixelY]
		}

		let outputData = Data(outputText.utf8)
		do {
		    try outputData.write(to: url, options: .atomic)
		} catch {
		    print(error)
		}





    } catch {
        print(error)
    }
}
