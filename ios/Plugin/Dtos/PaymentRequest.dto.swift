//
//  PaymentRequest.dto.swift
//
//  Created by Juan David (@juandl) on 12/05/2024.
//

import Foundation
import PassKit

class ApplePayPaymentRequestDto: Codable {
    let total: Total
    let merchantIdentifier, countryCode, currencyCode: String
    let merchantCapabilities, supportedNetworks: [String]
    
    init(merchantIdentifier: String, merchantCapabilities: [String], supportedNetworks: [String], total: Total, countryCode: String, currencyCode: String) {
        self.merchantIdentifier = merchantIdentifier
        self.merchantCapabilities = merchantCapabilities
        self.supportedNetworks = supportedNetworks
        self.total = total
        self.countryCode = countryCode
        self.currencyCode = currencyCode
    }
    
    var paymentNetworks: [PKPaymentNetwork] {
        return supportedNetworks.compactMap { networkString in
            switch networkString {
            case "visa":
                return .visa
            case "masterCard":
                return .masterCard
            case "amex":
                return .amex
            case "discover":
                return .discover
            case "JCB":
                return .JCB
            default:
                return nil
            }
        }
    }
    
    var merchantCapabilitiesOptions: PKMerchantCapability {
        var options: PKMerchantCapability = []

        merchantCapabilities.forEach { capability in
            switch capability {
            case "supports3DS":
                options.insert(.capability3DS)
            case "supportsCredit":
                options.insert(.capabilityCredit)
            case "supportsDebit":
                options.insert(.capabilityDebit)
            default:
                break
            }
        }

        return options
    }
    
    func createRequest() -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantIdentifier
        request.countryCode = countryCode
        request.currencyCode = currencyCode
        request.supportedNetworks = paymentNetworks
        request.merchantCapabilities = merchantCapabilitiesOptions
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: total.label, amount: NSDecimalNumber(string: total.amount))
        ]

        return request
    }
}

class Total: Codable {
    let amount, label: String
    
    init(amount: String, label: String) {
        self.amount = amount
        self.label = label
    }
}
