--[==[

   SPDX-License-Identifier: MIT
   MIT License
   Copyright (c) 2025 Clemerson Assunção

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.

   See more: https://github.com/ClemersonAssuncao/Love2D-UnitTest-Framework
   
--]==]

-- test/TestFramework.lua
-- Unit testing framework similar to JUnit for Lua
-- Inspired by JUnit, with support for describe/it, setup/teardown, and assertions

local TestFramework = {}
TestFramework.version = "1.0.0"

-- Global configurations
TestFramework.config = {
    verbose = true,
    stopOnFirstFailure = false,
    timeout = 5000, -- ms
    colors = true
}

-- Execution statistics
TestFramework.stats = {
    totalSuites = 0,
    totalTests = 0,
    passed = 0,
    failed = 0,
    skipped = 0,
    errors = 0,
    startTime = 0,
    endTime = 0
}

-- List of test suites
TestFramework.suites = {}

-- Core API Functions

-- Create a test suite (equivalent to a test class in JUnit)
function TestFramework.describe(suiteName, suiteFunction)
    local suite = {
        name = suiteName,
        filePath = debug.getinfo(2, "S").short_src,
        tests = {},
        beforeAll = nil,    -- Execute once before all tests in the suite
        afterAll = nil,     -- Execute once after all tests in the suite
        beforeEach = nil,   -- Execute before each test
        afterEach = nil,    -- Execute after each test
        setup = nil,        -- Alias for beforeAll
        teardown = nil,     -- Alias for afterAll
        only = false,       -- If true, only this suite will be executed
        skip = false        -- If true, this suite will be skipped
    }

    -- Context for the test suite
    local context = {
        beforeAll = function(fn) suite.beforeAll = fn end,
        afterAll = function(fn) suite.afterAll = fn end,
        beforeEach = function(fn) suite.beforeEach = fn end,
        afterEach = function(fn) suite.afterEach = fn end,
        setup = function(fn) suite.setup = fn end,
        teardown = function(fn) suite.teardown = fn end,

        -- Function to define individual tests
        it = function(testName, testFunction)
            TestFramework.it(testName, testFunction, suite)
        end,
        
        -- Aliases
        test = function(testName, testFunction)
            TestFramework.it(testName, testFunction, suite)
        end,

        -- Special tests
        xit = function(testName, testFunction)
            TestFramework.it(testName, testFunction, suite, {skip = true})
        end,
        
        fit = function(testName, testFunction)
            TestFramework.it(testName, testFunction, suite, {only = true})
        end
    }

    -- Execute the suite function in the context
    suiteFunction(context)

    -- Add the suite to the list
    table.insert(TestFramework.suites, suite)
    TestFramework.stats.totalSuites = TestFramework.stats.totalSuites + 1
    
    return suite
end

-- Create a test case (similar to a @Test method in JUnit)
function TestFramework.it(testName, testFunction, suite, options)
    options = options or {}
    
    local test = {
        name = testName,
        func = testFunction,
        suite = suite,
        only = options.only or false,
        skip = options.skip or false,
        timeout = options.timeout or TestFramework.config.timeout,
        result = nil,       -- 'passed', 'failed', 'skipped', 'error'
        error = nil,
        duration = 0,
        assertions = 0
    }
    
    table.insert(suite.tests, test)
    TestFramework.stats.totalTests = TestFramework.stats.totalTests + 1
    
    return test
end

-- Assertions System
TestFramework.assert = {}

function TestFramework.assert.equals(actual, expected, message)
    local msg = message or ("Expected " .. tostring(expected) .. " but got " .. tostring(actual))
    if actual ~= expected then        
        TestFramework.assertThrowError(msg)
    end
end

function TestFramework.assert.notEquals(actual, expected, message)
    local msg = message or ("Expected not " .. tostring(expected) .. " but got " .. tostring(actual))
    if actual == expected then
        TestFramework.assertThrowError(msg)
    end
end

function TestFramework.assert.assertTrue(condition, message)
    local msg = message or "Expected true but got false"
    if not condition then
        TestFramework.assertThrowError(msg)
    end
end

function TestFramework.assert.assertFalse(condition, message)
    local msg = message or "Expected false but got true"
    if condition then
        TestFramework.assertThrowError(msg)
    end
end

function TestFramework.assert.assertNil(value, message)
    local msg = message or ("Expected nil but got " .. tostring(value))
    if value ~= nil then
        TestFramework.assertThrowError(msg)
    end
end

function TestFramework.assert.assertNotNil(value, message)
    local msg = message or "Expected non-nil value but got nil"
    if value == nil then
        TestFramework.assertThrowError(msg)
    end
end

function TestFramework.assert.assertType(value, expectedType, message)
    local actualType = type(value)
    local msg = message or ("Expected type " .. expectedType .. " but got " .. actualType)
    if actualType ~= expectedType then
        TestFramework.assertThrowError(msg)
    end
end

-- Assertions numbers
function TestFramework.assert.assertGreater(actual, expected, message)
    local msg = message or (tostring(actual) .. " should be greater than " .. tostring(expected))
    if actual <= expected then
        TestFramework.assertThrowError(msg)
    end
end

function TestFramework.assert.assertLess(actual, expected, message)
    local msg = message or (tostring(actual) .. " should be less than " .. tostring(expected))
    if actual >= expected then
        TestFramework.assertThrowError(msg)
    end
end

function TestFramework.assert.assertGreaterOrEqual(actual, expected, message)
    local msg = message or (tostring(actual) .. " should be greater than or equal to " .. tostring(expected))
    if actual < expected then
        TestFramework.assertThrowError(msg)
    end
end

-- Assertions arrays and tables
function TestFramework.assert.assertTableEquals(actual, expected, message)
    local function deepCompare(t1, t2)
        if type(t1) ~= type(t2) then return false end
        if type(t1) ~= "table" then return t1 == t2 end
        
        for k, v in pairs(t1) do
            if not deepCompare(v, t2[k]) then return false end
        end
        
        for k, v in pairs(t2) do
            if not deepCompare(v, t1[k]) then return false end
        end
        
        return true
    end
    
    local msg = message or "Tables are not equal"
    if not deepCompare(actual, expected) then
        TestFramework.assertThrowError(msg)
    end
end

function TestFramework.assert.assertContains(table, value, message)
    local msg = message or ("Table should contain " .. tostring(value))
    for _, v in pairs(table) do
        if v == value then return end
    end
    TestFramework.assertThrowError(msg)
end

function TestFramework.assert.assertNotContains(table, value, message)
    local msg = message or ("Table should not contain " .. tostring(value))
    for _, v in pairs(table) do
        if v == value then
            TestFramework.assertThrowError(msg)
        end
    end
end

-- Assertions for exceptions
function TestFramework.assert.assertThrows(func, expectedError, message)
    local success, error = pcall(func)
    local msg = message or "Expected function to throw an error"
    
    if success then
        error("AssertionError: " .. msg)
    end
    
    if expectedError and not string.find(tostring(error), expectedError) then
        error("AssertionError: Expected error containing '" .. expectedError .. "' but got '" .. tostring(error) .. "'")
    end
end

-- Runner - Execute all tests
function TestFramework.run(options)
    options = options or {}

    -- Reset statistics
    TestFramework.stats = {
        totalSuites = #TestFramework.suites,
        totalTests = 0,
        passed = 0,
        failed = 0,
        skipped = 0,
        errors = 0,
        startTime = os.clock(),
        endTime = 0
    }
    
    print("TestFramework v" .. TestFramework.version)
    print("==============================")
    print("Executing " .. TestFramework.stats.totalSuites .. " test suite(s)...")
    print("")

    -- Execute each suite
    for _, suite in ipairs(TestFramework.suites) do
        TestFramework.runSuite(suite)
    end
    
    TestFramework.stats.endTime = os.clock()
    TestFramework.printResults()
    return TestFramework.suites
end

-- Execute a specific suite
function TestFramework.runSuite(suite)
    if suite.skip then
        print("SKIPPED: " .. suite.name)
        TestFramework.stats.skipped = TestFramework.stats.skipped + #suite.tests
        return
    end
    
    print("Running: " .. suite.name)

    -- Execute beforeAll/setup
    if suite.beforeAll then
        local success, error = pcall(suite.beforeAll)
        if not success then
            print("  ERROR in beforeAll: " .. tostring(error))
            return
        end
    elseif suite.setup then
        local success, error = pcall(suite.setup)
        if not success then
            print("  ERROR in setup: " .. tostring(error))
            return
        end
    end

    -- Execute each test
    for _, test in ipairs(suite.tests) do
        TestFramework.runTest(test, suite)
    end
    
    -- Execute afterAll/teardown
    if suite.afterAll then
        pcall(suite.afterAll)
    elseif suite.teardown then
        pcall(suite.teardown)
    end
    
    print("")
end

-- Executa a individual test
function TestFramework.runTest(test, suite)
    if test.skip then
        print("  SKIP: " .. test.name)
        TestFramework.stats.skipped = TestFramework.stats.skipped + 1
        test.result = "skipped"
        return
    end
    
    local startTime = os.clock()
    
    -- Execute beforeEach
    if suite.beforeEach then
        local success, error = pcall(suite.beforeEach)
        if not success then
            print("  ERROR in beforeEach: " .. tostring(error))
            TestFramework.stats.errors = TestFramework.stats.errors + 1
            test.result = "error"
            test.error = error
            return
        end
    end

    -- Execute the test
    local success, error = pcall(test.func)
    test.duration = (os.clock() - startTime) * 1000 -- em ms
    if success then
        print("  PASS: " .. test.name .. " (" .. string.format("%.2f", test.duration) .. "ms)")
        TestFramework.stats.passed = TestFramework.stats.passed + 1
        test.result = "passed"
    else
        print("  FAIL: " .. test.name .. " - " .. tostring(error))
        TestFramework.stats.failed = TestFramework.stats.failed + 1
        test.result = "failed"
        test.error = tostring(error):gsub(".*AssertionError:%s*", "")
        
        if TestFramework.config.stopOnFirstFailure then
            error("Stopping on first failure: " .. tostring(error))
        end
    end

    -- Execute afterEach
    if suite.afterEach then
        pcall(suite.afterEach)
    end
end

-- Show results in the console
function TestFramework.printResults()
    local duration = (TestFramework.stats.endTime - TestFramework.stats.startTime) * 1000
    
    print("==============================")
    print("Summary:")
    print("  Total: " .. TestFramework.stats.totalTests)
    print("  Passed: " .. TestFramework.stats.passed)
    print("  Failed: " .. TestFramework.stats.failed)
    print("  Skipped: " .. TestFramework.stats.skipped)
    print("  Errors: " .. TestFramework.stats.errors)
    print("  Duration: " .. string.format("%.2f", duration) .. "ms")
    
    if TestFramework.stats.failed > 0 or TestFramework.stats.errors > 0 then
        print("\nTESTS FAILED!")
    else
        print("\nALL TESTS PASSED!")
    end
end

-- Utility functions

-- Clear all tests (useful for reloading)
function TestFramework.clear()
    TestFramework.suites = {}
    TestFramework.stats = {
        totalSuites = 0,
        totalTests = 0,
        passed = 0,
        failed = 0,
        skipped = 0,
        errors = 0,
        startTime = 0,
        endTime = 0
    }
end

function TestFramework.assertThrowError(message)
    local info = debug.getinfo(3, "Sl")
    local file = info.short_src or "?"
    local line = info.currentline or "?"
    error("AssertionError: " .. message .. " at " .. file .. ":" .. line)
end

-- Global aliases to facilitate usage
_G.describe = TestFramework.describe
_G.it = TestFramework.it
_G.test = TestFramework.it
_G.assert = TestFramework.assert

return TestFramework
