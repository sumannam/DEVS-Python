/*     
 *    
 *  Author     : ACIMS(Arizona Centre for Integrative Modeling & Simulation)
 *  Version    : DEVSJAVA 2.7 
 *  Date       : 08-15-02 
 */
package Component.BasicProcessor;

import java.awt.*;

import GenCol.*;


import model.modeling.*;
import model.simulation.*;

import view.modeling.ViewableAtomic;
import view.modeling.ViewableComponent;
import view.modeling.ViewableDigraph;
import view.simView.*;



public class gpt extends ViewableDigraph{


public gpt(){
    super("gpt");

    ViewableAtomic g = new genr("generator",10);
    ViewableAtomic p = new proc("basicProcessor",5);
    ViewableAtomic t = new transd("transducer",370);

     add(g);
     add(p);
     add(t);

    addInport("in");
    addInport("start");
    addInport("stop");
    addOutport("out");
    addOutport("result");

     addTestInput("start",new entity());
     addTestInput("stop",new entity(), 5.0);

     addCoupling(this,"in",g,"in");

     addCoupling(this,"start",g,"start");
     addCoupling(this,"stop",g,"stop");

     addCoupling(g,"out",p,"in");

     addCoupling(g,"out",t,"ariv");
     addCoupling(p,"out",t,"solved");
     addCoupling(t,"out",g,"stop");


     addCoupling(p,"out",this,"out");
     addCoupling(t,"out",this,"result");

 //    initialize();
    // showState();
/*
    preferredSize = new Dimension(484, 145);
    g.setPreferredLocation(new Point(13, 18));
    p.setPreferredLocation(new Point(195, 18));
    t.setPreferredLocation(new Point(193, 80));
    */
}


    
    
    /**
     * Automatically generated by the SimView program.
     * Do not edit this manually, as such changes will get overwritten.
     */
    public void layoutForSimView()
    {
        preferredSize = new Dimension(591, 269);
        ((ViewableComponent)withName("transducer")).setPreferredLocation(new Point(63, 178));
        ((ViewableComponent)withName("basicProcessor")).setPreferredLocation(new Point(254, 47));
        ((ViewableComponent)withName("generator")).setPreferredLocation(new Point(50, 49));
    }
}
