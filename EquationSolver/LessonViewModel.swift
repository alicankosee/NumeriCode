import Foundation

class LessonViewModel {
    private var module: ModuleType?
    var lessonContent: LessonContent? {
        didSet { onContentUpdate?(lessonContent) }
    }
    var onContentUpdate: ((LessonContent?) -> Void)?
    
    func setModule(_ module: ModuleType) {
        self.module = module
    }
    
    func getCurrentModule() -> ModuleType? {
        return module
    }
    
    func loadContent() {
        guard let module = module,
              let content = ContentLoader.loadContent(for: module) else { return }
        lessonContent = content.lesson
    }
}
 