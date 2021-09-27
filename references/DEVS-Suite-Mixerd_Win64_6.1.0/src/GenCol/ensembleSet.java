/*     
 *    
 *  Author     : ACIMS(Arizona Centre for Integrative Modeling & Simulation)
 *  Version    : DEVSJAVA 2.7 
 *  Date       : 08-15-02 
 */
package GenCol;


import java.util.Collection;
import java.util.HashSet;
import java.util.function.Function;

@SuppressWarnings("serial")
public class ensembleSet<T> extends HashSet<T> implements ensembleInterface<T>
{
    private ensemble<T> el;

    public ensembleSet()
    {
        el = ensembleWrapper.make(this);
    }
    public ensembleSet(Collection<? extends T> c)
    {
        addAll(c);
        el = ensembleWrapper.make(this);
    }

    @Override
    public void tellAll(String MethodNm, Class<?>[] classes, Object[] args)
    {
        el.tellAll(MethodNm, classes, args);
    }

    @Override
    public void tellAll(String MethodNm)
    {
        Class<?>[] classes = {};
        Object[] args = {};
        el.tellAll(MethodNm, classes, args);
    }

    @Override
    public void AskAll(ensembleInterface<T> result, String MethodNm, Class<?>[] classes, Object[] args)
    {
        el.AskAll(result, MethodNm, classes, args);
    }

    @Override
    public void which(ensembleInterface<T> result, String MethodNm, Class<?>[] classes, Object[] args)
    {
        // MethodNm method must return this if condition is true and null
        // otherwise
        el.AskAll(result, MethodNm, classes, args);
    }

    @Override
    public T whichOne(String MethodNm, Class<?>[] classes, Object[] args)
    {
        return el.whichOne(MethodNm, classes, args);
    }

    @SuppressWarnings("unchecked")
    @Override
    public ensembleInterface<T> copy(ensembleInterface<?> c)
    {
        try
        {
            return ((ensembleInterface<T>) c).copy(c);
        }
        catch (ClassCastException e)
        {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public void wrapAll(ensembleInterface<Object> Result, Class<?> cl)
    {
        el.wrapAll(Result, cl);
    }

    @Override
    public boolean none(String MethodNm, Class<?>[] classes, Object[] args)
    {
        return el.none(MethodNm, classes, args);
    }

    @Override
    public boolean all(String MethodNm, Class<?>[] classes, Object[] args)
    {
        return el.all(MethodNm, classes, args);
    }

    @Override
    public void print()
    {
        el.print();
    }
    
    @Override 
    public T findIf(Function<T, Boolean> f)
    {
        for (T iod : this)
        {
            if (f.apply(iod) == true)
            {
                return iod;
            }
        }
        
        return null;
    }
}
