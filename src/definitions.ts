export declare type ApplePaySupportedNetworks =
  | 'amex'
  | 'discover'
  | 'JCB'
  | 'masterCard'
  | 'mada'
  | 'visa';

export type ApplePayMerchantCapability =
  | 'supports3DS'
  | 'supportsCredit'
  | 'supportsDebit';

export type ApplePayLineItem = {
  amount: string;
  label: string;
};

export interface ApplePayPaymentRequest {
  merchantIdentifier: string;
  merchantCapabilities: ApplePayMerchantCapability[];
  supportedNetworks: ApplePaySupportedNetworks[];
  total: ApplePayLineItem;
  countryCode: string;
  currencyCode: string;
}

export interface ApplePayResponseRequest {
  paymentData?: string;
  transactionIdentifier: string;
}

export interface ApplePayCompleteRequest {
  status: 'success' | 'failure';
}

export type ApplePayCanMakePayments = boolean;

export interface JdApplePayPlugin {
  canMakePayment(): Promise<{
    success: boolean;
  }>;
  completePayment(params: ApplePayCompleteRequest): Promise<void>;
  requestPayment(
    params: ApplePayPaymentRequest,
  ): Promise<ApplePayResponseRequest>;
}
