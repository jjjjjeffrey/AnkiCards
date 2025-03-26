import Foundation

// 首先定义一个枚举类型来表示词性
enum PartOfSpeech: String, Codable, CaseIterable {
    case noun           // 名词
    case verb           // 动词
    case adjective      // 形容词
    case adverb         // 副词
    case pronoun        // 代词
    case preposition    // 介词
    case conjunction    // 连词
    case interjection   // 感叹词
    case determiner     // 限定词
    case numeral        // 数词
}

// 定义一个句子结构体，包含英文例句和中文翻译
struct Sentence: Codable {
    let english: String        // 英文例句
    let chinese: String        // 中文翻译
    
    init(english: String, chinese: String) {
        self.english = english
        self.chinese = chinese
    }
}

// 定义一个表示单词含义的结构体
struct Meaning: Codable {
    let definition: String            // 英文定义/释义
    let chineseDefinition: String     // 中文定义/释义
    let partOfSpeech: PartOfSpeech    // 此含义对应的词性
    let examples: [Sentence]          // 使用例句，现在包含英文和中文
    let synonyms: [String]            // 同义词
    let antonyms: [String]            // 反义词
    
    init(definition: String, chineseDefinition: String = "", partOfSpeech: PartOfSpeech, 
         examples: [Sentence] = [], synonyms: [String] = [], antonyms: [String] = []) {
        self.definition = definition
        self.chineseDefinition = chineseDefinition
        self.partOfSpeech = partOfSpeech
        self.examples = examples
        self.synonyms = synonyms
        self.antonyms = antonyms
    }
}

// 定义一个结构体来存储动词的不同形式
struct VerbForms: Codable {
    let base: String            // 原形
    let thirdPersonSingular: String  // 第三人称单数
    let presentParticiple: String    // 现在分词
    let pastTense: String           // 过去式
    let pastParticiple: String      // 过去分词
}

// 定义一个结构体来存储名词的不同形式
struct NounForms: Codable {
    let singular: String        // 单数形式
    let plural: String          // 复数形式
}

// 定义一个结构体来存储形容词的不同形式
struct AdjectiveForms: Codable {
    let base: String            // 原级
    let comparative: String     // 比较级
    let superlative: String     // 最高级
}

// 定义单词变形的结构体，包含词性和对应的变形
struct WordForm: Codable {
    let partOfSpeech: PartOfSpeech
    
    // 定义一个枚举来封装不同形式的变形
    enum Form: Codable {
        case noun(NounForms)
        case verb(VerbForms)
        case adjective(AdjectiveForms)
        case invariable(String)     // 不变形的词
        
        // 为了支持 Codable，需要自定义编码和解码逻辑
        enum CodingKeys: String, CodingKey {
            case type
            case data
        }
        
        enum FormType: String, Codable {
            case noun
            case verb
            case adjective
            case invariable
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .noun(let nounForms):
                try container.encode(FormType.noun, forKey: .type)
                try container.encode(nounForms, forKey: .data)
            case .verb(let verbForms):
                try container.encode(FormType.verb, forKey: .type)
                try container.encode(verbForms, forKey: .data)
            case .adjective(let adjectiveForms):
                try container.encode(FormType.adjective, forKey: .type)
                try container.encode(adjectiveForms, forKey: .data)
            case .invariable(let word):
                try container.encode(FormType.invariable, forKey: .type)
                try container.encode(word, forKey: .data)
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(FormType.self, forKey: .type)
            
            switch type {
            case .noun:
                let nounForms = try container.decode(NounForms.self, forKey: .data)
                self = .noun(nounForms)
            case .verb:
                let verbForms = try container.decode(VerbForms.self, forKey: .data)
                self = .verb(verbForms)
            case .adjective:
                let adjectiveForms = try container.decode(AdjectiveForms.self, forKey: .data)
                self = .adjective(adjectiveForms)
            case .invariable:
                let word = try container.decode(String.self, forKey: .data)
                self = .invariable(word)
            }
        }
    }
    
    let form: Form
    
    // 便捷初始化方法 - 动词
    static func verb(base: String, thirdPersonSingular: String, presentParticiple: String, pastTense: String, pastParticiple: String) -> WordForm {
        let verbForms = VerbForms(
            base: base,
            thirdPersonSingular: thirdPersonSingular,
            presentParticiple: presentParticiple,
            pastTense: pastTense,
            pastParticiple: pastParticiple
        )
        return WordForm(partOfSpeech: .verb, form: .verb(verbForms))
    }
    
    // 便捷初始化方法 - 名词
    static func noun(singular: String, plural: String) -> WordForm {
        let nounForms = NounForms(singular: singular, plural: plural)
        return WordForm(partOfSpeech: .noun, form: .noun(nounForms))
    }
    
    // 便捷初始化方法 - 形容词
    static func adjective(base: String, comparative: String, superlative: String) -> WordForm {
        let adjectiveForms = AdjectiveForms(base: base, comparative: comparative, superlative: superlative)
        return WordForm(partOfSpeech: .adjective, form: .adjective(adjectiveForms))
    }
    
    // 便捷初始化方法 - 不变形的词
    static func invariable(word: String, partOfSpeech: PartOfSpeech) -> WordForm {
        return WordForm(partOfSpeech: partOfSpeech, form: .invariable(word))
    }
}

// 然后定义单词结构体
struct EnglishWord: Codable {
    // 存储原始单词
    let word: String
    
    // 单词的发音
    let pronunciation: String?
    
    // 存储单词的不同变形形式，按词性组织
    let forms: [WordForm]
    
    // 存储单词的多种含义
    let meanings: [Meaning]
    
    // 初始化方法
    init(word: String, pronunciation: String? = nil, forms: [WordForm], meanings: [Meaning]) {
        self.word = word
        self.pronunciation = pronunciation
        self.forms = forms
        self.meanings = meanings
    }
    
    // 获取特定词性下的所有含义
    func getMeanings(for partOfSpeech: PartOfSpeech) -> [Meaning] {
        return meanings.filter { $0.partOfSpeech == partOfSpeech }
    }
    
    // 获取特定词性的变形形式
    func getForm(for partOfSpeech: PartOfSpeech) -> WordForm? {
        return forms.first { $0.partOfSpeech == partOfSpeech }
    }
    
    // 获取单词所有的词性
    var partsOfSpeech: [PartOfSpeech] {
        return Array(Set(meanings.map { $0.partOfSpeech }))
    }
    
    // JSON 序列化方法
    func toJSON() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)!
    }
    
    // 从 JSON 创建单词的静态方法
    static func fromJSON(_ json: String) throws -> EnglishWord {
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8)!
        return try decoder.decode(EnglishWord.self, from: data)
    }
}





import Foundation

// Function to read and parse JSON files in the current directory
func loadEnglishWordsFromJSONFiles() -> [EnglishWord] {
    let fileManager = FileManager.default
    let currentDirectoryPath = fileManager.currentDirectoryPath
    var allWords: [EnglishWord] = []
    
    do {
        let fileURLs = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: currentDirectoryPath), 
                                                          includingPropertiesForKeys: nil)
        
        // Filter for JSON files that match the pattern N-words.json
        let jsonFiles = fileURLs.filter { url in
            let isJson = url.pathExtension == "json"
            if !isJson { return false }
            
            let pattern = "^\\d+-words\\.json$"
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: url.lastPathComponent.utf16.count)
            return regex?.firstMatch(in: url.lastPathComponent, options: [], range: range) != nil
        }
        
        for fileURL in jsonFiles.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            print("Processing file: \(fileURL.lastPathComponent)")
            
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let words = try decoder.decode([EnglishWord].self, from: data)
            
            allWords.append(contentsOf: words)
            print("Loaded \(words.count) words from \(fileURL.lastPathComponent)")
        }
    } catch {
        print("Error loading JSON files: \(error)")
    }
    
    return allWords
}

// Function to determine the form type of a word
func getFormType(word: String, wordForm: WordForm, formValue: String) -> String {
    switch wordForm.form {
    case .noun(let nounForms):
        if formValue == nounForms.singular {
            return "singular"
        } else if formValue == nounForms.plural {
            return "plural"
        }
    case .verb(let verbForms):
        if formValue == verbForms.base {
            return "base"
        } else if formValue == verbForms.thirdPersonSingular {
            return "thirdPersonSingular"
        } else if formValue == verbForms.presentParticiple {
            return "presentParticiple"
        } else if formValue == verbForms.pastTense {
            return "pastTense"
        } else if formValue == verbForms.pastParticiple {
            return "pastParticiple"
        }
    case .adjective(let adjectiveForms):
        if formValue == adjectiveForms.base {
            return "base"
        } else if formValue == adjectiveForms.comparative {
            return "comparative"
        } else if formValue == adjectiveForms.superlative {
            return "superlative"
        }
    case .invariable(let invariableForm):
        if formValue == invariableForm {
            return "invariable"
        }
    }
    return "unknown"
}

// Function to generate the output text for each meaning
func generateOutputLines(from words: [EnglishWord]) -> [String] {
    var outputLines: [String] = []
    
    for word in words {
        for meaning in word.meanings {
            // Skip meanings without examples
            guard let firstExample = meaning.examples.first else { continue }
            
            // Get all possible forms to match against the example
            var allForms: [(form: String, wordForm: WordForm)] = []
            for wordForm in word.forms {
                switch wordForm.form {
                case .noun(let nounForms):
                    allForms.append((nounForms.singular, wordForm))
                    allForms.append((nounForms.plural, wordForm))
                case .verb(let verbForms):
                    allForms.append((verbForms.base, wordForm))
                    allForms.append((verbForms.thirdPersonSingular, wordForm))
                    allForms.append((verbForms.presentParticiple, wordForm))
                    allForms.append((verbForms.pastTense, wordForm))
                    allForms.append((verbForms.pastParticiple, wordForm))
                case .adjective(let adjectiveForms):
                    allForms.append((adjectiveForms.base, wordForm))
                    allForms.append((adjectiveForms.comparative, wordForm))
                    allForms.append((adjectiveForms.superlative, wordForm))
                case .invariable(let invariableForm):
                    allForms.append((invariableForm, wordForm))
                }
            }
            
            // Sort forms by length (descending) to match longer forms first
            allForms.sort { $0.form.count > $1.form.count }
            
            // Find the form that appears in the example
            let originalExample = firstExample.english
            let lowercaseExample = originalExample.lowercased()
            
            var answer = word.word // Default to the base word if no match found
            var example = originalExample
            var formType = "unknown"
            var matchedWordForm: WordForm? = nil
            
            for (form, wordForm) in allForms {
                if lowercaseExample.contains(form.lowercased()) {
                    answer = form
                    matchedWordForm = wordForm
                    formType = getFormType(word: word.word, wordForm: wordForm, formValue: form)
                    
                    // Create the example with the answer blanked out
                    do {
                        let pattern = "(?i)\(NSRegularExpression.escapedPattern(for: form))"
                        let regex = try NSRegularExpression(pattern: pattern)
                        let range = NSRange(originalExample.startIndex..<originalExample.endIndex, in: originalExample)
                        example = regex.stringByReplacingMatches(
                            in: originalExample,
                            range: range,
                            withTemplate: "{{c1::\(form)}}"
                        )
                    } catch {
                        print("Error creating regex for form '\(form)': \(error)")
                        example = originalExample.replacingOccurrences(
                            of: form,
                            with: "{{c1::\(form)}}",
                            options: .caseInsensitive
                        )
                    }
                    break
                }
            }
            
            // Format synonyms and antonyms
            let synonyms = meaning.synonyms.joined(separator: ", ")
            let antonyms = meaning.antonyms.joined(separator: ", ")
            
            // Construct the output line with the new form field
            let outputLine = [
                answer,
                formType,
                example,
                originalExample,
                firstExample.chinese,
                meaning.definition,
                meaning.chineseDefinition,
                word.word,
                meaning.partOfSpeech.rawValue,
                synonyms,
                antonyms
            ].joined(separator: "|")
            
            outputLines.append(outputLine)
        }
    }
    
    return outputLines
}

// Main execution
func main() {
    print("Starting to process English word files...")
    
    let words = loadEnglishWordsFromJSONFiles()
    print("Loaded \(words.count) words in total")
    
    let outputLines = generateOutputLines(from: words)
    print("Generated \(outputLines.count) output lines")
    
    // Write to output file
    let outputString = outputLines.joined(separator: "\n")
    let outputURL = URL(fileURLWithPath: "word_data_output.txt")
    
    do {
        try outputString.write(to: outputURL, atomically: true, encoding: .utf8)
        print("Successfully wrote output to \(outputURL.path)")
    } catch {
        print("Error writing output file: \(error)")
    }
}

// Run the script
main()

