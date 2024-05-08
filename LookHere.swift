import Foundation
import SwiftData

// 👇 This is the enabler extension
extension Optional: Comparable where Wrapped: Comparable {
    public static func < (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        guard let lhs, let rhs else { return false }
        return lhs < rhs
    }
}

@Model class TodoModel {
    @Attribute(.unique) var id: String
    var taskName: String
    var number: Int? // 👈 This is the optional we are going to predicate on
    var time: Date?
    var isActive: Bool?

    init(id: String, taskName: String, number: Int?, time: Date?) {
        self.id = id
        self.taskName = taskName
        self.number = number
        self.time = time
    }
}

class DatabaseService {
    let numberPredicate = #Predicate<TodoModel> { 
        $0.number < 5 // 👈 This is a compare agains an optional
                      // This will not even compile without the above extension.
        && $0.isActive == true
    }

    static var shared = DatabaseService()
    lazy var container = try! ModelContainer(for: TodoModel.self)
    lazy var context = ModelContext(container)

    var accumulator = 0

    func saveTask(taskName: String?){
        guard let taskName else { return }
        accumulator += 1
        let taskToBeSaved = TodoModel(id: UUID().uuidString, taskName: taskName, number: accumulator, time: Date())
        context.insert(taskToBeSaved)
    }

    func fetchTasks(onCompletion: @escaping([TodoModel]?, Error?) -> Void)  {
        let descriptor = FetchDescriptor<TodoModel>(predicate: numberPredicate)
        do {
            let data = try context.fetch(descriptor)
            onCompletion(data, nil)
        } catch {
            onCompletion(nil, error)
        }
    }
    
    func updateTask(task: TodoModel, newTaskName: String){
        let taskToBeUpdated = task
        taskToBeUpdated.taskName = newTaskName
    }
    
    func deleteTask(task: TodoModel){
        let taskToBeDeleted = task
        context.delete(taskToBeDeleted)
    }
}




