package physics
{
	import geometry.Polygon2d;
	import geometry.Vector2d;
		
	public class PolygonIntersection
	{
	
		/**
		 * Returns true if two polygons will intersect within the time interval [0,tmax]
		 * Returns false if not 
		 * @param a 
		 * @param b
		 * @param u
		 * @param v
		 * @return 
		 * 
		 */		
		public static function PolygonsIntersect( a:Polygon2d, b:Polygon2d, u:Vector2d, v:Vector2d, tmax:Number ):Boolean
		{
			var interval:Object = { tmax: tmax, tfirst: 0, tlast: Number.MAX_VALUE };
			
			if ( TestIntersection( a, b, u, v, interval ))
			{
				return true ;
			}
			return false ;	
		}
		
		/**
		 * Resolves the polygon intersection by moving the polygons to their contact points
		 * and adjusting their velocities 
		 * @param a
		 * @param b
		 * @param u
		 * @param v
		 * 
		 */		
		public static function ResolveIntersection( a:Polygon2d, b:Polygon2d, u:Vector2d, v:Vector2d, tmax:Number ):void
		{
			//	A pair of ProjectionInfo instances which contains the information about the
			//	the closest pair of projection intervals.  If the time between the closest pair
			//	of projection intervals is less than the time over which we are looking for an intersection
			//	then we can expect the polygons to intersect during the current time interval
			//	This pair of ProjectionInfo instances contains the information about this "closest" pair
			//	of intervals
			var intersection:Vector.<ProjectionInfo> = new Vector.<ProjectionInfo>(2,true);
			
			//	This array could probably be a static property
			//	The info array can't be because we have to know the information
			//	for each axis projection, and store that which represents
			//	the time interval that is the earliest possible intersection
			intersection[0] = new ProjectionInfo();
			intersection[1] = new ProjectionInfo();

			var interval:Object = { tmax: tmax, tfirst: 0, tlast: Number.MAX_VALUE };
			//trace( interval.tmax );

			//	Do the polygons intersect?
			if ( TestIntersection( a, b, u, v, interval, intersection ))
			{
				//	Intersection point pointer
				var intersectionPoint:Vector2d ;
				var normal:Vector2d ;
				
				//	Polygon a's max projection interval value is less than
				//	polygon b's min projection interval value
				if ( interval.side == 1 )
				{
					//if ( intersection[1].min >= intersection[0].max )
					{
						intersectionPoint = b.getVertex( intersection[1].index[0] ).Add( v.ScaleBy( interval.tfirst ));
						
						if ( Math.abs( intersectionPoint.dot( a.getEdge( intersection[0].index[1] ))) < 
							Math.abs( intersectionPoint.dot( a.getEdge( intersection[0].index[1]-1))))
						{
							normal = a.getNormal( intersection[0].index[1] ).clone();	
							
						} else
						{
							normal = a.getNormal( intersection[0].index[1]-1 ).clone();
						}

						if ( normal != null )
						{
							var relativeVelocity:Vector2d = v.Subtract( u );
							//	Don't do anything if the polygons are going away from each other
							//	(Although they really shouldn't be at this point )
							if ( normal.dot( relativeVelocity ) >= 0 )
								return ;
							var perp:Vector2d = normal.perp();
							if ( perp.dot( relativeVelocity ) < 0 )
								perp.negate();
							
							//	Scale the normal by the dot project of the normal with the relative velocity
							normal.scale(normal.dot( relativeVelocity ));
							
							//	Reflect v about the normal
							var reflectedVelocity:Vector2d = perp.Subtract( normal );
							v.x = reflectedVelocity.x ;
							v.y = reflectedVelocity.y ;
							
							//	Update the position of the polygon
							b.centroid.x += v.x ;
							b.centroid.y += v.y ;
						}

					}
					
				} else if ( interval.side == -1 )
				{
					//if ( intersection[0].min >= intersection[1].max )
					{
						intersectionPoint = a.getVertex( intersection[0].index[0] ).Add( v.ScaleBy( interval.tfirst ));
						
						if ( Math.abs( intersectionPoint.dot( b.getEdge( intersection[1].index[0] ))) < 
							Math.abs( intersectionPoint.dot( b.getEdge( intersection[1].index[0]-1))))
						{
							normal = b.getNormal( intersection[1].index[0] ).clone();	
							
						} else
						{
							normal = b.getNormal( intersection[1].index[0]-1 ).clone();
						}
						if ( normal != null )
						{
							relativeVelocity = u.Subtract( v );
							//	Don't do anything if the polygons are going away from each other
							//	(Although they really shouldn't be at this point )
							if ( normal.dot( relativeVelocity ) >= 0 )
								return ;
							perp = normal.perp();
							if ( perp.dot( relativeVelocity ) < 0 )
								perp.negate();
							
							//	Scale the normal by the dot project of the normal with the relative velocity
							normal.scale(normal.dot( relativeVelocity ));
							
							//	Reflect v about the normal
							reflectedVelocity = perp.Subtract( normal );
							u.x = reflectedVelocity.x ;
							u.y = reflectedVelocity.y ;
							
							//	Update the position of the polygon
							a.centroid.x += u.x ;
							a.centroid.y += u.y ;
						}
						
					}
				}
			}
//			for ( var prop:String in interval )
//			{
//				trace( "interval["+prop+"]" + interval[prop] );
//			}
		}
		/**
		 * Tests a pair of polygons to see if they will intersect before a given time t
		 * Returns true if the pair of polygons will intersect, and false if not
		 *  
		 * @param a - The pair's first polygon
		 * @param b - The pair's second polygon
		 * @param u - The first polygon's velocity
		 * @param v - The second polygon's velocity
		 * @param tmax - The minimum time interval for inters ection.
		 * @param tfirst - The earliest time at which the polygons intersect
		 * @param tlast - The latest time at which the polygons will intersect
		 * @param side - This value is -1 if polygon b is to the 'left' of polygon a 
		 * (if the projection of polygon b is the lesser interval) and 1 if polygon b 
		 * is to the 'right' of polygon a (if the projection of polygon b is the greater interval)
		 * @return Boolean
		 * 
		 */		
		private static function TestIntersection
			( a:Polygon2d, b:Polygon2d, u:Vector2d, v:Vector2d, interval:Object, intersection:Vector.<ProjectionInfo> = null ):Boolean 
		{
			//	A pair of ProjectionInfo instances which contains the information about
			//	the projection of a pair of polygons onto a given potential separating axis
			//	Basically, when we iterate over each polygon's edge normals, we consider
			//	each normal a potential separating axis, and we project the pair of polygons
			//	onto each separating axis.  The first ProjectionInfo instance contains projection
			//	information for the first polygon in the pair, and the second ProjectionInfo instance
			//	contains projection information for the second polygon in the pair
			var info:Vector.<ProjectionInfo> = new Vector.<ProjectionInfo>(2,true);
			
			
			//	Compute the relative velocity between the polygons
			var relativeVelocity:Vector2d = v.Subtract( u ) ;
			
			
			//	Iterate over the edge normals of the first polygon, and compare the projection
			//	of the second polygon to the first along each axis
			for ( var i:int = a.normals.length - 1, j:int = 0; j < a.normals.length; i = j++ )
			{
				//	Initialize them
				info[0] = new ProjectionInfo();
				info[1] = new ProjectionInfo();
				var normal:Vector2d = a.getNormal( i ) ;
				var speed:Number = normal.dot( relativeVelocity ) ;
				ComputeInterval( a, normal, info[0] );
				ComputeInterval( b, normal, info[1] );
				
				if ( NoIntersection( speed, info, interval, intersection ))
				{
					return false ;
				}
			}
			
			//	Iterate over the edge normals of the second polygon, and compare the projection
			//	of the first polygon to the second along each axis
			for ( i = b.normals.length - 1, j = 0; j < b.normals.length; i = j++ )
			{
				//	Initialize them
				info[0] = new ProjectionInfo();
				info[1] = new ProjectionInfo();
				normal = b.getNormal( i ) ;
				speed = normal.dot( relativeVelocity ) ;
				ComputeInterval( a, normal, info[0] );
				ComputeInterval( b, normal, info[1] );
				
				if ( NoIntersection( speed, info, interval, intersection ))
				{
					return false ;
				}
			}
			return true ;
		}

		/**
		 * Returns true if there will NOT be an intersection between the two polygons
		 * and false if there will be or if they are already intersecting
		 * @return 
		 * 
		 */		
		private static function NoIntersection
			( speed:Number, info:Vector.<ProjectionInfo>, interval:Object, intersection:Vector.<ProjectionInfo> = null ):Boolean
		{
			if ( info[1].max < info[0].min )
			{
				//	Polygon b is to the 'left' of polygon a
				if ( speed <= 0 )
				{
					//	The speed is a function of the relative velocity
					//	and the relative velocity is the velocity of polygon
					//	b "minus" the velocity of polygon a ( v - u )
					
					//	Remember, the relative velocity of b to a is the
					//	velocity of b relative to a if a were not moving.
					//	If b is on the positive side of a, then it can only
					//	be moving towards a if its relative velocity is negative
					
					//	Conversely, if b is on the negative side of a, it can only
					//	be moving towards a if its relative velocity is positive
					
					//	Therefore, the polygons cannot intersect if b is on the
					//	negative side of a, and its velocity relative to a is negative
					return true ;
				}
				
				//	The time between the polygons is their distance from each other
				//	divided by their speed
				var t:Number = ( info[0].min - info[1].max ) / speed ;
				
				//	If the time t between the polygons is greater than the
				//	most recently calculated time to their earliest intersection
				//	we store the updated value
				
				//	The part is really counter-intuitive.  You'd think that 
				//	you'd want to find the earliest time to their intersection, and
				//	so the smallest time interval between them
				
				//	But we have to remember that the method of separating axes evaluates
				//	each potential separating axis (each polygon edge normal) independently
				//	and determines the speed of each projected interval by projecting the
				//	relative velocity between the polygons onto each potential separating
				//	axis.  Since we're projecting the relative velocity into each polygon
				//	edge normal, we might run into a situation where the relative speed of one
				//	pair of projection intervals is slower than another, in which case, the
				//	polygons cannot intersect earlier than this interval
				if ( t > interval.tfirst )
				{
					interval.tfirst = t ;
					interval.side = -1 ;
					if ( intersection != null )
					{
						intersection[0] = info[0] ;
						intersection[1] = info[1] ;
					}
				}
				
				//	If the earliest time the polygons will intersect
				//	is later than the time interval in which we're looking for an intersection
				//	they don't intersect, so return true
				if ( interval.tfirst > interval.tmax )
				{
					return true ;
				}
				
				//	Calculate the latest time at which they can intersect on this axis
				t = ( info[0].max - info[1].min ) / speed ;
				if ( t < interval.tlast )
				{
					interval.tlast = t ;
				}
				
				//	If the earliest time at which they could possibly intersect
				//	(as measured on another interval) is greater than the latest
				//	time at which they could possibly intersect (as measured on this interval)
				//	they don't intersect, so return true
				if ( interval.tfirst > interval.tlast )
				{
					return true ;
				}
			} else if ( info[0].max < info[1].min )
			{
				//	Polygon a is on the 'left' or negative side of polygon b
				if ( speed >= 0 )
				{
					//	Remember, the relative velocity of b to a is the
					//	velocity of b relative to a if a were not moving.
					//	If b is on the positive side of a, then it can only
					//	be moving towards a if its relative velocity is negative
					
					//	Conversely, if b is on the negative side of a, it can only
					//	be moving towards a if its relative velocity is positive
					
					//	Therefore, the polygons cannot intersect if b is on the
					//	positive side of a, and its velocity relative to a is positive
					return true ;
				}
				
				//	This time, we subtract the max of a from the min of b
				//	since the difference will be negative (a is on the 'left' or negative side of b).  
				//	We can thus divide by a negative speed, and the time interval will be positive
				t = ( info[0].max - info[1].min ) / speed ;
				
				if ( t > interval.tfirst )
				{
					interval.tfirst = t ;
					interval.side = 1 ;
					if ( intersection != null )
					{
						intersection[0] = info[0] ;
						intersection[1] = info[1] ;
					}
				}
				
				//	The earliest they can meet is greater than the interval during
				//	which we were looking for an intersection, so they can't intersect
				//	Return true
				if ( interval.tfirst > interval.tmax )
				{
					return true ;
				}
				
				//	Find the latest time at which they can possibly intersect
				t = ( info[0].min - info[1].max ) / speed ;
				if ( t < interval.tlast )
				{
					interval.tlast = t ;
				}
				//	If the earliest time at which they could possibly intersect
				//	(as measured on another interval) is greater than the latest
				//	time at which they could possibly intersect (as measured on this interval)
				//	they don't intersect, so return true
				if ( interval.tfirst > interval.tlast )
				{
					return true ;
				}
			} else {
				
				//	The projected intervals overlap
				if ( speed > 0 )
				{
					interval.side = 1 ;
					//	If the speed is positive, the polygons can only be heading towards each other if
					//	polygon a is on the right or the positive side of polygon b.  Therefore
					//	we calculate the latest time at which they can meet by subtracting the maximum of
					//	polygon a's interval from minimum of polygon b's interval 
					t = ( info[0].max - info[1].min ) / speed ;
					
					//	We only update tlast here since the intervals already overlap
					//	such that tfirst is negative
					if ( t < interval.tlast )
					{
						interval.tlast = t ;
					}
					if ( interval.tfirst > interval.tlast )
					{
						return true ;
					}
				} else if ( speed < 0 )
				{
					interval.side = -1 ;
					//	If the speed is negative, the polygons can only be heading towards each other if
					//	polygon a is on the left or the negative side of polygon b.  Therefore
					//	we calculate the latest time at which they can meet by subtracting the minimum of
					//	polygon a's interval from maximum of polygon b's interval (a negative difference)
					//	which we then divide by a negative speed to get a positive interval
					t = ( info[0].min - info[1].max ) / speed ;
					if ( t < interval.tlast )
					{
						interval.tlast = t ;
					}
					if ( interval.tfirst > interval.tlast )
					{
						return true ;
					}
				}
			}
			
			return false ;
		}
		

		
		

		private static function GetIntersection
			( a:Polygon2d, b:Polygon2d, u:Vector2d, v:Vector2d,
			  info:Vector.<ProjectionInfo>, interval:Object, vertices:Vector.<Vector2d> ):void
		{
			//	Pointer to a Vector2d instance
			var point:Vector2d ;
			
			//	Polygon a's max projection interval value is less than
			//	polygon b's min projection interval value
			if ( interval.side == 1 )
			{
				if ( info[0].unique[1] )
				{
					//	Polygon a's maximum extremal vertex intersects an 
					//	one of polygon b's edges
					vertices.push(a.getVertex( info[0].index[1]).Add( u.ScaleBy( interval.tfirst )));
						
				} else if ( info[1].unique[0] )
				{
					//	Polygon b's minimal extremal vertex intersects an 
					//	one of polygon a's edges
					vertices.push(b.getVertex( info[1].index[0]).Add( v.ScaleBy( interval.tfirst )));

				} else
				{
					//	Edge-edge intersection
					//	Get the maximum vertex of polygon a and translate it in time
					//	by its velocity.  This is the point of intersection.
					point = a.getVertex( info[0].index[1] ).Add( u.ScaleBy( interval.tfirst ));
					
					//	Grab the edge at the same index as the extremal vertex
					var edge:Vector2d = a.getEdge( info[0].index[1] );
					
					//	Grab the minimal extremal vertex of polygon b, and
					//	its next vertex.  These two vertices are the edge
					//	of intersection
					var p:Vector2d = b.getVertex( info[1].index[0]);
					var q:Vector2d = b.getVertex( info[1].index[0] + 1 );
					
					//	Calculate the projection of each of polygon b's edge
					//	vertices onto polygon a's extremal edge
					var e:Number = edge.dot( edge ) ;
					var s0:Number = edge.dot( q.Subtract( point )) / e ;
					var s1:Number = edge.dot( p.Subtract( point )) / e ;
					
					//	Find interval intersection
					var parameters:Array = SortEdgeIntersectionParameters( [0,1,s0,s1] );
					for ( var i:int = 1; i < parameters.length-1; i++ )
					{
						vertices.push(point.Add( edge.ScaleBy( parameters[i] )));
					}
						
				}
				
			} else if ( interval.side == -1 )
			{
				//	Polygon b's max projection interval value is less than
				//	polygon a's min projection interval value
				
				if ( info[1].unique[1] )
				{
					//	Polygon a's maximum extremal vertex intersects an 
					//	one of polygon b's edges
					vertices.push(b.getVertex( info[1].index[1]).Add( v.ScaleBy( interval.tfirst )));
					
				} else if ( info[0].unique[0] )
				{
					//	Polygon b's minimal extremal vertex intersects an 
					//	one of polygon a's edges
					vertices.push(a.getVertex( info[0].index[0]).Add( u.ScaleBy( interval.tfirst )));
					
				} else
				{
					//	Edge-edge intersection
					//	Get the maximum vertex of polygon a and translate it in time
					//	by its velocity.  This is the point of intersection.
					point = b.getVertex( info[1].index[1] ).Add( u.ScaleBy( interval.tfirst ));
					
					//	Grab the edge at the same index as the extremal vertex
					edge = a.getEdge( info[0].index[0] );
					
					//	Grab the minimal extremal vertex of polygon b, and
					//	its next vertex.  These two vertices are the edge
					//	of intersection
					p = a.getVertex( info[0].index[0]);
					q = a.getVertex( info[0].index[0] + 1 );
					
					//	Calculate the projection of each of polygon b's edge
					//	vertices onto polygon a's extremal edge
					e = edge.dot( edge ) ;
					s0 = edge.dot( q.Subtract( point )) / e ;
					s1 = edge.dot( p.Subtract( point )) / e ;
					
					//	Find interval intersection
					parameters = SortEdgeIntersectionParameters( [0,1,s0,s1] );
					for ( i = 1; i < parameters.length-1; i++ )
					{
						vertices.push(point.Add( edge.ScaleBy( parameters[i] )));
					}
				}
			} else
			{
				//	Polygon a and b are already intersecting
			}
		}
		
		/**
		 * Sorts the array of numbers that represent the parametrization of
		 * the points of an edge intersection 
		 * @param interval
		 * 
		 */		
		private static function SortEdgeIntersectionParameters( interval:Array ):Array
		{
			//	Sort the list of numbers
			for ( var i:int = 1; i < interval.length; i++ )
			{
				var j:int = i - 1;
				var number:Number = interval[i];
				while ( j >= 0 && number < interval[j])
				{
					var tmp:Number = interval[j] ;
					interval[j] = number ;
					interval[j+1] = tmp ;
					j-- ;
				}
				interval[ j+1]= number ;			
			}
			
			return interval ;
		}
			  
		private static function ComputeInterval( polygon:Polygon2d, direction:Vector2d, info:ProjectionInfo ):void
		{
			info.index[0] = Polygon2d.getExtremeIndex( polygon, direction.Negate() );
			info.min = direction.dot( polygon.getVertex( info.index[0] ));
			info.index[1] = Polygon2d.getExtremeIndex( polygon, direction );
			info.max = direction.dot( polygon.getVertex( info.index[1] ));
		}
	}  
}

/**
 * Contains information about the projection of the extreme
 * vertices of a polygon onto a potential separating axis.
 * 
 * min - Represents the minimum dot product/projection of
 * a polygon's extreme vertex onto a separating axis 
 * 
 * max - Represents the maximum dot product/projection of
 * a polygon's extreme vertex onto a separating axis 
 * 
 * index - A pair of integers representing the minimum and
 * maximum vertices of a given polygon along a potential
 * separating axis
 * 
 * unique - A boolean indicating whether or not an intersection
 * is vertex-edge (true) or edge-edge (false) 
 * 
 * @author Lindi
 * 
 */
class ProjectionInfo
{
	public var min:Number ;
	public var max:Number ;
	public var index:Vector.<int> = new Vector.<int>(2,true);
	public var unique:Vector.<Boolean> = new Vector.<Boolean>(2, true); ;
}