//
// Created by xnr on 14/05/18.
//

import Foundation

class MaillageObject {

    var coordinates: [[Coordinate]]
    var faces: [Triangle]

    init(coordinates: [[Coordinate]], faces: [Triangle]) {
        self.coordinates = coordinates
        self.faces = faces
    }

    func exportOff(fileName: String) {
        var header = "OFF\n # \(fileName)\n\n\(coordinates.count) \(faces.count)"
        var outputCoordinates : String = ""
        var outputTriangle : String = "3 "
        for pixelY in coordinates {
            for pixelX in pixelY {
                outputCoordinates.append("\(pixelX.X) \(pixelX.Y) \(pixelX.Z)\n")
            }
        }
        for t in faces {
            for i in 0..<3 {
                outputTriangle.append(String(t.sommets[i].id))
                if(i < 2) {
                    outputTriangle.append(" ")
                } else {
                    outputTriangle.append("\n")
                }

            }
        }
    }
}
