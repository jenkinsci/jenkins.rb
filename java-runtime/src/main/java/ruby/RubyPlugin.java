package ruby;

import hudson.ExtensionComponent;
import hudson.Util;
import jenkins.model.Jenkins;
import org.apache.commons.io.IOUtils;
import org.jruby.Ruby;
import org.jruby.RubyArray;
import org.jruby.RubyModule;
import org.jruby.embed.ScriptingContainer;
import org.jruby.rack.DefaultRackApplication;
import org.jruby.rack.servlet.*;
import org.jruby.runtime.builtin.IRubyObject;
import org.kohsuke.stapler.Stapler;
import org.kohsuke.stapler.StaplerRequest;
import org.kohsuke.stapler.StaplerResponse;
import org.kohsuke.stapler.jelly.jruby.RubyKlassNavigator;
import org.kohsuke.stapler.lang.Klass;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.jar.JarEntry;
import java.util.jar.JarInputStream;
import java.util.logging.Logger;


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
    private static final Logger LOGGER = Logger.getLogger(RubyPlugin.class.getName());

	/**
	 * A reference to the loadpath where this ruby runtime will search whenever
	 * a library is `require`d
	 */
	private RubyArray loadPath;

	/**
	 * The unique JRuby environment used by this plugin and all the objects
	 * and classes that it contains.
	 */
	ScriptingContainer ruby;

    private /*almost final*/ RubyKlassNavigator navigator;

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

    private ServletRackContext rackContext;

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
     * Registers an extension with the default ordiinal.
     */
	public void addExtension(Object extension) {
        addExtension(extension,0);
	}

    /**
     * Registers an extension with this Ruby plugin so that it will be found later on
     * <p/>
     * This method is generally called from inside Ruby, as objects that implement
     * extension points register themselves.
     *
     * @param extension
     */
    public void addExtension(Object extension, double ordinal) {
        extensions.add(new ExtensionComponent(extension, ordinal));
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
    public void loadBootScript() throws IOException {
        loadScript(new File(getLibPath(), "models.rb").getPath());
    }

    /**
     * Index of script files.
     * <p/>
     * The value is a URL bound for either a file or an entry of jar.
     */
    private final Map<String, URL> scriptIndex = new HashMap<String, URL>();

    /**
     * Loads all model scripts.
     * <p/>
     * This will be called from Ruby to initialize plugin.
     */
    public void loadModelScript() throws IOException {
        LOGGER.info("Trying to load models for " + getWrapper().getShortName());
        String prefix = getScriptDir().toURI().relativize(getModelsPath().toURI()).toString();
        for(String filename: scriptIndex.keySet()) {
            if (filename.startsWith(prefix)) {
                loadScript(filename);
            }
        }
    }

    private void loadScript(String filename) throws IOException {
        if (isScript(filename)) {
            LOGGER.info("Loading " + filename);
            String script = readScript(filename);
            eval(script);
        } else {
            LOGGER.warning("Skip loading " + filename);
        }
    }

    private boolean isScript(File file) {
        return file.isFile() && isScript(file.getPath());
    }

    private boolean isScript(JarEntry entry) {
        return !entry.isDirectory() && isScript(entry.getName());
    }

    private boolean isScript(String filename) {
        return filename.endsWith(".rb");
    }

    /**
     * Indexes all scripts within given path.
     * <p/>
     * Until Jenkins 1.519, it extracts the plugin contents into files.
     * This updates indexes of script files within extracted directory.
     *
     * @param file
     */
    private void updateScriptIndex(File file) throws IOException {
        File root = file.getAbsoluteFile();
        List<File> xs = new ArrayList<File>();
        xs.add(root);
        while (!xs.isEmpty()) {
            File x = xs.remove(0);
            if (x.isDirectory()) {
                xs.addAll(Arrays.asList(x.listFiles()));
            } else {
                if (isScript(x)) {
                    String relativePath = root.toURI().relativize(x.toURI()).getPath();
                    try {
                        LOGGER.fine("Indexing script: " + relativePath);
                        scriptIndex.put(relativePath, x.toURI().toURL());
                    } catch (MalformedURLException ignore) {
                        // nop
                    }
                }
            }
        }
    }

    /**
     * Indexes all scripts within given jar file.
     * <p/>
     * From Jenkins 1.519, it generates single "WEB-INF/lib/classes.jar" for plugins.
     * This updates indexes of script files within "classes.jar".
     *
     * @param jarFile
     */
    private void updateScriptIndexFromJar(File jarFile) throws IOException {
        InputStream stream = jarFile.toURI().toURL().openStream();
        try {
            JarInputStream jarStream = new JarInputStream(stream);
            for (JarEntry e=jarStream.getNextJarEntry(); e!=null; e=jarStream.getNextJarEntry()) {
                if (isScript(e)) {
                    LOGGER.fine("Indexing script: " + e.getName());
                    scriptIndex.put(e.getName(), jarURL(jarFile, e.getName()));
                }
            }
        } finally {
            if (stream != null) {
                stream.close();
            }
        }
    }

    /**
     * Returns the contents of given script.
     *
     * @param path
     * @return the contents of file. returns empty string if there is no such file with given name.
     */
    private String readScript(String path) throws IOException {
        if (scriptIndex.containsKey(path)) {
            URL scriptUrl = scriptIndex.get(path);
            InputStream stream = scriptUrl.openStream();
            try {
                return IOUtils.toString(stream);
            } finally {
                if (stream != null) {
                    stream.close();
                }
            }
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
		if (this.getWrapper().getShortName().equals("ruby-runtime"))    return;

        this.extensions = new ArrayList<ExtensionComponent>();
        ruby = new ScriptingContainerHolder().ruby;
        navigator = new RubyKlassNavigator(ruby.getProvider().getRuntime(),getWrapper().classLoader);

        initRubyLoadPaths();
        initRubyNativePlugin();

        rackContext = new DefaultServletRackContext(new ServletRackConfig(Jenkins.getInstance().servletContext));
	}

    /**
     * Gets the plugin that owns the container.
     */
    public static RubyPlugin from(Ruby r) {
        IRubyObject v = r.evalScriptlet("Jenkins::Plugin.instance.peer");
        if (v==null)        return null;
        return (RubyPlugin) v.toJava(RubyPlugin.class);
    }
    
    public Klass<RubyModule> klassFor(RubyModule module) {
        return module!=null ? new Klass<RubyModule>(module,navigator) : null;
    }

	private void initRubyNativePlugin() {
		require("jenkins/plugin/runtime");
		Object pluginClass = eval("Jenkins::Plugin");
		this.plugin = callMethod(pluginClass, "initialize", this);
		callMethod(plugin, "start");
	}

    private void initRubyLoadPaths() throws Exception {
        String _libPath = getManifestAttribute("Lib-Path", "lib");
        String _modelsPath = getManifestAttribute("Models-Path", "models");

        this.loadPath = (RubyArray)eval("$:");
        this.libPath = resolve(getScriptDir(), _libPath);
        this.modelsPath = resolve(getScriptDir(), _modelsPath);

        //the Load-Path entry will be explicitly set when we are running the test server
        //during plugin development. This allows you to just load the right gems off of the

        String loadPaths = getManifestAttribute("Load-Path");
        if (loadPaths != null) {
            for (String path: loadPaths.split(":")) {
                addLoadPath(path);
            }
        } else {
            //If we aren't explicitly passing the Load-Path, then this must be in production mode.
            //we will have a full standalone gem bundle, that generates the loadpaths for us
            String bundlePath = getManifestAttribute("Bundle-Path", "vendor/gems");
            // Until Jenkins 1.519, it extracts the plugin contents into files.
            if (getScriptDir().exists()) {
                addLoadPath(new File(getScriptDir(), bundlePath).getAbsolutePath());
                updateScriptIndex(getScriptDir());
            }
            // From Jenkins 1.519, it generates single "classes.jar" for each plugins.
            if (getScriptJar().exists()) {
                addLoadPath(jarURL(getScriptJar(), bundlePath).toString());
                updateScriptIndexFromJar(getScriptJar());
            }
            require("bundler/setup");
        }
        if (getLibPath().exists()) {
            addLoadPath(getLibPath().getAbsolutePath());
        }
        // If "classes.jar" exists, set "./lib" within jar as $LOAD_PATH.
        if (getScriptJar().exists()) {
            addLoadPath(jarURL(getScriptJar(), _libPath).toString());
        }

        // make it easier to load arbitrary scripts from the file system, especially during the development
        for (String path : Util.fixNull(System.getProperty("jenkins.ruby.paths")).split(",")) {
            if (path.length()==0) {
                continue;
            } else {
                addLoadPath(path);
            }
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
        String v = getManifestAttribute(attributeName, defaultValue);
        return resolve(getScriptDir(), v);
    }

    private String getManifestAttribute(String attributeName) {
        return getManifestAttribute(attributeName, null);
    }

    private String getManifestAttribute(String attributeName, String defaultValue) {
        String value = getWrapper().getManifest().getMainAttributes().getValue(attributeName);
        return value == null ? defaultValue : value;
    }

    private static File resolve(File base, String relative) {
        File rel = new File(relative);
        if(rel.isAbsolute())
            return rel;
        else
            return new File(base,relative);
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
        return new File(new File(baseResourceURL().getPath()), "WEB-INF/classes");
    }

    /**
     * Returns a classes.jar that stores all the Ruby scripts.
     */
    private File getScriptJar() {
        return new File(new File(baseResourceURL().getPath()), "WEB-INF/lib/classes.jar");
    }

    /**
     * Returns a URL which is pointed to the path in jarFile
     */
    private URL jarURL(File jarFile, String path) throws MalformedURLException {
        String absolutePath = new File("/", path).toString();
        return new URL("jar:" + jarFile.toURI().toURL() + "!" + absolutePath);
    }

    private URL baseResourceURL() {
        URL url = getWrapper().baseResourceURL;
        // we assume url to be file:// path because we later need to be able to enumerate them
        // to lift this limitation, we need build-time processing to enumerate all the rb files.
        if (!url.getProtocol().equals("file"))
            throw new IllegalStateException("Unexpected base resource URL: "+url);
        return url;
    }

    /**
     * Returns the absolute path to the "./lib"
     */
    public File getLibPath() {
        return libPath;
    }

    /**
     * Returns the absolute path to the "./models"
     */
    public File getModelsPath() {
        return modelsPath;
    }

	public ScriptingContainer getScriptingContainer() {
		return ruby;
	}

	public Object getNativeRubyPlugin() {
		return this.plugin;
	}

    /**
     * Let a Rack application handle the current request.
     *
     * @param servletHandler
     *      Instance of Rack::Handler::Servlet which wraps the actual rack application and provides
     *      the ruby part of the rack implementation.
     */
    public void rack(IRubyObject servletHandler) {
        final StaplerRequest req = Stapler.getCurrentRequest();
        final StaplerResponse res = Stapler.getCurrentResponse();
        // we don't want the Rack app to consider the portion of the URL that was already consumed
        // to reach to the Rack app, so for PATH_INFO we use getRestOfPath(), not getPathInfo()
        ServletRackEnvironment env = new ServletRackEnvironment(req, res, rackContext) {
            @Override
            public String getPathInfo() {
                return req.getRestOfPath();
            }
        };
        DefaultRackApplication dra = new DefaultRackApplication();
        dra.setApplication(servletHandler);
        dra.call(env)
                .respond(new ServletRackResponseEnvironment(res));
    }
}
