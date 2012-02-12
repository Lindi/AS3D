package geometry
{
	import flash.geom.Vector3D;
	
	import math.Utils;
	
	public class Quaternion
	{
		public var x:Number ;
		public var y:Number ;
		public var z:Number ;
		public var w:Number ;

		public function Quaternion( w:Number = 1, x:Number = 0, y:Number = 0, z:Number = 0 )
		{
			this.x = x ;
			this.y = y ;
			this.z = z ;
			this.w = w ;
		}
		
		/**
		 * Returns the dot product of this quaternion with another one.
		 * @param quat
		 * @return The dot product.
		 * 
		 */		
		public function Dot( quat:Quaternion ):Number
		{
			return ( w*quat.w + x*quat.x + y*quat.y + z*quat.z);
		}

		
		/**
		 * Slerp
		 * Spherical linearly interpolate two quaternions
		 * This will always take the shorter path between them.
		 * The start and end quaternions are normalized 
		 */	
		public static function Slerp( start:Quaternion, end:Quaternion, t:Number ):Quaternion
		{
			var epsilon:Number = Utils.EPSILON ;
			
			//	Get cosine of "angle" between quaternions
			//	The dot product of two quaternions yields the same
			//	result as the dot product of two vectors.
			//	The product of their magnitudes multiplied by
			//	the cosine of the angle between them.
			
			//	The start and end quaternions
			//	are normalized initially, which is why
			//	we don't need to divide by their magnitudes
			var cosTheta:Number = start.Dot( end ) ;
			var startInterpolation:Number, endInterpolation:Number ;
			
			// if "angle" between quaternions is between zero
			//	and 90 degrees
			if ( cosTheta >= epsilon )
			{
				// if angle is greater than zero
				if ( (1.0 - cosTheta) > epsilon )
				{
					// use standard slerp
					var theta:Number = Math.acos( cosTheta );
					var recipSinTheta:Number = 1.0/Math.sin( theta ) ;
					startInterpolation = Math.sin(( 1.0 - t ) * theta ) * recipSinTheta ;
					endInterpolation = Math.sin( t * theta ) * recipSinTheta ;
				}
					// angle is close to zero
				else
				{
					// use linear interpolation
					startInterpolation = 1.0 - t;
					endInterpolation = t;
				}
			}
				// otherwise, take the shorter route
			else
			{
				// if angle is less than 180 degrees
				//	In this case, the cosine of theta
				//	is between zero and negative one, so
				//	we add, so if this sum is greater than
				//	epsilon, the angle is less than 180
				if ((1.0 + cosTheta) > epsilon )
				{
					// use slerp w/negation of start quaternion					
					theta = Math.acos( -cosTheta );
					recipSinTheta = 1.0/Math.sin( theta ) ;
					startInterpolation = Math.sin(( t - 1.0 ) * theta ) * recipSinTheta ;
					endInterpolation = Math.sin( t * theta ) * recipSinTheta ;
				}
				// angle is close to 180 degrees
				else
				{
					// use lerp w/negation of start quaternion
					startInterpolation = t - 1.0;
					endInterpolation = t;
				}
			}
			return start.scale( startInterpolation ).Add( end.scale( endInterpolation ));
		} 
		
		/**
		 * Scales the current quaternion and returns it as a new Quaternion 
		 * @param scalar
		 * @return 
		 * 
		 */		
		public function Scale( scalar:Number ):Quaternion
		{
			return new Quaternion( w *= scalar, x *= scalar, y *= scalar, z *= scalar );
		}  

		/**
		 * Scales the current quaternion and returns it. 
		 * @param scalar
		 * @return 
		 * 
		 */		
		public function scale( scalar:Number ):Quaternion
		{
			w *= scalar;
			x *= scalar;
			y *= scalar;
			z *= scalar;
			return this;
		}  
			
		
		/**
		 * Set to the unit quaternion. 
		 * @return 
		 * 
		 */		
		public function normalize():void
		{
			var lengthsq:Number = w*w + x*x + y*y + z*z;
			
			if ( Utils.IsZero( lengthsq ) )
			{
				zero();
			}
			else
			{
				var factor:Number = 1/ lengthsq ;
				w *= factor;
				x *= factor;
				y *= factor;
				z *= factor;
			}
		}
		
		/**
		 * Returns the length of the quaternion 
		 * @return 
		 * 
		 */		
		public function length():Number
		{
			return Math.sqrt( w*w + x*x + y*y + z*z );
		}
		
		/**
		 * Returns the square of the length of the quaternion 
		 * @return 
		 * 
		 */		
		public function lengthSquared():Number
		{
			return w*w + x*x + y*y + z*z ;
		}
		
		/**
		 * Sets this quaternion to the identity quaternion
		 * @return 
		 * 
		 */		
		public function identity():Quaternion
		{
			w = 1.0 ;
			x = y = z = 0.0 ;
			return this ;
		}
		
		/**
		 * Returns a quaternion corresponding to the given axis/angle 
		 * @param axis
		 * @param angle - the angle in radians
		 * @return 
		 * 
		 */		
		public function SetAxisAngle( axis:Vector3D, angle:Number ):Quaternion
		{
			// if axis of rotation is zero vector, just set to identity quat
			var lengthSquared:Number = axis.lengthSquared ;
			if ( Utils.IsZero( lengthSquared ) )
			{
				identity();
				return this ;
			}
			
			// take half-angle
			angle *= 0.5;
			
			var sintheta:Number = Math.sin( angle ) ;
			var costheta:Number = Math.cos( angle ) ;
			
			var scaleFactor:Number = sintheta/Math.sqrt( lengthSquared );
			
			w = costheta;
			x = scaleFactor * axis.x;
			y = scaleFactor * axis.y;
			z = scaleFactor * axis.z;
			return this ;
		}  
		
		/**
		 * Return a new Quaternion which is the inverse of this one 
		 * @return 
		 * 
		 */		
		public function Inverse():Quaternion {
			var norm:Number = w*w + x*x + y*y + z*z;
			if ( Utils.IsZero( norm ) )
				return new Quaternion( 1, 0, 0, 0 );
			var normRecip:Number = 1.0 / norm;
			return new Quaternion( normRecip*w, -normRecip*x, -normRecip*y, -normRecip*z );
		}
		/**
		 * Sets this quaternion to the inverse 
		 * @return 
		 * 
		 */		
		public function inverse():Quaternion
		{
			var norm:Number = w*w + x*x + y*y + z*z;
			if ( Utils.IsZero( norm ) )
				return this ;
			var normRecip:Number = 1.0 / norm;
			w = normRecip*w;
			x = -normRecip*x;
			y = -normRecip*y;
			z = -normRecip*z;
			return this;
		}
		
				
		/**
		 * Adds another quaternion to this one, and returns a new quaternion. 
		 * @param other
		 * @return 
		 * 
		 */		
		public function Add( other:Quaternion ):Quaternion
		{
			return new Quaternion( w + other.w, x + other.x, y + other.y, z + other.z );
		}   
		
		/**
		 * Returns the sum of this quaternion and another
		 * @param other
		 * @return 
		 * 
		 */		
		public function add( other:Quaternion ):Quaternion
		{
			w += other.w;
			x += other.x;
			y += other.y;
			z += other.z;
			return this;
		}  
			
			
		/**
		 * Returns the difference of this quaternion and another as a new quaternion
		 * @param other - the other quaternion
		 * @return Quaternion
		 * 
		 */		
		public function Subtract( other:Quaternion ):Quaternion
		{
			return new Quaternion( w - other.w, x - other.x, y - other.y, z - other.z );
		}
		
		
		/**
		 * Returns the difference of this quaternion and another
		 * @param other - the other quaternion
		 * @return Quaternion
		 * 
		 */		
		public function subtract( other:Quaternion ):Quaternion
		{
			w -= other.w;
			x -= other.x;
			y -= other.y;
			z -= other.z;
			return this;
		}
			
			
		/**
		 * Returns a new quaternion which is the negative of this quaternion 
		 * @return 
		 * 
		 */		
		public function Negate():Quaternion
		{
			return new Quaternion(-w, -x, -y, -z);
		}   

		
		/**
		 * Negates this quaternion in place 
		 * @return 
		 * 
		 */		
		public function negate():Quaternion
		{
			w = -w ;
			x = -x ;
			y = -y ;
			z = -z ;
			return this ;
		}   
		
			
			
			
		/**
		 * Multiply this quaternion by another and return a new Quaternion
		 * @param other
		 * @return 
		 * 
		 */			
		public function Multiply( other:Quaternion ):Quaternion
		{
			return new Quaternion( w*other.w - x*other.x - y*other.y - z*other.z,
				w*other.x + x*other.w + y*other.z - z*other.y,
				w*other.y + y*other.w + z*other.x - x*other.z,
				w*other.z + z*other.w + x*other.y - y*other.x );
		}
		
		
		/**
		 * Multiply this quaternion by another in place
		 * @param other
		 * @return 
		 * 
		 */			
		public function multiply( other:Quaternion ):Quaternion
		{
			w = w*other.w - x*other.x - y*other.y - z*other.z;
			x =	w*other.x + x*other.w + y*other.z - z*other.y;
			y =	w*other.y + y*other.w + z*other.x - x*other.z;
			z =	w*other.z + z*other.w + x*other.y - y*other.x;
			return this;
			
		}


		
		/**
		 * Returns a clone of the quaternion. 
		 * @return 
		 * 
		 */		
		public function clone():Quaternion {
			return new Quaternion( x, y, z, w ) ;
		}
		
		/**
		 * Sets all the elements of the quaternion to zero. 
		 * 
		 */		
		public function zero():void {
			x = y = z = w = 0 ;
		}

	}
}