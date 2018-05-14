import Foundation

public struct Vector3D {

    var x, y, z : Double = 0.0

}

extension Vector3D {

    static func +(left:Vector3D, right:Vector3D) -> Vector3D{
        return Vector3D(x:left.x+right.x, y:left.y+right.y, z:left.z+right.z)
    }

    static func *(left:Vector3D, right:Vector3D) -> Double {
        return left.x*right.x + left.y*right.y + left.z*right.z
    }

    static func ^(left:Vector3D, right:Vector3D) -> Vector3D {
        return Vector3D(x:left.y * right.z - left.z * right.y, y:left.z * right.x - left.x * right.z, z:left.x * right.y - left.y * right.x)
    }

}
