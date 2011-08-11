package ruby;

import hudson.model.Hudson;
import hudson.model.Items;
import hudson.util.XStream2;
import jenkins.model.Jenkins;
import org.jenkinsci.jruby.JRubyMapper;
import org.jenkinsci.jruby.JRubyXStream;
import org.jruby.embed.LocalContextScope;
import org.jruby.embed.ScriptingContainer;

/**
 * Builds and holds on to {@link ScriptingContainer}.
 *
 * <p>
 * This is so that we can relatively painlessly switch to multi-scriptingcontainer implementation.
 *
 * @author Kohsuke Kawaguchi
 */
public class ScriptingContainerHolder {
    /**
     * The unique JRuby environment used by this plugin and all the objects
     * and classes that it contains.
     */
    public final ScriptingContainer ruby;

    /**
     * Initializes this plugin by setting up the JRuby scripting container
     * and then loading up the ruby side of the plugin by creating an
     * instance of the Ruby class Jenkins::Plugin which will serve as
     * its agent in the Ruby world.
     * <p/>
     * We also register xstream mappers for JRuby objects so that they
     * can be persisted along with other objects in Jenkins.
     */
    public ScriptingContainerHolder() {
        this.ruby = new ScriptingContainer(LocalContextScope.SINGLETHREAD);
        this.ruby.setClassLoader(Jenkins.getInstance().pluginManager.uberClassLoader);

        register((XStream2) Hudson.XSTREAM, ruby);
        register((XStream2) Items.XSTREAM, ruby);
    }

    private void register(XStream2 xs, ScriptingContainer ruby) {
        JRubyXStream.register(xs, ruby);
        synchronized (xs) {
            xs.setMapper(new JRubyMapper(xs.getMapperInjectionPoint()));
        }
    }
}
