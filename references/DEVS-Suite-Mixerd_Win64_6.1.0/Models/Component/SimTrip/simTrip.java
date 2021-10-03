/*     
 *    
 *  Author     : ACIMS(Arizona Centre for Integrative Modeling & Simulation)
 *  Version    : DEVSJAVA 2.7 
 *  Date       : 08-15-02 
 */
package Component.SimTrip;

import java.awt.*;

import Component.BasicProcessor.*;
import GenCol.*;
import model.modeling.*;
import model.simulation.*;
import view.modeling.ViewableComponent;
import view.modeling.ViewableDigraph;
import view.simView.*;



public class simTrip extends ViewableDigraph {


public simTrip(){
    super("simTrip");

    atomic g = new simulator("g",new genr("g",2000));
  atomic p = new simulator("p",new proc("p",1000));
//     atomic p = new simulator("p",new pipeSimple("p",300));
    atomic t = new simulator("t",new transd("t",20000));
    atomic c = new sCoordinator("c",g,p,t);


     add(c);
     add(g);
     add(p);
     add(t);

     addCoupling(g,"outTN",c,"getTN");
     addCoupling(p,"outTN",c,"getTN");
     addCoupling(t,"outTN",c,"getTN");

     addCoupling(g,"sendOut",c,"getOutFromG");
     addCoupling(p,"sendOut",c,"getOutFromP");
     addCoupling(t,"sendOut",c,"getOutFromT");

     addCoupling(c,"nextTN",g,"nextTN");
     addCoupling(c,"getOut",g,"getOut");

     addCoupling(c,"nextTN",p,"nextTN");
     addCoupling(c,"getOut",p,"getOut");

     addCoupling(c,"nextTN",t,"nextTN");
     addCoupling(c,"getOut",t,"getOut");



     addCoupling(c,"applyDeltG",g,"applyDelt");
     addCoupling(c,"applyDeltP",p,"applyDelt");
     addCoupling(c,"applyDeltT",t,"applyDelt");




     showState();



}


    /**
     * Automatically generated by the SimView program.
     * Do not edit this manually, as such changes will get overwritten.
     */
    public void layoutForSimView()
    {
        preferredSize = new Dimension(582, 287);
        ((ViewableComponent)withName("t")).setPreferredLocation(new Point(333, 192));
        ((ViewableComponent)withName("g")).setPreferredLocation(new Point(-18, 122));
        ((ViewableComponent)withName("p")).setPreferredLocation(new Point(94, 214));
        ((ViewableComponent)withName("c")).setPreferredLocation(new Point(157, 25));
    }
}
