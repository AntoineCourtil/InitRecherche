import Foundation

class Triangle {

    var sommets : [Vector3D]
    var normale : Vector3D

    init(sommetA : Vector3D, sommetB : Vector3D, sommetC : Vector3D) {
        self.sommets = [Vector3D]()
        self.sommets.append(sommetA)
        self.sommets.append(sommetB)
        self.sommets.append(sommetC)
        self.normale = (sommetB-sommetA)^(sommetC-sommetA)
    }
}
