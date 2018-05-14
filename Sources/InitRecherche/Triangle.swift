//
// Created by xnr on 14/05/18.
//

import Foundation

class Triangle {

    var sommets : [Vector3D]
    var normale : Vector3D

    init(sommetA : Vector3D, sommetB : Vector3D, sommetC : Vector3D) {
        sommets[0] = sommetA
        sommets[1] = sommetB
        sommets[2] = sommetC
        normale = (sommetA*sommetB)^(sommetA*sommetC)
    }
}
