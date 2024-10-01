import XCTest
@testable import Sources

final class AppTests: XCTestCase {
    
    // Test the Todo struct
    func testTodoInitialization() {
        let todo = Todo(id: UUID(), title: "Test Todo", isCompleted: false)
        XCTAssertEqual(todo.title, "Test Todo")
        XCTAssertFalse(todo.isCompleted)
    }

    // Test the TodoManager adding functionality
    func testAddTodo() {
        let todoManager = TodoManager()
        todoManager.addTodo(with: "First Todo")
        XCTAssertEqual(todoManager.todos.count, 1)
        XCTAssertEqual(todoManager.todos[0].title, "First Todo")
        XCTAssertFalse(todoManager.todos[0].isCompleted)
    }

    // Test the TodoManager toggling functionality
    func testToggleTodoCompletion() {
        let todoManager = TodoManager()
        todoManager.addTodo(with: "Toggle Todo")
        todoManager.toggleCompletion(forTodoAtIndex: 0)
        XCTAssertTrue(todoManager.todos[0].isCompleted)
        todoManager.toggleCompletion(forTodoAtIndex: 0)
        XCTAssertFalse(todoManager.todos[0].isCompleted)
    }

    // Test the TodoManager delete functionality
    func testDeleteTodo() {
        let todoManager = TodoManager()
        todoManager.addTodo(with: "Delete Todo")
        XCTAssertEqual(todoManager.todos.count, 1)
        todoManager.deleteTodo(atIndex: 0)
        XCTAssertEqual(todoManager.todos.count, 0)
    }

    // Test InMemoryCache save and load
    func testInMemoryCacheSaveLoad() {
        let cache = InMemoryCache()
        let todo = Todo(id: UUID(), title: "In Memory Todo", isCompleted: false)
        cache.save(todos: [todo])
        let loadedTodos = cache.load()
        XCTAssertNotNil(loadedTodos)
        XCTAssertEqual(loadedTodos?.count, 1)
        XCTAssertEqual(loadedTodos?[0].title, "In Memory Todo")
    }

    // Test JSONFileManagerCache save and load (for simplicity, we mock the file system operations)
    func testFileSystemCacheSaveLoad() {
        let fileManagerCache = JSONFileManagerCache()

        // Mock a sample Todo
        let todo = Todo(id: UUID(), title: "File Todo", isCompleted: false)

        // Save the todos
        fileManagerCache.save(todos: [todo])

        // Load the todos
        let loadedTodos = fileManagerCache.load()

        // Ensure the todos are properly saved and loaded
        XCTAssertNotNil(loadedTodos)
        XCTAssertEqual(loadedTodos?.count, 1)
        XCTAssertEqual(loadedTodos?[0].title, "File Todo")
    }
}
