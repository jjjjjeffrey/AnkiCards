import Foundation

// Function to validate the generated file
func validateGeneratedFile(filePath: String) {
    print("Starting validation of file: \(filePath)")
    
    guard let fileContents = try? String(contentsOfFile: filePath, encoding: .utf8) else {
        print("Error: Could not read file at \(filePath)")
        return
    }
    
    let lines = fileContents.components(separatedBy: .newlines)
    print("Found \(lines.count) lines to validate")
    
    var validLines = 0
    var invalidLines = 0
    var mismatchLineNumbers: [Int] = []
    var mismatchedLines: [(lineNumber: Int, content: String, answer: String, extractedWord: String)] = []
    var lineNumber = 0
    
    for line in lines {
        lineNumber += 1
        
        // Skip empty lines
        if line.isEmpty {
            continue
        }
        
        let components = line.components(separatedBy: "|")
        
        // Ensure the line has enough components
        guard components.count >= 3 else {
            print("Error on line \(lineNumber): Not enough fields (found \(components.count))")
            invalidLines += 1
            mismatchLineNumbers.append(lineNumber)
            mismatchedLines.append((lineNumber, line, "", ""))
            continue
        }
        
        let answer = components[0]
        let example = components[1]
        
        // Extract the word from {{c1::word}} in the example
        let pattern = "\\{\\{c1::([^}]+)\\}\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            print("Error: Could not create regex pattern")
            continue
        }
        
        let range = NSRange(example.startIndex..<example.endIndex, in: example)
        guard let match = regex.firstMatch(in: example, range: range) else {
            print("Error on line \(lineNumber): No {{c1::}} pattern found in example")
            invalidLines += 1
            mismatchLineNumbers.append(lineNumber)
            mismatchedLines.append((lineNumber, line, answer, "No {{c1::}} pattern found"))
            continue
        }
        
        if let matchRange = Range(match.range(at: 1), in: example) {
            let extractedWord = String(example[matchRange])
            
            if extractedWord == answer {
                validLines += 1
            } else {
                print("Mismatch on line \(lineNumber):")
                print("  Answer: '\(answer)'")
                print("  Word in example: '\(extractedWord)'")
                invalidLines += 1
                mismatchLineNumbers.append(lineNumber)
                mismatchedLines.append((lineNumber, line, answer, extractedWord))
            }
        } else {
            print("Error on line \(lineNumber): Could not extract word from match")
            invalidLines += 1
            mismatchLineNumbers.append(lineNumber)
            mismatchedLines.append((lineNumber, line, answer, "Could not extract word"))
        }
    }
    
    print("\nValidation Summary:")
    print("Total lines: \(lineNumber)")
    print("Valid lines: \(validLines)")
    print("Invalid lines: \(invalidLines)")
    
    if invalidLines == 0 {
        print("✅ All lines are valid!")
    } else {
        print("❌ Found \(invalidLines) invalid lines")
        
        print("\nMismatched line numbers:")
        // Group line numbers in ranges for more compact display
        var ranges: [(start: Int, end: Int)] = []
        var currentRange: (start: Int, end: Int)? = nil
        
        for num in mismatchLineNumbers.sorted() {
            if let range = currentRange {
                if num == range.end + 1 {
                    // Extend current range
                    currentRange!.end = num
                } else {
                    // Save current range and start a new one
                    ranges.append(range)
                    currentRange = (num, num)
                }
            } else {
                // Start first range
                currentRange = (num, num)
            }
        }
        
        // Add the last range if exists
        if let range = currentRange {
            ranges.append(range)
        }
        
        // Display the ranges
        for (index, range) in ranges.enumerated() {
            if range.start == range.end {
                print("\(range.start)", terminator: "")
            } else {
                print("\(range.start)-\(range.end)", terminator: "")
            }
            
            // Add comma except for the last element
            if index < ranges.count - 1 {
                print(", ", terminator: "")
            }
            
            // Add line break every 5 ranges for readability
            if (index + 1) % 5 == 0 {
                print()
            }
        }
        print() // Final line break
        
        print("\nDetailed mismatches:")
        print("===================")
        
        for (index, mismatch) in mismatchedLines.enumerated() {
            print("Line \(mismatch.lineNumber):")
            print("Answer: '\(mismatch.answer)'")
            print("Word in example: '\(mismatch.extractedWord)'")
            print("Full content:")
            print(mismatch.content)
            
            // Add separator between entries except for the last one
            if index < mismatchedLines.count - 1 {
                print("\n-------------------\n")
            }
        }
    }
}

// Main execution
func main() {
    let filePath = "word_data_output.txt"
    validateGeneratedFile(filePath: filePath)
}

// Run the script
main()
