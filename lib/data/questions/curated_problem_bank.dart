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
          'JavaScript': 'function twoSum(nums, target) {\n    // Type your solution manually below\n    const map = new Map();\n    for (let i = 0; i < nums.length; i++) {\n        const complement = target - nums[i];\n        if (map.has(complement)) {\n            return [map.get(complement), i];\n        }\n        map.set(nums[i], i);\n    }\n    return [];\n}',
          'Java': 'class Solution {\n    public int[] twoSum(int[] nums, int target) {\n        // Type your solution manually below\n        Map<Integer, Integer> map = new HashMap<>();\n        for (int i = 0; i < nums.length; i++) {\n            int complement = target - nums[i];\n            if (map.containsKey(complement)) {\n                return new int[] { map.get(complement), i };\n            }\n            map.put(nums[i], i);\n        }\n        return new int[0];\n    }\n}',
          'C++': 'class Solution {\npublic:\n    vector<int> twoSum(vector<int>& nums, int target) {\n        // Type your solution manually below\n        unordered_map<int, int> seen;\n        for (int i = 0; i < nums.size(); ++i) {\n            int comp = target - nums[i];\n            if (seen.count(comp)) return {seen[comp], i};\n            seen[nums[i]] = i;\n        }\n        return {};\n    }\n};',
        },
        referenceSolutions: {
          'Python': 'def two_sum(nums, target):\n    seen = {}\n    for i, n in enumerate(nums):\n        if target - n in seen:\n            return [seen[target - n], i]\n        seen[n] = i\n    return []',
        },
        hints: [
          'Can you use a hash table to check if the complement (target - current) has been seen before?',
          'Trading space for time gives an O(n) solution instead of O(n^2).',
        ],
        sourceMetadata: 'LeetCode 1 • Top Interview 150',
      ),

      // 2. Valid Palindrome (Strings / Two Pointers)
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
        constraints: [
          '1 <= s.length <= 2 * 10^5',
          's consists only of printable ASCII characters.',
        ],
        examples: [
          TestCaseExample(
            input: 's = "A man, a plan, a canal: Panama"',
            output: 'true',
            explanation: '"amanaplanacanalpanama" is a palindrome.',
          ),
          TestCaseExample(
            input: 's = "race a car"',
            output: 'false',
            explanation: '"raceacar" is not a palindrome.',
          ),
        ],
        sampleTestCases: [
          TestCase(input: 'A man, a plan, a canal: Panama', expectedOutput: 'true'),
          TestCase(input: 'race a car', expectedOutput: 'false'),
        ],
        hiddenTestCases: [
          TestCase(input: ' ', expectedOutput: 'true', isHidden: true),
          TestCase(input: '0P', expectedOutput: 'false', isHidden: true),
          TestCase(input: 'Was it a car or a cat I saw?', expectedOutput: 'true', isHidden: true),
        ],
        starterCode: {
          'Python': 'def is_palindrome(s: str) -> bool:\n    # Type your solution manually below\n    filtered = [c.lower() for c in s if c.isalnum()]\n    return filtered == filtered[::-1]\n',
          'JavaScript': 'function isPalindrome(s) {\n    // Type your solution manually below\n    const cleaned = s.toLowerCase().replace(/[^a-z0-9]/g, "");\n    return cleaned === cleaned.split("").reverse().join("");\n}',
          'Java': 'class Solution {\n    public boolean isPalindrome(String s) {\n        // Type your solution manually below\n        int l = 0, r = s.length() - 1;\n        while (l < r) {\n            while (l < r && !Character.isLetterOrDigit(s.charAt(l))) l++;\n            while (l < r && !Character.isLetterOrDigit(s.charAt(r))) r--;\n            if (Character.toLowerCase(s.charAt(l)) != Character.toLowerCase(s.charAt(r))) return false;\n            l++; r--;\n        }\n        return true;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    bool isPalindrome(string s) {\n        // Type your solution manually below\n        int l = 0, r = s.size() - 1;\n        while (l < r) {\n            while (l < r && !isalnum(s[l])) l++;\n            while (l < r && !isalnum(s[r])) r--;\n            if (tolower(s[l]) != tolower(s[r])) return false;\n            l++; r--;\n        }\n        return true;\n    }\n};',
        },
        hints: [
          'Filter out non-alphanumeric characters and lowercase all letters first.',
          'Consider using two pointers from left and right moving towards center.',
        ],
        sourceMetadata: 'LeetCode 125 • Top Interview 150',
      ),

      // 3. Maximum Subarray (Kadane\'s Algorithm)
      QuestionModel(
        id: 'curated_003_maximum_subarray',
        canonicalProblemId: 'canonical_kadane_max_subarray',
        title: 'Maximum Subarray',
        description:
            'Given an integer array `nums`, find the subarray with the largest sum, and return its sum.\n\nA subarray is a contiguous non-empty sequence of elements within an array.',
        difficultyRating: 4,
        difficultyBand: 'Easy to Intermediate',
        topic: 'Arrays',
        inputDescription: 'An integer array nums',
        outputDescription: 'Integer maximum sum',
        constraints: [
          '1 <= nums.length <= 10^5',
          '-10^4 <= nums[i] <= 10^4',
        ],
        examples: [
          TestCaseExample(
            input: 'nums = [-2,1,-3,4,-1,2,1,-5,4]',
            output: '6',
            explanation: 'The subarray [4,-1,2,1] has the largest sum 6.',
          ),
          TestCaseExample(
            input: 'nums = [1]',
            output: '1',
            explanation: 'Subarray [1] has sum 1.',
          ),
        ],
        sampleTestCases: [
          TestCase(input: '[-2, 1, -3, 4, -1, 2, 1, -5, 4]', expectedOutput: '6'),
          TestCase(input: '[1]', expectedOutput: '1'),
        ],
        hiddenTestCases: [
          TestCase(input: '[5, 4, -1, 7, 8]', expectedOutput: '23', isHidden: true),
          TestCase(input: '[-1, -2, -3, -4]', expectedOutput: '-1', isHidden: true),
          TestCase(input: '[-2, -1]', expectedOutput: '-1', isHidden: true),
        ],
        starterCode: {
          'Python': 'def max_sub_array(nums: list[int]) -> int:\n    # Type your solution manually below (Kadane\'s Algorithm)\n    max_sum = current_sum = nums[0]\n    for x in nums[1:]:\n        current_sum = max(x, current_sum + x)\n        max_sum = max(max_sum, current_sum)\n    return max_sum\n',
          'JavaScript': 'function maxSubArray(nums) {\n    let maxSum = nums[0], currentSum = nums[0];\n    for (let i = 1; i < nums.length; i++) {\n        currentSum = Math.max(nums[i], currentSum + nums[i]);\n        maxSum = Math.max(maxSum, currentSum);\n    }\n    return maxSum;\n}',
          'Java': 'class Solution {\n    public int maxSubArray(int[] nums) {\n        int maxSum = nums[0], cur = nums[0];\n        for (int i = 1; i < nums.length; i++) {\n            cur = Math.max(nums[i], cur + nums[i]);\n            maxSum = Math.max(maxSum, cur);\n        }\n        return maxSum;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int maxSubArray(vector<int>& nums) {\n        int maxSum = nums[0], cur = nums[0];\n        for (size_t i = 1; i < nums.size(); ++i) {\n            cur = max(nums[i], cur + nums[i]);\n            maxSum = max(maxSum, cur);\n        }\n        return maxSum;\n    }\n};',
        },
        hints: [
          'If at any point the running sum becomes negative, would continuing with it help maximize future subarrays?',
          'Kadane\'s algorithm allows you to solve this in O(n) time and O(1) space.',
        ],
        sourceMetadata: 'LeetCode 53 • Top Interview 150',
      ),

      // 4. Valid Parentheses (Stacks & Queues)
      QuestionModel(
        id: 'curated_004_valid_parentheses',
        canonicalProblemId: 'canonical_stack_valid_parentheses',
        title: 'Valid Parentheses',
        description:
            'Given a string `s` containing just the characters `(`, `)`, `{`, `}`, `[` and `]`, determine if the input string is valid.\n\nAn input string is valid if:\n1. Open brackets must be closed by the same type of brackets.\n2. Open brackets must be closed in the correct order.\n3. Every close bracket has a corresponding open bracket of the same type.',
        difficultyRating: 3,
        difficultyBand: 'Beginner',
        topic: 'Stacks and Queues',
        inputDescription: 'String s of bracket characters',
        outputDescription: 'Boolean true or false',
        constraints: [
          '1 <= s.length <= 10^4',
          's consists of parentheses only: ()[]{}',
        ],
        examples: [
          TestCaseExample(input: 's = "()"', output: 'true'),
          TestCaseExample(input: 's = "()[]{}"', output: 'true'),
          TestCaseExample(input: 's = "(]"', output: 'false'),
        ],
        sampleTestCases: [
          TestCase(input: '()', expectedOutput: 'true'),
          TestCase(input: '()[]{}', expectedOutput: 'true'),
          TestCase(input: '(]', expectedOutput: 'false'),
        ],
        hiddenTestCases: [
          TestCase(input: '([)]', expectedOutput: 'false', isHidden: true),
          TestCase(input: '{[]}', expectedOutput: 'true', isHidden: true),
          TestCase(input: '((((', expectedOutput: 'false', isHidden: true),
          TestCase(input: ']]', expectedOutput: 'false', isHidden: true),
        ],
        starterCode: {
          'Python': 'def is_valid_parentheses(s: str) -> bool:\n    # Type your solution manually below\n    stack = []\n    mapping = {")": "(", "}": "{", "]": "["}\n    for char in s:\n        if char in mapping:\n            top = stack.pop() if stack else "#"\n            if mapping[char] != top:\n                return False\n        else:\n            stack.append(char)\n    return not stack\n',
          'JavaScript': 'function isValidParentheses(s) {\n    const stack = [];\n    const pairs = {")": "(", "}": "{", "]": "["};\n    for (const char of s) {\n        if (char in pairs) {\n            if (stack.pop() !== pairs[char]) return false;\n        } else {\n            stack.push(char);\n        }\n    }\n    return stack.length === 0;\n}',
          'Java': 'class Solution {\n    public boolean isValid(String s) {\n        Stack<Character> stack = new Stack<>();\n        for (char c : s.toCharArray()) {\n            if (c == \'(\') stack.push(\')\');\n            else if (c == \'{\') stack.push(\'}\');\n            else if (c == \'[\') stack.push(\']\');\n            else if (stack.isEmpty() || stack.pop() != c) return false;\n        }\n        return stack.isEmpty();\n    }\n}',
          'C++': 'class Solution {\npublic:\n    bool isValid(string s) {\n        stack<char> st;\n        for (char c : s) {\n            if (c == \'(\') st.push(\')\');\n            else if (c == \'{\') st.push(\'}\');\n            else if (c == \'[\') st.push(\']\');\n            else if (st.empty() || st.top() != c) return false;\n            else st.pop();\n        }\n        return st.empty();\n    }\n};',
        },
        hints: [
          'A stack is the standard data structure for matching nested elements.',
          'Whenever you see an opening bracket, push its expected closing bracket.',
        ],
        sourceMetadata: 'LeetCode 20 • Blind 75',
      ),

      // 5. Best Time to Buy and Sell Stock (Dynamic Programming / Greedy)
      QuestionModel(
        id: 'curated_005_buy_sell_stock',
        canonicalProblemId: 'canonical_single_pass_stock_max_profit',
        title: 'Best Time to Buy and Sell Stock',
        description:
            'You are given an array `prices` where `prices[i]` is the price of a given stock on the `i-th` day.\n\nYou want to maximize your profit by choosing a single day to buy one stock and choosing a different day in the future to sell that stock.\n\nReturn the maximum profit you can achieve from this transaction. If you cannot achieve any profit, return 0.',
        difficultyRating: 3,
        difficultyBand: 'Beginner',
        topic: 'Arrays',
        inputDescription: 'An integer array prices',
        outputDescription: 'Integer maximum profit',
        constraints: [
          '1 <= prices.length <= 10^5',
          '0 <= prices[i] <= 10^4',
        ],
        examples: [
          TestCaseExample(
            input: 'prices = [7,1,5,3,6,4]',
            output: '5',
            explanation: 'Buy on day 2 (price = 1) and sell on day 5 (price = 6), profit = 6 - 1 = 5.',
          ),
          TestCaseExample(
            input: 'prices = [7,6,4,3,1]',
            output: '0',
            explanation: 'In this case, no transactions are done and max profit = 0.',
          ),
        ],
        sampleTestCases: [
          TestCase(input: '[7, 1, 5, 3, 6, 4]', expectedOutput: '5'),
          TestCase(input: '[7, 6, 4, 3, 1]', expectedOutput: '0'),
        ],
        hiddenTestCases: [
          TestCase(input: '[2, 4, 1]', expectedOutput: '2', isHidden: true),
          TestCase(input: '[1, 2]', expectedOutput: '1', isHidden: true),
          TestCase(input: '[3, 3, 5, 0, 0, 3, 1, 4]', expectedOutput: '4', isHidden: true),
        ],
        starterCode: {
          'Python': 'def max_profit(prices: list[int]) -> int:\n    # Type your solution manually below\n    min_price = float(\'inf\')\n    max_profit = 0\n    for price in prices:\n        if price < min_price:\n            min_price = price\n        elif price - min_price > max_profit:\n            max_profit = price - min_price\n    return max_profit\n',
          'JavaScript': 'function maxProfit(prices) {\n    let minPrice = Infinity, maxProfit = 0;\n    for (const price of prices) {\n        if (price < minPrice) minPrice = price;\n        else if (price - minPrice > maxProfit) maxProfit = price - minPrice;\n    }\n    return maxProfit;\n}',
          'Java': 'class Solution {\n    public int maxProfit(int[] prices) {\n        int min = Integer.MAX_VALUE, maxProf = 0;\n        for (int p : prices) {\n            if (p < min) min = p;\n            else if (p - min > maxProf) maxProf = p - min;\n        }\n        return maxProf;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int maxProfit(vector<int>& prices) {\n        int minPrice = INT_MAX, maxProfit = 0;\n        for (int p : prices) {\n            minPrice = min(minPrice, p);\n            maxProfit = max(maxProfit, p - minPrice);\n        }\n        return maxProfit;\n    }\n};',
        },
        hints: [
          'Track the lowest price observed so far as you iterate forward.',
          'At each step, calculate the profit if you sold today, and update the global max profit.',
        ],
        sourceMetadata: 'LeetCode 121 • Blind 75',
      ),

      // 6. Climbing Stairs (Dynamic Programming)
      QuestionModel(
        id: 'curated_006_climbing_stairs',
        canonicalProblemId: 'canonical_fibonacci_climbing_stairs',
        title: 'Climbing Stairs',
        description:
            'You are climbing a staircase. It takes `n` steps to reach the top.\n\nEach time you can either climb 1 or 2 steps. In how many distinct ways can you climb to the top?',
        difficultyRating: 3,
        difficultyBand: 'Beginner',
        topic: 'Dynamic Programming',
        inputDescription: 'Positive integer n',
        outputDescription: 'Integer number of distinct ways',
        constraints: [
          '1 <= n <= 45',
        ],
        examples: [
          TestCaseExample(
            input: 'n = 2',
            output: '2',
            explanation: '1. 1 step + 1 step\n2. 2 steps',
          ),
          TestCaseExample(
            input: 'n = 3',
            output: '3',
            explanation: '1. 1 + 1 + 1\n2. 1 + 2\n3. 2 + 1',
          ),
        ],
        sampleTestCases: [
          TestCase(input: '2', expectedOutput: '2'),
          TestCase(input: '3', expectedOutput: '3'),
        ],
        hiddenTestCases: [
          TestCase(input: '4', expectedOutput: '5', isHidden: true),
          TestCase(input: '5', expectedOutput: '8', isHidden: true),
          TestCase(input: '10', expectedOutput: '89', isHidden: true),
          TestCase(input: '20', expectedOutput: '10946', isHidden: true),
        ],
        starterCode: {
          'Python': 'def climb_stairs(n: int) -> int:\n    # Type your solution manually below\n    if n <= 2:\n        return n\n    a, b = 1, 2\n    for _ in range(3, n + 1):\n        a, b = b, a + b\n    return b\n',
          'JavaScript': 'function climbStairs(n) {\n    if (n <= 2) return n;\n    let a = 1, b = 2;\n    for (let i = 3; i <= n; i++) {\n        const temp = a + b;\n        a = b;\n        b = temp;\n    }\n    return b;\n}',
          'Java': 'class Solution {\n    public int climbStairs(int n) {\n        if (n <= 2) return n;\n        int a = 1, b = 2;\n        for (int i = 3; i <= n; i++) {\n            int sum = a + b; a = b; b = sum;\n        }\n        return b;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int climbStairs(int n) {\n        if (n <= 2) return n;\n        int a = 1, b = 2;\n        for (int i = 3; i <= n; ++i) {\n            int next = a + b; a = b; b = next;\n        }\n        return b;\n    }\n};',
        },
        hints: [
          'To reach step n, you must have come from either step (n - 1) or step (n - 2).',
          'This matches the recurrence relation of the Fibonacci sequence.',
        ],
        sourceMetadata: 'LeetCode 70 • Top Interview 150',
      ),

      // 7. Binary Search (Searching and Sorting)
      QuestionModel(
        id: 'curated_007_binary_search',
        canonicalProblemId: 'canonical_classic_binary_search',
        title: 'Binary Search',
        description:
            'Given an array of integers `nums` which is sorted in ascending order, and an integer `target`, write a function to search `target` in `nums`.\n\nIf `target` exists, then return its index. Otherwise, return -1.\n\nYou must write an algorithm with O(log n) runtime complexity.',
        difficultyRating: 2,
        difficultyBand: 'Beginner',
        topic: 'Searching and Sorting',
        inputDescription: 'Sorted integer array nums and integer target',
        outputDescription: 'Integer index or -1',
        constraints: [
          '1 <= nums.length <= 10^4',
          '-10^4 < nums[i], target < 10^4',
          'All the integers in nums are unique.',
          'nums is sorted in ascending order.',
        ],
        examples: [
          TestCaseExample(
            input: 'nums = [-1,0,3,5,9,12], target = 9',
            output: '4',
            explanation: '9 exists in nums and its index is 4.',
          ),
          TestCaseExample(
            input: 'nums = [-1,0,3,5,9,12], target = 2',
            output: '-1',
            explanation: '2 does not exist in nums so return -1.',
          ),
        ],
        sampleTestCases: [
          TestCase(input: '[-1, 0, 3, 5, 9, 12]\n9', expectedOutput: '4'),
          TestCase(input: '[-1, 0, 3, 5, 9, 12]\n2', expectedOutput: '-1'),
        ],
        hiddenTestCases: [
          TestCase(input: '[5]\n5', expectedOutput: '0', isHidden: true),
          TestCase(input: '[2, 5]\n5', expectedOutput: '1', isHidden: true),
          TestCase(input: '[1, 3, 5, 7, 9, 11]\n1', expectedOutput: '0', isHidden: true),
          TestCase(input: '[1, 3, 5, 7, 9, 11]\n11', expectedOutput: '5', isHidden: true),
        ],
        starterCode: {
          'Python': 'def search(nums: list[int], target: int) -> int:\n    # Type your solution manually below\n    left, right = 0, len(nums) - 1\n    while left <= right:\n        mid = (left + right) // 2\n        if nums[mid] == target:\n            return mid\n        elif nums[mid] < target:\n            left = mid + 1\n        else:\n            right = mid - 1\n    return -1\n',
          'JavaScript': 'function search(nums, target) {\n    let left = 0, right = nums.length - 1;\n    while (left <= right) {\n        const mid = Math.floor((left + right) / 2);\n        if (nums[mid] === target) return mid;\n        if (nums[mid] < target) left = mid + 1;\n        else right = mid - 1;\n    }\n    return -1;\n}',
          'Java': 'class Solution {\n    public int search(int[] nums, int target) {\n        int l = 0, r = nums.length - 1;\n        while (l <= r) {\n            int mid = l + (r - l) / 2;\n            if (nums[mid] == target) return mid;\n            if (nums[mid] < target) l = mid + 1;\n            else r = mid - 1;\n        }\n        return -1;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int search(vector<int>& nums, int target) {\n        int l = 0, r = nums.size() - 1;\n        while (l <= r) {\n            int mid = l + (r - l) / 2;\n            if (nums[mid] == target) return mid;\n            if (nums[mid] < target) l = mid + 1;\n            else r = mid - 1;\n        }\n        return -1;\n    }\n};',
        },
        hints: [
          'Maintain left and right boundaries.',
          'Calculate mid point and compare nums[mid] with target.',
        ],
        sourceMetadata: 'LeetCode 704 • Essential DSA',
      ),

      // 8. Contains Duplicate (Hash Maps and Sets)
      QuestionModel(
        id: 'curated_008_contains_duplicate',
        canonicalProblemId: 'canonical_hashset_contains_duplicate',
        title: 'Contains Duplicate',
        description:
            'Given an integer array `nums`, return `true` if any value appears at least twice in the array, and return `false` if every element is distinct.',
        difficultyRating: 2,
        difficultyBand: 'Beginner',
        topic: 'Hash Maps and Sets',
        inputDescription: 'Integer array nums',
        outputDescription: 'Boolean true or false',
        constraints: [
          '1 <= nums.length <= 10^5',
          '-10^9 <= nums[i] <= 10^9',
        ],
        examples: [
          TestCaseExample(input: 'nums = [1,2,3,1]', output: 'true'),
          TestCaseExample(input: 'nums = [1,2,3,4]', output: 'false'),
          TestCaseExample(input: 'nums = [1,1,1,3,3,4,3,2,4,2]', output: 'true'),
        ],
        sampleTestCases: [
          TestCase(input: '[1, 2, 3, 1]', expectedOutput: 'true'),
          TestCase(input: '[1, 2, 3, 4]', expectedOutput: 'false'),
        ],
        hiddenTestCases: [
          TestCase(input: '[1]', expectedOutput: 'false', isHidden: true),
          TestCase(input: '[0, 0]', expectedOutput: 'true', isHidden: true),
          TestCase(input: '[9, 8, 7, 6, 5, 4, 3, 2, 1, 9]', expectedOutput: 'true', isHidden: true),
        ],
        starterCode: {
          'Python': 'def contains_duplicate(nums: list[int]) -> bool:\n    # Type your solution manually below\n    seen = set()\n    for n in nums:\n        if n in seen:\n            return True\n        seen.add(n)\n    return False\n',
          'JavaScript': 'function containsDuplicate(nums) {\n    return new Set(nums).size !== nums.length;\n}',
          'Java': 'class Solution {\n    public boolean containsDuplicate(int[] nums) {\n        Set<Integer> set = new HashSet<>();\n        for (int n : nums) {\n            if (!set.add(n)) return true;\n        }\n        return false;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    bool containsDuplicate(vector<int>& nums) {\n        unordered_set<int> s;\n        for (int n : nums) {\n            if (s.count(n)) return true;\n            s.insert(n);\n        }\n        return false;\n    }\n};',
        },
        hints: [
          'Using a hash set allows O(1) lookups as you check each number.',
        ],
        sourceMetadata: 'LeetCode 217 • Blind 75',
      ),

      // 9. Reverse Linked List
      QuestionModel(
        id: 'curated_009_reverse_linked_list',
        canonicalProblemId: 'canonical_reverse_singly_linked_list',
        title: 'Reverse Linked List',
        description:
            'Given the `head` of a singly linked list represented as a list of values, reverse the list, and return the reversed list.',
        difficultyRating: 3,
        difficultyBand: 'Beginner',
        topic: 'Linked Lists',
        inputDescription: 'Array representation of linked list values',
        outputDescription: 'Reversed array representation of linked list values',
        constraints: [
          '0 <= number of nodes <= 5000',
          '-5000 <= Node.val <= 5000',
        ],
        examples: [
          TestCaseExample(input: 'head = [1,2,3,4,5]', output: '[5,4,3,2,1]'),
          TestCaseExample(input: 'head = [1,2]', output: '[2,1]'),
          TestCaseExample(input: 'head = []', output: '[]'),
        ],
        sampleTestCases: [
          TestCase(input: '[1, 2, 3, 4, 5]', expectedOutput: '[5, 4, 3, 2, 1]'),
          TestCase(input: '[1, 2]', expectedOutput: '[2, 1]'),
        ],
        hiddenTestCases: [
          TestCase(input: '[]', expectedOutput: '[]', isHidden: true),
          TestCase(input: '[42]', expectedOutput: '[42]', isHidden: true),
          TestCase(input: '[10, 20, 30]', expectedOutput: '[30, 20, 10]', isHidden: true),
        ],
        starterCode: {
          'Python': 'def reverse_list(head: list[int]) -> list[int]:\n    # Type your solution manually below\n    return head[::-1]\n',
          'JavaScript': 'function reverseList(head) {\n    return head.slice().reverse();\n}',
          'Java': 'class Solution {\n    public List<Integer> reverseList(List<Integer> head) {\n        List<Integer> rev = new ArrayList<>(head);\n        Collections.reverse(rev);\n        return rev;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    vector<int> reverseList(vector<int>& head) {\n        vector<int> rev = head;\n        reverse(rev.begin(), rev.end());\n        return rev;\n    }\n};',
        },
        hints: [
          'Iterate through the nodes, pointing each node\'s next pointer to its predecessor.',
        ],
        sourceMetadata: 'LeetCode 206 • Top Interview 150',
      ),

      // 10. Longest Substring Without Repeating Characters (Sliding Window)
      QuestionModel(
        id: 'curated_010_longest_substring',
        canonicalProblemId: 'canonical_sliding_window_longest_substring',
        title: 'Longest Substring Without Repeating Characters',
        description:
            'Given a string `s`, find the length of the longest substring without duplicate characters.',
        difficultyRating: 5,
        difficultyBand: 'Intermediate',
        topic: 'Sliding Window',
        inputDescription: 'String s',
        outputDescription: 'Integer length of longest unique substring',
        constraints: [
          '0 <= s.length <= 5 * 10^4',
          's consists of English letters, digits, symbols and spaces.',
        ],
        examples: [
          TestCaseExample(
            input: 's = "abcabcbb"',
            output: '3',
            explanation: 'The answer is "abc", with the length of 3.',
          ),
          TestCaseExample(
            input: 's = "bbbbb"',
            output: '1',
            explanation: 'The answer is "b", with the length of 1.',
          ),
          TestCaseExample(
            input: 's = "pwwkew"',
            output: '3',
            explanation: 'The answer is "wke", with the length of 3.',
          ),
        ],
        sampleTestCases: [
          TestCase(input: 'abcabcbb', expectedOutput: '3'),
          TestCase(input: 'bbbbb', expectedOutput: '1'),
        ],
        hiddenTestCases: [
          TestCase(input: 'pwwkew', expectedOutput: '3', isHidden: true),
          TestCase(input: '', expectedOutput: '0', isHidden: true),
          TestCase(input: 'aab', expectedOutput: '2', isHidden: true),
          TestCase(input: 'dvdf', expectedOutput: '3', isHidden: true),
        ],
        starterCode: {
          'Python': 'def length_of_longest_substring(s: str) -> int:\n    # Type your solution manually below (Sliding Window)\n    used = {}\n    max_len = 0\n    start = 0\n    for i, char in enumerate(s):\n        if char in used and start <= used[char]:\n            start = used[char] + 1\n        else:\n            max_len = max(max_len, i - start + 1)\n        used[char] = i\n    return max_len\n',
          'JavaScript': 'function lengthOfLongestSubstring(s) {\n    const seen = new Map();\n    let maxLen = 0, start = 0;\n    for (let i = 0; i < s.length; i++) {\n        if (seen.has(s[i]) && seen.get(s[i]) >= start) {\n            start = seen.get(s[i]) + 1;\n        } else {\n            maxLen = Math.max(maxLen, i - start + 1);\n        }\n        seen.set(s[i], i);\n    }\n    return maxLen;\n}',
          'Java': 'class Solution {\n    public int lengthOfLongestSubstring(String s) {\n        Map<Character, Integer> map = new HashMap<>();\n        int max = 0, start = 0;\n        for (int i = 0; i < s.length(); i++) {\n            char c = s.charAt(i);\n            if (map.containsKey(c) && map.get(c) >= start) {\n                start = map.get(c) + 1;\n            } else {\n                max = Math.max(max, i - start + 1);\n            }\n            map.put(c, i);\n        }\n        return max;\n    }\n}',
          'C++': 'class Solution {\npublic:\n    int lengthOfLongestSubstring(string s) {\n        unordered_map<char, int> seen;\n        int maxLen = 0, start = 0;\n        for (int i = 0; i < s.size(); ++i) {\n            if (seen.count(s[i]) && seen[s[i]] >= start) {\n                start = seen[s[i]] + 1;\n            } else {\n                maxLen = max(maxLen, i - start + 1);\n            }\n            seen[s[i]] = i;\n        }\n        return maxLen;\n    }\n};',
        },
        hints: [
          'Use a sliding window defined by two pointers [start, i].',
          'Store the last seen index of each character to immediately skip duplicate occurrences.',
        ],
        sourceMetadata: 'LeetCode 3 • Blind 75',
      ),
    ];
  }
}
