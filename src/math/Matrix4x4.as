package math
{
	import flash.geom.Matrix;
	import flash.geom.Vector3D;

	public class Matrix4x4
	{
		public var data:Vector.<Number> ;
		
		public function Matrix4x4( data:Vector.<Number> = null )
		{
			if ( data != null )
				this.data = data ;
			else this.data = new Vector.<Number>(16);
		}
		
		public function copy( matrix:Matrix4x4 ):void
		{
			data[0] = matrix.data[0];
			data[1] = matrix.data[1];
			data[2] = matrix.data[2];
			data[3] = matrix.data[3];
			data[4] = matrix.data[4];
			data[5] = matrix.data[5];
			data[6] = matrix.data[6];
			data[7] = matrix.data[7];
			data[8] = matrix.data[8];
			data[9] = matrix.data[9];
			data[10] = matrix.data[10];
			data[11] = matrix.data[11];
			data[12] = matrix.data[12];
			data[13] = matrix.data[13];
			data[14] = matrix.data[14];
			data[15] = matrix.data[15];
			
		}
		
		public function clone():Matrix4x4
		{
			var matrix:Matrix4x4 = new Matrix4x4( ) ;
			matrix.copy( this );
			return matrix ;
		}
		
		public function identity( ):Matrix4x4
		{
			data[0] = 1.0;
			data[1] = 0.0;
			data[2] = 0.0;
			data[3] = 0.0;
			data[4] = 0.0;
			data[5] = 1.0;
			data[6] = 0.0;
			data[7] = 0.0;
			data[8] = 0.0;
			data[9] = 0.0;
			data[10] = 1.0;
			data[11] = 0.0;
			data[12] = 0.0;
			data[13] = 0.0;
			data[14] = 0.0;
			data[15] = 1.0;
			return this ;
		}
		
		public function inverse( ):Matrix4x4
		{
			return Inverse( this ) ;
		}
		
		public function transpose():Matrix4x4
		{
			var temp:Number = data[1];
			data[1] = data[4];
			data[4] = temp;
			
			temp = data[2];
			data[2] = data[8];
			data[8] = temp;
			
			temp = data[3];
			data[2] = data[12];
			data[12] = temp;
			
			temp = data[6];
			data[6] = data[9];
			data[9] = temp;
			
			temp = data[7];
			data[7] = data[13];
			data[13] = temp;
			
			temp = data[11];
			data[11] = data[14];
			data[14] = temp;
			
			return this ;
		}
		
		
		
		public function translate( vector:Vector3D ):Matrix4x4
		{
			data[0] = 1.0;
			data[1] = 0.0;
			data[2] = 0.0;
			data[3] = 0.0;
			data[4] = 0.0;
			data[5] = 1.0;
			data[6] = 0.0;
			data[7] = 0.0;
			data[8] = 0.0;
			data[9] = 0.0;
			data[10] = 1.0;
			data[11] = 0.0;
			data[12] = vector.x;
			data[13] = vector.y;
			data[14] = vector.z;
			data[15] = 1.0;
			return this ;
			
		}
		
		public function scale( scale:Number ):Matrix4x4
		{
			data[0] = scale;
			data[1] = 0.0;
			data[2] = 0.0;
			data[3] = 0.0;
			data[4] = 0.0;
			data[5] = scale;
			data[6] = 0.0;
			data[7] = 0.0;
			data[8] = 0.0;
			data[9] = 0.0;
			data[10] = scale;
			data[11] = 0.0;
			data[12] = 0;
			data[13] = 0;
			data[14] = 0;
			data[15] = 1.0;
			return this ;
			
		}
				
		/**
		 * Multiplies a 4x4 matrix by another 4x4 matrix 
		 * @param matrix
		 * @return 
		 * 
		 */		
		public function multiply( matrix:Matrix4x4 ):Matrix4x4
		{
			
			var product:Matrix4x4 = new Matrix4x4( );
			product.data[0] = data[0]*matrix.data[0] + data[4]*matrix.data[1] + data[8]*matrix.data[2] 
				+ data[12]*matrix.data[3];
			product.data[1] = data[1]*matrix.data[0] + data[5]*matrix.data[1] + data[9]*matrix.data[2] 
				+ data[13]*matrix.data[3];
			product.data[2] = data[2]*matrix.data[0] + data[6]*matrix.data[1] + data[10]*matrix.data[2] 
				+ data[14]*matrix.data[3];
			product.data[3] = data[3]*matrix.data[0] + data[7]*matrix.data[1] + data[11]*matrix.data[2] 
				+ data[15]*matrix.data[3];
			
			product.data[4] = data[0]*matrix.data[4] + data[4]*matrix.data[5] + data[8]*matrix.data[6] 
				+ data[12]*matrix.data[7];
			product.data[5] = data[1]*matrix.data[4] + data[5]*matrix.data[5] + data[9]*matrix.data[6] 
				+ data[13]*matrix.data[7];
			product.data[6] = data[2]*matrix.data[4] + data[6]*matrix.data[5] + data[10]*matrix.data[6] 
				+ data[14]*matrix.data[7];
			product.data[7] = data[3]*matrix.data[4] + data[7]*matrix.data[5] + data[11]*matrix.data[6] 
				+ data[15]*matrix.data[7];
			
			product.data[8] = data[0]*matrix.data[8] + data[4]*matrix.data[9] + data[8]*matrix.data[10] 
				+ data[12]*matrix.data[11];
			product.data[9] = data[1]*matrix.data[8] + data[5]*matrix.data[9] + data[9]*matrix.data[10] 
				+ data[13]*matrix.data[11];
			product.data[10] = data[2]*matrix.data[8] + data[6]*matrix.data[9] + data[10]*matrix.data[10] 
				+ data[14]*matrix.data[11];
			product.data[11] = data[3]*matrix.data[8] + data[7]*matrix.data[9] + data[11]*matrix.data[10] 
				+ data[15]*matrix.data[11];
			
			product.data[12] = data[0]*matrix.data[12] + data[4]*matrix.data[13] + data[8]*matrix.data[14] 
				+ data[12]*matrix.data[15];
			product.data[13] = data[1]*matrix.data[12] + data[5]*matrix.data[13] + data[9]*matrix.data[14] 
				+ data[13]*matrix.data[15];
			product.data[14] = data[2]*matrix.data[12] + data[6]*matrix.data[13] + data[10]*matrix.data[14] 
				+ data[14]*matrix.data[15];
			product.data[15] = data[3]*matrix.data[12] + data[7]*matrix.data[13] + data[11]*matrix.data[14] 
				+ data[15]*matrix.data[15];
			
			return product;
			
		}
		
		/**
		 * Returns true if the matrix is the identity matrix, and false if not 
		 * @return 
		 * 
		 */		
		public function isIdentity( ):Boolean
		{
			return Utils.AreEqual( 1.0, data[0] )
				&& Utils.AreEqual( 1.0, data[5] )
				&& Utils.AreEqual( 1.0, data[10] )
				&& Utils.AreEqual( 1.0, data[15] )
				&& Utils.IsZero( data[1] ) 
				&& Utils.IsZero( data[2] )
				&& Utils.IsZero( data[3] )
				&& Utils.IsZero( data[4] ) 
				&& Utils.IsZero( data[6] )
				&& Utils.IsZero( data[7] )
				&& Utils.IsZero( data[8] )
				&& Utils.IsZero( data[9] )
				&& Utils.IsZero( data[11] )
				&& Utils.IsZero( data[12] )
				&& Utils.IsZero( data[13] )
				&& Utils.IsZero( data[14] );
		}
		
		/**
		 * Returns the matrix inverse if one exists 
		 * @param matrix
		 * @return 
		 * 
		 */		
		public static function Inverse( matrix:Matrix4x4 ):Matrix4x4
		{
			
			var inverse:Matrix4x4 = new Matrix4x4( ); 
			
			var cofactor0:Number = matrix.data[5]*matrix.data[10] - matrix.data[6]*matrix.data[9];
			var cofactor4:Number = matrix.data[2]*matrix.data[9] - matrix.data[1]*matrix.data[10];
			var cofactor8:Number = matrix.data[1]*matrix.data[6] - matrix.data[2]*matrix.data[5];
			var determinant:Number = matrix.data[0]*cofactor0 + matrix.data[4]*cofactor4 + matrix.data[8]*cofactor8;
			
			if (Utils.IsZero( determinant ))
			{
				throw new Error( "Matrix has no inverse." );
			}
			
			var inverseDeterminant:Number = 1.0/determinant;
			inverse.data[0] = inverseDeterminant*cofactor0;
			inverse.data[1] = inverseDeterminant*cofactor4;
			inverse.data[2] = inverseDeterminant*cofactor8;
			
			inverse.data[4] = inverseDeterminant*(matrix.data[6]*matrix.data[8] - matrix.data[4]*matrix.data[10]);
			inverse.data[5] = inverseDeterminant*(matrix.data[0]*matrix.data[10] - matrix.data[2]*matrix.data[8]);
			inverse.data[6] = inverseDeterminant*(matrix.data[2]*matrix.data[4] - matrix.data[0]*matrix.data[6]);
			
			inverse.data[8] = inverseDeterminant*(matrix.data[4]*matrix.data[9] - matrix.data[5]*matrix.data[8]);
			inverse.data[9] = inverseDeterminant*(matrix.data[1]*matrix.data[8] - matrix.data[0]*matrix.data[9]);
			inverse.data[10] = inverseDeterminant*(matrix.data[0]*matrix.data[5] - matrix.data[1]*matrix.data[4]);
			
			inverse.data[12] = -matrix.data[0]*matrix.data[12] - matrix.data[4]*matrix.data[13] - matrix.data[8]*matrix.data[14];
			inverse.data[13] = -matrix.data[1]*matrix.data[12] - matrix.data[5]*matrix.data[13] - matrix.data[9]*matrix.data[14];
			inverse.data[14] = -matrix.data[2]*matrix.data[12] - matrix.data[6]*matrix.data[13] - matrix.data[10]*matrix.data[14];
			inverse.data[15] = 1 ;
			
			return inverse;
			
		}
		
		/**
		 * Sets the upper 3x3 matrix to the rotation matrix specified
		 * by the rotation 3x3 matrix argument 
		 * @param rotation
		 * 
		 */		
		public function setRotation( rotation:Matrix3x3 ):Matrix4x4
		{
			
			data[0] = rotation.data[0];
			data[1] = rotation.data[1];
			data[2] = rotation.data[2];
			data[3] = 0;
			data[4] = rotation.data[3];
			data[5] = rotation.data[4];
			data[6] = rotation.data[5];
			data[7] = 0;
			data[8] = rotation.data[6];
			data[9] = rotation.data[7];
			data[10] = rotation.data[8];
			data[11] = 0;
			data[12] = 0;
			data[13] = 0;
			data[14] = 0;
			data[15] = 1;
			
			return this;
			
		}
		/**
		 * Transforms a vector by this matrix.  This transform
		 * assumes this is a row-major matrix.
		 *  
		 * @param vector - The vector to be transformed
		 * @return The transformed vector
		 * 
		 */		
		public function transform( vector:Vector3D ):Vector3D
		{
			var transform:Vector3D = new Vector3D( );
			transform.x = data[0]*vector.x + data[4]*vector.y + data[8]*vector.z + data[12]*vector.w;
			transform.y = data[1]*vector.x + data[5]*vector.y + data[9]*vector.z + data[13]*vector.w;
			transform.z = data[2]*vector.x + data[6]*vector.y + data[10]*vector.z + data[14]*vector.w;
			transform.w = data[3]*vector.x + data[7]*vector.y + data[11]*vector.z + data[15]*vector.w;
			return transform;
		}
		
		
		
		
		public static function Transpose( matrix:Matrix4x4 ):Matrix4x4
		{
			var transpose:Matrix4x4 = new Matrix4x4();
			transpose.data[0] = matrix.data[0];
			transpose.data[1] = matrix.data[4];
			transpose.data[2] = matrix.data[8];
			transpose.data[3] = matrix.data[12];
			transpose.data[4] = matrix.data[1];
			transpose.data[5] = matrix.data[5];
			transpose.data[6] = matrix.data[9];
			transpose.data[7] = matrix.data[13];
			transpose.data[8] = matrix.data[2];
			transpose.data[9] = matrix.data[6];
			transpose.data[10] = matrix.data[10];
			transpose.data[11] = matrix.data[14];
			transpose.data[12] = matrix.data[3];
			transpose.data[13] = matrix.data[7];
			transpose.data[14] = matrix.data[11];
			transpose.data[15] = matrix.data[15];
			return transpose ;
			
		}
		
		/**
		 * Sets a value using row/column indices 
		 * @param i
		 * @param j
		 * @param value
		 * 
		 */		
		public function set( i:int, j:int, value:Number ):void
		{
			data[ i + 4 * j ] = value ;
		}
		
		public function get( i:int, j:int ):Number
		{
			return data[ i + 4 * j ] ;
		}
		/**
		 * Return angular rotation matrix 
		 * @param xRotation - x-axis rotation angle (in degrees)
		 * @param yRotation - y-axis rotation angle (in degrees)
		 * @param zRotation - z-axis rotation angle (in degrees)
		 * @return 
		 * 
		 */		
		public static function Rotation( xRotation:Number, yRotation:Number, zRotation:Number ):Matrix4x4
		{
			
			//	Convert the angles to radians
			var radians:Number = Math.PI / 180 ;
			xRotation *= radians ;
			yRotation *= radians ;
			zRotation *= radians ;
		
			var Cx:Number = Math.cos( xRotation );
			var Sx:Number = Math.sin( xRotation );
			var Cy:Number = Math.cos( yRotation );
			var Sy:Number = Math.sin( yRotation );
			var Cz:Number = Math.cos( zRotation );
			var Sz:Number = Math.sin( zRotation );
			
			var matrix:Matrix4x4 = new Matrix4x4();
			
			matrix.data[0] =  (Cy * Cz);
			matrix.data[4] = -(Cy * Sz);  
			matrix.data[8] =  Sy;
			matrix.data[12] = 0.0;
			
			matrix.data[1] =  (Sx * Sy * Cz) + (Cx * Sz);
			matrix.data[5] = -(Sx * Sy * Sz) + (Cx * Cz);
			matrix.data[9] = -(Sx * Cy); 
			matrix.data[13] = 0.0;
			
			matrix.data[2] = -(Cx * Sy * Cz) + (Sx * Sz);
			matrix.data[6] =  (Cx * Sy * Sz) + (Sx * Cz);
			matrix.data[10] =  (Cx * Cy);
			matrix.data[14] = 0.0;
			
			matrix.data[3] = 0.0;
			matrix.data[7] = 0.0;
			matrix.data[11] = 0.0;
			matrix.data[15] = 1.0;
			
			return matrix ;
			
		}  // End of IvMatrix44::Rotation()

		public function rotate( matrix:Matrix3x3 ):Matrix4x4
		{
			data[0] = matrix.data[0];
			data[1] = matrix.data[1];
			data[2] = matrix.data[2];
			data[3] = 0;
			data[4] = matrix.data[3];
			data[5] = matrix.data[4];
			data[6] = matrix.data[5];
			data[7] = 0;
			data[8] = matrix.data[6];
			data[9] = matrix.data[7];
			data[10] = matrix.data[8];
			data[11] = 0;
			data[12] = 0;
			data[13] = 0;
			data[14] = 0;
			data[15] = 1;
			
			return this;
		}

	}
}