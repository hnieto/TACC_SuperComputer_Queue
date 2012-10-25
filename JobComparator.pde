// used in MachineQueueVis to find the largest slot count in the current qstat xml file

class JobComparator implements Comparator<Job> {
  public int compare(Job j1, Job j2){
    return j1.slots-j2.slots;
  } 
}
