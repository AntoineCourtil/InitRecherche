struct Coordinate {

  var X, Y, Z : Double
  var hauteur, largeur : Int

  init(x:String, y:String, z:String, hauteur:String, largeur:String) {
    self.X = NSString(string: x).doubleValue
    self.Y = NSString(string: y).doubleValue
    self.Z = NSString(string: z).doubleValue
    self.hauteur = NSString(string: hauteur).intValue
    self.largeur = NSString(string: largeur).intValue
  }

  init(x:Double, y:Double, z:Double, hauteur:Int, largeur:Int) {
    self.X = x
    self.Y = y
    self.Z = z
    self.hauteur = hauteur
    self.largeur = largeur
  }

}
