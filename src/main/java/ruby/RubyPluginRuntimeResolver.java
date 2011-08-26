package ruby;

import com.thoughtworks.xstream.converters.MarshallingContext;
import com.thoughtworks.xstream.converters.UnmarshallingContext;
import com.thoughtworks.xstream.io.HierarchicalStreamReader;
import com.thoughtworks.xstream.io.HierarchicalStreamWriter;
import jenkins.model.Jenkins;
import org.jenkinsci.jruby.RubyRuntimeResolver;
import org.jruby.Ruby;
import org.jruby.runtime.builtin.IRubyObject;

class RubyPluginRuntimeResolver extends RubyRuntimeResolver {
	private RubyPlugin plugin;

	public RubyPluginRuntimeResolver(RubyPlugin plugin) {
		this.plugin = plugin;
	}

	@Override
	public Ruby unmarshal(HierarchicalStreamReader reader, UnmarshallingContext context) {
		String pluginid = reader.getAttribute("pluginid");
		RubyPlugin plugin = (RubyPlugin) Jenkins.getInstance().getPlugin(pluginid);
		return plugin.getScriptingContainer().getProvider().getRuntime();
	}

	@Override
	public void marshal(IRubyObject iRubyObject, HierarchicalStreamWriter writer, MarshallingContext context) {
		writer.addAttribute("pluginid", plugin.getWrapper().getShortName());
	}
}
