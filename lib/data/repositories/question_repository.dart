import '../models/question_model.dart';
import '../questions/curated_problem_bank.dart';
import '../questions/procedural_problem_generator.dart';

class QuestionRepository {
  final List<QuestionModel> _curatedBank = CuratedProblemBank.getCuratedProblems();

  /// Retrieves a question by ID
  QuestionModel? getQuestionById(String id) {
    try {
      return _curatedBank.firstWhere((q) => q.id == id);
    } catch (_) {
      // If not in curated, try parsing level from id (e.g., 'challenge_lvl_12')
      if (id.startsWith('challenge_lvl_')) {
        final levelStr = id.replaceFirst('challenge_lvl_', '');
        final level = int.tryParse(levelStr) ?? 1;
        return ProceduralProblemGenerator.generateForLevel(level);
      }
      return null;
    }
  }

  /// Selects the next strictly unique question for the user's current level,
  /// ensuring canonical uniqueness against all previously assigned canonical IDs.
  QuestionModel getNextUniqueQuestion({
    required int userLevel,
    required List<String> assignedQuestionIds,
    required List<String> completedQuestionIds,
  }) {
    final Set<String> assignedSet = {...assignedQuestionIds, ...completedQuestionIds};

    // 1. First, search eligible curated problems matching current difficulty
    final eligibleCurated = _curatedBank.where((q) {
      if (assignedSet.contains(q.id) || assignedSet.contains(q.canonicalProblemId)) {
        return false;
      }
      // Check difficulty appropriateness
      if (userLevel <= 10) return q.difficultyRating <= 3;
      if (userLevel <= 30) return q.difficultyRating <= 4;
      if (userLevel <= 75) return q.difficultyRating <= 5;
      return true;
    }).toList();

    if (eligibleCurated.isNotEmpty) {
      return eligibleCurated.first;
    }

    // 2. Procedural Generation with guaranteed uniqueness across 1,000+ levels
    var candidateLevel = userLevel;
    while (true) {
      final generated = ProceduralProblemGenerator.generateForLevel(candidateLevel);
      if (!assignedSet.contains(generated.id) &&
          !assignedSet.contains(generated.canonicalProblemId)) {
        return generated;
      }
      candidateLevel++; // Advance level to find next unassigned canonical problem
    }
  }

  /// Returns a curated problem list for direct practice/browsing
  List<QuestionModel> getAllCuratedQuestions() {
    return List.unmodifiable(_curatedBank);
  }
}
