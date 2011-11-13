package physics
{
	import geometry.Polygon2d;
	import geometry.Vector2d;

	public class PolygonDistance
	{
		
		public function PolygonDistance()
		{
		}
		
		
		public static function distance( polygon0:Polygon2d, polygon1:Polygon2d ):Vector.<Vector.<Number>>
		{
			//	Grab the size of each of the polygons
			var n0:int = polygon0.vertices.length ;
			var n1:int = polygon1.vertices.length ;
			
			//	Translate the vertices of each polygon to the first quadrant
			//	if necessary
			var min:Vector2d = new Vector2d();
			for ( var i:int = 0; i < n0; i++ )
			{
				min.x = Math.min( polygon0.getVertex(i).x, min.x );
				min.y = Math.min( polygon0.getVertex(i).y, min.y );
			}
			for ( i = 0; i < n1; i++ )
			{
				min.x = Math.min( polygon1.getVertex(i).x, min.x );
				min.y = Math.min( polygon1.getVertex(i).y, min.y );
			}
			
			//	Make sure both components of the vertices of each polygon 
			//	are positive
			var vertex:Vector2d ;
			if ( min.x < 0 || min.y < 0 )
			{
				for ( i = 0; i < n0; i++ )
				{
					vertex = polygon0.getVertex( i );
					vertex.x -= min.x ;
					vertex.y -= min.y ;
				}
				for ( i = 0; i < n1; i++ )
				{
					vertex = polygon1.getVertex( i );
					vertex.x -= min.x ;
					vertex.y -= min.y ;
				}
			}
			
			//	Compute the M matrix
			//	Start with computing the A0 matrix for polygon0 and the A1 matrix for polygon1
			var n:int = n0 * 2 ;
			var normal:Vector2d ;
			var A0:Vector.<Number> = new Vector.<Number>( n, true );
			var B0:Vector.<Number> = new Vector.<Number>( n0, true ) ;
			for ( i = 0; i < n0; i++ )
			{
				normal = polygon0.getNormal( i );				
				A0[i] = normal.x ;
				A0[i+1] = normal.y ;
				vertex = polygon0.getVertex( i - 1 );
				B0[i] = normal.dotProduct( vertex );
			}
			
			//	Now compute the A1 matrix for polygon1
			n = n1 * 2 ;
			var A1:Vector.<Number> = new Vector.<Number>( n, true );
			var B1:Vector.<Number> = new Vector.<Number>( n1, true ) ;
			for ( i = 0; i < n1; i++ )
			{
				normal = polygon1.getNormal( i );				
				A1[i] = normal.x ;
				A1[i+1] = normal.y ;
				vertex = polygon1.getVertex( i - 1 );
				B1[i] = normal.dotProduct( vertex );
			}

			var r:int, c:int ;
			var row:Vector.<Number> ;
			
			//	Create a matrix A
			n = ( n0 + n1 ) * 4 ;
			var A:Vector.<Number> = new Vector.<Number>(n,true);
			for ( i = 0; i < n; i++)
			{
				r = ( i / 4 );
				c = ( i % 4 );
				if ( r < n0 )
				{
					A[ r * 4 + c ] = ( c < 2 ? A0[r * 2 + c] : 0 );
				} else
				{
					A[ r * 4 + c ] = ( c < 2 ? 0 : A1[(r - n0) * 2 + ( c - 2 )] );
				}
			}
			
			//	Now compute M
			n = ( n0 + n1 + 4 );
			var M:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(n,true);
			for ( i = 0; i < n; i++)
			{
				M[i] = new Vector.<Number>( n, true );	
			}
			
			//	First, write the matrix 2S in the upper left corner of M
			//	S is the 2x2 block matrix [I -I -I I] multiplied by 2 where
			//	I is the 2x2 identity matrix
			for ( i = 0; i < 16; i++ )
			{
				r = ( i / 4 );
				c = ( i % 4 );
				row = M[r] ;
				
				//	If the sum of the row and column indices is even
				//	the value should be 1, otherwise zero (checkerboard)
				row[c] = int(( r + c ) % 2);
				
				//	If the quadrant of the row and column
				//	is not divisible by 3, multiply -1
				var m:int = int( Math.floor( r / 2 ) + Math.floor( c / 2 ));
				row[c] *= ( 1 - ( 2 * int(( m % 3 ) % 2  > 0)));
				
				//	Multiply by 2
				row[c] *= 2 ;
			}
			
			//	Now, copy a transpose into the upper-right 'quadrant' of the block matrix
			n = ( n0 + n1 ) * 4;
			for ( i = 0; i < n; i++ )
			{
				r = ( i % ( n0 + n1 ));
				c = ( i / ( n0 + n1 ));
				var value:Number = A[ r * 4 + c ] ;
				row = M[3-c] ;
				row[r+4] = value ;
				row = M[ r + 4 ] ;
				row[ c] = value ;
			}
			
			//	Copy zeros into the rest of it
			var m:int = ( n0 + n1 );
			n = m * m ;
			for ( i = 0; i < n; i++ )
			{
				r = ( i / m );
				c = ( i % m );
				
				row = M[4 + r] ;
				row[ 4 + c ] = 0;
			}
			
			
			
			return M;
		}
	}
}