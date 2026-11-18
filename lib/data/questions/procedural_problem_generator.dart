import '../models/question_model.dart';

class ProceduralProblemGenerator {
  /// Generates a strictly unique canonical problem for a given level (1 to 1000+)
  static QuestionModel generateForLevel(int level) {
    final clampedLevel = level < 1 ? 1 : level;

    // Determine difficulty rating (1 to 10) and band
    final int rating;
    final String band;
    if (clampedLevel <= 10) {
      rating = 1 + (clampedLevel - 1) ~/ 4; // 1 - 3
      band = 'Beginner';
    } else if (clampedLevel <= 30) {
      rating = 3 + (clampedLevel - 11) ~/ 10; // 3 - 4
      band = 'Easy to Intermediate';
    } else if (clampedLevel <= 75) {
      rating = 4 + (clampedLevel - 31) ~/ 23; // 4 - 5
      band = 'Intermediate';
    } else if (clampedLevel <= 150) {
      rating = 5 + (clampedLevel - 76) ~/ 38; // 5 - 6
      band = 'Intermediate to Advanced';
    } else if (clampedLevel <= 300) {
      rating = 6 + (clampedLevel - 151) ~/ 75; // 6 - 7
      band = 'Advanced';
    } else if (clampedLevel <= 500) {
      rating = 7 + (clampedLevel - 301) ~/ 100; // 7 - 8
      band = 'Expert';
    } else if (clampedLevel <= 750) {
      rating = 8 + (clampedLevel - 501) ~/ 125; // 8 - 9
      band = 'Very Advanced';
    } else {
      rating = 9 + ((clampedLevel - 751) ~/ 250).clamp(0, 1); // 9 - 10
      band = 'Master';
    }

    // Determine algorithmic topic based on level tier & hash
    final topic = _determineTopicForLevel(clampedLevel);

    // Generate canonical problem specification
    return _buildProblemSpec(clampedLevel, rating, band, topic);
  }

  static String _determineTopicForLevel(int level) {
    if (level <= 10) {
      final topics = ['Arrays', 'Strings', 'Hash Maps and Sets', 'Searching and Sorting'];
      return topics[(level - 1) % topics.length];
    } else if (level <= 30) {
      final topics = ['Sliding Window', 'Linked Lists', 'Stacks and Queues', 'Binary Search', 'Two Pointers'];
      return topics[(level - 11) % topics.length];
    } else if (level <= 75) {
      final topics = ['Trees and Binary Search Trees', 'Heaps', 'Prefix Sums', 'Recursion & Backtracking', 'Greedy Algorithms'];
      return topics[(level - 31) % topics.length];
    } else if (level <= 150) {
      final topics = ['Dynamic Programming', 'Graphs', 'Topological Sort', 'Monotonic Stacks', 'Union Find'];
      return topics[(level - 76) % topics.length];
    } else if (level <= 300) {
      final topics = ['Tries', 'Bit Manipulation', 'Intervals', 'Advanced DP', 'Dijkstra & Shortest Path'];
      return topics[(level - 151) % topics.length];
    } else if (level <= 500) {
      final topics = ['Segment Trees', 'Binary Indexed Trees', 'Tree DP', 'Bitmask DP', 'Advanced Graphs'];
      return topics[(level - 301) % topics.length];
    } else if (level <= 750) {
      final topics = ['Heavy-Light Decomposition', 'Eulerian Paths', 'Game Theory & Minimax', 'Aho-Corasick', 'Matrix Exponentiation'];
      return topics[(level - 501) % topics.length];
    } else {
      final topics = ['Network Flow & Min-Cut', 'Suffix Automata', 'Advanced Combinatorics', 'Centroid Decomposition', 'High-Order DP'];
      return topics[(level - 751) % topics.length];
    }
  }

  static QuestionModel _buildProblemSpec(int level, int rating, String band, String topic) {
    final canonicalId = 'canonical_level_${level.toString().padLeft(4, '0')}_${topic.toLowerCase().replaceAll(' ', '_')}';
    final id = 'challenge_lvl_$level';

    // Algorithmic templates according to level
    switch (topic) {
      case 'Arrays':
      case 'Two Pointers':
        return _buildArrayVariation(level, id, canonicalId, rating, band, topic);
      case 'Strings':
      case 'Sliding Window':
        return _buildStringVariation(level, id, canonicalId, rating, band, topic);
      case 'Dynamic Programming':
      case 'Advanced DP':
      case 'Bitmask DP':
      case 'Tree DP':
        return _buildDpVariation(level, id, canonicalId, rating, band, topic);
      case 'Stacks and Queues':
      case 'Monotonic Stacks':
        return _buildStackVariation(level, id, canonicalId, rating, band, topic);
      case 'Searching and Sorting':
      case 'Binary Search':
        return _buildSearchVariation(level, id, canonicalId, rating, band, topic);
      case 'Trees and Binary Search Trees':
      case 'Segment Trees':
        return _buildTreeVariation(level, id, canonicalId, rating, band, topic);
      default:
        return _buildGraphOrGeneralVariation(level, id, canonicalId, rating, band, topic);
    }
  }

  static QuestionModel _buildArrayVariation(
      int level, String id, String canonicalId, int rating, String band, String topic) {
    final k = (level % 7) + 2;
    final title = 'Level $level: Subarray Sum Threshold (K = $k)';
    final description =
        'Given an array of integers `nums` and an integer threshold `K = $k`, find the maximum length of a contiguous subarray whose sum does not exceed `K * 10`.\n\nReturn 0 if no such non-empty subarray exists.';

    final sample1Input = '[2, 4, 1, 8, 3]\n${k * 10}';
    final sample2Input = '[100, 200]\n${k * 10}';

    return QuestionModel(
      id: id,
      canonicalProblemId: canonicalId,
      title: title,
      description: description,
      difficultyRating: rating,
      difficultyBand: band,
      topic: topic,
      inputDescription: 'Array of integers `nums` and integer limit `threshold`',
      outputDescription: 'Integer maximum length of contiguous subarray',
      constraints: [
        '1 <= nums.length <= 10^5',
        '0 <= nums[i] <= 1000',
        'threshold >= 1',
      ],
      examples: [
        TestCaseExample(
          input: 'nums = [2, 4, 1, 8, 3], threshold = ${k * 10}',
          output: '4',
          explanation: 'Subarray [2, 4, 1, 8] has sum 15 <= ${k * 10}.',
        ),
      ],
      sampleTestCases: [
        TestCase(input: sample1Input, expectedOutput: '4'),
        TestCase(input: sample2Input, expectedOutput: '0'),
      ],
      hiddenTestCases: [
        TestCase(input: '[1, 1, 1, 1, 1, 1]\n${k * 10}', expectedOutput: '6', isHidden: true),
        TestCase(input: '[5, 5, 5, 5]\n${k * 5}', expectedOutput: '${(k).clamp(0, 4)}', isHidden: true),
        TestCase(input: '[0, 0, 0, 0, 0]\n10', expectedOutput: '5', isHidden: true),
      ],
      starterCode: {
        'Python': 'def max_subarray_len(nums: list[int], threshold: int) -> int:\n    # Type your solution manually below\n    \n',
        'JavaScript': 'function maxSubarrayLen(nums, threshold) {\n    // Type your solution manually below\n    \n}',
        'Java': 'class Solution {\n    public int maxSubarrayLen(int[] nums, int threshold) {\n        // Type your solution manually below\n        return 0;\n    }\n}',
        'C++': 'class Solution {\npublic:\n    int maxSubarrayLen(vector<int>& nums, int threshold) {\n        // Type your solution manually below\n        return 0;\n    }\n};',
      },
      hints: [
        'Because all numbers are non-negative, you can use the two-pointer sliding window technique.',
        'Expand right pointer, and shrink left pointer whenever current_sum exceeds threshold.',
      ],
      sourceMetadata: 'Code to Unlock Master Bank • Level $level',
    );
  }

  static QuestionModel _buildStringVariation(
      int level, String id, String canonicalId, int rating, String band, String topic) {
    final title = 'Level $level: Lexicographically Smallest Equivalent Substring';
    final description =
        'Given a string `s` consisting of lowercase English letters, remove characters such that no letter appears more than twice, while preserving the original relative order and maximizing the length.\n\nReturn the resulting string.';

    return QuestionModel(
      id: id,
      canonicalProblemId: canonicalId,
      title: title,
      description: description,
      difficultyRating: rating,
      difficultyBand: band,
      topic: topic,
      inputDescription: 'A single string s',
      outputDescription: 'Resulting filtered string',
      constraints: ['1 <= s.length <= 10^5', 's consists of lowercase English letters'],
      examples: [
        TestCaseExample(input: 's = "aaabbbccc"', output: '"aabbcc"', explanation: 'Each letter kept at most twice.'),
      ],
      sampleTestCases: [
        TestCase(input: 'aaabbbccc', expectedOutput: 'aabbcc'),
        TestCase(input: 'abcd', expectedOutput: 'abcd'),
      ],
      hiddenTestCases: [
        TestCase(input: 'aaaaa', expectedOutput: 'aa', isHidden: true),
        TestCase(input: 'abacaba', expectedOutput: 'abacab', isHidden: true),
        TestCase(input: 'zzzzzz', expectedOutput: 'zz', isHidden: true),
      ],
      starterCode: {
        'Python': 'def filter_string(s: str) -> str:\n    # Type your solution manually below\n    \n',
        'JavaScript': 'function filterString(s) {\n    // Type your solution manually below\n    \n}',
        'Java': 'class Solution {\n    public String filterString(String s) {\n        // Type your solution manually below\n        return "";\n    }\n}',
        'C++': 'class Solution {\npublic:\n    string filterString(string s) {\n        // Type your solution manually below\n        return "";\n    }\n};',
      },
      hints: ['Use an array of size 26 or a hash map to keep track of character frequencies.'],
      sourceMetadata: 'Code to Unlock Master Bank • Level $level',
    );
  }

  static QuestionModel _buildDpVariation(
      int level, String id, String canonicalId, int rating, String band, String topic) {
    final title = 'Level $level: Minimum Path Energy (Dynamic Programming)';
    final description =
        'Given a sequence of energy stations represented as array `cost` where `cost[i]` is the cost to pass station `i`.\n\nYou start at index 0 and can jump either 1 or 2 steps forward. Find the minimum total cost to reach the end of the array (at or beyond index `n - 1`).';

    return QuestionModel(
      id: id,
      canonicalProblemId: canonicalId,
      title: title,
      description: description,
      difficultyRating: rating,
      difficultyBand: band,
      topic: topic,
      inputDescription: 'Array of integers `cost`',
      outputDescription: 'Integer minimum total cost',
      constraints: ['2 <= cost.length <= 1000', '0 <= cost[i] <= 999'],
      examples: [
        TestCaseExample(input: 'cost = [10, 15, 20]', output: '15', explanation: 'Start at index 1 (cost 15), jump 2 steps to end.'),
      ],
      sampleTestCases: [
        TestCase(input: '[10, 15, 20]', expectedOutput: '15'),
        TestCase(input: '[1, 100, 1, 1, 1, 100, 1, 1, 100, 1]', expectedOutput: '6'),
      ],
      hiddenTestCases: [
        TestCase(input: '[0, 0, 0, 0]', expectedOutput: '0', isHidden: true),
        TestCase(input: '[5, 10]', expectedOutput: '5', isHidden: true),
        TestCase(input: '[2, 5, 1, 8, 3, 4]', expectedOutput: '7', isHidden: true),
      ],
      starterCode: {
        'Python': 'def min_cost_energy(cost: list[int]) -> int:\n    # Type your solution manually below\n    \n',
        'JavaScript': 'function minCostEnergy(cost) {\n    // Type your solution manually below\n    \n}',
        'Java': 'class Solution {\n    public int minCostEnergy(int[] cost) {\n        // Type your solution manually below\n        return 0;\n    }\n}',
        'C++': 'class Solution {\npublic:\n    int minCostEnergy(vector<int>& cost) {\n        // Type your solution manually below\n        return 0;\n    }\n};',
      },
      hints: ['Define dp[i] as the minimum cost to arrive at step i.'],
      sourceMetadata: 'Code to Unlock Master Bank • Level $level',
    );
  }

  static QuestionModel _buildStackVariation(
      int level, String id, String canonicalId, int rating, String band, String topic) {
    final title = 'Level $level: Next Warmer Station (Monotonic Stack)';
    final description =
        'Given an array of integer temperatures `temperatures`, return an array `answer` such that `answer[i]` is the number of days you have to wait after the `i-th` day to get a warmer temperature. If there is no future day for which this is possible, keep `answer[i] == 0` instead.';

    return QuestionModel(
      id: id,
      canonicalProblemId: canonicalId,
      title: title,
      description: description,
      difficultyRating: rating,
      difficultyBand: band,
      topic: topic,
      inputDescription: 'Array of integer temperatures',
      outputDescription: 'Array of days to wait',
      constraints: ['1 <= temperatures.length <= 10^5', '30 <= temperatures[i] <= 100'],
      examples: [
        TestCaseExample(input: 'temperatures = [73, 74, 75, 71, 69, 72, 76, 73]', output: '[1, 1, 4, 2, 1, 1, 0, 0]'),
      ],
      sampleTestCases: [
        TestCase(input: '[73, 74, 75, 71, 69, 72, 76, 73]', expectedOutput: '[1, 1, 4, 2, 1, 1, 0, 0]'),
        TestCase(input: '[30, 40, 50, 60]', expectedOutput: '[1, 1, 1, 0]'),
      ],
      hiddenTestCases: [
        TestCase(input: '[30, 60, 90]', expectedOutput: '[1, 1, 0]', isHidden: true),
        TestCase(input: '[90, 80, 70]', expectedOutput: '[0, 0, 0]', isHidden: true),
      ],
      starterCode: {
        'Python': 'def daily_temperatures(temperatures: list[int]) -> list[int]:\n    # Type your solution manually below\n    \n',
        'JavaScript': 'function dailyTemperatures(temperatures) {\n    // Type your solution manually below\n    \n}',
        'Java': 'class Solution {\n    public int[] dailyTemperatures(int[] temperatures) {\n        // Type your solution manually below\n        return new int[0];\n    }\n}',
        'C++': 'class Solution {\npublic:\n    vector<int> dailyTemperatures(vector<int>& temperatures) {\n        // Type your solution manually below\n        return {};\n    }\n};',
      },
      hints: ['A monotonic decreasing stack keeps track of indices of unsettled temperatures.'],
      sourceMetadata: 'Code to Unlock Master Bank • Level $level',
    );
  }

  static QuestionModel _buildSearchVariation(
      int level, String id, String canonicalId, int rating, String band, String topic) {
    final title = 'Level $level: Peak Element In Terraced Terrain';
    final description =
        'A peak element is an element that is strictly greater than its neighbors.\n\nGiven a 0-indexed integer array `nums`, find a peak element, and return its index. If the array contains multiple peaks, return the index to any of the peaks.\n\nYou must write an algorithm that runs in O(log n) time.';

    return QuestionModel(
      id: id,
      canonicalProblemId: canonicalId,
      title: title,
      description: description,
      difficultyRating: rating,
      difficultyBand: band,
      topic: topic,
      inputDescription: 'Integer array nums',
      outputDescription: 'Index of any peak element',
      constraints: ['1 <= nums.length <= 1000', '-2^31 <= nums[i] <= 2^31 - 1', 'nums[i] != nums[i + 1] for all valid i'],
      examples: [
        TestCaseExample(input: 'nums = [1,2,3,1]', output: '2', explanation: '3 is a peak element and your function should return the index number 2.'),
      ],
      sampleTestCases: [
        TestCase(input: '[1, 2, 3, 1]', expectedOutput: '2'),
        TestCase(input: '[1, 2, 1, 3, 5, 6, 4]', expectedOutput: '5'),
      ],
      hiddenTestCases: [
        TestCase(input: '[1]', expectedOutput: '0', isHidden: true),
        TestCase(input: '[1, 2]', expectedOutput: '1', isHidden: true),
        TestCase(input: '[2, 1]', expectedOutput: '0', isHidden: true),
      ],
      starterCode: {
        'Python': 'def find_peak_element(nums: list[int]) -> int:\n    # Type your solution manually below\n    \n',
        'JavaScript': 'function findPeakElement(nums) {\n    // Type your solution manually below\n    \n}',
        'Java': 'class Solution {\n    public int findPeakElement(int[] nums) {\n        // Type your solution manually below\n        return 0;\n    }\n}',
        'C++': 'class Solution {\npublic:\n    int findPeakElement(vector<int>& nums) {\n        // Type your solution manually below\n        return 0;\n    }\n};',
      },
      hints: ['If nums[mid] > nums[mid + 1], a peak must exist to the left (including mid).'],
      sourceMetadata: 'Code to Unlock Master Bank • Level $level',
    );
  }

  static QuestionModel _buildTreeVariation(
      int level, String id, String canonicalId, int rating, String band, String topic) {
    final title = 'Level $level: Maximum Path Diameter in Tree Graph';
    final description =
        'Given a tree structure represented as an array of node values in level-order, return the maximum depth (length of longest path from root down to furthest leaf node).';

    return QuestionModel(
      id: id,
      canonicalProblemId: canonicalId,
      title: title,
      description: description,
      difficultyRating: rating,
      difficultyBand: band,
      topic: topic,
      inputDescription: 'Level order array representation of tree',
      outputDescription: 'Integer maximum depth',
      constraints: ['The number of nodes in the tree is in the range [0, 10^4]'],
      examples: [
        TestCaseExample(input: 'root = [3, 9, 20, null, null, 15, 7]', output: '3'),
      ],
      sampleTestCases: [
        TestCase(input: '[3, 9, 20, null, null, 15, 7]', expectedOutput: '3'),
        TestCase(input: '[1, null, 2]', expectedOutput: '2'),
      ],
      hiddenTestCases: [
        TestCase(input: '[]', expectedOutput: '0', isHidden: true),
        TestCase(input: '[0]', expectedOutput: '1', isHidden: true),
      ],
      starterCode: {
        'Python': 'def max_depth(tree_list: list) -> int:\n    # Type your solution manually below\n    \n',
        'JavaScript': 'function maxDepth(treeList) {\n    // Type your solution manually below\n    \n}',
        'Java': 'class Solution {\n    public int maxDepth(List<Object> treeList) {\n        // Type your solution manually below\n        return 0;\n    }\n}',
        'C++': 'class Solution {\npublic:\n    int maxDepth(vector<int>& treeList) {\n        // Type your solution manually below\n        return 0;\n    }\n};',
      },
      hints: ['The depth corresponds to log2 of the level-order capacity.'],
      sourceMetadata: 'Code to Unlock Master Bank • Level $level',
    );
  }

  static QuestionModel _buildGraphOrGeneralVariation(
      int level, String id, String canonicalId, int rating, String band, String topic) {
    final title = 'Level $level: Island Network Clusters ($topic)';
    final description =
        'Given an `m x n` 2D binary grid which represents a map of `\'1\'`s (land) and `\'0\'`s (water), return the number of islands.\n\nAn island is surrounded by water and is formed by connecting adjacent lands horizontally or vertically.';

    return QuestionModel(
      id: id,
      canonicalProblemId: canonicalId,
      title: title,
      description: description,
      difficultyRating: rating,
      difficultyBand: band,
      topic: topic,
      inputDescription: '2D array grid of characters',
      outputDescription: 'Integer number of islands',
      constraints: ['1 <= m, n <= 300', 'grid[i][j] is \'0\' or \'1\''],
      examples: [
        TestCaseExample(
          input: 'grid = [["1","1","0"],["1","1","0"],["0","0","1"]]',
          output: '2',
        ),
      ],
      sampleTestCases: [
        TestCase(input: '[["1","1","0"],["1","1","0"],["0","0","1"]]', expectedOutput: '2'),
        TestCase(input: '[["1","1","1"],["0","1","0"],["1","1","1"]]', expectedOutput: '1'),
      ],
      hiddenTestCases: [
        TestCase(input: '[["0","0"],["0","0"]]', expectedOutput: '0', isHidden: true),
        TestCase(input: '[["1","0","1"],["0","1","0"],["1","0","1"]]', expectedOutput: '5', isHidden: true),
      ],
      starterCode: {
        'Python': 'def num_islands(grid: list[list[str]]) -> int:\n    # Type your solution manually below (DFS / BFS)\n    \n',
        'JavaScript': 'function numIslands(grid) {\n    // Type your solution manually below\n    \n}',
        'Java': 'class Solution {\n    public int numIslands(char[][] grid) {\n        // Type your solution manually below\n        return 0;\n    }\n}',
        'C++': 'class Solution {\npublic:\n    int numIslands(vector<vector<char>>& grid) {\n        // Type your solution manually below\n        return 0;\n    }\n};',
      },
      hints: ['Whenever you find a "1", trigger a DFS traversal to sink all connected land.'],
      sourceMetadata: 'Code to Unlock Master Bank • Level $level',
    );
  }
}

