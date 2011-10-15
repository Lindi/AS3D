package geometry
{

	import geometry.Vector2d;
	
	public class Polygon2d
	{
		private var _vertices:Vector.<Vector2d> = new Vector.<Vector2d>();
		private var _edges:Vector.<Vector2d> ;
		private var _normals:Vector.<Vector2d> ;
		private var _centroid:Vector2d ;
		private var _tree:BspNode;
		
		
		public function Polygon2d()
		{
		}
		
		/**
		 * Add a point to the polygon 
		 * @param point
		 * 
		 */		
		public function addVertex( vertex:Vector2d ):int
		{
			return _vertices.push( vertex ) - 1;
		}
		
		/**
		 * Return a reference to the points array 
		 * @return 
		 * 
		 */		
		public function get vertices():Vector.<Vector2d>
		{
			return _vertices ; 	
		}
		
		/**
		 * Return a reference to the lines array 
		 * @return 
		 * 
		 */		
		public function get edges():Vector.<Vector2d>
		{
			return _edges ; 	
		}
		
		
		/**
		 * Return a reference to the lines array 
		 * @return 
		 * 
		 */		
		public function get normals():Vector.<Vector2d>
		{
			return _normals ; 	
		}
		
		/**
		 * Returns a reference to the centroid of the polygon
		 * @return 
		 * 
		 */		
		public function get centroid():Vector2d
		{
			return _centroid ; 	
		}

		
		/**
		 * Sets the polygon's centroid
		 * @return 
		 * 
		 */		
		public function set centroid( centroid:Vector2d ):void
		{
			_centroid = centroid ; 	
		}
		
		
		/**
		 * Returns a reference to the binary space partitioning tree of the polygon
		 * @return 
		 * 
		 */		
		public function get tree():BspNode
		{
			return _tree ; 	
		}
		/**
		 * Returns the vertex at the specified index
		 * @param index
		 * @return 
		 * 
		 */		
		public function getVertex( index:int ):Vector2d
		{
			if ( _vertices.length >= 3 )
				return _vertices[ ( index + _vertices.length ) % _vertices.length ];
			return null ;
		}
		
		/**
		 * Returns the edge at the specified index
		 * @param index
		 * @return 
		 * 
		 */		
		public function getEdge( index:int ):Vector2d
		{
			if ( _vertices.length >= 3 )
			{
				var i:int = ( index + 1 + _vertices.length ) % _vertices.length ;
				var j:int = ( index + _vertices.length ) % _vertices.length ;
				return _vertices[i].Subtract( _vertices[j] );
			}
			return null ;
		}
		
		/**
		 * Returns the current vertex
		 * @param index
		 * @return 
		 * 
		 */		
		public function getNormal( index:int ):Vector2d
		{
			if ( _normals.length >= 3 )
				return _normals[ ( index + _vertices.length ) % _vertices.length ];
			return null ;
		}
		
		/**
		 * Call this function after adding points to the polygon 
		 * Computes lines with inner-pointing normals
		 * 
		 * 
		 */		
		public function updateLines():void
		{
			
			if ( _edges == null )
				_edges = new Vector.<Vector2d>(_vertices.length, true);
			if ( _normals == null )
				_normals = new Vector.<Vector2d>(_vertices.length, true);

			//	Get the centroid
			if ( _centroid == null )
				_centroid = computeCentroid();

			//	Compute the lines
			var n:int = _vertices.length ;
			for (var i:int = 0; i < n; i++)
			{
				//	The index for the second point in the edge line segment
				var j:int = ( i + 1 ) % n ;
				
				
				//	Create a vector from the first point of the edge line segment
				//	to the centroid
				var v:Vector2d  = _centroid.Subtract( _vertices[i]);
				
				//	Create a vector from the first point of the edge line segment
				//	to the second point of the edge line segment
				var edge:Vector2d =  _vertices[j].Subtract( _vertices[i] );
				if ( _edges[i] == null )
					_edges[i] = edge ;
				else {
					_edges[i].x = edge.x ;
					_edges[i].y = edge.y ;
				}
				
				//	Create a vector representing the edge normal
				var normal:Vector2d = edge.perp();
				
				//	Now, if the 2d crossProduct of these two vectors is
				//	positive, then the pair of vectors are "convex"
				//	(meaning their common vertex 'points outwards' from the line
				//	formed from their two endpoints)
				//	If the cross product is negative, the pair of vectors
				//	are "concave" (their common vertex 'points inwards')
				var crossProduct:Number = edge.crossProduct( v );
				
				//	Computes outward-pointing normals
				if ( crossProduct < 0 )
					normal.negate();
				
				//	Normalize the normal to the line
				normal.normalize();
				if ( _normals[i] == null )
					_normals[i] = normal ;
				else {
					_normals[i].x = normal.x ;
					_normals[i].y = normal.y ;
				}
			}
		}
		
		/**
		 * Returns the point that is the centroid of the polygon 
		 * @return 
		 * 
		 */		
		public function computeCentroid():Vector2d
		{
			var centroid:Vector2d = new Vector2d();
			for each ( var point:Vector2d in _vertices )
			{
				centroid.x += point.x ;
				centroid.y += point.y ;
			}
			
			centroid.x /= _vertices.length ;
			centroid.y /= _vertices.length ;
			
			return centroid ;
		}
		
		/**
		 * Orders the vertices counter clockwise 
		 * 
		 */		
		public function orderVertices():void
		{
			
			//	Sort vertices by y-coordinate
			for ( var i:int = 1; i < vertices.length; i++ )
			{
				var j:int = i - 1;
				var point:Vector2d = vertices[i];
				while ( j >= 0 && ( point.y < vertices[j].y ))
				{
					var tmp:Vector2d = vertices[j] ;
					vertices[j] = point ;
					vertices[j+1] = tmp ;
					j-- ;
				}
				vertices[ j+1]= point ;
			}
			
			//	Grab the minimum vertices
			var min:Vector2d = vertices[0] ;
			
			//	Sort the rest of the list in order of dot product with the x-axis
			for ( i = 2; i < vertices.length; i++ )
			{
				j = i - 1 ;
				point = vertices[i] ;
				while ( j >= 1 && angleLessThan( point, vertices[j], min ))
				{
					tmp = vertices[j] ;
					vertices[j] = point ;
					vertices[j+1] = tmp ;
					j--;
				}
				
				vertices[j+1]= point ;
			}
			
		}
		
		/**
		 * Creates a binary space partitioning tree for storing
		 * and fetching (in log(n) time) the extremal vertices of
		 * the polygon in a given direction
		 * 
		 */		
		public function createTree():void
		{
			_tree = BspTree.CreateTree( this );	
		}
		
		/**
		 * Returns true if the dot product of point a with point min
		 * is less than the dot product of point b with min 
		 * @param a
		 * @param b
		 * @param min
		 * 
		 */		
		private function angleLessThan( a:Vector2d, b:Vector2d, min:Vector2d ):Boolean
		{
			var ax:Number = ( a.x - min.x ) ;
			var ay:Number = ( a.y - min.y ) ;
			var bx:Number = ( b.x - min.x ) ;
			var by:Number = ( b.y - min.y ) ;
			
			return ( ax/Math.sqrt(ax * ax + ay * ay) < bx/Math.sqrt(bx * bx + by * by));
		}

		/**
		 * Gets the 'extreme' vertex which is the vertex most aligned with
		 * a given direction.  When we built the tree, we did so by computing the dot
		 * product of the polygon's edge normals with the first edge in the collection
		 * of edges at each node in the tree
		 * 
		 * It makes sense, then, that here we compute the dot product of the edge
		 * at a given node index with the direction.  The direction is analagous to the normals
		 * that we used to build the tree.  If we know, for example, that the dot product of
		 * the direction and the edge specified by the node index is positive, we then know
		 * that we should visit the right side of the tree, because that's where we put 
		 * all indices of the normals with positive dot products with the first edge in our node collection 
		 *  
		 * @param polygon
		 * @return 
		 * 
		 */		
		public static function getExtremeIndex( polygon:Polygon2d, direction:Vector2d ):int
		{
			var node:BspNode = polygon.tree ;
			while ( node.right != null )
			{
				var index:int = node.index ;
				if ( polygon.edges[ index ].dot( direction ) >= 0 )
				{
					node = node.right ;
					
				} else
				{
					node = node.left ;
				}
			}
			
			return node.index ;
		}
	}
}