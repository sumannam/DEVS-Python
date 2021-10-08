/**
 * DEVS-Suite Simulator
 * Arizona Center for Integrative Modeling & Simulation
 * Arizona State University, Tempe, AZ, USA
 *
 * Author(s): H.S. Sarjoughian
 */

package Component.MapSearchDevice;

import java.awt.Dimension;
import java.awt.Point;

import view.modeling.ViewableAtomic;
import view.modeling.ViewableComponent;
import view.modeling.ViewableDigraph;

public class Generator extends ViewableDigraph {

	public Generator(String name,  double greenTA, double redTA) {
		super(name);

		ViewableAtomic D_Green = new D_Green("green",greenTA);
		ViewableAtomic D_Red = new D_Red("red", redTA);

		add(D_Green);
		add(D_Red);

		addInport("stop");
		addOutport("outGreen");
		addOutport("outRed");

		addCoupling(this, "stop", D_Green, "stop");
		addCoupling(this, "stop", D_Red, "stop");

		addCoupling(D_Green, "outGreen", this, "outGreen");
		addCoupling(D_Red, "outRed", this, "outRed");
	}
    /**
     * Automatically generated by the SimView program.
     * Do not edit this manually, as such changes will get overwritten.
     */
    public void layoutForSimView()
    {
        preferredSize = new Dimension(324, 172);
        ((ViewableComponent)withName("red")).setPreferredLocation(new Point(-1, 108));
        ((ViewableComponent)withName("green")).setPreferredLocation(new Point(-3, 33));
    }
}
