import x10.util.Timer;
import x10.util.ArrayList;
import x10.util.HashMap;
import x10.util.Pair;
import x10.array.*;
import x10.util.concurrent.*;
/**
 * This is the class that provides the HashMap functionalities.
 *
 * The assignment is to replace the content of this class with code that exhibit
 * a better scalability.
 */
public class Hash
{
    var table:Array_1[AtomicReference[ConList]];
    var size:long = 15n;
    var defaultVal:long;
    var counter:AtomicLong;

    public def this(defaultValue:long){
        
        this.defaultVal = defaultValue;
        table = new Array_1[AtomicReference[ConList]](size,AtomicReference.newAtomicReference[ConList](null));
        counter = new AtomicLong(0);
    }

    private def hash( key:long) : long{
        return key%size;
    }

    /**
     * Insert the pair <key,value> in the hash table
     *     'key'
     *     'value' 
     *
     * This function returns the unique order id of the operation in the linearized history.
     */
    public def put(key: long, value: long) : long
    {
        
        var index:long = hash(key);
        if (table(index).get() == null) {
          
          var aList:ConList = new ConList(defaultVal,counter);
          table(index).compareAndSet(null, aList);
          
        }
        
        return table(index).get().put(key,value);
        
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
    
     
    var index:long = hash(key);


    if( table(index).get() == null )
    {
           
      var c:long = counter.getAndIncrement();
      if( table(index).get() == null) {
        
        return new Pair[long, long](c,defaultVal);
          
      }
    }

    return table(index).get().get(key);
   
  }
}
