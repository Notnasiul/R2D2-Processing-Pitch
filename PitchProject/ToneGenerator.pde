/* R2D2 Pitch Processing
 * 
 * Audio analysis for pitch extraction 
 *
 * Generates an output tone using a triangle weave
 * 
 * L. Anton-Canalis (info@luisanton.es) 
 */

import ddf.minim.*;

class ToneGenerator
{
  Minim minim;
  AudioOutput out;
  TriangleWave wav;
  
  ToneGenerator(Minim m, float sampleRate) {
    this.minim = m;
    
    out = minim.getLineOut(Minim.MONO, 512, sampleRate);
    
    wav = new TriangleWave(100, 0.5, out.sampleRate());    
    out.addSignal(wav); 
  }
  
  void Close() {
    out.close();
  }
  
  void SetFrequency(float f) {
     wav.setFreq(f);
  }
  
  void SetLevel(float l) {
	 wav.setAmp(l);
  }
};
