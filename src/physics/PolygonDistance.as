package physics
{
	import geometry.Polygon2d;
	import geometry.Vector2d;
	
	import physics.lcp.LcpSolver;

	public class PolygonDistance
	{
		public static function distance( polygon0:Polygon2d, polygon1:Polygon2d ):Object
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
				A0[i*2] = normal.x ;
				A0[i*2+1] = normal.y ;
				vertex = polygon0.getVertex( i );
				B0[i] = normal.dotProduct( vertex );
			}
			
			//	Now compute the A1 matrix for polygon1
			n = n1 * 2 ;
			var A1:Vector.<Number> = new Vector.<Number>( n, true );
			var B1:Vector.<Number> = new Vector.<Number>( n1, true ) ;
			for ( i = 0; i < n1; i++ )
			{
				normal = polygon1.getNormal( i );				
				A1[i*2] = normal.x ;
				A1[i*2+1] = normal.y ;
				vertex = polygon1.getVertex( i );
				B1[i] = normal.dotProduct( vertex );
			}

			var matrices:Object = buildMatrices( A0, B0, A1, B1);
			
			//	Now run M and Q through the lcp solver
			var processing:Boolean = true ;
			var tries:int = Math.min( B0.length, B1.length ) - 1 ;
			while ( processing )
			{
				
				var solution:Object = new Object();
				var solver:LcpSolver = new LcpSolver( n0 + n1 + 4, matrices.M, matrices.Q, solution );
				if ( solution.status == LcpSolver.FOUND_SOLUTION )
				{
					solution.M = matrices.M ;
					return solution;
				}
				
				if ( solution.status == LcpSolver.CANNOT_REMOVE_COMPLEMENTARY_VARIABLE )
				{
					if ( tries++ > 3 )
					{
						return solution ;
					}
					//	shuffle the a and b matrices
					moveMatrices(A0,B0);
					moveMatrices(A1,B1);

					//	build the matrices again
					matrices = buildMatrices( A0, B0, A1, B1);
				}
			}
			return solution ;
		}
		
		private static function moveMatrices( A:Vector.<Number>, B:Vector.<Number> ):void
		{
			var x:Number = A[0] ;
			var y:Number = A[1] ;
			var tmp:Number = B[0];
			for (var i:int = 1; i < B.length; ++i)
			{
				var j:int = i - 1 ;
				A[j*2] = A[i*2];
				A[j*2+1] = A[i*2+1];
				B[j] = B[i];
			}
			A[A.length - 2] = x;
			A[A.length - 1] = y;
			B[B.length - 1] = tmp;
			
		}
		
		private static function buildMatrices( A0:Vector.<Number>, B0:Vector.<Number>, A1:Vector.<Number>, B1:Vector.<Number> ):Object
		{
			var matrices:Object = new Object();
			
			var r:int, c:int ;
			var row:Vector.<Number> ;
			var n0:int = A0.length ;
			var n1:int = A1.length ;
			
			//	Create a matrix A
			var n:int = ( A0.length + A1.length )/2 * 4 ;
			var A:Vector.<Number> = new Vector.<Number>(n,true);
			n = n0 + n1 ;
			for ( var i:int = 0; i < n; i++)
			{
				if ( i < n0 )
				{
					A[Math.floor(i/2)*4 + (i%2)] = A0[i] ;
				} else
				{
					A[Math.floor(i/2)*4 + (i%2)+2] = A1[i-n0] ;
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
			var m:int ;
			for ( i = 0; i < 16; i++ )
			{
				r = ( i / 4 );
				c = ( i % 4 );
				row = M[r] ;
				
				//	If the sum of the row and column indices is even
				//	the value should be 1, otherwise zero (checkerboard)
				row[c] = int(( r + c ) % 2 == 0);
				
				//	If the quadrant of the row and column
				//	is not divisible by 3, multiply -1
				m = int( Math.floor( r / 2 ) + Math.floor( c / 2 ));
				row[c] *= ( 1 - ( 2 * int(( m % 3 ) % 2  > 0)));
				
				//	Multiply by 2
				row[c] *= 2 ;
			}
			
			//	Now, copy a transpose into the upper-right 'quadrant' of the block matrix
			n = ( n0 + n1 )/2 * 4;
			for ( i = 0; i < n; i++ )
			{
				r = ( i % (( n0 + n1 )/2));
				c = ( i / (( n0 + n1 )/2));
				var value:Number = A[ r * 4 + c ] ;
				row = M[c] ;
				row[r+4] = value ;
				row = M[ r + 4 ] ;
				row[c] = -value ;
			}
						
			//	Now make the block matrix B
			//	B is an ( n0 + n1 + 4 ) x 1 block matrix
			//	The first four rows are zero
			//	The next n0 + n1 rows are the elements of matrix B0 and B1 respectively
			n = B0.length + B1.length + 4 ;
			var Q:Vector.<Number> = new Vector.<Number>(n, true);
			for ( i = 4; i < n; i++ )
			{
				if ( i < B0.length + 4 ) {
					Q[i] = B0[i-4] ;
				} else {
					Q[i] = B1[i-B0.length-4];
				}
			}
			
			matrices.M= M ;
			matrices.Q= Q ;
			return matrices ;
		}
	}
}