/* R2D2 Pitch Processing
 * 
 * Audio analysis for pitch extraction 
 * 
 * Looks for FFT bin with highest energy. Quite naive...
 *
 * L. Anton-Canalis (info@luisanton.es) 
 */

class PitchDetectorFFT implements AudioListener { 
  float sample_rate = 0;
  float last_period = 0;
  float current_frequency = 0;
  long t;
  
  FFT fft;
  
  final float F0min = 50;
  final float F0max = 400;
   
   
  PitchDetectorFFT () {
  }
  
  void ConfigureFFT (int bufferSize, float s) {
       fft = new FFT(bufferSize, s); 
       fft.window(FFT.HAMMING);
       SetSampleRate(s);
  }
  
  synchronized void StoreFrequency(float f) {
    current_frequency = f;
  }
  
  synchronized float GetFrequency() {
    return current_frequency;
  }
  
  void SetSampleRate(float s) {
     sample_rate = s;
     t = 0;
  }
  
  synchronized void samples(float[] samp) {
    FFT(samp);
  }
  
  synchronized void samples(float[] sampL, float[] sampR) {
    FFT(sampL);
  }
  
  synchronized long GetTime() {
    return t;
  }
 
  void FFT (float []audio) {
    t++;
    float highest = 0;
    int highest_bin = 0;
    fft.forward(audio);
    int max_bin =  fft.freqToIndex(10000.0f);

    for (int n = 0; n < max_bin; n++) {
       if (fft.getBand(n) > highest) {
         highest = fft.getBand(n);
         highest_bin = n;
       }

      // if (fft.getBand(n)/(n+1) > fft.getBand(highest)/(highest+1))
      //   highest = n;
    }


    /* for(int n = fft.specSize()-1; n > 0; n--) {
       float current_frec = n * 0.5 * sample_rate / float(audio.length);
       float bin_sum = fft.getBand(n);
       int multiple_bin = fft.freqToIndex(current_frec * 0.5f);
       int last_bin = multiple_bin;
       
       if (bin_sum > highest) {
         highest_bin = n;
         highest = (int)bin_sum;
       }
         
       
      // if (fft.getBand(n)/(n+1) > fft.getBand(highest)/(highest+1))
      //   highest = n;
    }*/
    
    
    
    float freq = highest_bin * 0.5 * sample_rate / float(audio.length);
    StoreFrequency(freq);
  }
};
