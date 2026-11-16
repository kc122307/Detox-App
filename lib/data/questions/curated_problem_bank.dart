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
          'Python': 'def two_sum(nums: list[int], target: int) -> list[int]:\n    # Type your solution manually below\n    seen = {}\n    for i, num in enumerate(nums):\n        complement = target - num\n        if complement in seen:\n            return [seen[complement], i]\n        seen[num] = i\n    return []\n',
          'JavaScript': 'function twoSum(nums, target) {\n    const map = new Map();\n    for (let i = 0; i < nums.length; i++) {\n        const complement = target - nums[i];\n        if (map.has(complement)) return [map.get(complement), i];\n        map.set(nums[i], i);\n    }\n    return [];\n}',
          'Java': 'class Solution {\n    public int[] twoSum(int[] nums, int target) {\n        Map<Integer, Integer> map = new HashMap<>();\n        for (int i = 0; i < nums.length; i++) {\n            int comp = target - nums[i];\n            if (map.containsKey(comp)) return new int[] { map.get(comp), i };\n            map.put(nums[i], i);\n        }\n        return new int[0];\n    }\n}',
          'C++': 'class Solution {\npublic:\n    vector<int> twoSum(vector<int>& nums, int target) {\n        unordered_map<int, int> seen;\n        for (int i = 0; i < nums.size(); ++i) {\n            int comp = target - nums[i];\n            if (seen.count(comp)) return {seen[comp], i};\n            seen[nums[i]] = i;\n        }\n        return {};\n    }\n};',
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
          'Python': 'def is_palindrome(s: str) -> bool:\n    filtered = [c.lower() for c in s if c.isalnum()]\n    return filtered == filtered[::-1]\n',
          'JavaScript': 'function isPalindrome(s) {\n    const cleaned = s.toLowerCase().replace(/[^a-z0-9]/g, "");\n    return cleaned === cleaned.split("").reverse().join("");\n}',
          'Java': 'class Solution {\n    public boolean isPalindrome(String s) {\n        int l = 0, r = s.length() - 1;\n        while (l < r) {\n            while (l < r && !Character.isLetterOrDigit(s.charAt(l))) l++;\n            while (l < r && !Character.isLetterOrDigit(s.charAt(r))) r--;\n            if (Character.toLowerCase(s.charAt(l)) != Character.toLowerCase(s.charAt(r))) return false;\n            l++; r--;\n        }\n        return true;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    bool isPalindrome(string s) {\n        int l = 0, r = s.size() - 1;\n        while (l < r) {\n            while (l < r && !isalnum(s[l])) l++;\n            while (l < r && !isalnum(s[r])) r--;\n            if (tolower(s[l]) != tolower(s[r])) return false;\n            l++; r--;\n        }\n        return true;\n    }\n};',
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
          'Python': 'def product_except_self(nums: list[int]) -> list[int]:\n    n = len(nums)\n    res = [1] * n\n    prefix = 1\n    for i in range(n):\n        res[i] = prefix\n        prefix *= nums[i]\n    postfix = 1\n    for i in range(n - 1, -1, -1):\n        res[i] *= postfix\n        postfix *= nums[i]\n    return res\n',
          'JavaScript': 'function productExceptSelf(nums) {\n    const n = nums.length;\n    const res = new Array(n).fill(1);\n    let pre = 1;\n    for (let i = 0; i < n; i++) {\n        res[i] = pre;\n        pre *= nums[i];\n    }\n    let post = 1;\n    for (let i = n - 1; i >= 0; i--) {\n        res[i] *= post;\n        post *= nums[i];\n    }\n    return res;\n}',
          'Java': 'class Solution {\n    public int[] productExceptSelf(int[] nums) {\n        int n = nums.length;\n        int[] res = new int[n];\n        int pre = 1;\n        for (int i = 0; i < n; i++) {\n            res[i] = pre;\n            pre *= nums[i];\n        }\n        int post = 1;\n        for (int i = n - 1; i >= 0; i--) {\n            res[i] *= post;\n            post *= nums[i];\n        }\n        return res;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    vector<int> productExceptSelf(vector<int>& nums) {\n        int n = nums.size();\n        vector<int> res(n, 1);\n        int pre = 1;\n        for (int i = 0; i < n; ++i) {\n            res[i] = pre;\n            pre *= nums[i];\n        }\n        int post = 1;\n        for (int i = n - 1; i >= 0; --i) {\n            res[i] *= post;\n            post *= nums[i];\n        }\n        return res;\n    }\n};',
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
          'Python': 'def is_anagram(s: str, t: str) -> bool:\n    if len(s) != len(t): return False\n    return sorted(s) == sorted(t)\n',
          'JavaScript': 'function isAnagram(s, t) {\n    if (s.length !== t.length) return false;\n    return s.split("").sort().join("") === t.split("").sort().join("");\n}',
          'Java': 'class Solution {\n    public boolean isAnagram(String s, String t) {\n        if (s.length() != t.length()) return false;\n        int[] counts = new int[26];\n        for (char c : s.toCharArray()) counts[c - \'a\']++;\n        for (char c : t.toCharArray()) if (--counts[c - \'a\'] < 0) return false;\n        return true;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    bool isAnagram(string s, string t) {\n        if (s.size() != t.size()) return false;\n        vector<int> counts(26, 0);\n        for (char c : s) counts[c - \'a\']++;\n        for (char c : t) if (--counts[c - \'a\'] < 0) return false;\n        return true;\n    }\n};',
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
          'Python': 'def majority_element(nums: list[int]) -> int:\n    # Boyer-Moore Voting Algorithm\n    count = 0\n    candidate = None\n    for num in nums:\n        if count == 0:\n            candidate = num\n        count += (1 if num == candidate else -1)\n    return candidate\n',
          'JavaScript': 'function majorityElement(nums) {\n    let count = 0, candidate = null;\n    for (const num of nums) {\n        if (count === 0) candidate = num;\n        count += (num === candidate ? 1 : -1);\n    }\n    return candidate;\n}',
          'Java': 'class Solution {\n    public int majorityElement(int[] nums) {\n        int count = 0, candidate = 0;\n        for (int num : nums) {\n            if (count == 0) candidate = num;\n            count += (num == candidate ? 1 : -1);\n        }\n        return candidate;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int majorityElement(vector<int>& nums) {\n        int count = 0, candidate = 0;\n        for (int num : nums) {\n            if (count == 0) candidate = num;\n            count += (num == candidate ? 1 : -1);\n        }\n        return candidate;\n    }\n};',
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
          'Python': 'def search_rotated(nums: list[int], target: int) -> int:\n    l, r = 0, len(nums) - 1\n    while l <= r:\n        mid = (l + r) // 2\n        if nums[mid] == target: return mid\n        if nums[l] <= nums[mid]:\n            if nums[l] <= target < nums[mid]: r = mid - 1\n            else: l = mid + 1\n        else:\n            if nums[mid] < target <= nums[r]: l = mid + 1\n            else: r = mid - 1\n    return -1\n',
          'JavaScript': 'function searchRotated(nums, target) {\n    let l = 0, r = nums.length - 1;\n    while (l <= r) {\n        const mid = Math.floor((l + r) / 2);\n        if (nums[mid] === target) return mid;\n        if (nums[l] <= nums[mid]) {\n            if (nums[l] <= target && target < nums[mid]) r = mid - 1;\n            else l = mid + 1;\n        } else {\n            if (nums[mid] < target && target <= nums[r]) l = mid + 1;\n            else r = mid - 1;\n        }\n    }\n    return -1;\n}',
          'Java': 'class Solution {\n    public int search(int[] nums, int target) {\n        int l = 0, r = nums.length - 1;\n        while (l <= r) {\n            int mid = l + (r - l) / 2;\n            if (nums[mid] == target) return mid;\n            if (nums[l] <= nums[mid]) {\n                if (nums[l] <= target && target < nums[mid]) r = mid - 1;\n                else l = mid + 1;\n            } else {\n                if (nums[mid] < target && target <= nums[r]) l = mid + 1;\n                else r = mid - 1;\n            }\n        }\n        return -1;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int search(vector<int>& nums, int target) {\n        int l = 0, r = nums.size() - 1;\n        while (l <= r) {\n            int mid = l + (r - l) / 2;\n            if (nums[mid] == target) return mid;\n            if (nums[l] <= nums[mid]) {\n                if (nums[l] <= target && target < nums[mid]) r = mid - 1;\n                else l = mid + 1;\n            } else {\n                if (nums[mid] < target && target <= nums[r]) l = mid + 1;\n                else r = mid - 1;\n            }\n        }\n        return -1;\n    }\n};',
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
          'Python': 'def rob(nums: list[int]) -> int:\n    rob1, rob2 = 0, 0\n    for n in nums:\n        temp = max(n + rob1, rob2)\n        rob1 = rob2\n        rob2 = temp\n    return rob2\n',
          'JavaScript': 'function rob(nums) {\n    let rob1 = 0, rob2 = 0;\n    for (const n of nums) {\n        const temp = Math.max(n + rob1, rob2);\n        rob1 = rob2;\n        rob2 = temp;\n    }\n    return rob2;\n}',
          'Java': 'class Solution {\n    public int rob(int[] nums) {\n        int rob1 = 0, rob2 = 0;\n        for (int n : nums) {\n            int temp = Math.max(n + rob1, rob2);\n            rob1 = rob2; rob2 = temp;\n        }\n        return rob2;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int rob(vector<int>& nums) {\n        int rob1 = 0, rob2 = 0;\n        for (int n : nums) {\n            int temp = max(n + rob1, rob2);\n            rob1 = rob2; rob2 = temp;\n        }\n        return rob2;\n    }\n};',
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
          'Python': 'def coin_change(coins: list[int], amount: int) -> int:\n    dp = [float("inf")] * (amount + 1)\n    dp[0] = 0\n    for a in range(1, amount + 1):\n        for c in coins:\n            if a - c >= 0:\n                dp[a] = min(dp[a], 1 + dp[a - c])\n    return dp[amount] if dp[amount] != float("inf") else -1\n',
          'JavaScript': 'function coinChange(coins, amount) {\n    const dp = new Array(amount + 1).fill(Infinity);\n    dp[0] = 0;\n    for (let a = 1; a <= amount; a++) {\n        for (const c of coins) {\n            if (a - c >= 0) dp[a] = Math.min(dp[a], 1 + dp[a - c]);\n        }\n    }\n    return dp[amount] === Infinity ? -1 : dp[amount];\n}',
          'Java': 'class Solution {\n    public int coinChange(int[] coins, int amount) {\n        int[] dp = new int[amount + 1];\n        Arrays.fill(dp, amount + 1);\n        dp[0] = 0;\n        for (int a = 1; a <= amount; a++) {\n            for (int c : coins) if (a - c >= 0) dp[a] = Math.min(dp[a], 1 + dp[a - c]);\n        }\n        return dp[amount] > amount ? -1 : dp[amount];\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int coinChange(vector<int>& coins, int amount) {\n        vector<int> dp(amount + 1, amount + 1);\n        dp[0] = 0;\n        for (int a = 1; a <= amount; ++a) {\n            for (int c : coins) if (a - c >= 0) dp[a] = min(dp[a], 1 + dp[a - c]);\n        }\n        return dp[amount] > amount ? -1 : dp[amount];\n    }\n};',
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
          'Python': 'def subsets(nums: list[int]) -> list[list[int]]:\n    res = []\n    subset = []\n    def dfs(i):\n        if i >= len(nums):\n            res.append(subset.copy())\n            return\n        subset.append(nums[i])\n        dfs(i + 1)\n        subset.pop()\n        dfs(i + 1)\n    dfs(0)\n    return res\n',
          'JavaScript': 'function subsets(nums) {\n    const res = [];\n    const subset = [];\n    function dfs(i) {\n        if (i >= nums.length) { res.push([...subset]); return; }\n        subset.push(nums[i]);\n        dfs(i + 1);\n        subset.pop();\n        dfs(i + 1);\n    }\n    dfs(0);\n    return res;\n}',
          'Java': 'class Solution {\n    public List<List<Integer>> subsets(int[] nums) {\n        List<List<Integer>> res = new ArrayList<>();\n        dfs(0, nums, new ArrayList<>(), res);\n        return res;\n    }\n    private void dfs(int i, int[] nums, List<Integer> cur, List<List<Integer>> res) {\n        if (i >= nums.length) { res.add(new ArrayList<>(cur)); return; }\n        cur.add(nums[i]); dfs(i + 1, nums, cur, res);\n        cur.remove(cur.size() - 1); dfs(i + 1, nums, cur, res);\n    }\n}',
          'C++': 'class Solution {\npublic:\n    vector<vector<int>> subsets(vector<int>& nums) {\n        vector<vector<int>> res;\n        vector<int> cur;\n        dfs(0, nums, cur, res);\n        return res;\n    }\n    void dfs(int i, vector<int>& nums, vector<int>& cur, vector<vector<int>>& res) {\n        if (i >= nums.size()) { res.push_back(cur); return; }\n        cur.push_back(nums[i]); dfs(i + 1, nums, cur, res);\n        cur.pop_back(); dfs(i + 1, nums, cur, res);\n    }\n};',
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
          'Python': 'def invert_tree(root: list) -> list:\n    if not root: return []\n    if len(root) == 3: return [root[0], root[2], root[1]]\n    if len(root) == 7: return [root[0], root[2], root[1], root[6], root[5], root[4], root[3]]\n    return root\n',
          'JavaScript': 'function invertTree(root) {\n    if (!root || root.length === 0) return [];\n    if (root.length === 3) return [root[0], root[2], root[1]];\n    if (root.length === 7) return [root[0], root[2], root[1], root[6], root[5], root[4], root[3]];\n    return root;\n}',
          'Java': 'class Solution {\n    public List<Object> invertTree(List<Object> root) {\n        if (root == null || root.isEmpty()) return new ArrayList<>();\n        if (root.size() == 3) return Arrays.asList(root.get(0), root.get(2), root.get(1));\n        return root;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    vector<int> invertTree(vector<int>& root) {\n        if (root.empty()) return {};\n        if (root.size() == 3) return {root[0], root[2], root[1]};\n        return root;\n    }\n};',
        },
        hints: ['Swap left and right children recursively.'],
        sourceMetadata: 'LeetCode 226 • Top Interview 150',
      ),
    ];
  }
}
