/* R2D2 Pitch Processing
 * 
 * Audio analysis for pitch extraction using 
 * Autocorrelation or Harmonic Product Spectrum.
 * 
 * TODO: Both PitchDetectorHPS and this class should inherit from a base PitchDetector class...
 *
 * L. Anton-Canalis (info@luisanton.es) 
 */

class PitchDetectorAutocorrelation implements AudioListener { 
  float sample_rate = 0;
  float last_frequency = 0;
  float last_period = 0;
  float current_frequency = 0;
  long t;

  PitchDetector () {
	t = 0;
  }
  
  synchronized void StoreFrequency(float f) {
 
	last_frequency = current_frequency;
	current_frequency = f;
  }
  
  synchronized float GetFrequency() {
	return current_frequency;
  }
  
  void SetSampleRate(float s) {
	sample_rate = s;
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
    float F0min = 50;
    float F0max = 300;
    float tmin = 1.0 / F0max;
    float tmax = 1.0 / F0min;
    int min_shift = int( tmin * sample_rate ); 
    int max_shift = int( tmax * sample_rate );

    int buffer_index = 0;
    while (buffer_index < audio.length - min_shift)
    {				
      float min_dif = 1e30;
      int period = 0;
      for (int shift = min_shift; shift < max_shift; shift++)
      {
        float dif = 0;
        float n_samples = 0;
        float mod = (float)(shift - min_shift) / (float)(max_shift - min_shift);
        mod *= 1.0 - 1.0 / (1.0 + abs(shift - last_period));
        for (int i = shift; i < audio.length; i++)
        {
          float d = audio[i] - audio[i - shift];
          dif += d*d;
          n_samples++;
        }
        dif /= n_samples;		
        dif *= 1.0 + mod;
        if (dif < min_dif)
        {
          min_dif = dif;			 
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
  }
};
