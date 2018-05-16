import Foundation

class Coordinate {

    var X, Y, Z: Double
    var hauteur, largeur: Int
    var isValid: Bool
    var trianglesHaut : [Triangle]
    var trianglesBas : [Triangle]

    init() {
        self.X = 0
        self.Y = 0
        self.Z = 0
        self.hauteur = 0
        self.largeur = 0
        self.isValid = false
        self.trianglesHaut = [Triangle]()
        self.trianglesBas = [Triangle]()
    }

    init(x: String, y: String, z: String, hauteur: String, largeur: String, isValid: Bool) {
        self.X = NSString(string: x).doubleValue
        self.Y = NSString(string: y).doubleValue
        self.Z = NSString(string: z).doubleValue
        self.hauteur = Int(hauteur)!
        self.largeur = Int(largeur)!
        self.isValid = isValid
        self.trianglesHaut = [Triangle]()
        self.trianglesBas = [Triangle]()
    }

    init(x: Double, y: Double, z: Double, hauteur: Int, largeur: Int, isValid: Bool) {
        self.X = x
        self.Y = y
        self.Z = z
        self.hauteur = hauteur
        self.largeur = largeur
        self.isValid = isValid
        self.trianglesHaut = [Triangle]()
        self.trianglesBas = [Triangle]()
    }

    func addTriangleHaut(t: Triangle) {
        self.trianglesHaut.append(t)
    }

    func addTriangleBas(t: Triangle) {
        self.trianglesBas.append(t)
    }



}
