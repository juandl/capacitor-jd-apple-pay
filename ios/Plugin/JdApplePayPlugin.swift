import Capacitor
import Foundation

@objc(JdApplePayPlugin)
public class JdApplePayPlugin: CAPPlugin {
  private let applePayPl = JdApplePay()

  @objc func canMakePayment(_ call: CAPPluginCall) {
    //Execute service
    let result = applePayPl.canMakePayment()

    if result {
      call.resolve(["success": result])
    } else {
      call.reject("Apple pay not available for payments.")
    }
  }

  @objc func requestPayment(_ call: CAPPluginCall) {
    guard let payloadDict = call.options else {
      call.reject("Payload is required.")
      return
    }

    do {

      let jsonData = try JSONSerialization.data(withJSONObject: payloadDict, options: [])
      let payload = try JSONDecoder().decode(ApplePayPaymentRequestDto.self, from: jsonData)

      applePayPl.requestPayment(payload: payload) { result in
        switch result {
        case .success(let response):
          do {
            let responseDict = try response.asDictionary()

            call.resolve(responseDict)
          } catch {
            call.reject("Failed to parse the response: \(error.localizedDescription)")
          }
        case .failure(let error):
          call.reject(error.localizedDescription)
        }
      }

    } catch {
      call.reject(error.localizedDescription)
    }
  }

    @objc func completePayment(_ call: CAPPluginCall) {
    guard let payloadDict = call.options else {
      call.reject("Payload is required.")
      return
    }

    do {

      let jsonData = try JSONSerialization.data(withJSONObject: payloadDict, options: [])
      let payload = try JSONDecoder().decode(ApplePayPaymentCompleteDto.self, from: jsonData)

      applePayPl.completePayment(payload: payload) { result in
        switch result {
        case .success:
          call.resolve()
        case .failure(let error):
          call.reject(error.localizedDescription)
        }
      }

    } catch {
      call.reject(error.localizedDescription)
    }

  }
}
