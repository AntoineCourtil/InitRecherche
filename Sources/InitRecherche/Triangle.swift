import Foundation

class Triangle {

    var sommetA: Vector3D
    var sommetB: Vector3D
    var sommetC: Vector3D
    var normale : Vector3D

    init() {
        self.sommetA = Vector3D()
        self.sommetB = Vector3D()
        self.sommetC = Vector3D()
        self.normale = Vector3D(x:0, y:0, z:0)
    }

    init(sommetA : Vector3D, sommetB : Vector3D, sommetC : Vector3D) {
        self.sommetA = sommetA
        self.sommetB = sommetB
        self.sommetC = sommetC
        self.normale = Vector3D()
        self.computeNormal()
    }

    func computeNormal() {
        //print("ancienne normale : \(self.normale)")
        self.normale = ((sommetB-sommetA)^(sommetC-sommetA))
        self.normale.normalize()

        //print("nouvelle normale : \(self.normale)")
    }
}
