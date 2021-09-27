package CellularAutomata.HeatDiffusion;

import java.awt.Dimension;
import java.awt.Point;

import model.modeling.CAModels.TwoDimCellSpace;
import view.modeling.ViewableComponent;

public class HeatDiffusion extends TwoDimCellSpace {

	public HeatDiffusion() {
		this(4, 4);
	}

	public HeatDiffusion(int xDim, int yDim) {
		super("Heat Diffusion", xDim, yDim);

		this.numCells = xDim * yDim;
		for (int i = 0; i < xDimCellspace; i++) {
			for (int j = 0; j < yDimCellspace; j++) {
				HeatCell heatcell = new HeatCell(i, j);
				addCell(heatcell);

				if (i == 0 && j > 2 && j < 6 ) {
					heatcell.isSource = 1;
				}
				heatcell.initialize();
			}
		}

		doNeighborToNeighborCoupling();

	}

    /**
     * Automatically generated by the SimView program.
     * Do not edit this manually, as such changes will get overwritten.
     */
    public void layoutForSimView()
    {
        preferredSize = new Dimension(964, 795);
        ((ViewableComponent)withName("Cell: 3, 2")).setPreferredLocation(new Point(573, 419));
        ((ViewableComponent)withName("Cell: 1, 1")).setPreferredLocation(new Point(197, 247));
        ((ViewableComponent)withName("Cell: 0, 2")).setPreferredLocation(new Point(15, 410));
        ((ViewableComponent)withName("Cell: 0, 3")).setPreferredLocation(new Point(7, 609));
        ((ViewableComponent)withName("Cell: 1, 2")).setPreferredLocation(new Point(192, 421));
        ((ViewableComponent)withName("Cell: 2, 0")).setPreferredLocation(new Point(369, 49));
        ((ViewableComponent)withName("Cell: 2, 2")).setPreferredLocation(new Point(381, 421));
        ((ViewableComponent)withName("Cell: 1, 3")).setPreferredLocation(new Point(193, 602));
        ((ViewableComponent)withName("Cell: 0, 0")).setPreferredLocation(new Point(4, 58));
        ((ViewableComponent)withName("Cell: 0, 1")).setPreferredLocation(new Point(15, 241));
        ((ViewableComponent)withName("Cell: 3, 3")).setPreferredLocation(new Point(585, 611));
        ((ViewableComponent)withName("Cell: 2, 1")).setPreferredLocation(new Point(375, 238));
        ((ViewableComponent)withName("Cell: 3, 0")).setPreferredLocation(new Point(571, 48));
        ((ViewableComponent)withName("Cell: 1, 0")).setPreferredLocation(new Point(187, 58));
        ((ViewableComponent)withName("Cell: 2, 3")).setPreferredLocation(new Point(380, 604));
        ((ViewableComponent)withName("Cell: 3, 1")).setPreferredLocation(new Point(574, 234));
    }
}
