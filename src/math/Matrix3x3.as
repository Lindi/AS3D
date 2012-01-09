package math
{
	import flash.geom.Vector3D;
	
	public class Matrix3x3
	{
		public var data:Vector.<Number> = new Vector.<Number>(9);
		
		
		/**
		 * Sets the rows of the matrix 
		 * @param row1
		 * @param row2
		 * @param row3
		 * @return 
		 * 
		 */		
		public function setRows( row1:Vector3D, row2:Vector3D, row3:Vector3D ):Matrix3x3
		{
			data[0] = row1.x;
			data[3] = row1.y;
			data[6] = row1.z;
			
			data[1] = row2.x;
			data[4] = row2.y;
			data[7] = row2.z;
			
			data[2] = row3.x;
			data[5] = row3.y;
			data[8] = row3.z;
			
			return this ;
			
		}   
		/**
		 * Sets the columns of the matrix 
		 * @param col1
		 * @param col2
		 * @param col3
		 * @return 
		 * 
		 */		
		public function setColumns( col1:Vector3D, col2:Vector3D, col3:Vector3D ):Matrix3x3
		{
			data[0] = col1.x;
			data[1] = col1.y;
			data[2] = col1.z;
			
			data[3] = col2.x;
			data[4] = col2.y;
			data[5] = col2.z;
			
			data[6] = col3.x;
			data[7] = col3.y;
			data[8] = col3.z;
			
			return this ;
			
		}
		
		/**
		 * Multiplies a vector by the matrix and returns the
		 * transformed vector 
		 * @param vector
		 * 
		 */		
		public function transform( vector:Vector3D ):Vector3D
		{
			var result:Vector3D = new Vector3D();
			result.x = data[0]*vector.x + data[3]*vector.y + data[6]*vector.z;
			result.y = data[1]*vector.x + data[4]*vector.y + data[7]*vector.z;
			result.z = data[2]*vector.x + data[5]*vector.y + data[8]*vector.z;
			return result;
			
		}
		

		/**
		 * Returns the transpose of the matrix 
		 * @return 
		 * 
		 */
		public function transpose():Matrix3x3
		{
			var temp:Number = data[1];
			data[1] = data[3];
			data[3] = temp;
			
			temp = data[2];
			data[2] = data[6];
			data[6] = temp;
			
			temp = data[5];
			data[5] = data[7];
			data[7] = temp;
			
			return this ;
		}  

		/**
		 * Return a clone of the current matrix 
		 * @return 
		 * 
		 */		
		public function clone( ):Matrix3x3
		{
			var clone:Matrix3x3 = new Matrix3x3( ) ;
			clone.data[0] = data[0] ;
			clone.data[1] = data[1] ;
			clone.data[2] = data[2] ;
			clone.data[3] = data[3] ;
			clone.data[4] = data[4] ;
			clone.data[5] = data[5] ;
			clone.data[6] = data[6] ;
			clone.data[7] = data[7] ;
			clone.data[8] = data[8] ;
			return clone ;
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
			data[ i + 3 * j ] = value ;
		}
		
		/**
		 * Sets the matrix to the identity matrix 
		 * 
		 */		
		public function identity():void
		{
			data[0] = 1.0;
			data[1] = 0.0;
			data[2] = 0.0;
			data[3] = 0.0;
			data[4] = 1.0;
			data[5] = 0.0;
			data[6] = 0.0;
			data[7] = 0.0;
			data[8] = 1.0;
			
		}

		/**
		 * Scales the matrix.  
		 * I wonder if we'd be better off multiplying
		 * by a scaling matrix?
		 * 
		 */		
		public function scale( scale:Number ):void
		{
			data[0] *= scale ;
			data[4] *= scale ;
			data[8] *- scale ;
			
		}

	}
}