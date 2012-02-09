package ruby;

import hudson.Plugin;
import hudson.model.Items;
import hudson.model.Run;
import hudson.util.XStream2;
import jenkins.model.Jenkins;
import org.jenkinsci.jruby.JRubyMapper;
import org.jenkinsci.jruby.JRubyXStream;
import org.kohsuke.stapler.Facet;
import org.kohsuke.stapler.WebApp;
import org.kohsuke.stapler.jelly.jruby.JRubyFacet;

import java.util.List;
import java.util.logging.Logger;

/**
 * This plugin class gets instantiated for the ruby-runtime plugin itself
 * (whereas {@link RubyPlugin} is used for all the other plugins implemented in Ruby.)
 *
 * @author Kohsuke Kawaguchi
 */
public class RubyRuntimePlugin extends Plugin {
    @Override
    public void start() throws Exception {
        super.start();
        LOGGER.info("Injecting JRuby into XStream");    // logging only because we suspect that different plugin classes are instantiated
        initRubyXStreams();

        registerJRubyFacet();
    }

    private void registerJRubyFacet() {
        List<Facet> facets = WebApp.get(Jenkins.getInstance().servletContext).facets;
        for (Facet f : facets) {
            if (f instanceof JRubyFacet)
                return; // already there
        }
        facets.add(new JRubyFacet());
    }

    private static void initRubyXStreams() {
        RubyPluginRuntimeResolver resolver = new RubyPluginRuntimeResolver();
        JRubyXStream.register(Jenkins.XSTREAM2, resolver);
        JRubyXStream.register(Items.XSTREAM2, resolver);
        JRubyXStream.register(Run.XSTREAM2, resolver);

        //TODO: these should be in some sort of static initializer, but where?
        //TODO: if I move it to an initializer block, then it barfs.
        enableJRubyXStream(Jenkins.XSTREAM2);
        enableJRubyXStream(Items.XSTREAM2);
        enableJRubyXStream(Run.XSTREAM2);
    }

    /**
     * sets up an XSTREAM to be able to handle jruby objects
     * @param xs
     */
    private static void enableJRubyXStream(XStream2 xs) {
        synchronized (xs) {
            xs.setMapper(new JRubyMapper(xs.getMapperInjectionPoint()));
        }
    }

    private static final Logger LOGGER = Logger.getLogger(RubyRuntimePlugin.class.getName());
}
