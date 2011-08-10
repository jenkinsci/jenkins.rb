package ruby;


import hudson.Extension;
import hudson.ExtensionComponent;
import hudson.ExtensionFinder;
import hudson.model.Hudson;

import java.util.ArrayList;
import java.util.Collection;


/**
 * Presents Ruby extensions to Jenkins.
 *
 * Whenever a ruby plugin loads, it scans its codebase and finds all of the objects
 * which implement Jenkins extensions points (there can be any number of these per plugin)
 *
 * Sometime later, whenever Jenkins is asking about a particular extension type, like a
 * Publisher on BuildWrapper, it will query this ExtensionFinder among others. This finder then
 * delegates to the ruby plugin to see if it has any extensions of the requested type.
 *
 * @see hudson.ExtensionPoint
 */

@SuppressWarnings({"UnusedDeclaration"})
@Extension
public class RubyExtensionFinder extends ExtensionFinder {

	@Override
	public <T> Collection<ExtensionComponent<T>> find(Class<T> type, Hudson hudson) {
		Collection<ExtensionComponent<T>> hits = new ArrayList<ExtensionComponent<T>>();
        for (RubyPlugin rp : hudson.getPlugins(RubyPlugin.class)) {
            for (ExtensionComponent c: rp.getExtensions()) {
                if (type.isAssignableFrom(c.getInstance().getClass())) {
                    hits.add(c);
                }
            }
        }
		return hits;
	}
}
