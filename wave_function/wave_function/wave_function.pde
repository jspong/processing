import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
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
    // https://stackoverflow.com/questions/19854564/hash-integer-array
    int hash = 17;
    for (int value : values) {
      hash = hash * 31 + value;
    }
    return hash;
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
        
        Pattern p = new Pattern(new Integer[] {
          pix[pi[0]], pix[pi[1]], pix[pi[2]],
          pix[pi[3]], pix[pi[4]], pix[pi[5]],
          pix[pi[6]], pix[pi[7]], pix[pi[8]]
        });
        
        if (!patternCounts.containsKey(p)) {
          patternCounts.put(p, 0); 
        }
        patternCounts.put(p, patternCounts.get(p) + 1);
      }
    }
    for (Pattern pattern : patternCounts.keySet()) {
      patterns.add(pattern);
      counts.add(patternCounts.get(pattern));
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

class Visit {
  int id;
  int choice;
  Set<Integer> patternIds;
    
  Visit(int id, int choice, Set<Integer> patternIds) {
    this.id = id;
    this.choice = choice;
    this.patternIds = patternIds;
  }
} 

class Collapser {
  ImageProperties rules;
  PImage generated;
  int count;
  HashMap<Integer, Float> entropy;
  List<Set<Integer>> wave;
  int w, h;
  boolean success;
  
  Stack<List<Visit>> visits;
  
  Collapser(ImageProperties rules, int w, int h) {
    this.rules = rules;
    this.w = w;
    this.h = h;
    this.generated = createImage(w, h, RGB);
    this.generated.loadPixels();
    entropy = new HashMap<Integer, Float>();
    wave = new ArrayList<Set<Integer>>(w * h);
    success = true;
    
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
    visits = new Stack<List<Visit>>();
  }
  
  boolean done() {
    return entropy.size() == 0;
  }
  
  int min_entropy() {
    float min = rules.patterns.size(); 
    int id = -1;
    for (int key : entropy.keySet()) {
      if (entropy.get(key) <= min) {
        id = key;
        min = entropy.get(key);
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

  boolean update(int x, int y, int x_offset, int y_offset, HashMap<Integer, Set<Integer>> options, Stack<Integer> stack, List<Visit> moves) {
    int x2 = (x + x_offset) % w;
    int y2 = (y + y_offset) % h;
    int idC = pos(x, y);
    int idN = pos(x2, y2);
    if (!entropy.containsKey(idN)) return true;
    
    Set<Integer> possible = new HashSet<Integer>();
    for (int pattern : wave.get(idC)) {
      possible.addAll(options.get(pattern)); 
    }
    
    Set<Integer> neighbor = wave.get(idN);
    if (possible.containsAll(neighbor)) return true;
    Set<Integer> previous = new HashSet<Integer>(neighbor);
    neighbor.retainAll(possible);
    
    if (neighbor.size() == 0) {
      wave.set(idN, previous);
      return false;
    } else {
      moves.add(new Visit(idN, 0, previous));
      entropy.put(idN, neighbor.size() - random(0.1));
      stack.push(idN);
      return true;
    }
  }
  
  int weighted_choice(int id) {
    Set<Integer> choices = wave.get(id);
    List<Integer> choice_list = new ArrayList<Integer>(choices);
    
    int total = 0;
    float[] weights = new float[choices.size()];
    for (int i = 0; i < weights.length; i++) {
        total += rules.counts.get(choice_list.get(i));
        weights[i] = total;
    }
    float choice = random(1.0);
    for (int i = 0; i < weights.length; i++) {
      if (weights[i] / total > choice) {
        return choice_list.get(i); 
      }
    }
    return 0;
  }
  
  void renderPixel(int id, color c) {
     generated.pixels[id] = c;
     int x = id % w, y = id / w;
     fill(collapser.generated.pixels[id]);
     rect(x*size, y*size, size, size);
  }
  
  Visit undo(List<Visit> visits) {
    for (int i = visits.size() - 1; i >= 0; i--) {
      Visit v = visits.get(i);
      wave.set(v.id, v.patternIds);
      entropy.put(v.id, wave.get(v.id).size() - random(0.1));
    }
    renderPixel(visits.get(0).id, color(255));
    
    return visits.get(0);
  }
  
  int step() {
    List<Visit> moves = new ArrayList<Visit>();
    int id;
    if (success) {
      id = min_entropy();
      success = collapse(min_entropy(), moves);
    } else {
      while (!visits.isEmpty() && visits.peek().get(0).patternIds.isEmpty()) {
        undo(visits.pop());
      }
      if (visits.isEmpty()) {
        success = true;
        return 0;
      }
      
      Visit last = undo(visits.pop());
      id = last.id;
      if (wave.get(id).size() > 0) {
        success = collapse(id, moves);
      }
    }
    visits.push(moves);
    return id;
  }

  boolean collapse(int id, List<Visit> moves) {
    Stack<Integer> stack = new Stack<Integer>();
    stack.push(id);
    int choice = weighted_choice(id);
    entropy.remove(id);
    Set<Integer> remaining = new HashSet<Integer>(wave.get(id));
    remaining.remove(choice);
    moves.add(new Visit(id, choice, remaining));
    wave.get(id).clear();
    wave.get(id).add(choice);
    
    while (!stack.isEmpty()) {
      int idc = stack.pop();
      int x = idc % w, y = idc / w;
      if (!update(x, y,  1,  0, rules.rights, stack, moves)) return false;
      if (!update(x, y, -1,  0, rules.lefts, stack, moves)) return false;
      if (!update(x, y,  0,  1, rules.downs, stack, moves)) return false;
      if (!update(x, y,  0, -1, rules.ups, stack, moves)) return false;
    }

    renderPixel(id, rules.patterns.get(choice).values[0]);
    return true;
  }
}

ImageProperties props;
Collapser collapser;

int size = 10;

void setup() {
  size(800, 450);
  background(255);
  frameRate(10000);
  noStroke();
  
  props = new ImageProperties(loadImage("Platformer.png"));
  collapser = new Collapser(props, width/size, height/size);
}

void draw() {
  if (collapser.done()) {
    //collapser = new Collapser(props, width/size, height/size);
    noLoop();
  } else {
    int id = collapser.step();
  }
}
