import Foundation

struct PaymentType: Identifiable {
    var id = UUID().uuidString
    var name: String
}

enum PaymentError: Error {
    case timeout
}

protocol PaymentTypesRepository {
    func getTypes(completion: @escaping (Swift.Result<[PaymentType], PaymentError>) -> Void)
}

class PaymentTypesRepositoryImplementation: PaymentTypesRepository {
    private var types: [PaymentType] {
        [
            PaymentType(name: "Apple Pay"),
            PaymentType(name: "Visa"),
            PaymentType(name: "Mastercard"),
            PaymentType(name: "Maestro"),
            PaymentType(name: "Google pay")
        ].shuffled()
    }

    func getTypes(completion: @escaping (Swift.Result<[PaymentType], PaymentError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(.success(self.types))
        }
    }
}
