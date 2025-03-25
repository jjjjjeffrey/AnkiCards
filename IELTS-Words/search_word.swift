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

// Function to search for a word in JSON files
func searchWordInJSONFiles(word: String) {
    let fileManager = FileManager.default
    let currentDirectoryPath = fileManager.currentDirectoryPath
    var matchingFiles: [String] = []
    
    print("Searching for word '\(word)' in JSON files...")
    
    do {
        let fileURLs = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: currentDirectoryPath), 
                                                          includingPropertiesForKeys: nil)
        
        // Filter for JSON files
        let jsonFiles = fileURLs.filter { url in
            return url.pathExtension == "json"
        }
        
        print("Found \(jsonFiles.count) JSON files to search")
        
        for fileURL in jsonFiles {
            let fileName = fileURL.lastPathComponent
            
            do {
                let data = try Data(contentsOf: fileURL)
                
                // First try to parse as an array of EnglishWord
                if let jsonString = String(data: data, encoding: .utf8) {
                    if jsonString.lowercased().contains("\"word\"\\s*:\\s*\"\(word.lowercased())\"") ||
                       jsonString.lowercased().contains("\"word\"\\s*:\\s*\"\(word.lowercased()),") ||
                       jsonString.lowercased().contains("\"word\"\\s*:\\s*\"\(word.lowercased())\\s") {
                        
                        matchingFiles.append(fileName)
                        continue
                    }
                }
                
                // Try to decode the JSON to check more precisely
                let decoder = JSONDecoder()
                
                // Try as array of EnglishWord
                if let words = try? decoder.decode([EnglishWord].self, from: data) {
                    for englishWord in words {
                        if englishWord.word.lowercased() == word.lowercased() {
                            matchingFiles.append(fileName)
                            break
                        }
                    }
                }
                // Try as single EnglishWord
                else if let singleWord = try? decoder.decode(EnglishWord.self, from: data) {
                    if singleWord.word.lowercased() == word.lowercased() {
                        matchingFiles.append(fileName)
                    }
                }
            } catch {
                print("Error processing file \(fileName): \(error)")
            }
        }
    } catch {
        print("Error listing directory contents: \(error)")
    }
    
    // Output results
    print("\nSearch Results:")
    if matchingFiles.isEmpty {
        print("No files found containing the word '\(word)'")
    } else {
        print("Found \(matchingFiles.count) files containing the word '\(word)':")
        for fileName in matchingFiles.sorted() {
            print("- \(fileName)")
        }
    }
}

// Main execution
func main() {
    print("Word Search in JSON Files")
    print("========================")
    
    // Check if word was provided as command line argument
    let arguments = CommandLine.arguments
    var searchWord: String
    
    if arguments.count > 1 {
        searchWord = arguments[1]
    } else {
        // Prompt for word if not provided as argument
        print("Enter a word to search for:")
        if let input = readLine(), !input.isEmpty {
            searchWord = input
        } else {
            print("No word provided. Exiting.")
            return
        }
    }
    
    searchWordInJSONFiles(word: searchWord)
}

// Run the script
main()
