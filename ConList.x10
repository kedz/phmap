import x10.util.Timer;
import x10.util.ArrayList;
import x10.util.HashMap;
import x10.util.Pair;
import x10.util.concurrent.AtomicReference;
import x10.util.concurrent.AtomicLong;

/**
 * A concurrent linked list.
 */
public class ConList
{


    // a default value is returned when an element with a given key is not present in the dict.
    private var defaultValue : Long;
    
    // A sentinel head node. We assume that all keys are positive as in the test harness.
    private var head : Node = new Node();
    
    // Linearization counter - this instance is overwritten by the constructor,
    // which takes a reference to a global counter.
    private var counter:AtomicLong = new AtomicLong(0);

    /**
     *  Inner Node class for this Concurrent Linked List.
     */
    private static class Node {
        
        // Key
        var key:Long;
        
        // Value
        var value:AtomicLong;     

        // Reference to the next Node.
        // next.get() returns null if this is the tail node.
        var next:AtomicReference[Node] = AtomicReference.newAtomicReference[Node](null);

        public def this(key:Long, value:AtomicLong) {
            this.key = key;
            this.value = value;
        }

        // Constructor for the sentinel node at the head of every list.
        public def this() {
            this.key = -1;
            this.value = new AtomicLong(-1);  
        }

        // toString method used for debugging.
        public def toString() : String {
            return "node k:"+key+" v:"+value.get();
        }

    }

    /**
     *  Constructor takes a default value and reference to the global counter.
     */
    public def this(defaultValue : Long, counter:AtomicLong){
        this.defaultValue = defaultValue;    
        this.counter = counter;
    } 

    /**
     * Insert the pair <key,value> in the hash table
     *     'key'
     *     'value' 
     *
     * This function return the unique order id of the operation in the linearized history.
     */
    public def put(key: long, value: long) : long {
        
        // Iterator node, used to the traverse the list and perform put action.
        var t:Node = head;

        // The new node we are trying to place if this node 
        // does not already exist in this list.
        node:Node = new Node(key, new AtomicLong(value));    

        // Keep trying to put, despite possibly being interrupted by other threads.
        while(true) {
      
            // This key is already in the list, update this nodes value.
            if (t.key == key) {
                
                // We must verify that no other work has attempted to modify
                // this node while we are changing. Keep trying until
                // successful.
                while(true) {
                
                    // get current value
                    var v:Long = t.value.get();
                    
                    // get linearization point
                    var c:Long = counter.getAndIncrement();
          
                    // If someone has modified the value since we grabbed
                    // a linearization point, this point is no longer valid,
                    // and so we must abort and try again.
                    if (t.value.compareAndSet(v,value)) {
                        return c;
                    }

                }
            
            // Else if we have made it the end and have not found our key,
            // try to add node to the end. If we abort due to concurrent
            // modification, rather than stay in this location, we must
            // search to the end of the list again to verify that the 
            // newest insert/modification did not put our key in the list.
            } else if (t.next.get() == null) {
                
                // get linearization point                
                var c:Long = counter.getAndIncrement();
                
                // Try and set the node, go back to head of the while loop if aborted.
                if (t.next.compareAndSet(null,node)) {
                    return c; 
                } else {
                    continue;
                }

            // Not at the end, and current node doesn't have our key,
            // move to the next node in the list.
            } else {

                if (t.next.get() != null)
                    t = t.next.get();

            }
        }    

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

        // Iterator node for traversing the list.
        var t:Node = head;
    
        // Keep trying to get the node until we have explicitly failed.
        while (true) {

            // We have found the key, try to return the value. We must
            // retry if our value has been modified after grabbing a
            // linearization point.
            if (key == t.key) {
            
                while(true) {
                    
                    // get value
                    v:Long = t.value.get();
                    
                    // get linearization point
                    c:Long = counter.getAndIncrement();

                    // If the value has changed, the linearization point
                    // is out of date and we must try again.
                    if (t.value.compareAndSet(v,v)) {
                        return new Pair[Long,Long](c,v);
                    }
                }

            // We have gotten to the end and not found our key.
            // Try to return default value. We must retry searching
            // if someone inserts a tail node after we have taken a
            // linearization point.    
            } else if (t.next.get() == null) {

                var c:Long = counter.getAndIncrement();
                if (t.next.compareAndSet(null,null)) 
                    return new Pair[Long,Long](c,defaultValue);    
            }

            // Not at end of list and current node doesn't have the key,
            // move to the next node.
            t = t.next.get();

        }

    }
}
