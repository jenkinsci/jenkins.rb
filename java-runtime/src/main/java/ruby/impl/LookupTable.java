package ruby.impl;

import java.lang.ref.WeakReference;
import java.util.WeakHashMap;

/**
 * Used to remember mapping between Ruby objects that are acting as proxies to their Java counterparts.
 *
 * <p>
 * We need this because seemingly innocent m[k] in JRuby involves iterating over the entire object,
 * and this ensures synchronization.
 *
 * @author Kohsuke Kawaguchi
 */
public class LookupTable {
    private final WeakHashMap map = new WeakHashMap();

    public synchronized void put(Object k, Object v) {
        map.put(k,v);
    }

    public synchronized void putWeak(Object k, Object v) {
        map.put(k,new WeakReference(v));
    }

    public synchronized Object get(Object k) {
        Object v = map.get(k);
        if (v instanceof WeakReference) {
            return ((WeakReference)v).get();
        }
        return v;
    }
}
