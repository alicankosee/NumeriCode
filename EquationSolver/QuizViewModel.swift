import Foundation

class QuizViewModel {
    private var questions: [QuizQuestion] = []
    private var currentIndex = 0
    private var score = 0
    private var module: ModuleType?
    
    var onQuestionUpdate: ((QuizQuestion?, Int, Int) -> Void)?
    var onQuizEnd: ((Int, Int) -> Void)?
    
    func setModule(_ module: ModuleType) {
        self.module = module
    }
    
    func loadContent() {
        guard let module = module,
              let content = ContentLoader.loadContent(for: module) else { return }
        questions = content.quiz
        currentIndex = 0
        score = 0
        showCurrentQuestion()
    }
    
    func answerQuestion(selectedIndex: Int) {
        guard currentIndex < questions.count else { return }
        
        if selectedIndex == questions[currentIndex].correctIndex {
            score += 1
        }
        
        currentIndex += 1
        
        // The transition to next question will be handled by the view after feedback delay
        // We don't immediately show the next question here
    }
    
    func transitionToNextQuestion() {
        if currentIndex < questions.count {
            showCurrentQuestion()
        } else {
            onQuizEnd?(score, questions.count)
            if let module = module {
                ModuleProgressManager.shared.markCompleted(module: module.contentFileName)
            }
        }
    }
    
    private func showCurrentQuestion() {
        guard currentIndex < questions.count else { return }
        onQuestionUpdate?(questions[currentIndex], currentIndex, score)
    }
} 