
float lengthOf(List<Float> vector) {
  float size = 0;
  for (int i = 0; i < vector.size(); i++) {
    size += vector.get(i) * vector.get(i);
  }
  return sqrt(size);
}

PVector screenPoint(int x, int y) {
  return new PVector(screenX(x, y), screenY(x, y));
}

PVector screenPoint(PVector p) {
  return new PVector(screenX(p.x, p.y), screenY(p.x, p.y));
}
