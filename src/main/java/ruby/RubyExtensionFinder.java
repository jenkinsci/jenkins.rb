package ruby;


import hudson.Extension;
import hudson.ExtensionComponent;
import hudson.ExtensionFinder;
import hudson.model.Hudson;
import jenkins.ExtensionComponentSet;
import jenkins.ExtensionRefreshException;
import jenkins.model.Jenkins;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;


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
    private List<RubyPlugin> parsedPlugins;

    @Override
	public <T> Collection<ExtensionComponent<T>> find(Class<T> type, Hudson jenkins) {
        if (parsedPlugins==null)
            parsedPlugins = jenkins.getPlugins(RubyPlugin.class);

        return new ExtensionComponentSetImpl(parsedPlugins).find(type);
	}

    @Override
    public ExtensionComponentSet refresh() throws ExtensionRefreshException {
        List<RubyPlugin> newList = Jenkins.getInstance().getPlugins(RubyPlugin.class);
        final List<RubyPlugin> delta = new ArrayList<RubyPlugin>(newList);
        delta.removeAll(parsedPlugins);
        parsedPlugins = newList;
        
        return new ExtensionComponentSetImpl(delta);
    }

    private static class ExtensionComponentSetImpl extends ExtensionComponentSet {
        private final List<RubyPlugin> plugins;

        public ExtensionComponentSetImpl(List<RubyPlugin> plugins) {
            this.plugins = plugins;
        }

        @Override
        public <T> Collection<ExtensionComponent<T>> find(Class<T> type) {
            Collection<ExtensionComponent<T>> hits = new ArrayList<ExtensionComponent<T>>();
            for (RubyPlugin rp : plugins) {
                for (ExtensionComponent c: rp.getExtensions()) {
                    if (type.isAssignableFrom(c.getInstance().getClass())) {
                        hits.add(c);
                    }
                }
            }
            return hits;
        }
    }
}
