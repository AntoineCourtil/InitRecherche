import Foundation

class Coordinate {

    var X, Y, Z: Double
    var hauteur, largeur: Int
    var isValid: Bool
    var triangles: [Triangle]

    init() {
        self.X = 0
        self.Y = 0
        self.Z = 0
        self.hauteur = 0
        self.largeur = 0
        self.isValid = false
        self.triangles = [Triangle]()
    }

    init(x: String, y: String, z: String, hauteur: String, largeur: String, isValid: Bool) {
        self.X = NSString(string: x).doubleValue
        self.Y = NSString(string: y).doubleValue
        self.Z = NSString(string: z).doubleValue
        self.hauteur = Int(hauteur)!
        self.largeur = Int(largeur)!
        self.isValid = isValid
        self.triangles = [Triangle]()
    }

    init(x: Double, y: Double, z: Double, hauteur: Int, largeur: Int, isValid: Bool) {
        self.X = x
        self.Y = y
        self.Z = z
        self.hauteur = hauteur
        self.largeur = largeur
        self.isValid = isValid
        self.triangles = [Triangle]()
    }

    init(x: Double, y: Double, z: Double, hauteur: Int, largeur: Int, isValid: Bool, triangles: [Triangle]) {
        self.X = x
        self.Y = y
        self.Z = z
        self.hauteur = hauteur
        self.largeur = largeur
        self.isValid = isValid
        self.triangles = triangles
    }

    func copy() -> Coordinate {
        var copy = Coordinate()
        copy.X = self.X
        copy.Y = self.Y
        copy.Z = self.Z
        copy.hauteur = self.hauteur
        copy.largeur = self.largeur
        copy.isValid = self.isValid
        var index = 0
        for t in self.triangles {
            copy.triangles.insert(Triangle(sommetA: Vector3D(v:t.sommetA), sommetB: Vector3D(v:t.sommetB), sommetC: Vector3D(v:t.sommetC)), at:index)
            index = index + 1
        }
        return copy
    }

    func setZ(z: Double, sommet: Vector3D) {
        for t in self.triangles {
            if(t.sommetA == sommet) {
                t.sommetA.z = z
            } else if (t.sommetB == sommet) {
                t.sommetB.z = z
            } else if(t.sommetC == sommet) {
                t.sommetC.z = z
            }

        }
    }



    func nbTriangle() -> Int {
        return self.triangles.count
    }



}
