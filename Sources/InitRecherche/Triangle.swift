import Foundation

class Triangle {

    var sommets : [Vector3D]
    var normale : Vector3D

    init() {
        self.sommets = [Vector3D]()
        self.normale = Vector3D(x:0, y:0, z:0)
    }

    init(sommetA : Vector3D, sommetB : Vector3D, sommetC : Vector3D) {
        self.sommets = [Vector3D]()
        self.sommets.append(sommetA)
        self.sommets.append(sommetC)
        self.sommets.append(sommetB)
        self.normale = ((sommetB-sommetA)^(sommetC-sommetA))
        self.normale.normalize()
    }
}
