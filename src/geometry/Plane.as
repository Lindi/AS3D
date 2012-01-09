package geometry
{
	import flash.geom.Vector3D;
	import math.Utils ;

	public class Plane
	{
		private var _normal:Vector3D = Vector3D.X_AXIS ;
		private var _distance:Number = 0 ;
		
		public function test( point:Vector3D ):Number 
		{
			return _normal.dotProduct( point ) + _distance ;
		
		}
		
		public function setCoefficients( a:Number, b:Number, c:Number, d:Number ):void
		{
			var lengthSquared:Number = a * a + b * b + c * c ;
			if ( Utils.IsZero( lengthSquared ))
			{
				_normal = Vector3D.X_AXIS ;
				_distance = 0.0 ;
			} else {
				var lengthInverse:Number = 1/Math.sqrt(lengthSquared );
				_normal = new Vector3D( a * lengthInverse, b * lengthInverse, c * lengthInverse );
				_distance = d * lengthInverse ;
			}
		}
	}
}