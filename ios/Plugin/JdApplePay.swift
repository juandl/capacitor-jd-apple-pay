import Foundation
import PassKit

typealias HandlerPaymentRequest = (
  Result<ApplePayPaymentResponseDto, ApplePayPaymentResponseErrorDto>
) -> Void

typealias HandlerPaymentComplete = (
  Result<Void, ApplePayPaymentResponseErrorDto>
) -> Void

class JdApplePay: NSObject {

  private var handlerPaymentRequest: HandlerPaymentRequest?
  private var handlerPaymentComplete: HandlerPaymentComplete?
  //Save Authorization
  private var handlerAuthorization: ((PKPaymentAuthorizationResult) -> Void)?

  //Check if device can use wallet.
  public func canMakePayment() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments()
  }

  //Create a payment authorization
  public func requestPayment(
    payload: ApplePayPaymentRequestDto, handler: @escaping HandlerPaymentRequest
  ) {

    //Share instance
    self.handlerPaymentRequest = handler

    let paymentRequest = payload.createRequest()

    let paymentAuthorizationController = PKPaymentAuthorizationController(
      paymentRequest: paymentRequest)

    paymentAuthorizationController.delegate = self

    DispatchQueue.main.async {
      paymentAuthorizationController.present { [weak self] (presented) in
        if !presented {
          self?.handlerPaymentRequest?(.failure(.notpresent))
        }
      }
    }
  }

  //Complete previous authorization
  public func completePayment(
    payload: ApplePayPaymentCompleteDto, handler: @escaping HandlerPaymentComplete
  ) {
    guard let handlerAuthorization = self.handlerAuthorization else {
      handler(.failure(.paymentnotstarted))

      return
    }

    guard let result = payload.asResult() else {
      handler(.failure(.notparse))

      return
    }

    handler(.success(()))

    DispatchQueue.main.async {
      handlerAuthorization(result)
    }

    // Clear the stored handler to prevent memory leaks
    self.handlerAuthorization = nil
  }

}

extension JdApplePay: PKPaymentAuthorizationControllerDelegate {

  public func paymentAuthorizationController(
    _ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment,
    handler: @escaping (PKPaymentAuthorizationResult) -> Void
  ) {
    let paymentResponseNz = ApplePayPaymentResponseDto(with: payment)

    self.handlerPaymentRequest?(.success(paymentResponseNz))

    // Store the handler instead of calling it
    self.handlerAuthorization = handler

    self.handlerPaymentRequest = nil  // Clear the handler to prevent memory leaks or unintended reuse
  }

  public func paymentAuthorizationControllerDidFinish(
    _ controller: PKPaymentAuthorizationController
  ) {
    controller.dismiss(completion: {
      // payment authorization is finished but not completed
      if let handler = self.handlerAuthorization {
        handler(PKPaymentAuthorizationResult(status: .failure, errors: nil))
      } else {
        self.handlerPaymentRequest?(.failure(.closed))
      }
    })

  }
}
