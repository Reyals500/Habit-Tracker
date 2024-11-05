import XCTest
@testable import Habit_Tracker

final class HabitViewModelTests: XCTestCase {
    var viewModel: HabitViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = HabitViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testAddHabit() {
        // Given
        let habitName = "Exercise"
        let frequency = Habit.Frequency.daily
        
        // When
        viewModel.addHabit(name: habitName, frequency: frequency, reminderTime: nil)
        
        // Then
        XCTAssertEqual(viewModel.habits.count, 1)
        XCTAssertEqual(viewModel.habits[0].name, habitName)
        XCTAssertEqual(viewModel.habits[0].frequency, frequency)
        XCTAssertEqual(viewModel.habits[0].streak, 0)
    }
    
    func testCompleteHabit() {
        // Given
        let habit = Habit(name: "Exercise", streak: 0, lastCompletedDate: nil, frequency: .daily)
        viewModel.habits = [habit]
        
        // When
        viewModel.completeHabit(habit: habit)
        
        // Then
        XCTAssertEqual(viewModel.habits[0].streak, 1)
        XCTAssertNotNil(viewModel.habits[0].lastCompletedDate)
    }
    
    func testStreak_ConsecutiveDays() {
        // Given
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let habit = Habit(name: "Exercise", streak: 1, lastCompletedDate: yesterday, frequency: .daily)
        viewModel.habits = [habit]
        
        // When
        viewModel.completeHabit(habit: habit)
        
        // Then
        XCTAssertEqual(viewModel.habits[0].streak, 2)
    }
    
    func testStreak_BreakStreak() {
        // Given
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let habit = Habit(name: "Exercise", streak: 5, lastCompletedDate: twoDaysAgo, frequency: .daily)
        viewModel.habits = [habit]
        
        // When
        viewModel.completeHabit(habit: habit)
        
        // Then
        XCTAssertEqual(viewModel.habits[0].streak, 1)
    }
    
    func testUpdateHabitReminder() {
        // Given
        let habit = Habit(name: "Exercise", streak: 0, lastCompletedDate: nil, frequency: .daily)
        viewModel.habits = [habit]
        let reminderTime = Date()
        
        // When
        viewModel.updateHabitReminder(habit: habit, newTime: reminderTime)
        
        // Then
        XCTAssertEqual(viewModel.habits[0].reminderTime, reminderTime)
    }
}

final class HabitModelTests: XCTestCase {
    func testHabitInitialization() {
        // Given
        let name = "Exercise"
        let frequency = Habit.Frequency.daily
        
        // When
        let habit = Habit(name: name, streak: 0, lastCompletedDate: nil, frequency: frequency)
        
        // Then
        XCTAssertEqual(habit.name, name)
        XCTAssertEqual(habit.frequency, frequency)
        XCTAssertEqual(habit.streak, 0)
        XCTAssertNil(habit.lastCompletedDate)
        XCTAssertNil(habit.reminderTime)
        XCTAssertNil(habit.notificationId)
    }
}