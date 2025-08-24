-- You can import external classes from your project like this:
-- local MyClass = require("src.to.MyClass")

describe("Tests in the same file: Basic Arithmetic Operations", function(ctx)

    ctx.it("should add two positive numbers correctly", function()
        local result = 2 + 3
        assert.equals(result, 5)
    end)

    ctx.it("should subtract numbers correctly", function()
        local result = 10 - 3
        assert.equals(result, 7)
    end)

    ctx.it("should multiply numbers correctly", function()
        local result = 4 * 6
        assert.equals(result, 24)
    end)

    ctx.it("should divide numbers correctly", function()
        local result = 15 / 3
        assert.equals(result, 5)
    end)

    ctx.it("should handle negative numbers in addition", function()
        local result = -5 + 3
        assert.equals(result, -2)
    end)

end)

describe("Tests in the same file: Advanced Mathematical Functions, one should fail", function(ctx)

    ctx.it("should calculate square root correctly", function()
        local result = math.sqrt(16)
        assert.equals(result, 4)
    end)

    ctx.it("should calculate power correctly", function()
        local result = math.pow(2, 3)
        assert.equals(result, 8)
    end)

    ctx.it("should handle trigonometric functions", function()
        local result = math.sin(math.pi / 2)
        assert.equals(math.floor(result + 0.5), 1) -- Round to nearest integer
    end)

    ctx.it("should calculate absolute value", function()
        local result = math.abs(-42)
        assert.equals(result, 42)
    end)

    ctx.it("should calculate minimum of two numbers", function()
        local result = math.min(5, 3)
        assert.equals(result, 3)
    end)

    ctx.it("should calculate maximum of two numbers", function()
        local result = math.max(5, 3)
        assert.equals(result, 5)
    end)

    ctx.it("should fail when expecting wrong square root", function()
        local result = math.sqrt(25)
        assert.equals(result, 6) -- This will fail, should be 5
    end)

end)

describe("Tests in the same file: Number Properties and Validations, all should pass", function(ctx)

    ctx.it("should validate that a number is not nil", function()
        local number = 42
        assert.assertNotNil(number)
    end)

    ctx.it("should validate that a calculation result is not nil", function()
        local result = 10 * 5
        assert.assertNotNil(result)
    end)

    ctx.it("should validate positive numbers", function()
        local number = 15
        assert.assertTrue(number > 0)
    end)

    ctx.it("should validate negative numbers", function()
        local number = -8
        assert.assertTrue(number < 0)
    end)

    ctx.it("should validate even numbers", function()
        local number = 12
        assert.assertTrue(number % 2 == 0)
    end)

    ctx.it("should validate odd numbers", function()
        local number = 7
        assert.assertTrue(number % 2 == 1)
    end)

end)

describe("Tests in the same file: Complex Mathematical Scenarios", function(ctx)

    ctx.it("should solve quadratic equation roots", function()
        -- Solving x² - 5x + 6 = 0 (roots should be 2 and 3)
        local a, b, c = 1, -5, 6
        local discriminant = b * b - 4 * a * c
        local root1 = (-b + math.sqrt(discriminant)) / (2 * a)
        local root2 = (-b - math.sqrt(discriminant)) / (2 * a)
        
        assert.assertTrue(root1 == 3 or root1 == 2)
        assert.assertTrue(root2 == 3 or root2 == 2)
    end)

    ctx.it("should calculate Fibonacci sequence", function()
        local function fibonacci(n)
            if n <= 1 then return n end
            return fibonacci(n - 1) + fibonacci(n - 2)
        end
        
        assert.equals(fibonacci(0), 0)
        assert.equals(fibonacci(1), 1)
        assert.equals(fibonacci(5), 5)
        assert.equals(fibonacci(7), 13)
    end)

    ctx.it("should validate prime number checking", function()
        local function isPrime(n)
            if n < 2 then return false end
            for i = 2, math.sqrt(n) do
                if n % i == 0 then return false end
            end
            return true
        end
        
        assert.assertTrue(isPrime(7))
        assert.assertTrue(isPrime(13))
        assert.assertFalse(isPrime(8))
        assert.assertFalse(isPrime(15))
    end)

    ctx.it("should calculate greatest common divisor", function()
        local function gcd(a, b)
            while b ~= 0 do
                a, b = b, a % b
            end
            return a
        end
        
        assert.equals(gcd(48, 18), 6)
        assert.equals(gcd(100, 25), 25)
    end)

    ctx.it("should fail with wrong Fibonacci expectation", function()
        local function fibonacci(n)
            if n <= 1 then return n end
            return fibonacci(n - 1) + fibonacci(n - 2)
        end
        
        assert.equals(fibonacci(6), 10) -- This will fail, should be 8
    end)

end)