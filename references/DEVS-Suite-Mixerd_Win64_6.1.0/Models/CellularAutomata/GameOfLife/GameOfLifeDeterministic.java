package CellularAutomata.GameOfLife;

import java.awt.Dimension;
import java.awt.Point;
import java.util.Random;

import Component.BasicProcessor.genr;
import javafx.application.Application;
import javafx.stage.Stage;
import model.modeling.CAModels.TwoDimCellSpace;
import view.modeling.ViewableAtomic;
import view.modeling.ViewableComponent;
import view.modeling.ViewableComponentUtil;

public class GameOfLifeDeterministic extends TwoDimCellSpace {

	// A b-heptomino looks like this:
	// X
	// XXX
	// X XX
	// public static final int[][] b_heptomino = new int[][] { { 0, 1, 1 }, { 1, 1, 0 }, { 0, 1, 1 }, { 0, 0, 1 } };

	public GameOfLifeDeterministic() {
		this(4,3);

	}

	public GameOfLifeDeterministic(int xDim, int yDim) {
		super("Game of Life", xDim, yDim);

//		clock g = new clock("g", 1);
//		add(g);
		this.numCells = xDim * yDim;
		for (int i = 0; i < xDimCellspace; i++) {
			for (int j = 0; j < yDimCellspace; j++) {
				LifeDeterministic life = new LifeDeterministic(i, j);
				addCell(life);
				
				if ((i % 2) == 0 && (j % 1) == 0) 
					life.isLife = 1;
				else if ((i % 1) == 0 && (j % 2) == 0)
					life.isLife= 0;
				else if ((i % 1) == 0 && (j % 1) == 0)
					life.isLife= 1;
		
				//life.initialize();
				System.out.println("initial STATE for " + life.getClass().getName() + " in the GAME OF LIFE is set in constructor");
				
//				addCoupling(g, "out", life, "clock");
			}
		}
		
//		for(int x=0;x<b_heptomino.length;x++)
//            for(int y=0;y<b_heptomino[x].length;y++){
//            	Life l = (Life)(getCell(x+xDim/2-b_heptomino.length/2, y+yDim/2-b_heptomino[x].length/2));
//            			l.isLife = b_heptomino[x][y];
//            			l.initialize();
//            }
        
		

		// Do the couplings

		doNeighborToNeighborCoupling();
		
	}

    /**
     * Automatically generated by the SimView program.
     * Do not edit this manually, as such changes will get overwritten.
     */
    public void layoutForSimView()
    {
        preferredSize = new Dimension(1054, 700);
        ((ViewableComponent)withName("Cell: 0, 1")).setPreferredLocation(new Point(-1, 34));
        ((ViewableComponent)withName("Cell: 1, 1")).setPreferredLocation(new Point(214, 426));
        ((ViewableComponent)withName("Cell: 0, 0")).setPreferredLocation(new Point(-37, 253));
        ((ViewableComponent)withName("Cell: 0, 2")).setPreferredLocation(new Point(697, 196));
        ((ViewableComponent)withName("Cell: 3, 1")).setPreferredLocation(new Point(427, 434));
        ((ViewableComponent)withName("Cell: 2, 2")).setPreferredLocation(new Point(162, 229));
        ((ViewableComponent)withName("Cell: 1, 2")).setPreferredLocation(new Point(410, 225));
        ((ViewableComponent)withName("Cell: 3, 0")).setPreferredLocation(new Point(212, 34));
        ((ViewableComponent)withName("Cell: 1, 0")).setPreferredLocation(new Point(-20, 459));
        ((ViewableComponent)withName("Cell: 3, 2")).setPreferredLocation(new Point(432, 21));
        ((ViewableComponent)withName("Cell: 2, 1")).setPreferredLocation(new Point(694, 14));
        ((ViewableComponent)withName("Cell: 2, 0")).setPreferredLocation(new Point(682, 419));
    }
}
