package geometry
{
	internal class BspTree
	{
		/**
		 * Creates a binary space partitioning tree which partitions
		 * polygon normals according to their dot product with a given edge
		 * If the dot product with an edge normal with the given edge is greater
		 * than zero, the normal index (and arc indices) are placed in the right
		 * half of the tree, and if less the left half
		 * 
		 * The arcs denote the arcs between two nodes on the unit circle which
		 * represents the polar dual of the polygon.  Each arc corresponds to
		 * a polygon vertex, and each node/vertex corresponds to a polygon edge
		 * between the current and previous vertices
		 * 
		 *  
		 * @param polygon
		 * 
		 */		
		internal static function CreateTree( polygon:Polygon2d ):BspNode
		{
			//	The collection that will hold the normal indices 
			//	which will be placed in the left side of the tree
			var leftNormals:Vector.<int> = new Vector.<int>();
			
			//	The collection that will hold the normal indices
			//	which will be placed in the right side of the tree
			var rightNormals:Vector.<int> = new Vector.<int>();
			
			//	The collection that will hold the pair of indices
			//	which represent the arcs that will be placed in the left
			//	side of the tree
			var leftArcs:Array = new Array();

			//	The collection that will hold the pair of indices
			//	which represent the arcs that will be placed in the right
			//	side of the tree
			var rightArcs:Array = new Array();
			
			//	A list for keeping track of the dot product of each normal with
			//	the given edge
			var dotProducts:Vector.<Number> = new Vector.<Number>( polygon.vertices.length, true ) ;
			
			//	The dot product of edge 0 with normal 0 is zero, by definition
			dotProducts[0] = 0 ;
			
			for ( var i:int = 1; i < polygon.vertices.length; i++ )
			{
				//	Compute the dot product of each of the polygon's normals
				//	with the first edge
				dotProducts[i] = polygon.edges[0].dot( polygon.normals[i] );
				
				
				if ( dotProducts[i] >= 0 )
				{
					//	Place the normals with a positive dot product with the first
					//	edge in the right half of the tree
					rightNormals.push( i );
					
				} else
				{
					//	Place the normals with a negative dot product with the first
					//	edge in the left half of the tree
					leftNormals.push( i ) ;
				}
				
				if ( dotProducts[i-1] >= 0 && dotProducts[i] >= 0 )
				{
					//	If the dot product of previous normal with the 
					//	first edge and the current normal with the first edge
					//	are both positive, put a pair of indices representing
					//	an arc in the right half of the tree
					rightArcs.push([i-1,i]);
					
				} else if ( dotProducts[i-1] <= 0 && dotProducts[i] <= 0 )
				{
					//	If the dot product of previous normal with the 
					//	first edge and the current normal with the first edge
					//	are both negative, put a pair of indices representing
					//	an arc in the left half of the tree
					leftArcs.push([i-1,i]);
					
				} else
				{
					//	If the product of the dot product of the previous normal
					//	with the first edge and the dot product of the current normal
					//	with the first edge is less than zero (i.e. one is positive and
					//	the other is negative), place the pair of indicies in the 
					//	right half and the left half of the tree
					
					//	I think this only happens in the first node, because the dot
					//	product of the last normal with the first edge is always going to be negative
					//	and the dot product of the first normal with the first edge is always going
					//	to be positive.  This is where the polygon "wraps".
					rightArcs.push([i-1,i]);
					leftArcs.push([i-1,i]);
				}
			}
			//	We append the last arc to the left since the dot product
			//	of the first edge with the last normal is always going
			//	to be less than zero.  This is where the polygon "wraps".
			leftArcs.push([ polygon.vertices.length-1,0]);
			
			//	Return the tree
			return CreateLeafNode( 0, CreateNode( polygon, rightNormals, rightArcs),
				CreateNode( polygon, leftNormals, leftArcs ));
		}
		
		/**
		 * Represents a leaf node in the binary space partitioning tree. 
		 * @param index - The index of the polygon vertex
		 * @param right - Right child
		 * @param left - Left child
		 * @return 
		 * 
		 */		
		private static function CreateLeafNode( index:int, right:BspNode, left:BspNode ):BspNode
		{
			var node:BspNode = new BspNode();
			node.index = index ;
			node.right = right ;
			node.left = left ;
			return node ;
		}
		
		private static function CreateNode( polygon:Polygon2d, normals:Vector.<int>, arcs:Array ):BspNode
		{
			//	The collection that will hold the normal indices 
			//	which will be placed in the left side of the tree
			var leftNormals:Vector.<int> = new Vector.<int>();
			
			//	The collection that will hold the normal indices
			//	which will be placed in the right side of the tree
			var rightNormals:Vector.<int> = new Vector.<int>();
			
			//	The collection that will hold the pair of indices
			//	which represent the arcs that will be placed in the left
			//	side of the tree
			var leftArcs:Array = new Array();
			
			//	The collection that will hold the pair of indices
			//	which represent the arcs that will be placed in the right
			//	side of the tree
			var rightArcs:Array = new Array();

			
			for ( var i:int = 1; i < normals.length; i++ )
			{
				if ( polygon.edges[normals[0]].dot( polygon.normals[normals[i]] ) >= 0 )
				{
					//	Place the normals with a positive dot product with the first
					//	edge in the right half of the tree
					rightNormals.push( normals[i] );
					
				} else
				{
					//	Place the normals with a negative dot product with the first
					//	edge in the left half of the tree
					leftNormals.push( normals[i] ) ;
				}
			}
			
			for ( i = 0; i < arcs.length; i++ )
			{
				var a:Number = polygon.edges[normals[0]].dot( polygon.normals[arcs[i][0]] );
				var b:Number = polygon.edges[normals[0]].dot( polygon.normals[arcs[i][1]] );
				if ( a >= 0 && b >= 0 )
				{
					//	If the dot product of previous normal with the 
					//	first edge and the current normal with the first edge
					//	are both positive, put a pair of indices representing
					//	an arc in the right half of the tree
					rightArcs.push( arcs[i] );
					
				} else
				{
					//	If the dot product of previous normal with the 
					//	first edge and the current normal with the first edge
					//	are both negative, put a pair of indices representing
					//	an arc in the left half of the tree
					leftArcs.push( arcs[i] );
				}
			}
			
			var right:BspNode ;
			if ( rightNormals.length > 0 )
				right = CreateNode( polygon, rightNormals, rightArcs );
			else if ( rightArcs.length > 0 )
				right = CreateLeafNode( rightArcs[0][1], null, null );
			
			var left:BspNode ;
			if ( leftNormals.length > 0 )
				left = CreateNode( polygon, leftNormals, leftArcs );
			else if ( leftArcs.length > 0 )
				left = CreateLeafNode( leftArcs[0][1], null, null );
			
			return CreateLeafNode( normals[0], right, left );
		}
	}
}