package ruby;

import com.thoughtworks.xstream.converters.MarshallingContext;
import com.thoughtworks.xstream.converters.UnmarshallingContext;
import com.thoughtworks.xstream.io.HierarchicalStreamReader;
import com.thoughtworks.xstream.io.HierarchicalStreamWriter;
import jenkins.model.Jenkins;
import org.jenkinsci.jruby.RubyRuntimeResolver;
import org.jruby.Ruby;
import org.jruby.embed.ScriptingContainer;
import org.jruby.runtime.builtin.IRubyObject;

/**
 * Each Ruby plugin gets its own {@link ScriptingContainer}, so put the plugin name
 * as an attribute so that we can correctly unmarshal it back.
 */
class RubyPluginRuntimeResolver extends RubyRuntimeResolver {
	public RubyPluginRuntimeResolver() {
	}

	@Override
	public Ruby unmarshal(HierarchicalStreamReader reader, UnmarshallingContext context) {
		String pluginid = reader.getAttribute("pluginid");
		RubyPlugin plugin = (RubyPlugin) Jenkins.getInstance().getPlugin(pluginid);
		return plugin.getScriptingContainer().getProvider().getRuntime();
	}

	@Override
	public void marshal(IRubyObject o, HierarchicalStreamWriter writer, MarshallingContext context) {
        RubyPlugin p = RubyPlugin.from(o.getRuntime());
        if (p!=null)
            writer.addAttribute("pluginid", p.getWrapper().getShortName());
	}
}
