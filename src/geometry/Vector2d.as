package geometry
{
	public class Vector2d 
	{
	
		private var _data:Vector.<Number> = new Vector.<Number>(2,true);
		
		public function Vector2d( x:Number = 0, y:Number = 0)
		{
			_data[0] = x ;
			_data[1] = y ;
		}
		
		/**
		 * Updates this vector in place by computing the difference
		 * between this vector and the argument vector 
		 * @param vector
		 * 
		 */		
		public function subtract( vector:Vector2d ):void
		{
			this.x -= vector.x ;
			this.y -= vector.y ;
		}
		
		/**
		 * Returns a new vector which is the difference between this
		 * vector and the argument vector 
		 * @param vector
		 * @return 
		 * 
		 */		
		public function Subtract( vector:Vector2d ):Vector2d
		{
			return new Vector2d( this.x - vector.x, this.y - vector.y ) ;
		}
			
		/**
		 * Updates this vector in place by computing the sum
		 * of this vector and the argument vector 
		 * @param vector
		 * 
		 */		
		public function add( vector:Vector2d ):void
		{
			this.x += vector.x ;
			this.y += vector.y ;
		}
		
		/**
		 * Returns a new vector which is the sum of this
		 * vector and the argument vector 
		 * @param vector
		 * @return 
		 * 
		 */		
		public function Add( vector:Vector2d ):Vector2d
		{
			return new Vector2d( this.x + vector.x, this.y + vector.y ) ;
		}
		
		/**
		 * Returns a copy of the current vector scaled by a given scale factor 
		 * @param scale
		 * @return 
		 * 
		 */		
		public function ScaleBy( scale:Number ):Vector2d
		{
			var vector:Vector2d = this.clone();
			vector.scale( scale ) ;
			return vector ;
		}
		
		/**
		 * Scales the current vector in place 
		 * @param scale
		 * 
		 */		
		public function scale( scale:Number ):void
		{
			_data[0] *= scale ; _data[1] *= scale ;
		}
		
		
		/**
		 * Returns the vector dot product of this vector
		 * with the parameter vector 
		 * @param vector
		 * @return 
		 * 
		 */		
		public function dotProduct( vector:Vector2d ):Number
		{
			return _data[0] * vector.x + _data[1] * vector.y ;
		}
		
		/**
		 * Returns the vector dot product of this vector
		 * with the parameter vector (shorter function name)
		 * @param vector
		 * @return 
		 * 
		 */		
		public function dot( vector:Vector2d ):Number
		{
			return _data[0] * vector.x + _data[1] * vector.y ;
		}
		
		/**
		 * Returns the two-dimensional cross-product which is
		 * the determinant of a 2x2 row matrix of each vector's
		 * components
		 * 
		 */		
		public function crossProduct( vector:Vector2d ):Number
		{
			return x * vector.y - y * vector.x ;
		}
		
		/**
		 * Negates the current vector
		 * @return 
		 * 
		 */		
		public function negate():void
		{
			_data[0] = -_data[0] ;
			_data[1] = -_data[1] ;
		}
		
		/**
		 * Returns a new vector which is the negative of the
		 * current vector 
		 * @return 
		 * 
		 */		
		public function Negate():Vector2d
		{
			return new Vector2d( -_data[0], -_data[1] );
		}
		
		/**
		 * Returns a clone of the current vector 
		 * @return 
		 * 
		 */		
		public function clone() : Vector2d
		{
			return new Vector2d( _data[0], _data[1] );
		}
		
		/**
		 * Changes this vector to its perpendicular
		 * 
		 */		
		public function perpendicular():void
		{
			var tmp:Number = _data[0] ;
			_data[0] = _data[1] ;
			_data[1] = -tmp ;
		}
		
		/**
		 * Returns the vector that is the perpendicular of this one
		 * @return 
		 * 
		 */		
		public function perp(  ):Vector2d
		{
			return new Vector2d( _data[1], -_data[0] );
		}
		
		/**
		 * Returns the normalized perpendicular of this vector 
		 * @return 
		 * 
		 */		
		public function unitPerp():Vector2d
		{
			var perp:Vector2d = new Vector2d( _data[1], -_data[0] );
			perp.normalize();
			return perp ;
		}
		
		/**
		 * Divides each component of this vector by its length 
		 * 
		 */		
		public function normalize():void
		{
			var magnitude:Number = Math.sqrt( _data[0] * _data[0] + _data[1] * _data[1] );
			_data[0] /= magnitude ;
			_data[1] /= magnitude ;
		}
		
		/**
		 * Returns the length of the vector 
		 * @return 
		 * 
		 */		
		public function get length():Number
		{
			return Math.sqrt( _data[0] * _data[0] + _data[1] * _data[1] );
		}
		
		/**
		 * Returns the x-coordinate of this vector 
		 * @return 
		 * 
		 */		
		public function get x():Number
		{
			return _data[0] ;
		}
		
		/**
		 * Updates the x-coordinate of this vector 
		 * @param x
		 * 
		 */		
		public function set x( x:Number ):void
		{
			_data[0] = x ;
		}

		/**
		 * Returns the y-coordinate of this vector 
		 * @return 
		 * 
		 */		
		public function get y():Number
		{
			return _data[1] ;
		}

		/**
		 * Updates the y-coordinate of this vector 
		 * @param y
		 * 
		 */		
		public function set y( y:Number ):void
		{
			_data[1] = y ;
		}
	}
}