//
//  PaymentRequest.dto.swift
//
//  Created by Juan David (@juandl) on 12/05/2024.
//

import Foundation
import PassKit

class ApplePayPaymentResponseDto: Codable {
    let paymentData, transactionIdentifier: String

    init (with pkPayment: PKPayment) {
        self.transactionIdentifier = pkPayment.token.transactionIdentifier
        self.paymentData = pkPayment.token.paymentData.base64EncodedString()
    }
}

enum ApplePayPaymentResponseErrorDto: Error, LocalizedError, Encodable {
    case closed
    case notpresent
    case paymentnotstarted
    case notparse

    var errorDescription: String? {
        switch self {
        case .closed:
            return "User cancelled the payment"
        case .notpresent:
            return "Unable to present the payment authorization."
        case .paymentnotstarted:
            return "Payment has not been authorized yet or handler is missing"
        case .notparse:
            return "Could not proccess or parse payment"
        }
    }
}

extension ApplePayPaymentResponseDto {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to convert to dictionary"])
        }
        
        return dictionary
    }
}

class ApplePayPaymentCompleteDto: Codable {
    enum Status: String, Codable {
        case success
        case failure
    }

    let status: Status?

    func asResult() -> PKPaymentAuthorizationResult? {
        guard let status = status else { return nil }
        
        switch status {
        case .success:
            return PKPaymentAuthorizationResult(status: .success, errors: nil)
        case .failure:
            return PKPaymentAuthorizationResult(status: .failure, errors: nil)
        }
    }
}
