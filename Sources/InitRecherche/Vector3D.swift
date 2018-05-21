import Foundation

public struct Vector3D {

    var x: Double
    var y: Double
    var z: Double
    var id : Int

    init() {
        self.x = 0
        self.y = 0
        self.z = 0
        self.id = 0
    }

    init(x: Double, y:Double, z:Double) {
        self.x = x
        self.y = y
        self.z = z
        self.id = 0
    }

    init(x: Double, y:Double, z:Double, id: Int) {
        self.x = x
        self.y = y
        self.z = z
        self.id = id
    }

    init(v: Vector3D) {
        self.x = v.x
        self.y = v.y
        self.z = v.z
        self.id = v.id
    }

    func getNorme() -> Double {
        return  (self.x*self.x+self.y*self.y+self.z*self.z).squareRoot()
    }

    mutating func normalize() {
        let norm = self.getNorme()
        if(norm > 0) {
            self.x = self.x / norm
            self.y = self.y / norm
            self.z = self.z / norm
        }
    }

    var description: String {
        let string = "\(self.x);\(self.y);\(self.z)"
        return string
    }
}

extension Vector3D {

    static func +(left:Vector3D, right:Vector3D) -> Vector3D{
        return Vector3D(x:left.x+right.x, y:left.y+right.y, z:left.z+right.z)
    }

    static func -(left:Vector3D, right:Vector3D) -> Vector3D{
        return Vector3D(x:left.x-right.x, y:left.y-right.y, z:left.z-right.z)
    }

    static func *(left:Vector3D, right:Vector3D) -> Double {
        return left.x*right.x + left.y*right.y + left.z*right.z
    }

    static func /(left:Vector3D, right:Double) -> Vector3D{
        return Vector3D(x:left.x/right, y: left.y/right, z: left.z/right)
    }

    static func ^(left:Vector3D, right:Vector3D) -> Vector3D {
        return Vector3D(x:left.y * right.z - left.z * right.y, y:left.z * right.x - left.x * right.z, z:left.x * right.y - left.y * right.x)
    }

    static func ==(left:Vector3D, right:Vector3D) -> Bool {
        //return (left.x == right.x) && (left.y == right.y) && (left.z == right.z)
        return left.id == right.id
    }

    static func <(left:Vector3D, right:Vector3D) -> Bool {
        var leftSum = (abs(left.x) + abs(left.y) + abs(left.z))
        var rightSum = (abs(right.x) + abs(right.y) + abs(right.z))
        return leftSum < rightSum
    }

    static func >(left:Vector3D, right:Vector3D) -> Bool {
        var leftSum = (abs(left.x) + abs(left.y) + abs(left.z))
        var rightSum = (abs(right.x) + abs(right.y) + abs(right.z))
        return leftSum > rightSum
    }

    static func >=(left:Vector3D, right:Vector3D) -> Bool {
        var leftSum = (abs(left.x) + abs(left.y) + abs(left.z))
        var rightSum = (abs(right.x) + abs(right.y) + abs(right.z))
        return leftSum >= rightSum
    }
}
