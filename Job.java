/////////////////////////////////////////////////////////////////
// IMPORTANT: In the Processing PDE this class needs to be stored
// in its own tab and named "Job.java"
/////////////////////////////////////////////////////////////////

import javax.xml.bind.annotation.*;

public class Job {

  @XmlElement
    int JB_job_number;

  @XmlElement
    float JAT_prio;

  @XmlElement 
    String JB_name;

  @XmlElement
    String JB_owner;

  @XmlElement
    String state;

  @XmlElement
    String JAT_start_time;

  @XmlElement
    String queue_name;

  @XmlElement
    int slots;
}

