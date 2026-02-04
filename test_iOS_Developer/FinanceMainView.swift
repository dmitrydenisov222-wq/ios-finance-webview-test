import SwiftUI

// MARK: - Models

/// Тип финансовой операции.
enum TransactionType: String, CaseIterable, Identifiable, Codable {
    case income = "Доход"
    case expense = "Расход"

    var id: String { rawValue }
}

/// Одна финансовая операция.
struct Transaction: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Double
    let type: TransactionType
    let title: String
}

private enum FinanceDefaultsKeys {
    static let transactions = "transactions"
}

// MARK: - Main finance screen

struct FinanceMainView: View {
    @State private var transactions: [Transaction] = []
    @State private var showingAddSheet = false

    /// Текущий баланс на основе всех операций.
    private var balance: Double {
        transactions.reduce(0) { result, tx in
            switch tx.type {
            case .income:
                return result + tx.amount
            case .expense:
                return result - tx.amount
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                balanceHeader

                FinanceChartView(transactions: transactions)
                    .frame(height: 180)
                    .padding(.horizontal)

                transactionList
            }
            .navigationTitle("Финансы")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTransactionView { newTx in
                    transactions.append(newTx)
                    saveTransactions()
                }
            }
            .onAppear {
                loadTransactions()
            }
        }
    }

    // MARK: - Subviews

    private var balanceHeader: some View {
        VStack(spacing: 4) {
            Text("Баланс")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(String(format: "%.2f ₽", balance))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(balance >= 0 ? .green : .red)
        }
        .padding(.top)
    }

    private var transactionList: some View {
        List {
            ForEach(transactions.sorted(by: { $0.date > $1.date })) { tx in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tx.title)
                            .font(.body)

                        Text(dateFormatter.string(from: tx.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text((tx.type == .income ? "+" : "-") + String(format: "%.2f", tx.amount))
                        .foregroundColor(tx.type == .income ? .green : .red)
                }
            }
        }
    }

    // MARK: - Persistence

    private func saveTransactions() {
        do {
            let data = try JSONEncoder().encode(transactions)
            UserDefaults.standard.set(data, forKey: FinanceDefaultsKeys.transactions)
        } catch {
            print("Failed to encode transactions: \(error)")
        }
    }

    private func loadTransactions() {
        guard let data = UserDefaults.standard.data(forKey: FinanceDefaultsKeys.transactions) else { return }
        do {
            let decoded = try JSONDecoder().decode([Transaction].self, from: data)
            transactions = decoded
        } catch {
            print("Failed to decode transactions: \(error)")
        }
    }
}

// MARK: - Date formatting

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .short
    df.timeStyle = .short
    return df
}()

// MARK: - Add transaction sheet

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var type: TransactionType = .income
    @State private var date: Date = Date()

    let onSave: (Transaction) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Описание")) {
                    TextField("Название", text: $title)
                }

                Section(header: Text("Сумма")) {
                    TextField("0", text: $amountText)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Тип")) {
                    Picker("Тип", selection: $type) {
                        ForEach(TransactionType.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Дата")) {
                    DatePicker(
                        "Дата",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
            .navigationTitle("Новая операция")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        save()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        guard let _ = Double(amountText.replacingOccurrences(of: ",", with: ".")),
              !title.isEmpty else {
            return false
        }
        return true
    }

    private func save() {
        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) else { return }

        let tx = Transaction(
            id: UUID(),
            date: date,
            amount: amount,
            type: type,
            title: title
        )
        onSave(tx)
        dismiss()
    }
}

// MARK: - Chart view

/// Простой линейный график динамики баланса по операциям.
struct FinanceChartView: View {
    let transactions: [Transaction]

    var body: some View {
        GeometryReader { geo in
            let points = cumulativePoints()
            let maxValue = (points.map { $0.y }.max() ?? 0)
            let minValue = (points.map { $0.y }.min() ?? 0)
            let range = max(maxValue - minValue, 1)

            Path { path in
                guard !points.isEmpty else { return }

                for (index, point) in points.enumerated() {
                    let x = geo.size.width * CGFloat(index) / CGFloat(max(points.count - 1, 1))
                    let normalizedY = (point.y - minValue) / range
                    let y = geo.size.height * (1 - normalizedY)

                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }

    /// Формирует точки кумулятивного баланса по датам операций.
    private func cumulativePoints() -> [(x: Double, y: Double)] {
        let sorted = transactions.sorted(by: { $0.date < $1.date })
        var result: [(x: Double, y: Double)] = []
        var balance: Double = 0

        for (index, tx) in sorted.enumerated() {
            switch tx.type {
            case .income:
                balance += tx.amount
            case .expense:
                balance -= tx.amount
            }
            result.append((x: Double(index), y: balance))
        }
        return result
    }
}
