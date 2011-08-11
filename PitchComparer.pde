import ddf.minim.*;

class PitchComparer
{
  int TIME = 0;
  int FREQ = 1;
  int last_time_index = 0;
  float[][] model; //Current model: time(ms) freq(Hz)
  float start_time = 0;
  
  PitchComparer() {
  }
  
  int GetTimeline(float realtime) {
    int time_index = last_time_index++;
    while ((time_index < model.length) && 
           (model[time_index][TIME] < realtime))
           time_index++;
    if (time_index < model.length)
      return time_index;
    else
      return -1;
  }
  
  void ReadModel(String filename) {
    try{
      String[] map = loadStrings(filename);
      int length = map.length;	
      model = new float[length][2];
      for (int line = 0; line < length; line++) {
        String[] data = split(map[line], ' ');
        model[line][TIME] = float(data[0]);
        model[line][FREQ] = float(data[1]);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  void StoreFrequency(float base_t, float f, float level, String filename) {
    try{
      BufferedWriter out = new BufferedWriter(new FileWriter(filename,true));
      out.write(millis() - base_t + " " + f + " " + level + "\n");
      out.close();
    } catch(IOException e) {  
      e.printStackTrace();
    }
  }
};
  
