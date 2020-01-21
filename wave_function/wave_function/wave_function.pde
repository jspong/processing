import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

class Pattern {
  public Integer[] values;
  
  Pattern(Integer[] values) {
    this.values = values;
  }
  
  public boolean equals(Object obj) {
    if (!(obj instanceof Pattern)) {
      return false;
    }
    Pattern other = (Pattern)obj;
    for (int i = 0; i < values.length; i++) {
      if (!values[i].equals(other.values[i])) {
        return false;
      }
    }
    return true;
  }
  
  public int hashCode() {
    String s = "";
    for (int i = 0; i < values.length; i++) {
      s = s + "_" + values[i]; 
    }
    return s.hashCode();
  }
  
  public boolean overlaps_down(Pattern other) {
     Integer[] v1 = values,
               v2 = other.values;
    return v2[3].equals(v1[0]) && v2[4].equals(v1[1]) && v2[5].equals(v1[2]) &&
           v2[6].equals(v1[3]) && v2[7].equals(v1[4]) && v2[8].equals(v1[5]);
  }
  public boolean overlaps_right(Pattern other) {
    Integer[] v1 = values,
              v2 = other.values;
    return v2[1].equals(v1[0]) && v2[4].equals(v1[3]) && v2[7].equals(v1[6]) &&
           v2[2].equals(v1[1]) && v2[5].equals(v1[4]) && v2[8].equals(v1[7]);
  }
}

class ImageProperties {
  HashMap<Integer, Set<Integer>> ups, downs, lefts, rights;
  
  List<Pattern> patterns;
  List<Integer> counts;
  
  ImageProperties(PImage img) {
    int w = img.width, h = img.height;
    color[] pix = img.pixels;
    ups = new HashMap<Integer, Set<Integer>>();
    downs = new HashMap<Integer, Set<Integer>>();
    lefts = new HashMap<Integer, Set<Integer>>();
    rights = new HashMap<Integer, Set<Integer>>();
    patterns = new ArrayList<Pattern>();
    counts = new ArrayList<Integer>();  
    HashMap<Pattern, Integer> patternCounts = new HashMap<Pattern, Integer>();
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        int[] pi = new int[] {
           x + y * w,           (x + 1) % w + y * w,           (x + 2) % w + y * w,
           x + (y + 1) % h * w, (x + 1) % w + (y + 1) % h * w, (x + 2) % w + (y + 1) % h * w,
           x + (y + 2) % h * w, (x + 1) % w + (y + 2) % h * w, (x + 2) % w + (y + 2) % h * w
        };
        
        Integer[] pattern = new Integer[] {
          pix[pi[0]], pix[pi[1]], pix[pi[2]],
          pix[pi[3]], pix[pi[4]], pix[pi[5]],
          pix[pi[6]], pix[pi[7]], pix[pi[8]]
        };
        Pattern p = new Pattern(pattern);
        if (!patternCounts.containsKey(p)) {
          patternCounts.put(p, 0); 
        }
        patternCounts.put(p, patternCounts.get(p) + 1);
      }
    }
    Object[] entries = patternCounts.entrySet().toArray();
    for (int i = 0; i < entries.length; i++) {
      patterns.add(((Map.Entry<Pattern, Integer>)entries[i]).getKey());
      counts.add(((Map.Entry<Pattern, Integer>)entries[i]).getValue());
    }
    for (int i = 0; i < patterns.size(); i++) {
      ups.put(i, new HashSet<Integer>());
      downs.put(i, new HashSet<Integer>());
      lefts.put(i, new HashSet<Integer>());
      rights.put(i, new HashSet<Integer>());
      Pattern pattern_i = patterns.get(i);
      for (int j = 0; j < patterns.size(); j++) {
        Pattern pattern_j = patterns.get(j);
        if (pattern_i.overlaps_down(pattern_j)) {
          ups.get(i).add(j);
        }
        if (pattern_i.overlaps_right(pattern_j)) {
          rights.get(i).add(j);
        }
        if (pattern_j.overlaps_down(pattern_i)) {
          downs.get(i).add(j);
        }
        if (pattern_j.overlaps_right(pattern_i)) {
          lefts.get(i).add(j);
        }
      }
    }
  }
}

class Collapser {
  ImageProperties rules;
  PImage generated;
  int count;
  HashMap<Integer, Float> entropy;
  List<Set<Integer>> wave;
  Integer[] buffer;
  int w, h;
  
  Collapser(ImageProperties rules, int w, int h) {
    this.rules = rules;
    this.w = w;
    this.h = h;
    this.generated = createImage(w, h, RGB);
    this.generated.loadPixels();
    entropy = new HashMap<Integer, Float>();
    wave = new ArrayList<Set<Integer>>(w * h);
    
    List<Integer> patternIndexes = new ArrayList<Integer>(rules.patterns.size());
    for (int i = 0; i < rules.patterns.size(); i++) {
      patternIndexes.add(i);
    }
    
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        wave.add(new HashSet<Integer>(patternIndexes));
        entropy.put(pos(x,y), patternIndexes.size() - random(0.1));
      }
    }
    buffer = new Integer[patternIndexes.size()];
  }
  
  boolean done() {
    return entropy.size() == 0;
  }
  
  int min_entropy() {
    float current = rules.patterns.size();
    int id = -1;
    for (int i = 0; i < w * h; i++) {
      if (entropy.containsKey(i) && entropy.get(i) <= current) {
        id = i;
        current = entropy.get(id);
      }
    }
    return id;
  }
  
  boolean in_bounds(int x, int y) {
    return x >= 0 && x < w && y >= 0 && y < h; 
  }
  
  int pos(int x, int y) {
    return x + y * w;
  }

  void update(int x, int y, int x_offset, int y_offset, HashMap<Integer, Set<Integer>> options, Stack<Integer> stack) {
    int x2 = (x + x_offset) % w;
    int y2 = (y + y_offset) % h;
    int idC = pos(x, y);
    int idN = pos(x2, y2);
    if (!entropy.containsKey(idN)) return;
    
    Set<Integer> possible = new HashSet<Integer>();
    wave.get(idC).toArray(buffer);
    for (int i = 0; i < wave.get(idC).size(); i++) {
      possible.addAll(options.get(buffer[i]));
    }
    
    if (possible.containsAll(wave.get(idN))) return;
    wave.get(idN).retainAll(possible);
    if (wave.get(idN).size() == 0) {
      print("conflict at " + idN);
      entropy.remove(idN);
    } else {
      entropy.put(idN, wave.get(idN).size() - random(0.1));
      stack.push(idN);
    }
  }
  
  int weighted_choice(int id) {
    wave.get(id).toArray(buffer);
    int total = 0;
    float[] weights = new float[wave.get(id).size()];
    for (int i = 0; i < weights.length; i++) {
        total += rules.counts.get(buffer[i]);
        weights[i] = total;
    }
    float choice = random(1.0);
    for (int i = 0; i < weights.length; i++) {
      if (weights[i] / total > choice) {
        return buffer[i]; 
      }
    }
    return buffer[buffer.length - 1];
  }

  int step() {
    int id = min_entropy();
    Stack<Integer> stack = new Stack<Integer>();
    stack.push(id);
    int choice = weighted_choice(id);
    entropy.remove(id);
    wave.get(id).clear();
    wave.get(id).add(choice);
    
    while (!stack.isEmpty()) {
      int idc = stack.pop();
      int x = idc % w, y = idc / w;
      update(x, y,  1,  0, rules.rights, stack);
      update(x, y, -1,  0, rules.lefts, stack);
      update(x, y,  0,  1, rules.downs, stack);
      update(x, y,  0, -1, rules.ups, stack);
    }
    
    generated.pixels[id] = rules.patterns.get(choice).values[4];
    return id;
  }
}

ImageProperties props;
Collapser collapser;

int size = 10;

void setup() {
  size(864, 450);
  background(255);
  frameRate(10000);
  noStroke();
  
  props = new ImageProperties(loadImage("Flowers.png"));
  collapser = new Collapser(props, width/size, height/size);
}

void draw() {
  if (collapser.done()) {
    noLoop();
  } else {
    int id = -1;
    try {
      id = collapser.step();
    } catch (RuntimeException e) {
      print("restarting");
      collapser = new Collapser(props, width / size, height / size);
    }
    if (id != -1) {
      int x = id % collapser.w,
          y = id / collapser.w;
      fill(collapser.generated.pixels[id]);
      rect(x*size, y*size, size, size);
    }
  }
}
