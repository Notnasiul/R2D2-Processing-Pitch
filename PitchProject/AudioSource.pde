/* R2D2 Pitch Processing
 * 
 * Audio analysis for pitch extraction 
 *
 * Audio Source extracts audio from wav files or microphones
 * 
 * L. Anton-Canalis (info@luisanton.es) 
 */

import ddf.minim.*;

class AudioSource
{
  Minim minim;
  AudioPlayer wav_file;
  AudioInput microphone;
  Boolean reading_file;


  AudioSource(Minim m) {
    this.minim = m;
    reading_file = false;
  }  
  
  void Close() {
    if (reading_file)
      wav_file.close();
    else
      microphone.close();
  }
  
  void SetListener(AudioListener listener) {
    if (reading_file)
      wav_file.addListener (listener);
    else
      microphone.addListener (listener);
  }
  
  void OpenAudioFile(String filename, int loops, int buffersize) {
    reading_file = true;
    wav_file = minim.loadFile(filename, buffersize);
    wav_file.loop(loops);  
  }
  
  void OpenMicrophone () {
    microphone = minim.getLineIn(Minim.MONO, 2048, 44100);
  }
  
  float GetSampleRate() {
    if (reading_file)
      return wav_file.sampleRate();
    else
      return microphone.sampleRate();
  }
  
  float GetLevel() {
    if (reading_file)
      return wav_file.mix.level();
    else
      return microphone.mix.level();
  }
};
