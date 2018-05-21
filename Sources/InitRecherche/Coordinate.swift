import Foundation

class Coordinate {

    var X, Y, Z: Double
    var hauteur, largeur: Int
    var isValid: Bool
    var triangles: [Triangle]
    var nbTriangle: Int

    init() {
        self.X = 0
        self.Y = 0
        self.Z = 0
        self.hauteur = 0
        self.largeur = 0
        self.isValid = false
        self.triangles = [Triangle](repeating:Triangle(), count:6)
        self.nbTriangle = 0

    }

    init(x: String, y: String, z: String, hauteur: String, largeur: String, isValid: Bool) {
        self.X = NSString(string: x).doubleValue
        self.Y = NSString(string: y).doubleValue
        self.Z = NSString(string: z).doubleValue
        self.hauteur = Int(hauteur)!
        self.largeur = Int(largeur)!
        self.isValid = isValid
        self.triangles = [Triangle](repeating:Triangle(),count:6)
        self.nbTriangle = 0
    }

    init(x: Double, y: Double, z: Double, hauteur: Int, largeur: Int, isValid: Bool) {
        self.X = x
        self.Y = y
        self.Z = z
        self.hauteur = hauteur
        self.largeur = largeur
        self.isValid = isValid
        self.triangles = [Triangle](repeating:Triangle(),count:6)
        self.nbTriangle = 0
    }

    init(x: Double, y: Double, z: Double, hauteur: Int, largeur: Int, isValid: Bool, triangles: [Triangle]) {
        self.X = x
        self.Y = y
        self.Z = z
        self.hauteur = hauteur
        self.largeur = largeur
        self.isValid = isValid
        self.triangles = triangles
        self.nbTriangle = 0
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
            copy.triangles[index] = Triangle(sommetA: Vector3D(v:t.sommetA), sommetB: Vector3D(v:t.sommetB), sommetC: Vector3D(v:t.sommetC))
            index = index + 1
        }
        copy.nbTriangle = self.nbTriangle
        return copy
    }

    func setZ(z: Double, sommet: Vector3D) {
//        print("setZ \(nbTriangle)")
        self.Z = z
        var i = 0
        for t in self.triangles {
//            print("I = \(i) \(t.sommetA) === \(sommet)")
            if(t.sommetA == sommet) {
//                print("on change le z A! ==> \(t.sommetA.z)")
                t.sommetA.z = z
//                print("====> \(t.sommetA.z)")
            } else if (t.sommetB == sommet) {
//                print("on change le z B! ==> \(t.sommetB.z)")
                t.sommetB.z = z
//                print("====> \(t.sommetB.z)")
            } else if(t.sommetC == sommet) {
//                print("on change le z C! ==> \(t.sommetC.z)")
                t.sommetC.z = z
//                print("====> \(t.sommetC.z)")
            }

            t.computeNormal()
            if(i == 0) {
//                print("compute normal donne : \(t.normale)")
            }
            i = i + 1
        }
    }

    func getNbTriangle() -> Int {
        return self.nbTriangle
    }



}
