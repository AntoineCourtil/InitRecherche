
var fileName = ""
var cpt = 0
var loop: Bool = false
var median: Bool = false
var taux: Bool = false
var type:String = "off"
var medianFileName = "median"
var number:Int = 1
let maillageObjet = Maillage()
if CommandLine.argc < 2 {
	//    print("No arguments are passed.")
	let firstArgument = CommandLine.arguments[0]
	print("Usage : \(firstArgument) fileName (csv||off)")
	print("Usage : \(firstArgument) loop fileName numberOfFiles (csv||off)")
  print("Usage : \(firstArgument) median fileName numberOfFiles (csv||off||sdp)")
	print("Usage : \(firstArgument) taux fileName medianFileName numberOfFiles")
} else {
	let arguments = CommandLine.arguments
	for argument in arguments {
		//print(argument)
		if(cpt == 1) {
			if(argument=="loop") {
				loop = true
			} else if (argument=="median"){
        median = true
      } else if (argument=="taux") {
				taux = true
			} else {
				fileName = argument
			}
		}
		if(cpt == 2) {
			if(loop || median || taux) {
				fileName = argument
			} else {
					number = Int(argument)!
			}
		}
		if(cpt == 3) {
			if(loop || median) {
				number = Int(argument)!
			} else if (taux) {
					medianFileName = argument
			} else {
				type = argument
			}
		}
		if(cpt == 4) {
			if(loop || median) {
				type = argument
			} else if(taux) {
				number = Int(argument)!
			}
		}
		cpt += 1
	}
	if(loop) {
		maillageObjet.loopSdpMaillageToType(fileBaseName:fileName, numberOfFiles:number, type:type)
	} else if(taux) {
		maillageObjet.loopCalculerPourcentageDifferenceMedian(fileBaseName:fileName, medianFileName:medianFileName, nbFile:number)
	} else if(median) {
    maillageObjet.calculerMedianne(fileName:fileName, nbFile:number, type:type)
  } else {
		maillageObjet.sdpMaillageExport(fileName:fileName, type:type)
	}
}
