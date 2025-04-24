// Your task is to finish this application to satisfy requirements below and make it look like on the attached screenshots. Try to use 80/20 principle.
// Good luck! 🍀

// 1. Setup UI of the ContentView. Try to keep it as similar as possible.
// 2. Subscribe to the timer and count seconds down from 60 to 0 on the ContentView.
// 3. Present PaymentModalView as a sheet after tapping on the "Open payment" button.
// 4. Load payment types from repository in PaymentInfoView. Show loader when waiting for the response. No need to handle error.
// 5. List should be refreshable.
// 6. Show search bar for the list to filter payment types. You can filter items in any way.
// 7. User should select one of the types on the list. Show checkmark next to the name when item is selected.
// 8. Show "Done" button in navigation bar only if payment type is selected. Tapping this button should hide the modal.
// 9. Show "Finish" button on ContentScreen only when "payment type" was selected.
// 10. Replace main view with "FinishView" when user taps on the "Finish" button.

import SwiftUI
import Combine

class Model: ObservableObject {

    let processDurationInSeconds: Int = 60
    var repository: PaymentTypesRepository = PaymentTypesRepositoryImplementation()
    var cancellables: [AnyCancellable] = []

    init() {
//        Timer.publish(every: 1, on: .main, in: .common)
//            .autoconnect()
//            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @State private var secondsRemaining = 60
    @State private var isModalPresented = false
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            Text("You have only \(secondsRemaining) seconds left to get the discount")
                .font(.headline)
                .padding()

            Button("Open payment") {
                isModalPresented = true
                startTimer()
            }
            .padding()

            // Show finish view
            if secondsRemaining == 0 {
                Button("Finish", action: {})
                    .padding()
            }
        }
        .sheet(isPresented: $isModalPresented) {
            PaymentModalView()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    func startTimer() {
        timer?.invalidate()
        secondsRemaining = 60
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            }
        }
    }
}

struct FinishView: View {
    var body: some View {
        Text("Congratulations")
    }
}

struct PaymentModalView : View {
    var body: some View {
        NavigationView {
            PaymentInfoView()
        }
    }
}

struct PaymentInfoView: View {
    @State private var paymentTypes: [PaymentType] = []
    @State private var selectedTypeID: String? = nil
    @State private var isLoading: Bool = true
    @State private var searchText: String = ""

    var repository: PaymentTypesRepository = PaymentTypesRepositoryImplementation()

    var filteredTypes: [PaymentType] {
        paymentTypes.filter { searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        VStack {
            // Search bar
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Loader
            if isLoading {
                ProgressView("Loading payment types...")
            } else {
                List(filteredTypes) { type in
                    HStack {
                        Text(type.name)
                        Spacer()
                        if selectedTypeID == type.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .onTapGesture {
                        selectedTypeID = type.id
                    }
                }
            }
        }
        .onAppear {
            loadPaymentTypes()
        }
        .navigationTitle("Payment Info")
        .navigationBarItems(trailing: Button("Finish") {
            print("Modal closed with selection: \(selectedTypeID ?? "None")")
        }.disabled(selectedTypeID == nil))
    }

    func loadPaymentTypes() {
        isLoading = true
        repository.getTypes { result in
            switch result {
            case .success(let types):
                self.paymentTypes = types
            case .failure:
                self.paymentTypes = []
            }
            self.isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
