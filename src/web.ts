import { WebPlugin } from '@capacitor/core';

import type { JdApplePayPlugin, ApplePayResponseRequest } from './definitions';

export class JdApplePayWeb extends WebPlugin implements JdApplePayPlugin {
  /**
   * Check if device can make payments.
   */
  async canMakePayment(): Promise<{
    success: boolean;
  }> {
    throw new Error('Not implemented');
  }

  /**
   * Check if device can make payments.
   */
  async completePayment(): Promise<void> {
    throw new Error('Not implemented');
  }

  /**
   * Request a payment
   */
  async requestPayment(): Promise<ApplePayResponseRequest> {
    throw new Error('Not implemented');
  }
}
