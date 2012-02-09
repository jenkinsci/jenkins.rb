package jenkins.ruby;


import org.kohsuke.stapler.StaplerRequest;
import org.kohsuke.stapler.StaplerResponse;

/**
 * This interface is meant to be included by JRuby proxies so that they
 * can respond directly to stapler requests.
 *
 * If I understand correctly, stapler will see if the <code>doDynamic</code>
 * method exists and if so, dispatch it via that method.
 */

public interface DoDynamic {

	void doDynamic(StaplerRequest request, StaplerResponse response);
}
