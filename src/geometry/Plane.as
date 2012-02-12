package geometry
{
	import flash.geom.Vector3D;
	
	import math.Utils;

	public class Plane
	{
		private var _normal:Vector3D = Vector3D.X_AXIS ;
		private var _distance:Number = 0 ;
		private var _a:Number ;
		private var _b:Number ;
		private var _c:Number ;
		private var _d:Number ;
		
		
		public function Plane( p:Vector3D = null, q:Vector3D = null, r:Vector3D = null )
		{
			
		}
		public function test( point:Vector3D ):Number 
		{
			return _normal.dotProduct( point ) + _distance ;
		
		}
		
		/**
		 * Returns the a coefficient
		 * @return 
		 * 
		 */		
		public function get a():Number
		{
			return _a ;
		}
		
		/**
		 * Returns the b coefficient
		 * @return 
		 * 
		 */		
		public function get b():Number
		{
			return _b ;
		}
		/**
		 * Returns the c coefficient
		 * @return 
		 * 
		 */		
		public function get c():Number
		{
			return _c ;
		}
		/**
		 * Returns the d coefficient
		 * @return 
		 * 
		 */		
		public function get d():Number
		{
			return _d ;
		}
		public function setCoefficients( a:Number, b:Number, c:Number, d:Number ):void
		{
			//_a = a; _b = b; _c = c; _d = d ;
			var lengthSquared:Number = a * a + b * b + c * c ;
			if ( Utils.IsZero( lengthSquared ))
			{
				_normal = Vector3D.X_AXIS ;
				_distance = 0.0 ;
			} else {
				var lengthInverse:Number = 1/Math.sqrt( lengthSquared );
				_normal = new Vector3D( a * lengthInverse, b * lengthInverse, c * lengthInverse );
				_distance = d * lengthInverse ;
				_a = _normal.x ;
				_b = _normal.y ;
				_c = _normal.z ;
				_d = _distance ;
			}
		}
	}
}