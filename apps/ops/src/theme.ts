import {
  createDarkTheme,
  createLightTheme,
  type BrandVariants,
  type Theme,
} from '@fluentui/react-components';

export const trotxiBrand: BrandVariants = {
  10: '#010401',
  20: '#081D0D',
  30: '#013114',
  40: '#123D21',
  50: '#23492E',
  60: '#33563C',
  70: '#42634A',
  80: '#527058',
  90: '#617D67',
  100: '#718A76',
  110: '#829886',
  120: '#92A696',
  130: '#A3B4A6',
  140: '#B4C2B7',
  150: '#C6D0C8',
  160: '#D7DFD9',
};

export const trotxiLight: Theme = {
  ...createLightTheme(trotxiBrand),
  colorNeutralBackground1: '#f8f7fa',
  colorNeutralBackground2: '#f0edf3',
  colorNeutralForeground1: '#17151b',
  colorNeutralForeground2: '#5f5966',
  borderRadiusMedium: '12px',
  borderRadiusLarge: '18px',
};

export const trotxiDark: Theme = {
  ...createDarkTheme(trotxiBrand),
  colorNeutralBackground1: '#17151b',
  colorNeutralBackground2: '#201c25',
  colorNeutralForeground1: '#f7f3fa',
  colorBrandForeground1: '#c7bdd5',
  colorBrandForeground2: '#afa1c1',
  borderRadiusMedium: '12px',
  borderRadiusLarge: '18px',
};
