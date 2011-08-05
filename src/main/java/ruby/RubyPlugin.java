package ruby;

import hudson.Extension;
import hudson.ExtensionComponent;
import hudson.Plugin;
import hudson.model.Describable;
import hudson.model.Descriptor;
import hudson.model.Hudson;
import hudson.model.Items;
import hudson.util.IOUtils;
import hudson.util.XStream2;
import org.jenkinsci.jruby.JRubyMapper;
import org.jenkinsci.jruby.JRubyXStream;
import org.jruby.embed.LocalContextScope;
import org.jruby.embed.ScriptingContainer;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;


/**
 * The primary Java interface to a plugin which is implemented in Ruby
 * <p/>
 * When this plugin initializes, it will instantiate a Jenkins::Plugin
 * object which acts as the gateway for Ruby to interact with the java
 * side.
 * <p/>
 * When the RubyPlugin is loaded, it will discover, load and provide
 * a mechanism for extensions written in Ruby that it contains to register
 * themselves.
 * <p/>
 * These Extensions are presented to Jenkins via the {@link RubyExtensionFinder}
 * <p/>
 * Each plugin has its own JRuby environment
 */
@SuppressWarnings({"UnusedDeclaration"})
@Extension
public class RubyPlugin extends Plugin implements Describable<RubyPlugin> {
	/**
	 * The unique JRuby environment used by this plugin and all the objects
	 * and classes that it contains.
	 */
	private ScriptingContainer ruby;


	private Object plugin;
	private ArrayList<ExtensionComponent> extensions;

	public static RubyPlugin get() {
		return Hudson.getInstance().getPlugin(RubyPlugin.class);
	}

	/**
	 * Kinda acts like the "agent" of this ruby plugin in the Ruby world.
	 * This is the object that the internals of the ruby side talk to when
	 * then want to talk back to Java.
	 *
	 * @return an instance of Jenkins::Plugin
	 */
	public static Object getRubyController() {
		return get().plugin;
	}

	/**
	 * invokes a Ruby method on the specified object in the context of this plugin's
	 * {@link ScriptingContainer}
	 *
	 * @param object     <b>JRuby</b> object to use as invocant
	 * @param methodName the method to end
	 * @param args       arguments to the method
	 * @return the return value of the method call.
	 */
	public static Object callMethod(Object object, String methodName, Object... args) {
		return RubyPlugin.get().ruby.callMethod(object, methodName, args);
	}

	/**
	 * Registers an extenion with this Ruby plugin so that it will be found later on
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
	public static Collection<ExtensionComponent> getExtensions() {
		return get().extensions;
	}

	/**
	 * Reads a resource relative to this plugin's Java class using a formatted string
	 *
	 * @param resource the string template specifying the resource
	 * @param args     format arguments
	 * @return the content of the resource
	 */
	public static String readf(String resource, Object... args) {
		return RubyPlugin.get().read(String.format(resource, args));
	}

	/**
	 * Initializes this plugin by setting up the JRuby scripting container
	 * and then loading up the ruby side of the plugin by creating an
	 * instance of the Ruby class Jenkins::Plugin which will serve as
	 * its agent in the Ruby world.
	 * <p/>
	 * We also register xstream mappers for JRuby objects so that they
	 * can be persisted along with other objects in Jenkins.
	 */
	public RubyPlugin() {
		this.ruby = new ScriptingContainer(LocalContextScope.THREADSAFE);
		this.ruby.setClassLoader(this.getClass().getClassLoader());
        // JRuby can't load jar inside jar, so put this in a file system
        // TODO: it's very hard to consistently clean up temporary directories in Java,
        // so ideally we should just unjar it and load it from ruby-runtime.jar itself
        File dir;
        try {
            dir = File.createTempFile("jenkins", "rb");
            dir.delete();
            dir.mkdir();
            IOUtils.copy(getClass().getResourceAsStream("support/bundled-gems.jar"),new File(dir,"bundled-gems.jar"));
        } catch (IOException e) {
            throw new Error(e);
        }

        this.ruby.getLoadPaths().add(0, dir.getPath());
//		this.ruby.getLoadPaths().add(this.getClass().getResource("jenkins-plugins/lib").getPath());
		this.ruby.getLoadPaths().add(this.getClass().getResource(".").getPath());
		this.extensions = new ArrayList<ExtensionComponent>();
		this.ruby.runScriptlet("require 'rubygems'");
		this.ruby.runScriptlet("require 'bundled-gems.jar'");
		this.ruby.runScriptlet("require 'jenkins/plugins'");
		Object pluginClass = this.ruby.runScriptlet("Jenkins::Plugin");
		this.plugin = this.ruby.callMethod(pluginClass, "new", this);

		register((XStream2) Hudson.XSTREAM, ruby);
		register((XStream2) Items.XSTREAM, ruby);
	}

	private void register(XStream2 xs, ScriptingContainer ruby) {
		JRubyXStream.register(xs, ruby);
		synchronized (xs) {
			xs.setMapper(new JRubyMapper(xs.getMapperInjectionPoint()));
		}
	}

	/**
	 * Read a resource relative to this plugin clas
	 *
	 * @param resource the name of the resource to be read
	 * @return the content of the resource
	 */
	public String read(String resource) {
		InputStream stream = this.getClass().getResourceAsStream(resource);
		try {
			if (stream == null) {
				throw new RuntimeException("no such resource: " + resource);
			}
			StringBuffer buffer = new StringBuffer();
			for (int c = stream.read(); c > 0; c = stream.read()) {
				buffer.append((char) c);
			}
			return buffer.toString();
		} catch (IOException e) {
			throw new RuntimeException(e);
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
		this.ruby.callMethod(plugin, "start");
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
		this.ruby.callMethod(plugin, "stop");
	}


	/**
	 * This is mandatory for Jenkins to find this plugin, although I'm not
	 * exactly sure why.
	 *
	 * @return
	 */
	public DescriptorImpl getDescriptor() {
		return (DescriptorImpl) Hudson.getInstance().getDescriptorOrDie(getClass());
	}

	public static String getResourceURI(String relativePathFormat, Object... args) {
		return get().getClass().getResource(String.format(relativePathFormat, args)).getPath();
	}

	/**
	 * Again, this is mandatory for Jenkins to find this plugin, although I'm not
	 * exactly sure why.
	 */
	@Extension
	public static final class DescriptorImpl extends Descriptor<RubyPlugin> {
		@Override
		public String getDisplayName() {
			return "Ruby Plugin";
		}
	}
}
