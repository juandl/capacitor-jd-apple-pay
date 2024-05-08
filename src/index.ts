import { registerPlugin } from '@capacitor/core';

import type { JdApplePayPlugin } from './definitions';

const JdApplePay = registerPlugin<JdApplePayPlugin>('JdApplePay', {
  web: () => import('./web').then(m => new m.JdApplePayWeb()),
});

export * from './definitions';
export { JdApplePay };
