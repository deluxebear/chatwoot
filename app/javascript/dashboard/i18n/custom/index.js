import zh_CN from './zh_CN.json';

// Local translation overrides for our fork. Keys defined here win over the
// upstream community translations; everything else falls through untouched.
// Add more locales by importing their JSON and listing them in `overrides`.
const overrides = { zh_CN };

const deepMerge = (target, source) => {
  const result = { ...target };
  Object.keys(source).forEach(key => {
    if (
      source[key] &&
      typeof source[key] === 'object' &&
      typeof result[key] === 'object'
    ) {
      result[key] = deepMerge(result[key], source[key]);
    } else {
      result[key] = source[key];
    }
  });
  return result;
};

export const applyOverrides = (messages, localeOverrides) => {
  Object.keys(localeOverrides).forEach(locale => {
    messages[locale] = deepMerge(
      messages[locale] || {},
      localeOverrides[locale]
    );
  });
  return messages;
};

export default messages => applyOverrides(messages, overrides);
