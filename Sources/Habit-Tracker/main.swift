import SwiftUI
import CoreData

// MARK: - Data Model
struct Habit: Identifiable {
    let id = UUID()
    var name: String
    var streak: Int
    var lastCompletedDate: Date?
    var frequency: Frequency
    
    enum Frequency: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
    }
}

// MARK: - View Models
class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    
    func addHabit(name: String, frequency: Habit.Frequency) {
        let habit = Habit(name: name, streak: 0, lastCompletedDate: nil, frequency: frequency)
        habits.append(habit)
    }
    
    func completeHabit(habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            var updatedHabit = habit
            let calendar = Calendar.current
            
            if let lastCompleted = habit.lastCompletedDate {
                let isConsecutive = habit.frequency == .daily
                    ? calendar.isDate(lastCompleted, inSameDayAs: Date().addingTimeInterval(-86400))
                    : calendar.isDate(lastCompleted, inSameDayAs: Date().addingTimeInterval(-604800))
                
                updatedHabit.streak = isConsecutive ? habit.streak + 1 : 1
            } else {
                updatedHabit.streak = 1
            }
            
            updatedHabit.lastCompletedDate = Date()
            habits[index] = updatedHabit
        }
    }
}

// MARK: - Views
struct ContentView: View {
    @StateObject private var viewModel = HabitViewModel()
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.habits) { habit in
                    HabitRowView(habit: habit, viewModel: viewModel)
                }
            }
            .navigationTitle("Habit Tracker")
            .toolbar {
                Button(action: { showingAddHabit = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(viewModel: viewModel)
            }
        }
    }
}

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(habit.name)
                    .font(.headline)
                Text("\(habit.frequency.rawValue) - Streak: \(habit.streak)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { viewModel.completeHabit(habit: habit) }) {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(habit.lastCompletedDate.map { Calendar.current.isDateInToday($0) } ?? false
                        ? .green
                        : .gray)
                    .imageScale(.large)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitViewModel
    @State private var habitName = ""
    @State private var frequency = Habit.Frequency.daily
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Habit Name", text: $habitName)
                
                Picker("Frequency", selection: $frequency) {
                    ForEach(Habit.Frequency.allCases, id: \.self) { frequency in
                        Text(frequency.rawValue).tag(frequency)
                    }
                }
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Add") {
                        guard !habitName.isEmpty else { return }
                        viewModel.addHabit(name: habitName, frequency: frequency)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}