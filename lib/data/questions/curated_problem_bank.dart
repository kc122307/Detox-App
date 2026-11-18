import '../models/question_model.dart';

class CuratedProblemBank {
  static List<QuestionModel> getCuratedProblems() {
    return [
      // 1. Two Sum (Arrays / Hash Map)
      QuestionModel(
        id: 'curated_001_two_sum',
        canonicalProblemId: 'canonical_two_sum_indices',
        title: 'Two Sum',
        description:
            'Given an array of integers `nums` and an integer `target`, return indices of the two numbers such that they add up to `target`.\n\nYou may assume that each input would have exactly one solution, and you may not use the same element twice. You can return the answer in any order.',
        difficultyRating: 2,
        difficultyBand: 'Beginner',
        topic: 'Arrays',
        inputDescription: 'An integer array nums and an integer target',
        outputDescription: 'A list of two integer indices [index1, index2]',
        constraints: [
          '2 <= nums.length <= 10^4',
          '-10^9 <= nums[i] <= 10^9',
          '-10^9 <= target <= 10^9',
          'Only one valid answer exists.',
        ],
        examples: [
          TestCaseExample(
            input: 'nums = [2,7,11,15], target = 9',
            output: '[0,1]',
            explanation: 'Because nums[0] + nums[1] == 9, we return [0, 1].',
          ),
          TestCaseExample(
            input: 'nums = [3,2,4], target = 6',
            output: '[1,2]',
            explanation: 'nums[1] + nums[2] == 2 + 4 == 6, so indices [1, 2].',
          ),
        ],
        sampleTestCases: [
          TestCase(input: '[2, 7, 11, 15]\n9', expectedOutput: '[0, 1]'),
          TestCase(input: '[3, 2, 4]\n6', expectedOutput: '[1, 2]'),
        ],
        hiddenTestCases: [
          TestCase(input: '[3, 3]\n6', expectedOutput: '[0, 1]', isHidden: true),
          TestCase(input: '[-1, -2, -3, -4, -5]\n-8', expectedOutput: '[2, 4]', isHidden: true),
          TestCase(input: '[0, 4, 3, 0]\n0', expectedOutput: '[0, 3]', isHidden: true),
        ],
        starterCode: {
          'Python': 'def two_sum(nums: list[int], target: int) -> list[int]:\n    # Type your solution manually below\n    \n',
          'JavaScript': 'function twoSum(nums, target) {\n    // Type your solution manually below\n    \n}',
          'Java': 'class Solution {\n    public int[] twoSum(int[] nums, int target) {\n        // Type your solution manually below\n        return new int[0];\n    }\n}',
          'C++': 'class Solution {\npublic:\n    vector<int> twoSum(vector<int>& nums, int target) {\n        // Type your solution manually below\n        return {};\n    }\n};',
        },
        hints: ['Use a hash table to check if the complement has been seen before.'],
        sourceMetadata: 'LeetCode 1 • Top Interview 150',
      ),

      // 2. Valid Palindrome
      QuestionModel(
        id: 'curated_002_valid_palindrome',
        canonicalProblemId: 'canonical_valid_palindrome_two_pointer',
        title: 'Valid Palindrome',
        description:
            'A phrase is a palindrome if, after converting all uppercase letters into lowercase letters and removing all non-alphanumeric characters, it reads the same forward and backward.\n\nGiven a string `s`, return `true` if it is a palindrome, or `false` otherwise.',
        difficultyRating: 2,
        difficultyBand: 'Beginner',
        topic: 'Strings',
        inputDescription: 'A single string s',
        outputDescription: 'Boolean true or false',
        constraints: ['1 <= s.length <= 2 * 10^5', 's consists of printable ASCII characters.'],
        examples: [
          TestCaseExample(input: 's = "A man, a plan, a canal: Panama"', output: 'true'),
          TestCaseExample(input: 's = "race a car"', output: 'false'),
        ],
        sampleTestCases: [
          TestCase(input: 'A man, a plan, a canal: Panama', expectedOutput: 'true'),
          TestCase(input: 'race a car', expectedOutput: 'false'),
        ],
        hiddenTestCases: [
          TestCase(input: ' ', expectedOutput: 'true', isHidden: true),
          TestCase(input: '0P', expectedOutput: 'false', isHidden: true),
        ],
        starterCode: {
          'Python': 'def is_palindrome(s: str) -> bool:\n    # Type your solution manually below\n    \n',
          'JavaScript': 'function isPalindrome(s) {\n    // Type your solution manually below\n    \n}',
          'Java': 'class Solution {\n    public boolean isPalindrome(String s) {\n        // Type your solution manually below\n        return false;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    bool isPalindrome(string s) {\n        // Type your solution manually below\n        return false;\n    }\n};',
        },
        hints: ['Consider two pointers moving inward from both ends.'],
        sourceMetadata: 'LeetCode 125 • Top Interview 150',
      ),

      // 3. Product of Array Except Self
      QuestionModel(
        id: 'curated_003_product_except_self',
        canonicalProblemId: 'canonical_product_array_except_self',
        title: 'Product of Array Except Self',
        description:
            'Given an integer array `nums`, return an array `answer` such that `answer[i]` is equal to the product of all the elements of `nums` except `nums[i]`.\n\nYou must write an algorithm that runs in O(n) time and without using the division operation.',
        difficultyRating: 5,
        difficultyBand: 'Intermediate',
        topic: 'Arrays',
        inputDescription: 'Integer array nums',
        outputDescription: 'Integer array answer',
        constraints: ['2 <= nums.length <= 10^5', '-30 <= nums[i] <= 30'],
        examples: [
          TestCaseExample(input: 'nums = [1,2,3,4]', output: '[24,12,8,6]'),
          TestCaseExample(input: 'nums = [-1,1,0,-3,3]', output: '[0,0,9,0,0]'),
        ],
        sampleTestCases: [
          TestCase(input: '[1, 2, 3, 4]', expectedOutput: '[24, 12, 8, 6]'),
          TestCase(input: '[-1, 1, 0, -3, 3]', expectedOutput: '[0, 0, 9, 0, 0]'),
        ],
        hiddenTestCases: [
          TestCase(input: '[2, 3]', expectedOutput: '[3, 2]', isHidden: true),
          TestCase(input: '[1, 1, 1, 1]', expectedOutput: '[1, 1, 1, 1]', isHidden: true),
        ],
        starterCode: {
          'Python': 'def product_except_self(nums: list[int]) -> list[int]:\n    # Type your solution manually below\n    \n',
          'JavaScript': 'function productExceptSelf(nums) {\n    // Type your solution manually below\n    \n}',
          'Java': 'class Solution {\n    public int[] productExceptSelf(int[] nums) {\n        // Type your solution manually below\n        return new int[0];\n    }\n}',
          'C++': 'class Solution {\npublic:\n    vector<int> productExceptSelf(vector<int>& nums) {\n        // Type your solution manually below\n        return {};\n    }\n};',
        },
        hints: ['Calculate prefix products from left to right, then postfix products from right to left.'],
        sourceMetadata: 'LeetCode 238 • Blind 75',
      ),

      // 4. Valid Anagram
      QuestionModel(
        id: 'curated_004_valid_anagram',
        canonicalProblemId: 'canonical_valid_anagram_frequency',
        title: 'Valid Anagram',
        description:
            'Given two strings `s` and `t`, return `true` if `t` is an anagram of `s`, and `false` otherwise.\n\nAn Anagram is a word or phrase formed by rearranging the letters of a different word or phrase, typically using all the original letters exactly once.',
        difficultyRating: 2,
        difficultyBand: 'Beginner',
        topic: 'Strings',
        inputDescription: 'Two strings s and t',
        outputDescription: 'Boolean true or false',
        constraints: ['1 <= s.length, t.length <= 5 * 10^4', 's and t consist of lowercase English letters.'],
        examples: [
          TestCaseExample(input: 's = "anagram", t = "nagaram"', output: 'true'),
          TestCaseExample(input: 's = "rat", t = "car"', output: 'false'),
        ],
        sampleTestCases: [
          TestCase(input: 'anagram\nnagaram', expectedOutput: 'true'),
          TestCase(input: 'rat\ncar', expectedOutput: 'false'),
        ],
        hiddenTestCases: [
          TestCase(input: 'a\nab', expectedOutput: 'false', isHidden: true),
          TestCase(input: 'listen\nsilent', expectedOutput: 'true', isHidden: true),
        ],
        starterCode: {
          'Python': 'def is_anagram(s: str, t: str) -> bool:\n    # Type your solution manually below\n    \n',
          'JavaScript': 'function isAnagram(s, t) {\n    // Type your solution manually below\n    \n}',
          'Java': 'class Solution {\n    public boolean isAnagram(String s, String t) {\n        // Type your solution manually below\n        return false;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    bool isAnagram(string s, string t) {\n        // Type your solution manually below\n        return false;\n    }\n};',
        },
        hints: ['Use a frequency count array of size 26 or sort both strings.'],
        sourceMetadata: 'LeetCode 242 • Blind 75',
      ),

      // 5. Majority Element (Boyer-Moore Voting)
      QuestionModel(
        id: 'curated_005_majority_element',
        canonicalProblemId: 'canonical_boyer_moore_majority_element',
        title: 'Majority Element',
        description:
            'Given an array `nums` of size `n`, return the majority element.\n\nThe majority element is the element that appears more than `⌊n / 2⌋` times. You may assume that the majority element always exists in the array.',
        difficultyRating: 3,
        difficultyBand: 'Beginner',
        topic: 'Arrays',
        inputDescription: 'Integer array nums',
        outputDescription: 'Integer majority element',
        constraints: ['n == nums.length', '1 <= n <= 5 * 10^4', '-10^9 <= nums[i] <= 10^9'],
        examples: [
          TestCaseExample(input: 'nums = [3,2,3]', output: '3'),
          TestCaseExample(input: 'nums = [2,2,1,1,1,2,2]', output: '2'),
        ],
        sampleTestCases: [
          TestCase(input: '[3, 2, 3]', expectedOutput: '3'),
          TestCase(input: '[2, 2, 1, 1, 1, 2, 2]', expectedOutput: '2'),
        ],
        hiddenTestCases: [
          TestCase(input: '[1]', expectedOutput: '1', isHidden: true),
          TestCase(input: '[6, 5, 5]', expectedOutput: '5', isHidden: true),
        ],
        starterCode: {
          'Python': 'def majority_element(nums: list[int]) -> int:\n    # Type your solution manually below\n    \n',
          'JavaScript': 'function majorityElement(nums) {\n    // Type your solution manually below\n    \n}',
          'Java': 'class Solution {\n    public int majorityElement(int[] nums) {\n        // Type your solution manually below\n        return 0;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int majorityElement(vector<int>& nums) {\n        // Type your solution manually below\n        return 0;\n    }\n};',
        },
        hints: ['Boyer-Moore Voting Algorithm solves this in O(n) time and O(1) space.'],
        sourceMetadata: 'LeetCode 169 • Top Interview 150',
      ),

      // 6. Search in Rotated Sorted Array
      QuestionModel(
        id: 'curated_006_search_rotated_array',
        canonicalProblemId: 'canonical_binary_search_rotated_sorted',
        title: 'Search in Rotated Sorted Array',
        description:
            'There is an integer array `nums` sorted in ascending order (with distinct values).\n\nPrior to being passed to your function, `nums` is possibly rotated at an unknown pivot index.\n\nGiven the array `nums` after the possible rotation and an integer `target`, return the index of `target` if it is in `nums`, or -1 if it is not in `nums`.\n\nYou must write an algorithm with O(log n) runtime complexity.',
        difficultyRating: 6,
        difficultyBand: 'Intermediate',
        topic: 'Searching and Sorting',
        inputDescription: 'Array nums and target integer',
        outputDescription: 'Integer index or -1',
        constraints: ['1 <= nums.length <= 5000', '-10^4 <= nums[i], target <= 10^4', 'All values in nums are unique.'],
        examples: [
          TestCaseExample(input: 'nums = [4,5,6,7,0,1,2], target = 0', output: '4'),
          TestCaseExample(input: 'nums = [4,5,6,7,0,1,2], target = 3', output: '-1'),
        ],
        sampleTestCases: [
          TestCase(input: '[4, 5, 6, 7, 0, 1, 2]\n0', expectedOutput: '4'),
          TestCase(input: '[4, 5, 6, 7, 0, 1, 2]\n3', expectedOutput: '-1'),
        ],
        hiddenTestCases: [
          TestCase(input: '[1]\n0', expectedOutput: '-1', isHidden: true),
          TestCase(input: '[1, 3]\n3', expectedOutput: '1', isHidden: true),
        ],
        starterCode: {
          'Python': 'def search_rotated(nums: list[int], target: int) -> int:\n    # Type your solution manually below\n    \n',
          'JavaScript': 'function searchRotated(nums, target) {\n    // Type your solution manually below\n    \n}',
          'Java': 'class Solution {\n    public int search(int[] nums, int target) {\n        // Type your solution manually below\n        return -1;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int search(vector<int>& nums, int target) {\n        // Type your solution manually below\n        return -1;\n    }\n};',
        },
        hints: ['Notice that one half of the array is always sorted.'],
        sourceMetadata: 'LeetCode 33 • Blind 75',
      ),

      // 7. House Robber (Dynamic Programming)
      QuestionModel(
        id: 'curated_007_house_robber',
        canonicalProblemId: 'canonical_house_robber_dp',
        title: 'House Robber',
        description:
            'You are a professional robber planning to rob houses along a street. Each house has a certain amount of money stashed, the only constraint stopping you from robbing each of them is that adjacent houses have security systems connected and it will automatically contact the police if two adjacent houses were broken into on the same night.\n\nGiven an integer array `nums` representing the amount of money of each house, return the maximum amount of money you can rob tonight without alerting the police.',
        difficultyRating: 4,
        difficultyBand: 'Intermediate',
        topic: 'Dynamic Programming',
        inputDescription: 'Integer array nums',
        outputDescription: 'Integer maximum robbed money',
        constraints: ['1 <= nums.length <= 100', '0 <= nums[i] <= 400'],
        examples: [
          TestCaseExample(input: 'nums = [1,2,3,1]', output: '4', explanation: 'Rob house 1 (money = 1) and house 3 (money = 3), total = 4.'),
          TestCaseExample(input: 'nums = [2,7,9,3,1]', output: '12', explanation: 'Rob house 1 (2), house 3 (9) and house 5 (1), total = 12.'),
        ],
        sampleTestCases: [
          TestCase(input: '[1, 2, 3, 1]', expectedOutput: '4'),
          TestCase(input: '[2, 7, 9, 3, 1]', expectedOutput: '12'),
        ],
        hiddenTestCases: [
          TestCase(input: '[0]', expectedOutput: '0', isHidden: true),
          TestCase(input: '[2, 1, 1, 2]', expectedOutput: '4', isHidden: true),
        ],
        starterCode: {
          'Python': 'def rob(nums: list[int]) -> int:\n    # Type your solution manually below\n    \n',
          'JavaScript': 'function rob(nums) {\n    // Type your solution manually below\n    \n}',
          'Java': 'class Solution {\n    public int rob(int[] nums) {\n        // Type your solution manually below\n        return 0;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int rob(vector<int>& nums) {\n        // Type your solution manually below\n        return 0;\n    }\n};',
        },
        hints: ['For each house, you decide whether to rob it (and skip the previous) or skip it.'],
        sourceMetadata: 'LeetCode 198 • Blind 75',
      ),

      // 8. Coin Change (Dynamic Programming)
      QuestionModel(
        id: 'curated_008_coin_change',
        canonicalProblemId: 'canonical_coin_change_unbounded_knapsack',
        title: 'Coin Change',
        description:
            'You are given an integer array `coins` representing coins of different denominations and an integer `amount` representing a total amount of money.\n\nReturn the fewest number of coins that you need to make up that amount. If that amount of money cannot be made up by any combination of the coins, return -1.\n\nYou may assume that you have an infinite number of each kind of coin.',
        difficultyRating: 5,
        difficultyBand: 'Intermediate',
        topic: 'Dynamic Programming',
        inputDescription: 'Integer array coins and integer amount',
        outputDescription: 'Integer minimum coins or -1',
        constraints: ['1 <= coins.length <= 12', '1 <= coins[i] <= 2^31 - 1', '0 <= amount <= 10^4'],
        examples: [
          TestCaseExample(input: 'coins = [1,2,5], amount = 11', output: '3', explanation: '11 = 5 + 5 + 1'),
          TestCaseExample(input: 'coins = [2], amount = 3', output: '-1'),
          TestCaseExample(input: 'coins = [1], amount = 0', output: '0'),
        ],
        sampleTestCases: [
          TestCase(input: '[1, 2, 5]\n11', expectedOutput: '3'),
          TestCase(input: '[2]\n3', expectedOutput: '-1'),
        ],
        hiddenTestCases: [
          TestCase(input: '[1]\n0', expectedOutput: '0', isHidden: true),
          TestCase(input: '[1, 3, 4]\n6', expectedOutput: '2', isHidden: true),
        ],
        starterCode: {
          'Python': 'def coin_change(coins: list[int], amount: int) -> int:\n    # Type your solution manually below\n    \n',
          'JavaScript': 'function coinChange(coins, amount) {\n    // Type your solution manually below\n    \n}',
          'Java': 'class Solution {\n    public int coinChange(int[] coins, int amount) {\n        // Type your solution manually below\n        return -1;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int coinChange(vector<int>& coins, int amount) {\n        // Type your solution manually below\n        return -1;\n    }\n};',
        },
        hints: ['Build an array dp[0..amount] where dp[i] is the minimum coins to make amount i.'],
        sourceMetadata: 'LeetCode 322 • Blind 75',
      ),

      // 9. Subsets (Backtracking)
      QuestionModel(
        id: 'curated_009_subsets',
        canonicalProblemId: 'canonical_subsets_power_set',
        title: 'Subsets',
        description:
            'Given an integer array `nums` of unique elements, return all possible subsets (the power set).\n\nThe solution set must not contain duplicate subsets. Return the solution in any order.',
        difficultyRating: 4,
        difficultyBand: 'Intermediate',
        topic: 'Backtracking',
        inputDescription: 'Integer array nums',
        outputDescription: 'List of subsets',
        constraints: ['1 <= nums.length <= 10', '-10 <= nums[i] <= 10', 'All numbers of nums are unique.'],
        examples: [
          TestCaseExample(input: 'nums = [1,2,3]', output: '[[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]'),
          TestCaseExample(input: 'nums = [0]', output: '[[],[0]]'),
        ],
        sampleTestCases: [
          TestCase(input: '[1, 2, 3]', expectedOutput: '[[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3]]'),
          TestCase(input: '[0]', expectedOutput: '[[], [0]]'),
        ],
        hiddenTestCases: [
          TestCase(input: '[1, 2]', expectedOutput: '[[], [1], [2], [1, 2]]', isHidden: true),
        ],
        starterCode: {
          'Python': 'def subsets(nums: list[int]) -> list[list[int]]:\n    # Type your solution manually below\n    \n',
          'JavaScript': 'function subsets(nums) {\n    // Type your solution manually below\n    \n}',
          'Java': 'class Solution {\n    public List<List<Integer>> subsets(int[] nums) {\n        // Type your solution manually below\n        return new ArrayList<>();\n    }\n}',
          'C++': 'class Solution {\npublic:\n    vector<vector<int>> subsets(vector<int>& nums) {\n        // Type your solution manually below\n        return {};\n    }\n};',
        },
        hints: ['Use recursive backtracking: at each index, you either include or exclude nums[i].'],
        sourceMetadata: 'LeetCode 78 • Blind 75',
      ),

      // 10. Invert Binary Tree
      QuestionModel(
        id: 'curated_010_invert_binary_tree',
        canonicalProblemId: 'canonical_invert_binary_tree_mirror',
        title: 'Invert Binary Tree',
        description:
            'Given the root of a binary tree represented as an array in level-order, invert the tree, and return its level-order representation.',
        difficultyRating: 2,
        difficultyBand: 'Beginner',
        topic: 'Trees and Binary Search Trees',
        inputDescription: 'Level order array of tree',
        outputDescription: 'Inverted level order array of tree',
        constraints: ['The number of nodes in the tree is in the range [0, 100].'],
        examples: [
          TestCaseExample(input: 'root = [4,2,7,1,3,6,9]', output: '[4,7,2,9,6,3,1]'),
          TestCaseExample(input: 'root = [2,1,3]', output: '[2,3,1]'),
          TestCaseExample(input: 'root = []', output: '[]'),
        ],
        sampleTestCases: [
          TestCase(input: '[4, 2, 7, 1, 3, 6, 9]', expectedOutput: '[4, 7, 2, 9, 6, 3, 1]'),
          TestCase(input: '[2, 1, 3]', expectedOutput: '[2, 3, 1]'),
        ],
        hiddenTestCases: [
          TestCase(input: '[]', expectedOutput: '[]', isHidden: true),
        ],
        starterCode: {
          'Python': 'def invert_tree(root: list) -> list:\n    # Type your solution manually below\n    \n',
          'JavaScript': 'function invertTree(root) {\n    // Type your solution manually below\n    \n}',
          'Java': 'class Solution {\n    public List<Object> invertTree(List<Object> root) {\n        // Type your solution manually below\n        return new ArrayList<>();\n    }\n}',
          'C++': 'class Solution {\npublic:\n    vector<int> invertTree(vector<int>& root) {\n        // Type your solution manually below\n        return {};\n    }\n};',
        },
        hints: ['Swap left and right children recursively.'],
        sourceMetadata: 'LeetCode 226 • Top Interview 150',
      ),
    ];
  }
}
