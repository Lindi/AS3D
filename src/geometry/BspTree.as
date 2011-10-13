package geometry
{
	public class BspTree
	{
		public static function CreateTree( polygon:Polygon2d ):void
		{
			var leftNormals:Vector.<int> = new Vector.<int>();
			var rightNormals:Vector.<int> = new Vector.<int>();
			var leftArcs:Array = new Array();
			var rightArcs:Array = new Array();
			var dotProducts:Vector.<Number> = new Vector.<Number>( polygon.vertices.length, true ) ;
			dotProducts[0] = 0 ;
			for ( var i:int = 1; i < polygon.vertices.length; i++ )
			{
				dotProducts[i] = polygon.edges[0].dot( polygon.normals[i] );
				if ( dotProducts[i] >= 0 )
				{
					rightNormals.push( i );
					
				} else
				{
					leftNormals.push( i ) ;
				}
				
				if ( dotProducts[i-1] >= 0 && dotProducts[i] >= 0 )
				{
					rightArcs.push([i-1,i]);
					
				} else if ( dotProducts[i-1] <= 0 && dotProducts[i] <= 0 )
				{
					leftArcs.push([i-1,i]);
					
				} else
				{
					rightArcs.push([i-1,i]);
					leftArcs.push([i-1,i]);
				}
				
				//	We append the last arc to the left since the dot product
				//	of the first edge with the last normal is always going
				//	to be less than zero
				leftArcs.push([ polygon.vertices.length-1,0]);
				
			}
		}
		
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
			var leftNormals:Vector.<int> = new Vector.<int>();
			var rightNormals:Vector.<int> = new Vector.<int>();
			var leftArcs:Array = new Array();
			var rightArcs:Array = new Array();
			var dotProducts:Vector.<Number> = new Vector.<Number>( normals.length, true ) ;
			
			//	??
			//	Why are we assigning a normal index to a value that should be a dot product?
			dotProducts[0] = normals[0] ;
			
			for ( var i:int = 1; i < normals.length; i++ )
			{
				dotProducts[i] = polygon.edges[normals[0]].dot( polygon.normals[normals[i]] );
				if ( dotProducts[i] >= 0 )
				{
					rightNormals.push( normals[i] );
					
				} else
				{
					leftNormals.push( normals[i] ) ;
				}
			}
			
			for ( i = 1; i < arcs.length; i++ )
			{
				if ( dotProducts[ arcs[i][0]] >= 0 && dotProducts[ arcs[i][1]] >= 0 )
				{
					rightArcs.push( arcs[i] );
				} else
				{
					leftArcs.push( arcs[i] );
				}
			}
			
			var right:BspNode ;
			if ( rightNormals.length > 0 )
				right = CreateNode( polygon, rightNormals, rightArcs );
			else right = CreateLeafNode( arcs[0][1], null, null );
			
			var left:BspNode ;
			if ( leftNormals.length > 0 )
				left = CreateNode( polygon, leftNormals, leftArcs );
			else left = CreateLeafNode( arcs[0][1], null, null );
			
			return CreateLeafNode( normals[0], right, left );
		}
	}
}