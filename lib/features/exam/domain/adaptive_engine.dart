class AdaptiveEngine {
  double difficulty = 0.5; // 0..1

  void record(bool correct) {
    // Simple Elo-like adjustment
    difficulty += correct ? 0.05 : -0.05;
    if (difficulty < 0.0) difficulty = 0.0;
    if (difficulty > 1.0) difficulty = 1.0;
  }

  int nextIndex(int total) {
    // Map difficulty to index space; center around difficulty*total
    final target = (difficulty * (total - 1)).round();
    return target.clamp(0, total - 1);
  }
}

