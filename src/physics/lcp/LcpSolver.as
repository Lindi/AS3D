package physics.lcp
{
	public class LcpSolver
	{
		public static var FOUND_TRIVIAL_SOLUTION:int = 0 ;
		public static var FOUND_SOLUTION:int = 1 ;
		public static var CANNOT_REMOVE_COMPLEMENTARY_VARIABLE:int = 2 ;
		public static var EXCEEDED_MAX_RETRIES:int = 3 ;
		
		private var maxRetries:int = 50;
		private var numberOfEquations:int ;
		private var equations:Vector.<Equation> ;
		private var M:Vector.<Vector.<Number>> ;
		private var Q:Vector.<Number> ;
		//private var result:Object ;
		
		private var departingVariableIndex:int ;
		private var departingVariable:String ;
		private var nonBasicVariableIndex:int ;
		private var nonBasicVariable:String ;
		private var zeroTolerance:Number = 0.0 ;
		private var ratioError:Number = 0.0 ;
		
		/**
		 * Implementation of Lemke's algorithm to solve the linear complementarity problem 
		 * @param numberOfEquations - the number of equations for which we're finding a solution
		 * @param M - Matrix of coefficients
		 * @param Q - Vector of slack variables
		 * @param Z - Vector of non-basic variables
		 * @param W - Vector of basic variables
		 * @param info - Object containing the following properties:
		 * status -
		 * maxRetries -
		 * zeroTolerance - 
		 * ratioError
		 * 
		 */		
		public function LcpSolver
			( numberOfEquations:int, M:Vector.<Vector.<Number>>, 
			  Q:Vector.<Number>, result:Object)
		{
			this.numberOfEquations = numberOfEquations ;
			this.equations = new Vector.<Equation>( numberOfEquations, true );
			this.M = M ;
			this.Q = Q ;
			//this.zeroTolerance = result.zeroTolerance ;
			//this.ratioError = result.ratioError ;
			initialize( result ) ;
			
		}
		
		private function initialize( result:Object ):void
		{
			allocateEquations();
			if (initializeEquations())
			{
				for ( var i:int = 0; i < maxRetries; i++ )
				{
					var info:Object = new Object();
					if ( !selectEquation( info ))
					{
						result.status = CANNOT_REMOVE_COMPLEMENTARY_VARIABLE ;
						break ;
					}
					
					var index:int = info.index - 1;
					solve( equations[index].Var, equations[index].VarIndex );
					printEquations();
					
					//	Is z0 basic?
					var basic:Boolean = false ;
					for ( var j:int = 0; j < numberOfEquations; j++)
					{
						if ( equations[j].Var == 'z' && equations[j].VarIndex == 0 )
						{
							basic = true ;
							break ;
						}
					}
					
					
					if ( !basic )
					{
						//	Copy the solution into two arrays
						var Z:Array = new Array( numberOfEquations );
						var W:Array = new Array( numberOfEquations );
						for ( j = 0; j < numberOfEquations; j++)
						{
							if ( equations[j].Var == 'z' )
							{
								Z[equations[j].VarIndex-1] = equations[j].C[0] ;
							} else 
							{
								W[equations[j].VarIndex-1] = equations[j].C[0] ;
							}
						}
						
						result.status = FOUND_SOLUTION ;
						result.Z = Z ;
						result.W = W ;
						break ;
					}
					
					
				}
				
				if ( i == maxRetries )
				{
					result.status = EXCEEDED_MAX_RETRIES ;
				}
			} else {
				result.status = FOUND_TRIVIAL_SOLUTION ;
			}
		}
		
		/**
		 * Create the collection of equations
		 * So, ... we're creating a collection of these equation objects.
		 * I get that.  Each equation instance contains three collections:
		 * 1 for the constants, 1 for the W coefficients and 1 for the Z coefficients
		 * 
		 * So I guess ... each equation represents a row in our system of equations
		 * but if that's the case ... then why does each one have a collection
		 * of coefficients that is one more than the number of equations long? 
		 * 
		 * Okay, I see now.  We obviously have a collection of w's and z's since
		 * each equation can have z1, z2, z3, or w1, w2, w3 and so forth ...
		 * However, each equation can have only 1 constant term.  We keep
		 * the constant term for each equation in the first element of each
		 * equation's C vector.  We then set all the other constant term
		 * coefficients to 1.0.  I think we do this so that we don't bomb out
		 * when we're finding the limiting equation using the ratio of the constant
		 * coefficient to the non-basic variable coefficient? 
		 * 
		 */		
		private function allocateEquations():void
		{
			equations = new Vector.<Equation>(numberOfEquations,true);
			var n:int = numberOfEquations + 1;
			for (var i:int = 0; i < numberOfEquations; ++i)
			{
				equations[i] = new Equation();
				equations[i].C = new Vector.<Number>(n);
				equations[i].W = new Vector.<Number>(n);
				equations[i].Z = new Vector.<Number>(n);
			}
		}
		
		private function initializeEquations():Boolean
		{
			var numberOfEquationsP1:int = numberOfEquations + 1;
			var i:int ;
			for (i = 0; i < numberOfEquations; ++i)
			{
				// Initially w's are basic, z's are non-basic.
				equations[i].Var = 'w';
				
				//	w indices run from 1 to numberOfEquations.
				//	This is why we return the equation index + 1 from
				//	functions that find a limiting equation.  
				//	Because the equation var index is 1-indexed
				//	Makes sense, since according to the algorithm
				//	the auxiliary variable is z0
				//	and every other variable index starts with 1
				equations[i].VarIndex = i + 1;
				
				//	The extra variable in the equations is z0.
				//	Each z0 variable has a coefficient of 1
				equations[i].Z[0] = 1.0;
				
				//	Set all but the first constant coefficient to 1
				equations[i].C[i + 1] = 1.0;
			}
			
			// Check whether all the constant terms are nonnegative.  If so, the
			// solution is z = 0 and w = constant_terms.  The caller will set the
			// values of z and w, so just return from here.
			var constTermMin:Number = 0.0;
			for (i = 0; i < numberOfEquations; ++i)
			{
				//	Here, we set the first constant coefficient
				//	to the ith coefficient in the Q vector
				equations[i].C[0] = Q[i];
				if (Q[i] < constTermMin)
				{
					constTermMin = Q[i];
				}
			}
			if (constTermMin >= 0.0)
			{
				return false;
			}
			
			// Enter Z terms.
			var j:int ;
			for (i = 0; i < numberOfEquations; ++i)
			{
				//	Set equations Z[0] to 0.0 for any row in which all mM are 0.0.
				//	Obviously, if you have an equation with only a constant term,
				//	the z0 coefficient is going to be 0 because ...
				var rowOfZeros:Number = 0.0;
				
				//	We loop over the number of equations because
				//	the number of columns in the M matrix must match the number
				//	of rows in the Z matrix (which is the number of equations)
				for (j = 0; j < numberOfEquations; ++j)
				{
					var temp:Number = M[i][j];
					
					//	We set each equation's Z coefficients 
					//	starting with index 1
					equations[i].Z[j + 1] = temp;
					if (temp != 0.0)
					{
						rowOfZeros = 1.0;
					}
				}
				
				//	If all the other coefficients in the equation are 0.0
				//	then kill z0 from the equation
				equations[i].Z[0] *= rowOfZeros;
			}
			
//			for (i = 0; i < numberOfEquations; ++i)
//			{
//				// Find the max abs value of the coefficients on each row and divide
//				// each row by that max abs value.
//				var maxAbsValue:Number = 0.0;
//				for (j = 0; j < numberOfEquationsP1; ++j)
//				{
//					var absValue:Number = Math.abs(equations[i].C[j]);
//					if (absValue > maxAbsValue)
//					{
//						maxAbsValue = absValue;
//					}
//					
//					absValue = Math.abs(equations[i].W[j]);
//					if (absValue > maxAbsValue)
//					{
//						maxAbsValue = absValue;
//					}
//					
//					absValue = Math.abs(equations[i].Z[j]);
//					if (absValue > maxAbsValue)
//					{
//						maxAbsValue = absValue;
//					}
//				}
//				
//				var invMaxAbsValue:Number = 1.0/maxAbsValue;
//				for (j = 0; j < numberOfEquationsP1; ++j)
//				{
//					equations[i].C[j] *= invMaxAbsValue;
//					equations[i].W[j] *= invMaxAbsValue;
//					equations[i].Z[j] *= invMaxAbsValue;
//				}       
//			}
			return true;
		}
		/**
		 * We select an equation as follows:
		 * If the extra variable z0 is not basic, we solve for it by choosing the equation
		 * with the smallest (most negative?) constant negative term.
		 * 
		 * If a variable in the 'W' (wj) vector has left the building (the dictionary, but the building is more fun)
		 * then we solve for zj.  It's kind of confusing, because z0 is the extra variable, but there's also
		 * a z vector, and so zj denotes the jth element of the Z vector.  Anyway, if one of the w's has just left
		 * the building, we solve for one of the variables in the z vector by finding the coefficient cj
		 * of term zj that is negative, and then finding the smallest ratio of the constant term of equation
		 * j and the negative of the coefficient of zj (constantj/-zj)
		 * 
		 * @param info - An object with a property 'index'.  The function will store the
		 * index of the equation it found in this variable.
		 * 
		 * @return - true if the function found an equation, false if not 
		 * 
		 */		
		private function selectEquation( result:Object ):Boolean
		{
			//	Is z0 basic?
			var basic:Boolean = false ;
			for ( var i:int = 0; i < numberOfEquations; i++ )
			{
				var equation:Equation = equations[i] ;
				
				//	If the variable of each equation is 'w', and the var index is 0, then z0 is basic
				//	Ah, okay.  I see why there's a var index now.  Var index specifies which z variable
				//	in the equation the algorithm is considering.  
				if ( equation.Var == 'z' && equation.VarIndex == 0 )
				{
					basic = true ;
				}
				
				//	If z0 is not basic, then we find the equation with the smallest negative constant term
				if ( !basic )
				{
					departingVariableIndex =
						nonBasicVariableIndex = 0 ;
					departingVariable =
						nonBasicVariable = 'z' ;
					
				} else 
				{
					//	If a variable is in the dictionary, it's basic.  If a variable is out of the dictionary
					//	it's non-basic.  (I *think* basic refers to the basis of a vector space?
					//	Anyway, like the idea that that which is non-basic cannot be defined.)
					//	So, z0 is initially *non-basic*.  If z0 is *now basic*, then we set the new
					//	non-basic variable to that which just left the dictionary.
					
					//	I was confused about this initially, because I thought well, if z0 is
					//	now non-basic, then why not just set the new nonBasic variable to 'w'?
					//	But that question misunderstands what the algorithm's doing.  The algorithm
					//	is alternately solving for variables in the w vector and variables in the z vector
					//	because they're complementary (when one iz zero, the other must be non-zero and
					//	vice-versa).  Therefore, at this point, since z0 has left the dictionary
					//	the new non-basic variable must be wj or zj (must be an element in either
					//	the w vector or the z vector), and that's why we must check what the departing
					//	variable is, and set the new non-basic variable to the opposite of the
					//	departing variable (I think this is to ensure that the algorithm doesn't
					//	encounter the same set of equations twice?)
					
					//	So if 'w' is departing the dictionary, it is becoming non-basic.  Which means
					//	that it's opposite is already non-basic (and about to become basic?)
					nonBasicVariable = ( departingVariable == 'w' ? 'z' : 'w' );
				}
				
				var found:Boolean = findEquation( result ) ;
				if ( found )
				{
					var index:int = result.index - 1 ;
					
					//	The nonBasicVariableIndex is the index of the variable
					//	that's entering the dictionary
					nonBasicVariableIndex = departingVariableIndex ;
					
					//	The departingVariable, therefore, is the variable
					//	of the equation that we've found.  
					//	N.B.: The Var variable denotes the found equation's *basic variable*
					//	The VarIndex variable denotes the found equation's *basic variable*
					departingVariable = equations[index].Var ;
					departingVariableIndex = equations[index].VarIndex ;
					
				}
				return found ;
			}
			return false ;
		}
		
		private function findEquation( result:Object ):Boolean
		{
			//	Okay, so if z0 is not leaving the dictionary
			if ( departingVariableIndex != 0 )
			{
				// Find the limiting equation for variables other than z0.  The
				// coefficient of the variable must be negative.  The ratio of the
				// constant polynomial to the negative of the smallest coefficient
				// of the variable is sought.   The constant polynomial must be
				// evaluated to compute this ratio.  It must be evaluated at a value
				// of the variable, dEpsi, such that the ratio remains smallest for
				// all smaller dEpsi.
				return equationAlgorithm(result);
			}
			// Special case for nonbasic z0; the coefficients are 1.  Find the
			// limiting equation when solving for z0.  At least one C[0] must be
			// negative initially or we start with a solution.  If all of the
			// negative constant terms are different, pick the equation with the
			// smallest (negative) ratio of constant term to the coefficient of
			// z0.  If several equations contain the smallest negative constant
			// term, pick the one with the highest coefficient for that one
			// contains dEpsi to the largest exponent.  NOTE: This is equivalent
			// to using the constant term polynomial in dEpsi but avoids
			// evaluating it.
			
			//	If z0 is non-basic, we find the equation with the smallest
			//	negative constant coefficient.
			var minValue:Number = 0 ;
			for (var i:int = 0; i < numberOfEquations; i++)
			{
				if (equations[i].Z[0] != 0.0)
				{
					var value:Number = equations[i].C[0]/equations[i].Z[0];
					if (value <= minValue || minValue == 0.0)
					{
						minValue = value;
						
						//	We always return the equation index + 1
						result.index = i + 1;
					}
				}
			}
			return minValue < 0.0;
		}

		private function equationAlgorithm( result:Object ):Boolean
		{
			//	Initialize the loop counters
			var i:int, j:int ;
			
			//	Initialize the found array
			//	This array will hold the indices of the equations w/negative
			//	coefficients for the (nonBasicVariable, departingVariableIndex)
			var found:Array= new Array( equations.length + 1 );
			for ( i=0; i < equations.length + 1; i++ )
			{
				found[i] = new Array(2);
			}
			
			// 	Find equations with negative coefficients for selected index.
			//	Okay, so basically what's happening here is that we're finding
			//	all the equations with coefficients for the non-basic variable we
			//	wish to enter the dictionary.
			
			//	So, for example, if w1 has just left the dictionary
			//	then z1 must enter.  In that case, the nonBasicVariable will be z
			//	and the variable index we're interested in will be that of the
			//	variable that just left the dictionary (in this case 1).
			var temp:Number ;
			for (i = 0, j = 0; i < equations.length; ++i)
			{                                    
				if ( nonBasicVariable == 'z')
				{
					temp = equations[i].Z[departingVariableIndex];
				}
				else
				{
					temp = equations[i].W[departingVariableIndex];
				}
				
				if (temp < 0)
				{
					//	We need to find the non-basic variable with a negative coefficient such
					//	that it becomes positive when it enters the dictionary.  This way, division
					//	of the equation it belongs to by its coefficient won't make the equation's
					//	constant coefficient negative
					found[j++][0] = i;
				}
			}
			
			if ( j != 0 )
			{
				//	If we have found terms with negative coefficients ...
				//	Okay, now this part's tricky.
				//	First, we set the 1st element of the array *after* the last found array with
				//	a negative coefficient to -1.  This serves as a sentinel, to tell us
				//	when we've reached the end of the list
				found[j][0] = -1 ;
				
				//	Find the equation with the smallest ratio of constant term
				//	with selected (nonbasicvariable, departingVariableIndex) coefficient
				//	First, initialize two found array cursors
				var row1:int, row2:int ;
				
				//	These are column index variables.  
				//	If column1 is 0, then column2 must be 1 and vice versa
				var column1:int, column2:int ;
				column1 = 0; column2 = 1 ;
				
				
				//	Iterate over the equations
				for ( i = 0; i <= equations.length; i++)
				{
					//	Initialize the column counters
					column2 = ( column1 == 0 ? 1 : 0 );
					
					//	Initialize the row counters
					row1 = row2 = 0 ;
					
					//	Grab the equation index of the row
					//	we're holding 'fixed' (row1) and store it
					//	in the spare column of row2
					var index1:int = found[row1++][column1] ;
					found[row2++][column2] = index1 ; 
					
					//	Store row1 in a variable k
					var k:int = row1 ;
					while ( found[k][column1] > -1 )
					{
						//	Get the index in column1 of row k
						//	Row k changes while (k is incremented after
						//	the equation comparison) row2 doesn't
						var index2:int = found[k][column1] ;
						
						//	If it's negative, break out of the loop
						if ( index2 < 0 )
						{
							break ;
						}
						
						var denom1:Number, denom2:Number ;
						if ( nonBasicVariable == 'z')
						{
							denom1 = equations[index1].Z[departingVariableIndex];
							denom2 = equations[index2].Z[departingVariableIndex];
						}
						else
						{
							denom1 = equations[index1].W[departingVariableIndex]; 
							denom2 = equations[index2].W[departingVariableIndex]; 
						}
						
						
						//	Make sure that the ratio of the equation at the kth found index
						//	(the kth found index is what's changing) is less than the ratio
						//	for the row we're holding fixed
						temp = equations[index2].C[i]/denom2 -
							equations[index1].C[i]/denom1;
						
						
						if (temp < 0.0)       
						{
							// The first equation has the smallest ratio.  Do nothing;
							// the first equation is the choice.
						}
						else if (temp > 0.0) 
						{
							
							//	This means we've found an equation that's less
							//	than the "kth" one, so we stick k in row one, 
							//	such that it becomes the pointer to the index of
							//	the minimum equation
							
							// The second equation has the smallest ratio.
							row1 = k;  // Make second equation comparison standard.
							row2 = 0;  // Restart the found array index.
							
							//	Grab the index of the new minimum equation
							//	and stick it in the 'spare' column of row2
							index1 = found[row1++][column1];
							found[row2++][column2] = index1;
						}
						else  // The ratios are the same.
						{
							//	Set the 'spare column' of the spare row
							//	to the index of the equation that is also
							//	as small as our minimum equation
							found[row2++][column2] = index2 ;
						}
						
						//	Increment k
						k++;
						
						//	Eliminate the 'row2th' equation
						found[row2][column2] = -1;
						
					}
					
					if ( row2 == 1 )
					{
						//	If we've gone all the way through the list
						//	without incrementing row2 (it's still 1, which was its
						//	value before the start of the while loop), that means our minimum
						//	equation index is in the spare column of row 0
						result.index = found[0][column2] + 1;
						return true ;
					}
					
					//	If column1 was 0, it should now be 1 and vice-versa
					column1 = ( column1 == 0 ? 1 : 0 );
				}
			}
			
			//	Oops.  Couldn't find anything.
			return false ;	
		}
		
		
		private function solve( basicVariable:String, basicVariableIndex:int ):void
		{
			//	Initialize a found flag
			var found:int = -1 ;
			
			//	Initialize loop counters
			var i:int, j:int ;
			
			//	Find the equation whose basic variable matches the one 
			//	we've passed in.  We're going to solve this equation
			for (i = 0; i < numberOfEquations; ++i)
			{
				if (equations[i].Var == basicVariable)
				{
					if (equations[i].VarIndex == basicVariableIndex)
					{
						found = i;
					}
				}
			}
			if (found < 0 || found > numberOfEquations-1)
			{
				//	We didn't a matching equation, so return
				return;
			}
			
			// The equation for the replacement variable in this cycle.
			var numEquationsP1:int = numberOfEquations + 1;
			var replacement:Equation = new Equation();
			
			//	Since the current non-basic variable is leaving the dictionary
			//	That means this new equation's basic variable should be
			//	set to the current non-basic variable
			replacement.Var = nonBasicVariable;
			replacement.VarIndex = nonBasicVariableIndex;
			replacement.C = new Vector.<Number>(numEquationsP1); //new1<double>(numEquationsP1);
			replacement.W = new Vector.<Number>(numEquationsP1); //new1<double>(numEquationsP1);
			replacement.Z = new Vector.<Number>(numEquationsP1); //new1<double>(numEquationsP1);
			
			//	Invert the coefficient of the non-basic variable ...
			var denom:Number ;
			if ( nonBasicVariable == 'z')
			{
				denom = -equations[found].Z[nonBasicVariableIndex];
			}
			else
			{
				denom = -equations[found].W[nonBasicVariableIndex];
			}
			
			//	... and divide all the other equations by this coefficient
			var invDenom:Number = 1.0/denom;
			for (i = 0; i <= numberOfEquations; ++i)
			{
				replacement.C[i] = equations[found].C[i]*invDenom;
				replacement.W[i] = equations[found].W[i]*invDenom;
				replacement.Z[i] = equations[found].Z[i]*invDenom;
			}
			
			//	If the variable entering the dictionary is z
			//	Then zero out its coefficient in the replacment equation
			//	Why? Because the variable entering the dictionary (i.e. becoming basic)
			//	won't exist on the 'right-hand side' of the new equation
			if ( nonBasicVariable == 'z')
			{
				replacement.Z[nonBasicVariableIndex] = 0.0;
			}
			else
			{
				replacement.W[nonBasicVariableIndex] = 0.0;
			}
			
			//	Since the basic-variable is moving over to the 'left-hand side'
			//	of the new equation (i.e. becoming non-basic), we set its
			//	new coefficient to -invDenom.  The minus is because it's being
			//	shifted to the left hand side, and the invDemon is because its
			//	original coefficient was 1
			if (basicVariable == 'z')
			{
				replacement.Z[basicVariableIndex] = -invDenom;
			}
			else
			{
				replacement.W[basicVariableIndex] = -invDenom;
			}

			for (i = 0; i < numberOfEquations; ++i)
			{
				if (i != found)      
				{
					//	For each equation that is not the replacement equation
					//	(the replacement equation is the one we're solving), grab the coefficient of the
					//	variable that is becoming basic (i.e. entering the dictionary)
					var coeff:Number ;
					if (replacement.Var == 'z')
					{
						coeff = equations[i].Z[nonBasicVariableIndex];
					}
					else
					{
						coeff = equations[i].W[nonBasicVariableIndex];
					}
					
					if (coeff != 0.0)
					{
						//	Now, iterate over all of the other equations
						//	And substitute the terms on the right-hand side of our replacement equation
						//	into the slots where the current non-basic variable exists in all
						//	the other equations
						for (j = 0; j < numEquationsP1; ++j)
						{
							equations[i].C[j] += coeff*replacement.C[j];
							if (Math.abs(equations[i].C[j]) <
								ratioError*Math.abs(replacement.C[j]))
							{
								equations[i].C[j] = 0.0;
							}
							
							equations[i].W[j] += coeff*replacement.W[j];
							if (Math.abs(equations[i].W[j]) <
								ratioError*Math.abs(replacement.W[j]))
							{
								equations[i].W[j] = 0.0;
							}
							
							equations[i].Z[j] += coeff*replacement.Z[j];
							if (Math.abs(equations[i].Z[j]) <
								ratioError*Math.abs(replacement.Z[j]))
							{
								equations[i].Z[j] = 0.0;
							}
						}
						
						//	Now, after the substitution, zero out the original
						//	coefficient.  So for example, if z0 is becoming basic
						//	it won't exist on the right side of any of the new equations
						//	so zero it in each equation
						if (replacement.Var == 'z')
						{
							equations[i].Z[replacement.VarIndex] = 0.0;
						}
						else
						{
							equations[i].W[replacement.VarIndex] = 0.0;
						}
					}
				}
			}
			
			// Replace the row corresponding to the found equation.
			//	With all the values in the replacment equation
			equations[found].Var = replacement.Var;
			equations[found].VarIndex = replacement.VarIndex;
			for ( i = 0; i <= numberOfEquations; i++)
			{
				equations[found].C[i] = replacement.C[i] ;
				equations[found].W[i] = replacement.W[i] ;
				equations[found].Z[i] = replacement.Z[i] ;
			}
			

			
			//	And we're done
		}
		
		
		private function printEquations():void
		{			
			trace( "\n\n" );
			for (var i:int =0; i < numberOfEquations; ++i)
			{
				var equation:String = equations[i].Var + "(" + equations[i].VarIndex + ") = " + equations[i].C[0]; 
				
				for ( var j:int = 0; j <= numberOfEquations; ++j)
				{
					if ( equations[i].W[j] != 0.0)
					{
						equation += " " + equations[i].W[j] + "w(" + j + ") " ;
					}
				}
				for ( j = 0; j <= numberOfEquations; ++j)
				{
					if ( equations[i].Z[j] != 0.0)
					{
						equation += equations[i].Z[j] + "z(" + j + ") " ;
					}
				}
				
//				for ( j = 0; j <= numberOfEquations; ++j)
//				{
//					if ( equations[i].C[j] != 0.0)
//					{
//						equation += " " + equations[i].C[0] + "c(" + j + ") " ;
//					}
//				}
				
				trace( equation ) ;
			}
		}

	}
}

class Equation
{
	internal var Var:String ;
	internal var VarIndex:int ;
	internal var C:Vector.<Number> ;
	internal var W:Vector.<Number> ; ;
	internal var Z:Vector.<Number> ; ;
}