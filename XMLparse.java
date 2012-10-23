/////////////////////////////////////////////////////////////////
// IMPORTANT: In the Processing PDE this class needs to be stored
// in its own tab and named "XMLparse.java"
/////////////////////////////////////////////////////////////////
 
import java.util.*;
import javax.xml.bind.annotation.*;
 
// this annoation marks the XMLparse class to be able to act as
// an XML root element. The name parameter is only needed since
// our XML element name is different from the class name:
// <job_info> vs. XMLparse
 
@XmlRootElement(name="job_info")
public class XMLparse {
 
  // now we simply annotate the different variables
  // depending if they are XML elements/nodes or node attributes
  // the mapping to the actual data type is done automatically
  @XmlElementWrapper(name="queue_info")
  
  // one of the best things in JAXB is the ability to map entire
  // class hierarchies and collections of data
  // in this case each <Job> element will be added to this list
  // the actual Job class is defined in its own tab in the Processing PDE
  @XmlElement(name="job_list")
    List<Job> jobs=new ArrayList<Job>();
}
