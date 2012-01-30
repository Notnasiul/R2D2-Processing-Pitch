/* R2D2 Pitch Processing
 * 
 * Audio analysis for pitch extraction 
 * 
 * TODO: Both PitchDetectorHPS and this class should inherit from a base PitchDetector class...
 *
 * L. Anton-Canalis (info@luisanton.es) 
 */

import ddf.minim.analysis.*;

class PitchDetectorHPS implements AudioListener { 
  float sample_rate = 0;
  float last_frequency = 0;
  float last_period = 0;
  float current_frequency = 0;
  long t;
  FFT fft;
  float [] x2;
  float [] x3;
  float [] x4;
  float [] x5;

  PitchDetectorHPS () {
    t = 0;
    fft = null;
  }
  
  void SetSampleRate(float s) {
	sample_rate = s;
  }
  
  synchronized void StoreFrequency(float f) {
    last_frequency = current_frequency;  
    current_frequency = f;
  }
  
  
  synchronized float GetFrequency() {
	return current_frequency;
  }
  
  synchronized void samples(float[] samp) {
    HSP(samp);
  }
  
  synchronized void samples(float[] sampL, float[] sampR) {
    HSP(sampL);
  }
  
  synchronized long GetTime() {
    return t;
  }
 
  void HSP (float []audio) {
    t++;
    
    // Create fft and support arrays if they don't exist.
    if (fft == null) {
       fft = new FFT(audio.length, sample_rate);
       x2 = new float[fft.specSize()];
       x3 = new float[fft.specSize()];
       x4 = new float[fft.specSize()];
       x5 = new float[fft.specSize()];
    }
    
    fft.forward(audio);
    
    // Downsample power spectrum
    for(int i = 0; i < fft.specSize(); i++)
    {
       if (i % 2 == 0) x2[i/2] = fft.getBand(i);
       if (i % 3 == 0) x3[i/3] = fft.getBand(i);
       if (i % 4 == 0) x4[i/4] = fft.getBand(i);
       if (i % 5 == 0) x5[i/5] = fft.getBand(i);
    }
    
    // Multiply original and downsampled version.
    // Find index of maximum product (HSP)
    float hps = 0;
    int bin = 0;
    for(int i = 0; i < fft.specSize()/5; i++)
    {
      float sum = 0;
      sum = fft.getBand(i) * x2[i] * x3[i] * x4[i] * x5[i];
      
      if (sum > hps) {
        hps = sum;
        bin = i;
      }
    }
    
    
    StoreFrequency(bin * fft.getBandWidth());	
  }	  
};
