import Foundation

enum Command: String {
    case add
    case list
    case toggle
    case delete
    case exit
}

// * Create the `Todo` struct.
// * Ensure it has properties: id (UUID), title (String), and isCompleted (Bool).
struct Todo: Codable {
    var id: UUID
    var title: String
    var isCompleted: Bool
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {
    func save(todos: [Todo])
    func load() -> [Todo]?
}

// `FileSystemCache`: This implementation should utilize the file system 
// to persist and retrieve the list of todos. 
// Utilize Swift's `FileManager` to handle file operations.
final class JSONFileManagerCache: Cache {
    private let fileName = "todos.json"
    private let fileManager = FileManager.default

    private var fileURL: URL? {
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentDirectory.appendingPathComponent(fileName)
    }

    func save(todos: [Todo]) {
        guard let fileURL = fileURL else { return }
        do {
            let data = try JSONEncoder().encode(todos)
            try data.write(to: fileURL)
        } catch {
            print("Error saving todos: \(error)")
        }
    }

    func load() -> [Todo]? {
        guard let fileURL = fileURL, fileManager.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            let todos = try JSONDecoder().decode([Todo].self, from: data)
            return todos
        } catch {
            print("Error loading todos: \(error)")
            return nil
        }
    }
}

// `InMemoryCache`: : Keeps todos in an array or similar structure during the session. 
// This won't retain todos across different app launches, 
// but serves as a quick in-session cache.
final class InMemoryCache: Cache {
    private var todos: [Todo] = []
    
    func save(todos: [Todo]) {
        self.todos = todos
    }
    
    func load() -> [Todo]? {
        return todos.isEmpty ? nil : todos
    }
}

// The `TodosManager` class should have:
// * A function `func listTodos()` to display all todos.
// * A function named `func addTodo(with title: String)` to insert a new todo.
// * A function named `func toggleCompletion(forTodoAtIndex index: Int)` 
//   to alter the completion status of a specific todo using its index.
// * A function named `func deleteTodo(atIndex index: Int)` to remove a todo using its index.
final class TodoManager {
    var todos: [Todo] = []
    
    func addTodo(with title: String) -> Bool {
        var success = true
        if !title.isEmpty{
            let newTodo = Todo(id: UUID(), title: title, isCompleted: false)
            todos.append(newTodo)
        }else{
            print("\n Invalid Todo title: \(title)")
            success = false
        }
        return success
    }
    
    func toggleCompletion(forTodoAtIndex index: Int) {
        if index >= 0 && index < todos.count {
            todos[index].isCompleted.toggle()
        }else{
            print("Invalid TODO \(index)")
            self.listTodos()
        }
    }

    func listTodos() {
        if todos.isEmpty {
            print("No todos available.")
        } else {
            for (index, todo) in todos.enumerated() {
                let status = todo.isCompleted ? "✅" : "❌"
                print("\(index + 1). \(todo.title) [\(status)]")
            }
        }
    }
    
    func deleteTodo(atIndex index: Int) -> Bool {
        var success = false
        if index >= 0 && index < todos.count {
            todos.remove(at: index)
            success = true
        }
        return success
    }
}

// `App` class with a `run()` method that perpetually awaits user input and executes commands.
final class App {
    private let todoManager = TodoManager()
    
    func getMenuEntry() -> String? {
        print("What would you like to do? (add, list, toggle, delete, exit): ", terminator: "")
        return readLine()
    }

    func getTodoTitle() -> String? {
        print("Enter todo title: ", terminator: "")
        return readLine()
    }

    func getTodoIndex() -> Int? {
        print("\nEnter the number of the todo: ", terminator: "")
        if let input = readLine(), let index = Int(input) {
            return index - 1
        }
        return nil
    }

    func takeAction(entry: String) -> Bool {
        guard let command = Command(rawValue: entry) else {
            print("\nInvalid command. Please try again.")
            return true
        }

        switch command {
        case .add:
            if let todoTitle = getTodoTitle() {
                let success = todoManager.addTodo(with: todoTitle)
                if success{
                    print("\nTodo added.")
                }
            }

        case .list:
            todoManager.listTodos()

        case .toggle:
            todoManager.listTodos()
            if let index = getTodoIndex() {
                todoManager.toggleCompletion(forTodoAtIndex: index)
                print("\nTodo status updated.")
            }

        case .delete:
            todoManager.listTodos()
            if let index = getTodoIndex() {
                let success = todoManager.deleteTodo(atIndex: index)
                if success{
                    print("\nTodo deleted.")
                }
            }

        case .exit:
            print("\nExiting...")
            return false
        }
        return true
    }

    func run() {
        print("====================================================================================")
        print("============================ 🌟 WELCOME TO TODOS CLI APP 🌟 ========================")
        print("====================================================================================")
        print("\n")

        var mustContinue = true
        while mustContinue {
            if let userEntry = getMenuEntry() {
                mustContinue = takeAction(entry: userEntry)
            }
        }
    }
}

// Start the app
let app = App()
app.run()
