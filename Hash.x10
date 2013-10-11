import x10.util.Timer;
import x10.util.ArrayList;
import x10.util.HashMap;
import x10.util.Pair;
/**
 * This is the class that provides the HashMap functionalities.
 *
 * The assignment is to replace the content of this class with code that exhibit
 * a better scalability.
 */
public class Hash
{
	private var h : HashMap[long,long];
	private var counter : long;
	private var defaultValue : Long; // a default value is returned when an element with a given key is not present in the dict.
	private var pending:ArrayList[long];

	public def this(defV : long){
		counter = 0n;
		h = new HashMap[long,long]();
		defaultValue = defV;
		pending = new ArrayList[long]();
	}

    /**
     * Insert the pair <key,value> in the hash table
     *     'key'
     *     'value' 
     *
     * This function return the unique order id of the operation in the linearized history.
     */
    public def put(key: long, value: long) : long
    {
		var r : long = -1;

		atomic{
			r = ++counter;
			h.put(key,value);
		}

		return r;

    }

    /**
     * get the value associated to the input key
     *     'key'
     *
     * This function return the pair composed by
	 *     'first'    unique order id of the operation in the linearized history.
	 *     'second'   values associated to the input pair (defaultValue if there is no value associated to the input key)
     */
    public def get(key: long) : Pair[long,long]
    {
		var i:long = -1;
		var value:long = defaultValue;

		atomic{
			i = ++counter;
			val boxedValue = h.get(key);
			try{
				value = boxedValue();
			}catch(Exception){}
		}

        return new Pair[long,long](i,value);
    }
}