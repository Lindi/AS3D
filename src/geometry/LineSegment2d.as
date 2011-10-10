package geometry
{
	public class LineSegment2d
	{
		
		/**
		 * Given two pairs of points, each of which define a line segment, find the intersection between
		 * the points 
		 * @param a
		 * @param b
		 * @param c
		 * @param d
		 * @return 
		 * 
		 */		
		public static function getLineIntersection( a:Vector2d, b:Vector2d, c:Vector2d, d:Vector2d ):Vector2d
		{
			var determinant:Number = (( a.x - b.x ) * ( c.y - d.y )) - (( a.y - b.y ) * ( c.x - d.x ));
			if ( determinant == 0 )
				return null ;
			var x:Number = (( a.x * b.y - b.x * a.y ) * ( c.x - d.x ) - ( a.x - b.x ) * ( c.x * d.y - d.x * c.y ))/ determinant ;
			var y:Number = (( a.x * b.y - b.x * a.y ) * ( c.y - d.y ) - ( a.y - b.y ) * ( c.x * d.y - d.x * c.y ))/ determinant ;
			return new Vector2d( x, y ) ;
		}
	}
}