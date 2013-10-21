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
public class Hash {
    
    // Array of buckets for hashing items to
    var table:Array_1[AtomicReference[ConList]];
    
    // Default bucket size is 50
    var size:long = 50n;
    
    // Defaul value to return if Hash does not contain requested key.
    var defaultVal:long;
    
    // Linearization point counter
    var counter:AtomicLong;

    
    public def this(defaultValue:long){
        
        this.defaultVal = defaultValue;
        
        // Initialize array of atomic references to null.
        table = new Array_1[AtomicReference[ConList]](size);
        for (var i:Long = 0; i < size; i++)
            table(i) = AtomicReference.newAtomicReference[ConList](null);
        
        counter = new AtomicLong(0);
    }

    /**
     * Get bucket index.
     */
    private def hash( key:long) : long {
        return key % size;
    } 

    /**
     * Insert the pair <key,value> in the hash table
     *     'key'
     *     'value' 
     *
     * This function returns the unique order id of the operation in the linearized history.
     */
    public def put(key: long, value: long) : long {
        
        var index:long = hash(key);
        
        // If nothing is in this bucket, create a new ConList instance here.
        if (table(index).get() == null) {
          
          var aList:ConList = new ConList(defaultVal,counter);
          
          // Don't delete if someone has beaten us to it.
          table(index).compareAndSet(null, aList);
          
        }
        
        // Insert into the ConList and return the linearization point.
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
    public def get(key: long) : Pair[long,long] {
     
        var index:long = hash(key);

        // If there is nothing in this bucket, try to return the default
        // value. If someone creates a ConList while we are doing this, we
        // must abort and search the index. 
        if (table(index).get() == null) {
            
            // get linearization point
            var c:long = counter.getAndIncrement();
            
            // verify no one has put a ConList here and return default value.
            if (table(index).get() == null) {
                return new Pair[long, long](c,defaultVal);
            }
        }

        // This is a ConList here -- search it.
        return table(index).get().get(key);
   
    }
}
