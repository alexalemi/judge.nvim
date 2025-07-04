# Example Janet file with Judge tests
# This demonstrates how judge.nvim works with Judge tests

(use judge)

# Basic arithmetic tests
(test (+ 1 2))
(test (* 3 4))
(test (/ 10 2))

# String operations
(test (string/upper "hello"))
(test (string/length "judge"))

# Array operations
(defn sort-array [arr]
  (sort arr))

(test (sort-array [3 1 4 1 5]))

# Named test group
(deftest "string manipulation"
  (test (string/trim "  hello  "))
  (test (string/split "a,b,c" ","))
  (test (string/replace "hello world" "world" "judge")))

# Error testing
(test-error (in [1 2 3] 5))

# Trust expression (cached result)
(def random-data
  (trust (do
    (print "Generating random data...")
    (map (fn [_] (math/random)) (range 5)))))

(test (length random-data))

# Function testing
(defn fibonacci [n]
  (if (< n 2)
    n
    (+ (fibonacci (- n 1)) (fibonacci (- n 2)))))

(test (fibonacci 0))
(test (fibonacci 1))
(test (fibonacci 5))
(test (fibonacci 10))

# Test with output
(defn greet [name]
  (printf "Hello, %s!" name)
  (string "Greeting for " name))

(test-stdout (greet "Judge"))