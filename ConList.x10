import x10.util.Timer;
import x10.util.ArrayList;
import x10.util.HashMap;
import x10.util.Pair;
import x10.util.concurrent.AtomicReference;
import x10.util.concurrent.AtomicLong;

/**
 * A concurrent (hopefully) list.
 */
public class ConList
{
	private var defaultValue : Long; // a default value is returned when an element with a given key is not present in the dict.
  private var head : Node = new Node(); // A sentinel head node with empty key and value.
  private static counter:AtomicLong = new AtomicLong(0);
  

  private static class Node {
    
    var key:Long;
    var value:AtomicLong;     

    var next:AtomicReference[Node] = AtomicReference.newAtomicReference[Node](null);

    public def this(key:Long, value:AtomicLong) {
      this.key = key;
      this.value = value;
    }

    public def this() {}

  }

	public def this(defaultValue : Long){
    this.defaultValue = defaultValue;    
	} 

  public def this() {
    this(0n);
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
    var t:Node = head;
    node:Node = new Node(key, new AtomicLong(value));    

    while(true) {

      if (t.next.get() == null) {
        var c:Long = counter.getAndIncrement();
        if (t.next.compareAndSet(null,node))
          return c; 
        else 
          continue;
      } else if (t.key == key) {
        while(true) {
          var v:Long = t.value.get();
          var c:Long = counter.getAndIncrement();
          if (t.value.compareAndSet(v,value)) {
            return c;
          }

        }

      } else {

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
  public def get(key: long) : Pair[long,long]
  {

    var t:Node = head;

    while (true) {

      if (key == t.key) {
        while(true) {
          
          v:Long = t.value.get();
          c:Long = counter.getAndIncrement();
          if (t.value.compareAndSet(v,v)) {
            return new Pair[Long,Long](c,v);
          }
        }
      } else if (t.next.get() == null) {

          var c:Long = counter.getAndIncrement();
          if (t.next.compareAndSet(null,null)) 
            return new Pair[Long,Long](c,defaultValue);    
      }

      t = t.next.get();

    }

  }
}
