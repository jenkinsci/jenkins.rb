package jenkins.ruby;


/**
 * When stapler is querying a Java object to see which properties it has
 * it normally uses reflection to see if there is a field or getter with the
 * corresponding name which it can use.
 *
 * You obviously can't do this on a JRuby object, so instead Stapler and Jenkins
 * will look and see if it has a get(String) method and if so, use that for
 * property lookup.
 *
 * JRuby proxies include this interface to support this.
 */
public interface Get {

  Object get(String name);
}
