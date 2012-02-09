package ruby;

import hudson.Extension;
import hudson.model.RootAction;
import hudson.util.HttpResponses;
import jenkins.model.Jenkins;
import org.kohsuke.stapler.HttpResponse;

import java.util.logging.Logger;

/**
 * Reloads all the model definitions in Ruby plugins.
 * Somewhat crude but nonetheless rather useful.
 *
 * I believe the original author is NaHi.
 *
 * @author Kohsuke Kawaguchi
 */
public class ModelReloadAction implements RootAction {

    public String getIconFileName() {
        return "refresh.png";
    }

    public String getDisplayName() {
        return "Reload Ruby plugins";
    }

    public String getUrlName() {
        return "reload-ruby-plugins";
    }

    public HttpResponse doIndex() {
        for (RubyPlugin p : Jenkins.getInstance().getPlugins(RubyPlugin.class)) {
            p.getExtensions().clear();
            p.callMethod(p.getNativeRubyPlugin(), "load_models");
        }
        LOGGER.info("Reloaded");
        return HttpResponses.redirectToContextRoot();
    }

    @Extension
    public static ModelReloadAction create() {
        // only activated during the development mode (or if the user explicitly enabled this)
        if (Boolean.getBoolean("jenkins.development-mode") || Boolean.getBoolean(ModelReloadAction.class.getName()))
            return new ModelReloadAction();
        return null;
    }

    private static final Logger LOGGER = Logger.getLogger(ModelReloadAction.class.getName());
}
