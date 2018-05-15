//
// Created by xnr on 14/05/18.
//

import Foundation

class MaillageObject {

    var coordinates: [[Coordinate]]
    var faces: [Triangle]

    init() {
        self.coordinates = [[Coordinate]]()
        self.faces = [Triangle]()
    }

    init(coordinates: [[Coordinate]], faces: [Triangle]) {
        self.coordinates = coordinates
        self.faces = faces
    }

    func toOff(fileName: String) -> String {
        var header : String = "OFF\n#\(fileName)\n\n\(coordinates.count*coordinates[0].count) \(faces.count) 0\n"
        var outputCoordinates : String = ""
        var outputTriangle : String = ""
        for pixelY in coordinates {
            for pixelX in pixelY {
                outputCoordinates += "\(String(pixelX.X)) \(String(pixelX.Y)) \(String(pixelX.Z))\n"
            }
        }
        outputCoordinates += "\n"
        for t in faces {
            outputTriangle += "3 "
            for i in 0...2 {
                outputTriangle += String(t.sommets[i].id)
                if(i < 2) {
                    outputTriangle += " "
                } else {
                    outputTriangle += "\n"
                }

            }
        }
        return header + outputCoordinates + outputTriangle
    }
}
