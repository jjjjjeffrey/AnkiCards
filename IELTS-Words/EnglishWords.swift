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

// 使用示例 - "book" 作为一个有多种词性和含义的单词
let bookMeanings = [
    Meaning(
        definition: "A written or printed work consisting of pages glued or sewn together along one side and bound in covers.",
        chineseDefinition: "一种由纸张装订成册的印刷品，通常包含文字和/或图片。",
        partOfSpeech: .noun,
        examples: [
            Sentence(
                english: "She's reading a book about astronomy.", 
                chinese: "她正在读一本关于天文学的书。"
            ),
            Sentence(
                english: "He published his first book last year.", 
                chinese: "他去年出版了他的第一本书。"
            )
        ]
    ),
    Meaning(
        definition: "A main division of a literary work or narrative.",
        chineseDefinition: "文学作品或叙事作品的主要分段。",
        partOfSpeech: .noun,
        examples: [
            Sentence(
                english: "The story was told in three books.", 
                chinese: "这个故事分为三卷叙述。"
            )
        ]
    ),
    Meaning(
        definition: "To reserve (something) for future use.",
        chineseDefinition: "预订（某物）以供将来使用。",
        partOfSpeech: .verb,
        examples: [
            Sentence(
                english: "I've booked a table at the restaurant.", 
                chinese: "我已经在餐厅预订了一张桌子。"
            ),
            Sentence(
                english: "You need to book in advance.", 
                chinese: "你需要提前预订。"
            )
        ]
    ),
    Meaning(
        definition: "To arrange for someone to have a seat on a plane, train, etc.",
        chineseDefinition: "为某人安排飞机、火车等的座位。",
        partOfSpeech: .verb,
        examples: [
            Sentence(
                english: "We booked our tickets online.", 
                chinese: "我们在网上订了票。"
            )
        ]
    )
]

let bookForms = [
    WordForm.noun(singular: "book", plural: "books"),
    WordForm.verb(base: "book", thirdPersonSingular: "books", presentParticiple: "booking", pastTense: "booked", pastParticiple: "booked")
]

// 创建一个有多种词性和含义的单词实例
let book = EnglishWord(
    word: "book",
    pronunciation: "/bʊk/",
    forms: bookForms,
    meanings: bookMeanings
)

// 演示 JSON 序列化和反序列化
do {
    // 序列化为 JSON
    let bookJSON = try book.toJSON()
    print("Book JSON:\n\(bookJSON)")
    
    // 从 JSON 反序列化
    let reconstructedBook = try EnglishWord.fromJSON(bookJSON)
    print("重建的单词: \(reconstructedBook.word)")
    print("含义数量: \(reconstructedBook.meanings.count)")
    
    // 显示例句（英文和中文）
    if let firstMeaning = reconstructedBook.meanings.first, let firstExample = firstMeaning.examples.first {
        print("例句(英): \(firstExample.english)")
        print("例句(中): \(firstExample.chinese)")
    }
    
    // 验证反序列化是否正确
    if let verbForm = reconstructedBook.getForm(for: .verb), case .verb(let verbForms) = verbForm.form {
        print("\(reconstructedBook.word) 动词形式的过去式: \(verbForms.pastTense)")
    }
    
    // 保存到文件
    let fileURL = URL(fileURLWithPath: "EnglishWords.json")
    try bookJSON.write(to: fileURL, atomically: true, encoding: .utf8)
    print("单词数据已保存到: \(fileURL.path)")
    
    // 创建一个单词词典示例
    let wordDictionary = [book]
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let dictionaryData = try encoder.encode(wordDictionary)
    let dictionaryJSON = String(data: dictionaryData, encoding: .utf8)!
    
    let dictionaryURL = URL(fileURLWithPath: "WordDictionary.json")
    try dictionaryJSON.write(to: dictionaryURL, atomically: true, encoding: .utf8)
    print("词典数据已保存到: \(dictionaryURL.path)")
    
} catch {
    print("错误: \(error)")
}
