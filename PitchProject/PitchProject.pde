/* R2D2 Pitch Processing
 *
 * Audio analysis for pitch extraction using
 * Autocorrelation or Harmonic Product Spectrum.
 *
 * Relies on Minim audio library
 * http://code.compartmental.net/tools/minim/
 *
 * L. Anton-Canalis (info@luisanton.es)
 */

import processing.opengl.*;

import javax.swing.JFileChooser;

import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.*;

PitchDetectorAutocorrelation PD; //Autocorrelation
//PitchDetectorHPS PD; //Harmonic Product Spectrum -not working yet-
ToneGenerator TG;
AudioSource AS;
Minim minim;

//Some arrays just to smooth output frequencies with a simple median.
float []freq_buffer = new float[10];
float []sorted;
int freq_buffer_index = 0;

long last_t = -1;
float avg_level = 0;
float last_level = 0;
String filename;
float begin_playing_time = -1;

void setup()
{
  size(600, 500, OPENGL);
  minim = new Minim(this);
  minim.debugOn();

  AS = new AudioSource(minim);

  // Choose .wav file to analyze
  boolean ok = false;
  while (!ok) {
    JFileChooser chooser = new JFileChooser();
    chooser.setFileFilter(chooser.getAcceptAllFileFilter());
    int returnVal = chooser.showOpenDialog(null);
    if (returnVal == JFileChooser.APPROVE_OPTION) {
    filename = chooser.getSelectedFile().getPath();
      AS.OpenAudioFile(chooser.getSelectedFile().getPath(), 5, 1024); //1024 for AMDF
      ok = true;
    }
  }

  // Comment the previous block and uncomment the next line for microphone input
  //AS.OpenMicrophone();

  PD = new PitchDetectorAutocorrelation();  //This one uses Autocorrelation
  //PD = new PitchDetectorHPS(); //This one uses Harmonit Product Spectrum -not working yet-
  PD.SetSampleRate(AS.GetSampleRate());
  AS.SetListener(PD);
  TG = new ToneGenerator (minim, AS.GetSampleRate());

  rectMode(CORNERS);
  background(0);
  fill(0);
  stroke(255);
}


void draw()
{
  if (begin_playing_time == -1)
  begin_playing_time = millis();

  float f = 0;
  float level = AS.GetLevel();
  long t = PD.GetTime();
  if (t == last_t) return;
  last_t = t;
  int xpos = (int)t % width;
  if (xpos >= width-1) {
     rect(0,0,width,height);
  }

  f = PD.GetFrequency();

  freq_buffer[freq_buffer_index] = f;
  freq_buffer_index++;
  freq_buffer_index = freq_buffer_index % freq_buffer.length;
  sorted = sort(freq_buffer);

  f = sorted[5];

  TG.SetFrequency(f);
  TG.SetLevel(level * 10.0);

  stroke(level * 255.0 * 10.0);
  line(xpos, height, xpos, height-(level - last_level) - 300);
  avg_level = level;
  last_level = f;
}



void stop()
{
  TG.Close();
  AS.Close();

  minim.stop();

  println("Se acabo");

  super.stop();
}


