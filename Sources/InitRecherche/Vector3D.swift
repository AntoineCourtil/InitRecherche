import Foundation

public struct Vector3D {

    let x: Double
    let y: Double
    let z: Double
    let id : Int

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

    static func ^(left:Vector3D, right:Vector3D) -> Vector3D {
        return Vector3D(x:left.y * right.z - left.z * right.y, y:left.z * right.x - left.x * right.z, z:left.x * right.y - left.y * right.x)
    }

}
