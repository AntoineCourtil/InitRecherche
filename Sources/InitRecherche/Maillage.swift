import Foundation
import Glibc

class Maillage {

    static var WIDTH: Int = 640
    static var HEIGHT: Int = 360
    static var MAX_DISTANCE: Double = 0.01

    /*
    * return l'id de la ligne du pixel en x y
    * en SDP, il y a un point par ligne
    * vu qu'il y a une résolution de 640*360
    * il faut acceder à la ligne 640+1 pour avoir le premier
    * point de la deuxième ligne.
    */
    static func getIdforXY(x: Int, y: Int) -> Int {
        return (x + (y * Maillage.WIDTH))
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
        var coordinatesByLine = [[Coordinate]]()
        //Chaque ligne dans un tableau line
        let line = stringFile.components(separatedBy: .newlines)

        for pixelY in 0...(Maillage.HEIGHT - 1) {
            var coordinates = [Coordinate]()
            for pixelX in 0...(Maillage.WIDTH - 1) {
                //On récupère la ligne du pixel dans le tableau
                var cLine = line[Maillage.getIdforXY(x: pixelX, y: pixelY)].trimmingCharacters(in: .whitespaces)
                var dataArr = cLine.components(separatedBy: " ")
                if(dataArr[0] == "") {
                    continue
                }
                if(dataArr[0].contains("#")) {
                    continue
                }
//                print("\(dataArr[3]) \(dataArr[4]) | \(pixelY) \(pixelX)")

                if (dataArr[5] == "1") {
                    coordinates.append(Coordinate(x: dataArr[0], y: dataArr[1], z: dataArr[2], hauteur: dataArr[3], largeur: dataArr[4], isValid: true))
                } else {
                    coordinates.append(Coordinate(x: dataArr[0], y: dataArr[1], z: dataArr[2], hauteur: dataArr[3], largeur: dataArr[4], isValid: false))
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
    func getlistPtsByFile(fileName: String, nbFile: Int) -> [[[Coordinate]]] {
        var listPtsByFile = [[[Coordinate]]]()
        for inbFile in 1...nbFile {
            if let path = Bundle.main.path(forResource: "../../../ressource/\(fileName)\(inbFile)", ofType: "sdp") {
                do {
                    //Tout le fichier dans une string file
                    let file = try String(contentsOfFile: path, encoding: .utf8)
                    listPtsByFile.append(parseSdp(stringFile: file))
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
    func exportCoordinates(fileName: String, coordinates: [[Coordinate]], type: String) {
        var listPtsByLine = [String]()
        var cptPoints = 0
        var header = "OFF\n# \(fileName) off\n# median \(fileName)\n\n"
        for currentLine in 0...(Maillage.HEIGHT - 1) {
            var listPoints = ""
            for currentColumn in 0...(Maillage.WIDTH - 1) {
                let coordinate = coordinates[currentLine][currentColumn]
                var valid = 1
                if (!coordinate.isValid) {
                    valid = 0
                }
                if (type == "off" || type == "sdp") {
                    listPoints += "\(coordinate.X) \(coordinate.Y) \(coordinate.Z) \(coordinate.hauteur) \(coordinate.largeur) \(valid)\n"
                } else {
                    listPoints += "\(coordinate.X);\(coordinate.Y);\(coordinate.Z);\(coordinate.hauteur);\(coordinate.largeur);\(valid)\n"
                }
                cptPoints += 1
            }
            listPtsByLine.append(listPoints)
        }

        var outputFileName = "ressource/\(fileName)_median.\(type)"

        if (type == "sdp") {
            outputFileName = "ressource/\(fileName)_median.\(type)"
        }
        var outputText = ""
        if (type == "off") {
            outputFileName = "result/\(fileName)_median.\(type)"
            header += "\(cptPoints) 0 0\n\n"
            outputText = header
        }
        // on ajoute les points au fichier
        for line in 0...(Maillage.HEIGHT - 1) {
            outputText += listPtsByLine[line]
        }
        print("Writing to \(outputFileName)...")
        let url = URL(fileURLWithPath: "../../../\(outputFileName)")
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
    func calculerMedianne(fileName: String, nbFile: Int, type: String, byNormale: Bool) -> [[Coordinate]] {
        var listPtsByFile = self.getlistPtsByFile(fileName: fileName, nbFile: nbFile)
        var medianneCoordinatesFile = [[Coordinate]]()
        var pourcentage = -10
        print("Calculating...")
        for currentLine in 0...(Maillage.HEIGHT - 1) {
            var medianneLine = [Coordinate]()
            var lineByFile = [[Coordinate]]()

//            print(currentLine)

            for inbFile in 0...nbFile - 1 {
                let line = listPtsByFile[inbFile][currentLine]
                lineByFile.append(line)
            }

            for currentColumn in 0...(Maillage.WIDTH - 1) {
                //Init var du pixel
                var tabPixelX = [Double]()
                var valPixelX: Double? = nil
                var tabPixelY = [Double]()
                var valPixelY: Double? = nil
                var tabPixelZ = [Double]()
                var valPixelZ: Double? = nil
                var medianne = 0

                var mediannePointCoordinate: Coordinate? = nil

                // lecture pixel par pixel par fichier
                for inbFile in 0...nbFile - 1 {
                    let currentFilePixel = lineByFile[inbFile][currentColumn]
//                    print("\(currentFilePixel.hauteur) \(currentFilePixel.largeur) | \(currentLine) \(currentColumn)")

                    if (currentFilePixel.isValid) {

                        tabPixelX.append(currentFilePixel.X)
                        tabPixelY.append(currentFilePixel.Y)
                        tabPixelZ.append(currentFilePixel.Z)

                    }
                }

                //Traitement valeur medianne
                if (tabPixelX.count > 0 && tabPixelY.count > 0 && tabPixelZ.count > 0) {
                    tabPixelX.sort()
                    tabPixelY.sort()
                    tabPixelZ.sort()
                    medianne = tabPixelX.count / 2
                    valPixelX = tabPixelX[medianne]
                    medianne = tabPixelY.count / 2
                    valPixelY = tabPixelY[medianne]
                    medianne = tabPixelZ.count / 2
                    valPixelZ = tabPixelZ[medianne]

                    mediannePointCoordinate = Coordinate(x: valPixelX!, y: valPixelY!, z: valPixelZ!, hauteur: currentLine, largeur: currentColumn, isValid: true)
                } else {
                    mediannePointCoordinate = Coordinate(x: 0, y: 0, z: 0, hauteur: currentLine, largeur: currentColumn, isValid: false)
                }
                medianneLine.append(mediannePointCoordinate!)
            }
            if (currentLine % ((Maillage.HEIGHT - 1) / 10) == 0) {
                pourcentage += 10
                print("\(pourcentage)%")
            }
            medianneCoordinatesFile.append(medianneLine)
        }
        // on exporte en fichier type
        self.exportCoordinates(fileName: fileName, coordinates: medianneCoordinatesFile, type: type)
        return medianneCoordinatesFile
    }

/**
 * methode permettant de calculer le %
 * de difference entre un nuage de points
 * et un fichier median
 *
 * @type {[type]}
 */
    func calculerPourcentageDifferenceMedian(fileName: String, medianFileName: String, typeMedian: String) {
        if let path = Bundle.main.path(forResource: "../../../ressource/\(fileName)", ofType: "sdp") {
            do {
                let file = try String(contentsOfFile: path, encoding: .utf8)
                if let pathMedian = Bundle.main.path(forResource: "../../../ressource/\(medianFileName)", ofType: typeMedian) {
                    do {
                        let fileMedian = try String(contentsOfFile: pathMedian, encoding: .utf8)
                        print("Récupèration informations fichier visé...")
                        let targetFile = self.parseSdp(stringFile: file)
                        print("Récupèration informations fichier médian...")
                        let median = self.parseSdp(stringFile: fileMedian)
                        var cptLignes: Double = 0
                        var cptPointsLigne: Double = 0
                        var sommeTaux: Double = 0
                        var sommeTauxLigne: Double = 0
                        var taux: Double = 0
                        var tauxX: Double = 0
                        var tauxY: Double = 0
                        var tauxZ: Double = 0

                        for ligne in 0...Maillage.HEIGHT - 1 {
                            cptPointsLigne = 0
                            sommeTauxLigne = 0
                            for colonne in 0...Maillage.WIDTH - 1 {
                                cptPointsLigne += 1
                                var nbCoordinateConsidered: Double = 0
                                if (median[ligne][colonne].X != 0) {
                                    nbCoordinateConsidered += 1
                                    tauxX = abs(abs(median[ligne][colonne].X - targetFile[ligne][colonne].X) / median[ligne][colonne].X)
                                }
                                if (median[ligne][colonne].Y != 0) {
                                    nbCoordinateConsidered += 1
                                    tauxY = abs(abs(median[ligne][colonne].Y - targetFile[ligne][colonne].Y) / median[ligne][colonne].Y)
                                }
                                if (median[ligne][colonne].Z != 0) {
                                    nbCoordinateConsidered += 1
                                    tauxZ = abs(abs(median[ligne][colonne].Z - targetFile[ligne][colonne].Z) / median[ligne][colonne].Z)
                                }
                                if (nbCoordinateConsidered != 0) {
                                    let tauxMoyen = (tauxX + tauxY + tauxZ) / nbCoordinateConsidered
                                    sommeTauxLigne += tauxMoyen
                                }
                            }
                            cptLignes += 1
                            sommeTaux = sommeTaux + (sommeTauxLigne / cptPointsLigne)
                        }
                        taux = (sommeTaux / cptLignes) * 100
                        print("Le fichier présente une différence de \(taux)% avec le fichier médian.")
                    } catch {
                        print("Ressource ressource/\(medianFileName).\(typeMedian) introuvable")
                        print(error)
                    }
                } else {
                    print("Ressource ressource/\(medianFileName).\(typeMedian) introuvable")
                }
            } catch {
                print("Ressource ressource/\(fileName).sdp introuvable")
                print(error)
            }
        } else {
            print("Ressource ressource/\(fileName).sdp introuvable")
        }
    }

    func loopCalculerPourcentageDifferenceMedian(fileBaseName: String, medianFileName: String, nbFile: Int) {
        var currentFile: String? = nil
        for i in 1...nbFile {
            currentFile = "\(fileBaseName)\(i)"
            print("\(fileBaseName)\(i) : ")
            self.calculerPourcentageDifferenceMedian(fileName: currentFile!, medianFileName: medianFileName, typeMedian: "sdp")
        }
    }

    /**
    * Parcours une série de captures similaires pour construire un maillage
    * rectifié par le surplus de données
    */
    func maillageLoopRectification(fileBaseName: String, nbFile: Int) {
        // on prend comme base le fichier 1
        var stringFile = getStringFile(fileName: fileBaseName+"1")
        // on fait un maillage triangle sur celui-ci
        var maillageObj = self.maillageObject(stringFile: stringFile, fileName: fileBaseName+"1")
        // on parse les autres fichiers
        var cooFiles = [[[Coordinate]]]()
        for i in 1...nbFile {
            cooFiles[i] = self.parseSdp(stringFile: "\(fileBaseName)\(i+1)")
            print("File \(fileBaseName)\(i+1) captured...")
        }

        // valeurs maximales et minimales d'une coordonnée
        let constVector = Vector3D()
        var bInf : Double = 0.0
        var bSup : Double = 0.0
        var e : Double = 0.001
        var temp = Coordinate()
        var refN = Vector3D()
        var triangles = [Triangle]()
        // début de la rectification sur le maillage
        var coordinates = maillageObj.coordinates
        for i in 0...(Maillage.HEIGHT-1) {
            for j in 0...(Maillage.WIDTH-1) {
                var cCoord : Coordinate = coordinates[i][j]
                temp = Coordinate(x: cCoord.X, y: cCoord.Y, z:cCoord.Z, hauteur:cCoord.hauteur, largeur:cCoord.largeur, isValid: cCoord.isValid, triangleH: cCoord.trianglesHaut, triangleB: cCoord.trianglesBas)
                // recupération bornes inf et sup
                bInf = cCoord.Z
                bSup = cCoord.Z
                for k in 1...nbFile {
                    var currentC = cooFiles[k][i][j]
                    if(currentC.Z < bInf) {
                        bInf = currentC.Z
                    } else if(currentC.Z > bSup) {
                        bSup = currentC.Z
                    }
                }
                // on récupère les triangles du bas associé au point de coordonné
                triangles = cCoord.trianglesBas
                // normale de reference sur lequel on base la colinéarité
                refN = triangles[0].normale
                var diff = abs(bSup - bInf)
                for i in stride(from:e, to:diff, by:e) {

                }
                //T0D0 : diminuer ou augmenter les coordonnées des triangles associés en fonction
                // puis recalculer les normales etc...
            }
        }
    }


    func maillageObject(stringFile: String, fileName: String) -> MaillageObject {
        var coordinates = parseSdp(stringFile: stringFile)
        print(coordinates[0][0].X)
        var triangles = [Triangle]()
        for i in 0...(Maillage.HEIGHT-1) {
            for j in 0...(Maillage.WIDTH-1) {
                /**
                *   Algorithme calculant la moyenne des coordonnées sur une grille 10x10
                *   et attribuant cette valeur au point (i,j) parcouru
                */
                let GRILLE = 10
                var sommeX: Double = 0
                var sommeY: Double = 0
                var sommeZ: Double = 0
                var nbPixel: Double = 0
                var c : Coordinate = Coordinate()
                for k in 1...(GRILLE / 2) {
                    if (j + k < Maillage.WIDTH) {
                        for h in 1...(GRILLE / 2) {
                            if (i + h < Maillage.HEIGHT) {
                                //T0D0 : peut être inverser
                                c = coordinates[i + h][j + k]
                                nbPixel = nbPixel + 1
                                sommeX = sommeX + c.X
                                sommeY = sommeY + c.Y
                                sommeZ = sommeZ + c.Z
                            }
                            if (i - h >= 0) {
                                c = coordinates[i - h][j + k]
                                nbPixel = nbPixel + 1
                                sommeX = sommeX + c.X
                                sommeY = sommeY + c.Y
                                sommeZ = sommeZ + c.Z
                            }
                        }
                    }
                    if (j - k >= 0) {
                        for h in 1...(GRILLE / 2) {
                            if (i + h < Maillage.HEIGHT) {
                                c = coordinates[i + h][j - k]
                                nbPixel = nbPixel + 1
                                sommeX = sommeX + c.X
                                sommeY = sommeY + c.Y
                                sommeZ = sommeZ + c.Z
                            }
                            if (i - h >= 0) {
                                c = coordinates[i - h][j - k]
                                nbPixel = nbPixel + 1
                                sommeX = sommeX + c.X
                                sommeY = sommeY + c.Y
                                sommeZ = sommeZ + c.Z
                            }
                        }
                    }
                }
                var currentPoint = coordinates[i][j]
                currentPoint.X = sommeX / nbPixel
                currentPoint.Y = sommeY / nbPixel
                currentPoint.Z = sommeZ / nbPixel

                /**
                * Algorithme de tracé des faces (triangle)
                *
                */
                let FILTRE = 5
                var triangle : Triangle = Triangle()
                // Si le Point est valide
                // on supprime le bruit en ne prenant pas en compte les pixels
                // de hauteur 0 ou > 0.3 && hauteur>0 && hauteur<0.3
                if (currentPoint.isValid) {
                    // Si les voisins de droite et d'en bas sont dans l'image
                    if (((j + FILTRE) < Maillage.WIDTH) && ((i + FILTRE) < Maillage.HEIGHT)) {
                        let right = coordinates[i][j + FILTRE]
                        let down = coordinates[i + FILTRE][j]
                        ////Si les voisins de droite et d'en bas sont valides
                        if (right.isValid && down.isValid) {
                            // Check difference de hauteurZ
                            var diffDroiteZ, diffBasZ: Double
                            diffDroiteZ = abs(currentPoint.Z - right.Z)
                            diffBasZ = abs(currentPoint.Z - down.Z)
                            if (diffDroiteZ < Maillage.MAX_DISTANCE && diffBasZ < Maillage.MAX_DISTANCE) {
                                triangle = Triangle(sommetA: Vector3D(x: currentPoint.X, y: currentPoint.Y, z: currentPoint.Z, id: Maillage.getIdforXY(x: j, y: i)), sommetB: Vector3D(x: down.X, y: down.Y, z: down.Z, id: Maillage.getIdforXY(x: j, y: i + FILTRE)), sommetC: Vector3D(x: right.X, y: right.Y, z: right.Z, id: Maillage.getIdforXY(x: j + FILTRE, y: i)))
                                triangles.append(triangle)
                                currentPoint.addTriangleBas(t: triangle)
                                right.addTriangleBas(t: triangle)
                                down.addTriangleHaut(t: triangle)
                            }
                        }
                    }
                    //Si les voisins de gauche et d'en haut sont dans l'image

                    if (((j - FILTRE) >= 0) && ((i - FILTRE) >= 0)) {
                        let left = coordinates[i][j - FILTRE]
                        let up = coordinates[i - FILTRE][j]
                        if (left.isValid && up.isValid) {
                            // Check difference de hauteurZ
                            var diffGaucheZ, diffHautZ: Double
                            diffGaucheZ = abs(currentPoint.Z - left.Z)
                            diffHautZ = abs(currentPoint.Z - up.Z)
                            if (diffGaucheZ < Maillage.MAX_DISTANCE && diffHautZ < Maillage.MAX_DISTANCE) {
                                triangle = Triangle(sommetA: Vector3D(x: currentPoint.X, y: currentPoint.Y, z: currentPoint.Z, id: Maillage.getIdforXY(x: j, y: i)), sommetB: Vector3D(x: up.X, y: up.Y, z: up.Z, id: Maillage.getIdforXY(x: j, y: i - FILTRE)), sommetC: Vector3D(x: left.X, y: left.Y, z: left.Z, id: Maillage.getIdforXY(x: j - FILTRE, y: i)))
                                triangles.append(triangle)
                                currentPoint.addTriangleHaut(t: triangle)
                                left.addTriangleHaut(t:triangle)
                                up.addTriangleBas(t:triangle)
                            }
                        }

                    }
                }
            }
        }

        // construction maillage objet
        var maillageObjet = MaillageObject(coordinates:coordinates, faces:triangles)

        return maillageObjet
    }

    /*
    * récupère un fichier SDP et effectue
    * un maillage en format OFF
    * @type {[type]}
    **/
    func maillage(stringFile: String, fileName: String, typeExport: String, byNormale: Bool) -> String {
        var cptPoints = 0
        var cptTriangle = 0

        var listPtsByLine = [String]()
        var listPoints = ""

        //arrayNormal [abs] [ord] [Nx/Ny/Nz/nbNormals/isValid]
//        var arrayNormal = [[[Double]]]()
//        var arrayNormal = [[Double]](repeating: [Double](repeating: 0, count: self.Maillage.HEIGHT), count: Maillage.WIDTH)
        var arrayNormal = [[[Double]]](repeating: [[Double]](repeating: [Double](repeating: 0, count: 5), count: Maillage.HEIGHT), count: Maillage.WIDTH)

        var listTriangleByLine = [String]()
        var listTriangles = ""
        var listTriangleObj = [Triangle]()
        var nbListTriangle = 0

        var pourcentage = -10

        var header = "OFF\n# \(fileName).off\n# \(fileName)\n\n"

        //Chaque ligne dans un tableau line
        let line = stringFile.components(separatedBy: .newlines)

        for pixelY in 0...(Maillage.HEIGHT - 1) {
            listPoints = ""
            listTriangles = ""
            for pixelX in 0...(Maillage.WIDTH - 1) {

                cptPoints = cptPoints + 1
                // On récupère la ligne du pixel dans le tableau
                // On récupère les données du pixel (X Y Z HAUTEUR LARGEUR isValid)
                var dataArr = line[Maillage.getIdforXY(x: pixelX, y: pixelY)].components(separatedBy: " ")
//                let GRILLE = 10
//                var sommeX : Double = 0
//                var sommeY : Double = 0
//                var sommeZ: Double = 0
//                var nbPixel : Double = 0
//                var c : [String]
//                for i in 1...(GRILLE/2) {
//                    if(pixelX + i < Maillage.WIDTH) {
//                        for j in 1...(GRILLE/2) {
//                            if(pixelY + j < Maillage.HEIGHT) {
//                                c = line[Maillage.getIdforXY(x: pixelX+i, y: pixelY+j)].components(separatedBy: " ")
//                                nbPixel = nbPixel + 1
//                                sommeX = sommeX + Double(c[0])!
//                                sommeY = sommeY + Double(c[1])!
//                                sommeZ = sommeZ + Double(c[2])!
//                            }
//                            if(pixelY - j >= 0) {
//                                c = line[Maillage.getIdforXY(x: pixelX+i, y: pixelY-j)].components(separatedBy: " ")
//                                nbPixel = nbPixel + 1
//                                sommeX = sommeX + Double(c[0])!
//                                sommeY = sommeY + Double(c[1])!
//                                sommeZ = sommeZ + Double(c[2])!
//                            }
//                        }
//                    }
//                    if(pixelX - i >= 0) {
//                        for j in 1...(GRILLE/2) {
//                            if(pixelY + j < Maillage.HEIGHT) {
//                                c = line[Maillage.getIdforXY(x: pixelX-i, y: pixelY+j)].components(separatedBy: " ")
//                                nbPixel = nbPixel + 1
//                                sommeX = sommeX + Double(c[0])!
//                                sommeY = sommeY + Double(c[1])!
//                                sommeZ = sommeZ + Double(c[2])!
//                            }
//                            if(pixelY - j >= 0) {
//                                c = line[Maillage.getIdforXY(x: pixelX-i, y: pixelY-j)].components(separatedBy: " ")
//                                nbPixel = nbPixel + 1
//                                sommeX = sommeX + Double(c[0])!
//                                sommeY = sommeY + Double(c[1])!
//                                sommeZ = sommeZ + Double(c[2])!
//                            }
//                        }
//                    }
//                }
//                dataArr[0] = String(sommeX / nbPixel)
//                dataArr[1] = String(sommeY / nbPixel)
//                dataArr[2] = String(sommeZ / nbPixel)

                // ajouts des coordonnées en x y z
                switch (typeExport) {
                case "off":
                    listPoints = listPoints + dataArr[0] + " " + dataArr[1] + " " + dataArr[2] + "\n"
                case "obj":
                    listPoints = listPoints + "v " + dataArr[0] + " " + dataArr[1] + " " + dataArr[2] + "\n"
                case "csv":
                    listPoints = listPoints + dataArr[0] + ";" + dataArr[1] + ";" + dataArr[2] + ";" + dataArr[3] + ";" + dataArr[4] + ";" + dataArr[5] + "\n"
                default:
                    listPoints = listPoints + dataArr[0] + " " + dataArr[1] + " " + dataArr[2] + "\n"
                }
                let hauteurX: Double = NSString(string: dataArr[0]).doubleValue
                let hauteurY: Double = NSString(string: dataArr[1]).doubleValue
                let hauteurZ: Double = NSString(string: dataArr[2]).doubleValue
                var cX, cY, cZ: Double
                cX = Double(dataArr[0])!
                cY = Double(dataArr[1])!
                cZ = Double(dataArr[2])!
                /**
                * VARIABLE DE FILTRE (prend en compte 1 pixel sur FILTRE dans le tracé d'un triangle)
                * @type {Number}
                */
                let FILTRE = 5

                // Si le Point est valide
                // on supprime le bruit en ne prenant pas en compte les pixels
                // de hauteur 0 ou > 0.3 && hauteur>0 && hauteur<0.3
                if (dataArr[5] == "1" && typeExport != "csv") {

                    // Si les voisins de droite et d'en bas sont dans l'image
                    if (((pixelX + FILTRE) < Maillage.WIDTH) && ((pixelY + FILTRE) < Maillage.HEIGHT)) {
                        let dataArrRIGHT = line[Maillage.getIdforXY(x: (pixelX + FILTRE), y: pixelY)].components(separatedBy: " ")
                        let dataArrDOWN = line[Maillage.getIdforXY(x: pixelX, y: (pixelY + FILTRE))].components(separatedBy: " ")

                        ////Si les voisins de droite et d'en bas sont valides
                        if ((dataArrRIGHT[5] == "1") && (dataArrDOWN[5] == "1")) {


                            // Check difference de hauteurX
//                            var rX, dX, diffDroiteX, diffBasX: Double
//
//                            rX = Double(dataArrRIGHT[0])!
//                            dX = Double(dataArrDOWN[0])!
//                            diffDroiteX = abs(hauteurX - rX)
//                            diffBasX = abs(hauteurX - dX)
//
//
//                            // Check difference de hauteurY
//                            var rY, dY, diffDroiteY, diffBasY: Double
//
//                            rY = Double(dataArrRIGHT[0])!
//                            dY = Double(dataArrDOWN[0])!
//                            diffDroiteY = abs(hauteurY - rY)
//                            diffBasY = abs(hauteurY - dY)


                            // Check difference de hauteurZ
                            var rZ, dZ, diffDroiteZ, diffBasZ: Double

                            rZ = Double(dataArrRIGHT[2])!
                            dZ = Double(dataArrDOWN[2])!
                            diffDroiteZ = abs(hauteurZ - rZ)
                            diffBasZ = abs(hauteurZ - dZ)


//                            if (diffDroiteX < Maillage.MAX_DISTANCE && diffBasX < Maillage.MAX_DISTANCE && diffDroiteY < Maillage.MAX_DISTANCE && diffBasY < Maillage.MAX_DISTANCE && diffDroiteZ < Maillage.MAX_DISTANCE && diffBasZ < Maillage.MAX_DISTANCE) {
                            if (diffDroiteZ < Maillage.MAX_DISTANCE && diffBasZ < Maillage.MAX_DISTANCE) {
                                cptTriangle = cptTriangle + 1

                                if (byNormale) {
                                    listTriangles = listTriangles + "f "
                                    listTriangles += String(Maillage.getIdforXY(x: pixelX, y: pixelY) + 1) + "//" + String(Maillage.getIdforXY(x: pixelX, y: pixelY) + 1) + " "
                                    listTriangles += String(Maillage.getIdforXY(x: pixelX + FILTRE, y: pixelY) + 1) + "//" + String(Maillage.getIdforXY(x: pixelX + FILTRE, y: pixelY) + 1) + " "
                                    listTriangles += String(Maillage.getIdforXY(x: pixelX, y: pixelY + FILTRE) + 1) + "//" + String(Maillage.getIdforXY(x: pixelX, y: pixelY + FILTRE) + 1) + "\n"
                                } else {
                                    listTriangles = listTriangles + "3 " + String(Maillage.getIdforXY(x: pixelX, y: pixelY)) + " " + String(Maillage.getIdforXY(x: pixelX + FILTRE, y: pixelY)) + " " + String(Maillage.getIdforXY(x: pixelX, y: pixelY + FILTRE)) + "\n"
                                }

                                // calcul de la normale
                                var rX, rY, dX, dY, nX, nY, nZ, norme: Double
                                rX = Double(dataArrRIGHT[0])!
                                rY = Double(dataArrRIGHT[1])!
                                dX = Double(dataArrDOWN[0])!
                                dY = Double(dataArrDOWN[1])!

                                var triangle = Triangle(sommetA:Vector3D(x:cX, y:cY, z:cZ, id:Maillage.getIdforXY(x: pixelX, y: pixelY)), sommetB:Vector3D(x:dX, y:dY, z:dZ, id:Maillage.getIdforXY(x: pixelX, y: pixelY + FILTRE)), sommetC:Vector3D(x:rX, y:rY, z:rZ, id:Maillage.getIdforXY(x: pixelX + FILTRE, y: pixelY)))
                                nX = (rY - cY) * (dZ - hauteurZ) - (rZ - hauteurZ) * (dY - cY)
                                nY = (rZ - hauteurZ) * (dX - cX) - (rX - cX) * (dZ - hauteurZ)
                                nZ = (rX - cX) * (dY - cY) - (rY - cY) * (dX - cX)
                                norme = sqrt((nX * nX) + (nY * nY) + (nZ * nZ))
                                // normale :
                                nX = nX / norme
                                nY = nY / norme
                                nZ = nZ / norme


                                //save in array
                                arrayNormal[pixelX][pixelY][0] += nX
                                arrayNormal[pixelX][pixelY][1] += nY
                                arrayNormal[pixelX][pixelY][2] += nZ
                                arrayNormal[pixelX][pixelY][3] += 1
                                arrayNormal[pixelX][pixelY][4] = Double(dataArr[5])!


                                //T0D0: affichage normale + moyenne des normales pour chaque sommet
                            }
                            //print("droite : \(diffDroite) | bas : \(diffBas)")
                            //Alors on créé un triangle
                        }
                    }

                    //Si les voisins de gauche et d'en haut sont dans l'image
                    if (((pixelX - FILTRE) >= 0) && ((pixelY - FILTRE) >= 0)) {
                        let dataArrLEFT = line[Maillage.getIdforXY(x: (pixelX - FILTRE), y: pixelY)].components(separatedBy: " ")
                        let dataArrUP = line[Maillage.getIdforXY(x: pixelX, y: (pixelY - FILTRE))].components(separatedBy: " ")

                        ////Si les voisins de droite et d'en bas sont valides
                        if ((dataArrLEFT[5] == "1") && (dataArrUP[5] == "1")) {


                            // Check difference de hauteurX
//                            var lX, uX, diffGaucheX, diffHautX: Double
//
//                            lX = Double(dataArrLEFT[0])!
//                            uX = Double(dataArrUP[0])!
//                            diffGaucheX = abs(hauteurX - lX)
//                            diffHautX = abs(hauteurX - uX)
//
//
//                            // Check difference de hauteurY
//                            var lY, uY, diffGaucheY, diffHautY: Double
//
//                            lY = Double(dataArrLEFT[0])!
//                            uY = Double(dataArrUP[0])!
//                            diffGaucheY = abs(hauteurY - lY)
//                            diffHautY = abs(hauteurY - uY)


                            // Check difference de hauteurZ
                            var lZ, uZ, diffGaucheZ, diffHautZ: Double

                            lZ = Double(dataArrLEFT[2])!
                            uZ = Double(dataArrUP[2])!
                            diffGaucheZ = abs(hauteurZ - lZ)
                            diffHautZ = abs(hauteurZ - uZ)


                            if (diffGaucheZ < Maillage.MAX_DISTANCE && diffHautZ < Maillage.MAX_DISTANCE) {
//                            if (diffGaucheX < Maillage.MAX_DISTANCE && diffHautX < Maillage.MAX_DISTANCE && diffGaucheY < Maillage.MAX_DISTANCE && diffHautY < Maillage.MAX_DISTANCE && diffGaucheZ < Maillage.MAX_DISTANCE && diffHautZ < Maillage.MAX_DISTANCE) {

                                //Alors on créé un triangle
                                cptTriangle = cptTriangle + 1

                                if (byNormale) {
                                    listTriangles = listTriangles + "f "
                                    listTriangles += String(Maillage.getIdforXY(x: pixelX, y: pixelY) + 1) + "//" + String(Maillage.getIdforXY(x: pixelX, y: pixelY) + 1) + " "
                                    listTriangles += String(Maillage.getIdforXY(x: pixelX - FILTRE, y: pixelY) + 1) + "//" + String(Maillage.getIdforXY(x: pixelX - FILTRE, y: pixelY) + 1) + " "
                                    listTriangles += String(Maillage.getIdforXY(x: pixelX, y: pixelY - FILTRE) + 1) + "//" + String(Maillage.getIdforXY(x: pixelX, y: pixelY - FILTRE) + 1) + "\n"
                                } else {
                                    listTriangles = listTriangles + "3 " + String(Maillage.getIdforXY(x: pixelX, y: pixelY)) + " " + String(Maillage.getIdforXY(x: pixelX - FILTRE, y: pixelY)) + " " + String(Maillage.getIdforXY(x: pixelX, y: pixelY - FILTRE)) + "\n"
                                }

                                // calcul de la normale
                                var lX, lY, uX, uY, nX, nY, nZ, norme: Double
                                lX = Double(dataArrLEFT[0])!
                                lY = Double(dataArrLEFT[1])!
                                uX = Double(dataArrUP[0])!
                                uY = Double(dataArrUP[1])!
                                nX = (lY - cY) * (uZ - hauteurZ) - (lZ - hauteurZ) * (uY - cY)
                                nY = (lZ - hauteurZ) * (uX - cX) - (lX - cX) * (uZ - hauteurZ)
                                nZ = (lX - cX) * (uY - cY) - (lY - cY) * (uX - cX)
                                norme = sqrt((nX * nX) + (nY * nY) + (nZ * nZ))

                                // normale :
                                nX = nX / norme
                                nY = nY / norme
                                nZ = nZ / norme

                                //save in array
                                arrayNormal[pixelX][pixelY][0] += nX
                                arrayNormal[pixelX][pixelY][1] += nY
                                arrayNormal[pixelX][pixelY][2] += nZ
                                arrayNormal[pixelX][pixelY][3] += 1
                                arrayNormal[pixelX][pixelY][4] = Double(dataArr[5])!
                            }

                        }
                    }
                }
            }
            if (pixelY % ((Maillage.HEIGHT - 1) / 10) == 0) {
                pourcentage += 10
                if (pourcentage != 100) {
                    print("\(pourcentage)%\r", terminator: "")
                    fflush(stdout)
                } else {
                    print("\(pourcentage)%\r\n")
                }

            }
            listPtsByLine.append(listPoints)
            listTriangleByLine.append(listTriangles)
            nbListTriangle = nbListTriangle + 1
        }


        var outputText = ""

        if (typeExport == "obj") {


            outputText = "#" + fileName + "OBJ File\n#\ng " + fileName + "\n\n\n"


            for pixelY in 0...(Maillage.HEIGHT - 1) {
                outputText = outputText + listPtsByLine[pixelY]
            }

            //calcul de la moyenne de la normale par points

            for pixelY in 0...(Maillage.HEIGHT - 1) {
                for pixelX in 0...(Maillage.WIDTH - 1) {

                    var ligneNormale = ""

                    //if isValid
                    if (arrayNormal[pixelX][pixelY][4] == 1) {
                        arrayNormal[pixelX][pixelY][0] = arrayNormal[pixelX][pixelY][0] / arrayNormal[pixelX][pixelY][3]  //Nx
                        arrayNormal[pixelX][pixelY][1] = arrayNormal[pixelX][pixelY][1] / arrayNormal[pixelX][pixelY][3]  //Ny
                        arrayNormal[pixelX][pixelY][2] = arrayNormal[pixelX][pixelY][2] / arrayNormal[pixelX][pixelY][3]  //Nz

                        outputText += "vn \(arrayNormal[pixelX][pixelY][0])  \(arrayNormal[pixelX][pixelY][1]) \(arrayNormal[pixelX][pixelY][2]) \n"
                    } else {
//                        outputText += "vn 90 90 90 \n"
                    }

                }
            }

            outputText = outputText + "\n"
            for i in 0...(nbListTriangle - 1) {
                outputText = outputText + listTriangleByLine[i]
            }


        } else if (typeExport == "pgm" || typeExport == "ppm") {

            var scalar, min, max, miseAEchelle, R, G, B: Double

            min = DBL_MAX
            max = -DBL_MAX

            // Recherche du min et max pour mettre les valeurs entre 0 et 255
            for pixelY in 0...(Maillage.HEIGHT - 1) {
                for pixelX in 0...(Maillage.WIDTH - 1) {

                    if (arrayNormal[pixelX][pixelY][4] == 1) {

                        scalar = arrayNormal[pixelX][pixelY][0] * 1 + arrayNormal[pixelX][pixelY][1] * 1 + arrayNormal[pixelX][pixelY][2] * 1

                        if (scalar > max) {
                            max = scalar
                        }
                        if (scalar < min) {
                            min = scalar
                        }
                    }
                }
            }




            if(typeExport == "pgm") {
                outputText = "P2 \n#\(fileName) \n \(Maillage.HEIGHT) \(Maillage.WIDTH) \n255\n"
            } else{
                outputText = "P3 \n#\(fileName) \n \(Maillage.HEIGHT) \(Maillage.WIDTH) \n255\n"
            }




            miseAEchelle = 256 / (abs(min) * max)

            for pixelX in 0...(Maillage.WIDTH - 1) {
                for pixelY in 0...(Maillage.HEIGHT - 1) {
                    //if isValid
                    if (arrayNormal[pixelX][pixelY][4] == 1) {

                        //vector light = (1,1,1)

                        R = arrayNormal[pixelX][pixelY][0]
                        G = arrayNormal[pixelX][pixelY][1]
                        B = arrayNormal[pixelX][pixelY][2]

                        scalar = R * 1 + G * 1 + B * 1

                        //valeur entre 0 et 255 :
                        scalar = scalar * miseAEchelle + 128
                        R = R * miseAEchelle + 128
                        G = G * miseAEchelle + 128
                        B = B * miseAEchelle + 128

                    } else {
                        scalar = 0
                        R = 0
                        G = 0
                        B = 0
                    }

                    if(typeExport == "pgm") {
                        outputText += "\(Int(scalar)) "
                    } else{
                        outputText += "\(Int(R)) \(Int(G)) \(Int(B)) "
                    }


                }
            }

        } else {
            if (typeExport == "off") {
                header += "\(cptPoints) \(cptTriangle) 0\n\n"
                outputText = header
            }


            for pixelY in 0...(Maillage.HEIGHT - 1) {
                outputText = outputText + listPtsByLine[pixelY]
            }

            if (typeExport == "off") {
                outputText = outputText + "\n"
                for i in 0...(nbListTriangle - 1) {
                    outputText = outputText + listTriangleByLine[i]
                }
            }
        }
        return outputText
    }

    /**
    * Retourne une chaine de caractère avec le contenu du fichier fileName
    */
    func getStringFile(fileName:String) -> String {
        let fileManager = FileManager()
        let path = fileManager.currentDirectoryPath
        var file = ""
        if let path = Bundle.main.path(forResource:"../../../ressource/\(fileName)", ofType:"sdp") {
            do {
                let outputFileName = "../../../result/\(fileName).\(type)"
                let url = URL(fileURLWithPath:"").appendingPathComponent(outputFileName)
                do {
                    file = try String(contentsOfFile:path, encoding:.utf8)
                } catch {
                    print(error)
                    print("ressource/\(fileName) n'est pas un fichier SDP.")
                }
            }
        }
        return file
    }

    /*
    * Convertis une capture depuis Camera True-Depth
    * sous format SDP vers le format précisé (type)
    * et effectue un maillage triangle
    *
    */
    func sdpMaillageExport(fileName:String, type:String, byNormale:Bool) {
        var stringFile = getStringFile(fileName: fileName)
        if(stringFile != "") {
            //let maillage = self.maillage(stringFile:file, fileName:fileName, typeExport:type, byNormale:byNormale)
            //let maillage = self.maillage(stringFile:file, fileName:fileName+"2", typeExport:type, byNormale:false)
            //// T0D0 : gestion des types d'export
            let maillage = self.maillageObject(stringFile: stringFile, fileName: fileName).toOff(fileName: fileName)
            /*
            * Write result in .type file
            */
            let outputFileName = "../../../result/\(fileName).off"
            print("Generating [\(outputFileName)]")
            let url = URL(fileURLWithPath:"").appendingPathComponent(outputFileName)
            let outputData = Data(maillage.utf8)
            do {
                try outputData.write(to: url, options: .atomic)
            } catch {
                print(error)
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
    func loopSdpMaillageToType(fileBaseName:String, numberOfFiles:Int, type:String, byNormale:Bool) {

        if (!fileBaseName.isEmpty && numberOfFiles > 0 && (type == "off" || type == "csv")) {
            for nbFile in 1...numberOfFiles {
                if let path = Bundle.main.path(forResource:"../../../ressource/\(fileName)\(nbFile)", ofType:"sdp") {
                    do {
                        var dir = "csv"
                        if (type == "off") {
                            dir = "out"
                        }
                        let outputFileName = "../../../\(dir)/\(fileName)\(nbFile).\(type)"
                        print("Generating [\(outputFileName)]")
                        let url = URL(fileURLWithPath:"").appendingPathComponent(outputFileName)
                        let file = try String(contentsOfFile:path, encoding:.utf8)
                        let maillage = self.maillage(stringFile:file, fileName:"../../../ressource/\(fileName)\(nbFile)", typeExport:type, byNormale:byNormale)
                        let outputData = Data(maillage.utf8)
                        do {
                            try outputData.write(to:url, options:.atomic)
                        } catch {
                            print("error: \(error)")
                        }

                    } catch {
                        print(error)
                        print("ressource/\(fileName) n'est pas un fichier SDP.")
                    }
                }
            }
        }
    }
}
