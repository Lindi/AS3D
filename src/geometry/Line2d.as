package geometry
{
	import flash.geom.Point;

	public class Line2d
	{
		private var _normal:Vector2d ;
		private var _constant:Number ;
		
		public function Line2d( a:Vector2d, b:Vector2d )
		{
			var segment:Vector2d = b.Subtract( a );
			_normal = segment.perp();
			_constant = _normal.dot(a);
		}
		
		public function get normal():Vector2d
		{
			return _normal ;
		}
		
		public function set normal( normal:Vector2d ):void
		{
			_normal = normal ;
		}
		
		public function get constant( ):Number
		{
			return _constant ;
		}
		
		public function set constant( constant:Number ):void
		{
			_constant = constant ;
		}
		
		/**
		 * Returns the pseudo distance which is positive if
		 * the point is on the positive side of the line, and
		 * negative if the point is on the negative side of the line
		 *  
		 * @param point
		 * @return 
		 * 
		 */		
		public function pseudoDistance( point:Vector2d ):Number
		{
			return _normal.dot( point ) ;
		}
	}
}