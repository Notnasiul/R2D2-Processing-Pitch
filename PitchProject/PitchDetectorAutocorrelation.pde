/* R2D2 Pitch Processing
 * 
 * Audio analysis for pitch extraction
 * 
 * TODO: Both PitchDetectorHPS and this class should inherit from a base PitchDetector class...
 *
 * L. Anton-Canalis (info@luisanton.es) 
 */

class PitchDetectorAutocorrelation implements AudioListener { 
  float sample_rate = 0;
  float last_period = 0;
  float current_frequency = 0;
  long t;
  
   final float F0min = 50;
   final float F0max = 400;
   int min_shift;
   int max_shift;
   
   
  PitchDetectorAutocorrelation () {
    t = 0;
  }
  
  // We could as well store a vector with frequencies and return a smoothed value. 
  synchronized void StoreFrequency(float f) {
    current_frequency = f;
  }
  
  synchronized float GetFrequency() {
    return current_frequency;
  }
  
  void SetSampleRate(float s) {
     sample_rate = s;
     float tmin = 1.0 / F0max;
     float tmax = 1.0 / F0min;
     min_shift = int( tmin * sample_rate ); 
     max_shift = int( tmax * sample_rate );
     System.out.println(min_shift + " " + max_shift);
     last_period = max_shift;
     t = 0;
  }
  
  synchronized void samples(float[] samp) {
    AMDF(samp);
  }
  
  synchronized void samples(float[] sampL, float[] sampR) {
    AMDF(sampL);
  }
  
  synchronized long GetTime() {
    return t;
  }
 
  void AMDF (float []audio) {
    t++;
    int buffer_index = 0;
				
    float max_sum = 0;   
    int period = 0;
    for (int shift = min_shift; shift < max_shift; shift++)
    {  
      // Assigh higher weights to lower frequencies
      // and even higher to periods that are closer to the last period (quick temporal coherence hack)
      float mod = (float)(shift - min_shift) / (float)(max_shift - min_shift);
      mod *= 1.0 - 1.0 / (1.0 + abs(shift - last_period));
      
      // Compare samples with shifted samples using autocorrelation
      float dif = 0;
      for (int i = shift; i < audio.length; i++)
        dif += audio[i] * audio[i - shift];		
        
      // Apply weight
      dif *= 1.0 + mod;
     
      if (dif > max_sum)
      {
        max_sum = dif;			 
        period = shift;
      }
    }	
    
    if (period != 0)
    {
      last_period = period;
      float freq = 1.0 / (float)period;
      freq *= (float)sample_rate;			  
      StoreFrequency(freq);
      buffer_index += period + min_shift;		  
    }
    else {
      last_period = (max_shift + min_shift) / 2;
      StoreFrequency(0);
      buffer_index += min_shift;
    }
  }
};
