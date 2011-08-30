package ruby;

import hudson.ExtensionComponent;
import hudson.Util;
import hudson.model.Items;
import hudson.util.XStream2;
import jenkins.model.Jenkins;
import org.apache.commons.io.FileUtils;
import org.jenkinsci.jruby.JRubyMapper;
import org.jenkinsci.jruby.JRubyXStream;
import org.jruby.RubyArray;
import org.jruby.embed.ScriptingContainer;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;


/**
 * The primary Java interface to a plugin which is implemented in Ruby.
 * One instance is created per each Ruby plugin.
 *
 * <p>
 * When this plugin initializes, it will instantiate a Jenkins::Plugin
 * object which acts as the gateway for Ruby to interact with the java
 * side.
 * <p>
 * When the RubyPlugin is loaded, it will discover, load and provide
 * a mechanism for extensions written in Ruby that it contains to register
 * themselves.
 * <p>
 * These Extensions are presented to Jenkins via the {@link RubyExtensionFinder}
 * <p>
 * Each plugin has its own JRuby environment
 */
@SuppressWarnings({"UnusedDeclaration"})
public class RubyPlugin extends PluginImpl {


	/**
	 * A reference to the loadpath where this ruby runtime will search whenever
	 * a library is `require`d
	 */
	private RubyArray loadPath;

	/**
	 * sets up an XSTREAM to be able to handle jruby objects
	 * @param xs
	 */
	private static void enableJRubyXStream(XStream2 xs) {
		synchronized (xs) {
			xs.setMapper(new JRubyMapper(xs.getMapperInjectionPoint()));
        }
	}

	/**
	 * The unique JRuby environment used by this plugin and all the objects
	 * and classes that it contains.
	 */
	ScriptingContainer ruby;

    /**
     * Kinda acts like the "agent" of this ruby plugin in the Ruby world.
     * This is the object that the internals of the ruby side talk to when
     * then want to talk back to Java.
     *
     * @return an instance of Jenkins::Plugin
     */
	private Object plugin;

	private ArrayList<ExtensionComponent> extensions;

    /**
     * Directory to load ruby lib/*.rb from.
     */
    private File libPath;

    /**
     * Directory to load ruby model definitions.
     */
    private File modelsPath;

	/**
	 * invokes a Ruby method on the specified object in the context of this plugin's
	 * {@link ScriptingContainer}
	 *
	 * @param object     <b>JRuby</b> object to use as invocant
	 * @param methodName the method to end
	 * @param args       arguments to the method
	 * @return the return value of the method call.
	 */
	public Object callMethod(Object object, String methodName, Object... args) {
		return ruby.callMethod(object, methodName, args);
	}

	/**
	 * Registers an extension with this Ruby plugin so that it will be found later on
	 * <p/>
	 * This method is generally called from inside Ruby, as objects that implement
	 * extension points register themselves.
	 *
	 * @param extension
	 */
	public void addExtension(Object extension) {
		extensions.add(new ExtensionComponent(extension));
	}

	/**
	 * @return the list of extensions registered with this Plugin. this is used by
	 *         the {@link RubyExtensionFinder} to present extension points to Jenkins
	 */
	public Collection<ExtensionComponent> getExtensions() {
		return extensions;
	}

	public RubyPlugin() {
		this.extensions = new ArrayList<ExtensionComponent>();
	}

    /**
     * Loads the models.rb
     */
    public String loadBootScript() throws IOException {
        File rb = new File(getLibPath(),"models.rb");
        if (rb.exists()) {
            return FileUtils.readFileToString(rb);
        } else {
            return "";
        }
    }

	/**
	 * Jenkins will call this method whenever the plugin is initialized
	 * The plugin will in turn delegate to its instance of Jenkins::Plugin
	 * which can take action on the Ruby side.
	 *
	 * @throws Exception
	 */
	@Override
	public void start() throws Exception {
		//This seems to be instantiatiating RubyPlugin for the abstract instance
		//I thought it had been working to not do so at one point...
		if (!this.getWrapper().getShortName().equals("ruby-runtime")) {
			this.extensions = new ArrayList<ExtensionComponent>();
			ruby = new ScriptingContainerHolder().ruby;

			initRubyLoadPaths();
			initRubyXStreams();
			initRubyNativePlugin();
		}
	}

	private void initRubyNativePlugin() {
		require("jenkins/plugin/runtime");
		Object pluginClass = eval("Jenkins::Plugin");
		this.plugin = callMethod(pluginClass, "new", this);
		callMethod(plugin, "start");
	}

	private void initRubyXStreams() {
		RubyPluginRuntimeResolver resolver = new RubyPluginRuntimeResolver(this);
		JRubyXStream.register(Jenkins.XSTREAM2, resolver);
		JRubyXStream.register(Items.XSTREAM2, resolver);

		//TODO: these should be in some sort of static initializer, but where?
		//TODO: if I move it to an initializer block, then it barfs.
		enableJRubyXStream(Jenkins.XSTREAM2);
		enableJRubyXStream(Items.XSTREAM2);

	}

	private void initRubyLoadPaths() throws Exception {
		this.loadPath = (RubyArray)eval("$:");
        this.libPath = getPathFromManifest("Lib-Path","lib");
        this.modelsPath = getPathFromManifest("Models-Path","models");

		//the Load-Path entry will be explicitly set when we are running the test server
		//during plugin development. This allows you to just load the right gems off of the

		String loadPaths = getWrapper().getManifest().getMainAttributes().getValue("Load-Path");
		if (loadPaths != null) {
			for (String path: loadPaths.split(":")) {
				addLoadPath(path);
			}
		} else {
			//If we aren't explicitly passing the Load-Path, then this must be in production mode.
			//we will have a full standalone gem bundle, that generates the loadpaths for us
			File gemsHome = getPathFromManifest("Bundle-Path", "vendor/gems");
			if (!gemsHome.exists()) {
				throw new Exception("unable to locate gem bundle for " + getWrapper().getShortName() + " at " + gemsHome.getAbsolutePath());
			}
			addLoadPath(gemsHome.getAbsolutePath());
			require("bundler/setup");
		}
		addLoadPath(this.libPath.getAbsolutePath());

        // make it easier to load arbitrary scripts from the file system, especially during the development
        for (String path : Util.fixNull(System.getProperty("jenkins.ruby.paths")).split(",")) {
            if (path.length()==0)   continue;   // "".split(",")=>[""]
	        addLoadPath(path);
        }
	}

	private Object eval(String script) {
		return this.ruby.runScriptlet(script);
	}

	private void require(String path) {
		eval("require '" + path + "'");
	}

	private void addLoadPath(String path) {
		callMethod(this.loadPath, "unshift", path);
	}

	private File getPathFromManifest(String attributeName, String defaultValue) {
        String v = getWrapper().getManifest().getMainAttributes().getValue(attributeName);
        if (v ==null)   v = defaultValue;
        return resolve(getScriptDir(), v);
    }

    private static File resolve(File base, String relative) {
        File rel = new File(relative);
        if(rel.isAbsolute())
            return rel;
        else
            return new File(base.getParentFile(),relative);
    }

	/**
	 * Jenkins will call this method whenever the plugin is shut down
	 * The plugin will in turn delegate to its instance of Jenkins::Plugin
	 * which can take action on the Ruby side
	 *
	 * @throws Exception
	 */
	@Override
	public void stop() throws Exception {
		if (this.ruby != null) {
			callMethod(plugin, "stop");
		}
	}

	public String getResourceURI(String relativePathFormat, Object... args) {
		return getClass().getResource(String.format(relativePathFormat, args)).getPath();
	}

    /**
     * Returns a directory that stores all the Ruby scripts.
     */
    public File getScriptDir() {
        URL url = getWrapper().baseResourceURL;
        // we assume url to be file:// path because we later need to be able to enumerate them
        // to lift this limitation, we need build-time processing to enumerate all the rb files.
        if (!url.getProtocol().equals("file"))
            throw new IllegalStateException("Unexpected base resource URL: "+url);

        return new File(new File(url.getPath()),"WEB-INF/classes");
    }

    public File getLibPath() {
        return libPath;
    }

    public File getModelsPath() {
        return modelsPath;
    }

	public ScriptingContainer getScriptingContainer() {
		return ruby;
	}

	public Object getNativeRubyPlugin() {
		return this.plugin;
	}
}
