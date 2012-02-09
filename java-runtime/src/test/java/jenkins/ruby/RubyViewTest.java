package jenkins.ruby;

import com.gargoylesoftware.htmlunit.html.HtmlPage;
import org.jvnet.hudson.test.HudsonTestCase;

/**
 * @author Kohsuke Kawaguchi
 */
public class RubyViewTest extends HudsonTestCase {
    public void test1() throws Exception {
        // make sure plugin started
        assertTrue(jenkins.pluginManager.getPlugin("ruby-runtime").isActive());

        HtmlPage p = createWebClient().goTo("self");
        String text = p.asText();
        assertTrue(text.contains("I am Java::JenkinsRuby::RubyViewTest"));
        assertTrue(text.contains("1+1=2"));
        assertTrue(text.contains("Hello from ERB [Jenkins]"));
    }
}
