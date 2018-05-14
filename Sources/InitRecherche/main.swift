var fileName = ""
var cpt = 0
var loop: Bool = false
var median: Bool = false
var byNormale: Bool = false
var taux: Bool = false
var simple: Bool = false
var type: String = "off"
var medianFileName = "median"
var number: Int = 1
let maillageObjet = Maillage()
if CommandLine.argc < 2 {
    let firstArgument = CommandLine.arguments[0]
    print("Usage : \(firstArgument) fileName (csv||off||pgm||ppm) byNormale")
    print("Usage : \(firstArgument) loop fileName numberOfFiles (csv||off) byNormale")
    print("Usage : \(firstArgument) median fileName numberOfFiles (csv||sdp) byNormale")
    print("Usage : \(firstArgument) taux fileName medianFileName numberOfFiles byNormale")
} else {
    let arguments = CommandLine.arguments
    for argument in arguments {
        if (cpt == 1) {
            if (argument == "loop") {
                loop = true
            } else if (argument == "median") {
                median = true
            } else if (argument == "taux") {
                taux = true
            } else {
                simple = true
                fileName = argument
            }
        }
        if (cpt == 2) {
            if (loop || median || taux) {
                fileName = argument
            } else {
                type = argument
            }
        }
        if (cpt == 3) {
            if (loop || median) {
                number = Int(argument)!
            } else if (taux) {
                medianFileName = argument
            } else if (simple) {
                if (argument == "true") {
                    byNormale = true
                }
            } else {
                type = argument
            }
        }
        if (cpt == 4) {
            if (loop || median) {
                type = argument
            } else if (taux) {
                number = Int(argument)!
            }
        }
        if (cpt == 5) {
            if (argument == "true") {
                byNormale = true
                type = "obj"
            }
        }
        cpt += 1
    }
    if (loop) {
        maillageObjet.loopSdpMaillageToType(fileBaseName: fileName, numberOfFiles: number, type: type, byNormale: byNormale)
    } else if (taux) {
        maillageObjet.loopCalculerPourcentageDifferenceMedian(fileBaseName: fileName, medianFileName: medianFileName, nbFile: number)
    } else if (median) {
        maillageObjet.calculerMedianne(fileName: fileName, nbFile: number, type: type, byNormale: byNormale)
    } else {
        maillageObjet.sdpMaillageExport(fileName: fileName, type: type, byNormale: byNormale)
    }
}
