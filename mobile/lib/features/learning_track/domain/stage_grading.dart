/// Pure grading helpers for DEMO practice only. They produce a practice
/// score; they never decide pass/fail of a lesson (that is the server's job).

library;

/// Rounded percentage; 0 when [total] is 0.
int percentOf(int correct, int total) =>
    total == 0 ? 0 : (correct * 100 / total).round();

/// Counts blanks filled with exactly the expected word.
int gradeBlanks(List<String?> placed, List<String> answers) {
  var correct = 0;
  for (var i = 0; i < answers.length; i++) {
    if (i < placed.length && placed[i] == answers[i]) correct++;
  }
  return correct;
}

/// A word arrangement is correct only if every position matches.
bool gradeArrangement(List<String> placed, List<String> correctOrder) {
  if (placed.length != correctOrder.length) return false;
  for (var i = 0; i < placed.length; i++) {
    if (placed[i] != correctOrder[i]) return false;
  }
  return true;
}

/// Exact comparison with whitespace trimmed/collapsed; no diacritics are
/// removed. Alternative spellings must be listed in [accepted].
bool gradeText(String input, List<String> accepted) {
  final normalized = input.trim().replaceAll(RegExp(r'\s+'), ' ');
  return normalized.isNotEmpty && accepted.contains(normalized);
}
