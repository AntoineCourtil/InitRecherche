import Foundation
import Glibc

var WIDTH = 640
var HEIGHT = 360
var UNDEFINED = -99.9



/**
* return l'id de la ligne du pixel en x y
**/

func getIdforXY(x: Int, y: Int) -> Int {
	return (x + (y*WIDTH) )
}


func getlistPtsByLine(fileName: String, nbFile:Int) -> [String] {

	/**
	* Init var & buffers
	**/

	var listPtsByFile = [String]()
	var cptPoints = 0


	if let path = Bundle.main.path(forResource: "res/\(fileName)\(nbFile)", ofType: "sdp") {
	    do {
	        
	    	//Tout le fichier dans une string file
	        let file = try String(contentsOfFile: path, encoding: .utf8)

	        //Chaque ligne dans un tableau line
	        let line = file.components(separatedBy: .newlines)



	        for pixelY in 0...(HEIGHT-1){

	        	var listPoints = ""

		        for pixelX in 0...(WIDTH-1){

	                cptPoints = cptPoints+1

		        	//On récupère la ligne du pixel dans le tableau
					let dataArr = line[ getIdforXY(x:pixelX, y:pixelY) ].components(separatedBy: " ")


					listPoints = listPoints+dataArr[0]+" "+dataArr[1]+" "+dataArr[2]+" "+dataArr[5]+"\n"

				}



				listPtsByFile.append(listPoints)
			}





	    } catch {
	        print(error)
	    }
	}

	return listPtsByFile
}






/**
* MAIN
**/



/**
* Read fileName
**/

var fileName = ""
var numberOfFiles = 1;

if CommandLine.argc < 3 {
//    print("No arguments are passed.")
    let firstArgument = CommandLine.arguments[0]
    print("Usage : \(firstArgument) fileName numberOfFiles")
} else {
    let arguments = CommandLine.arguments
    var cpt = 0
    for argument in arguments {
        //print(argument)
        if(cpt == 1){
        	fileName = argument
        }
        if(cpt == 2){
        	let i = Int(argument)!

			if(i>1){
				numberOfFiles = i
			}
        }
        cpt += 1
    }
}

//print("fileName : \(fileName)")
//print("numberOfFiles : \(numberOfFiles)")


var listPtsByFile = [[String]]()

var listPtsByLine = [String]()
var listPoints = ""

var pourcentage = -10


/**
* Processing
**/

for nbFile in 1...numberOfFiles {

	//Lecture des fichiers .off stockés en tableau de lignes

	listPtsByFile.append( getlistPtsByLine(fileName: fileName, nbFile:nbFile) )	
	print("\(fileName)\(nbFile) captured")

	//print(listPtsByFile.count)

}

//print(listPtsByFile[0][0].count)

print("\n Calculating..")


for pixelY in 0...(HEIGHT-1){

	listPoints = ""

	//tableau de (tableau de pixel de la ligne) pour chaque nbFile

	var lineByFile = [[String]]()

	for nbFile in 0...numberOfFiles-1 {

		//ERROR
        let line = listPtsByFile[nbFile][pixelY].components(separatedBy: .newlines)

        lineByFile.append(line)

	}

	for pixelX in 0...(WIDTH-1){

		//Init var du pixel
		var tabPixelX = [Double]() 
		var valPixelX = UNDEFINED

		var tabPixelY = [Double]() 
		var valPixelY = UNDEFINED

		var tabPixelZ = [Double]() 
		var valPixelZ = UNDEFINED

		var medianne = 0

		var medianneLine = ""

		//lecture de chaque pixel par fichier
		for nbFile in 0...numberOfFiles-1 {
			//print(lineByFile[nbFile][pixelX])

			let pixel = lineByFile[nbFile][pixelX].components(separatedBy: " ")

			

			//Si le pixel est valide, alors on le prend en compte
			if(pixel[3] == "1"){
				let doubleValueX : Double = NSString(string: pixel[0]).doubleValue
				tabPixelX.append(doubleValueX)

				let doubleValueY : Double = NSString(string: pixel[1]).doubleValue
				tabPixelY.append(doubleValueY)

				let doubleValueZ : Double = NSString(string: pixel[2]).doubleValue
				tabPixelZ.append(doubleValueZ)
			}

		}


		//Traitement valeur medianne

		if(tabPixelX.count > 0 && tabPixelY.count > 0 && tabPixelZ.count > 0){

			tabPixelX.sort()

			medianne = tabPixelX.count / 2
			valPixelX = tabPixelX[medianne]

			medianne = tabPixelY.count / 2
			valPixelY = tabPixelY[medianne]

			medianne = tabPixelZ.count / 2
			valPixelZ = tabPixelZ[medianne]

			medianneLine = "\(valPixelX) \(valPixelY) \(valPixelZ) \(pixelY) \(pixelX) 1\n"
			//medianneLine = "\(tabPixelX[0]) \(tabPixelY[0]) \(tabPixelZ[0]) \(pixelY) \(pixelX) 1\n"

		} else{

			medianneLine = "0 0 0 \(pixelY) \(pixelX) 0\n"

		}

		//print(medianneLine)

		listPoints = listPoints+medianneLine


	}

	if(pixelY%((HEIGHT-1)/10) == 0){
		pourcentage += 10
		print("\( pourcentage )%")
	}

	listPtsByLine.append(listPoints)

}


//Calcul outputText en une seul var String
var outputText = ""

for pixelY in 0...(HEIGHT-1){
	outputText = outputText+listPtsByLine[pixelY]
}

//print(outputText)



//Ecriture nouveau fichier medianne.sdp

let outputFileName = "res/\(fileName)_median\(numberOfFiles).sdp"
let url = URL(fileURLWithPath: "").appendingPathComponent(outputFileName)



let outputData = Data(outputText.utf8)
do {

    try outputData.write(to: url, options: .atomic)

} catch {

    print(error)

}


print(url)