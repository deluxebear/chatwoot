import { applyOverrides } from 'dashboard/i18n/custom';
import zh_CN from './zh_CN.json';

// Local translation overrides for the website widget (see dashboard/i18n/custom).
export default messages => applyOverrides(messages, { zh_CN });
