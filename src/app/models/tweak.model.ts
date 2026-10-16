export interface TweakDefinition {
  id: string;
  title: string;
  key: string;
  category: 'alerts' | 'lockscreen' | 'system' | 'appearance';
  description: string;
  badge?: string;
  defaultValue: boolean;
}

export const SPRINGBOARD_TWEAKS: TweakDefinition[] = [
  {
    id: 'lowBattery',
    title: 'Disable Low Battery Alerts',
    key: 'SBHideLowPowerAlerts',
    category: 'alerts',
    description: 'Suppresses the 20% and 10% low battery modal interruptions on SpringBoard.',
    badge: 'Popular',
    defaultValue: false
  },
  {
    id: 'acPower',
    title: 'Hide AC Power on Lock Screen',
    key: 'SBHideACPower',
    category: 'lockscreen',
    description: 'Hides the large battery charging glyph and percentage when plugged into AC power.',
    defaultValue: false
  },
  {
    id: 'respringLock',
    title: 'Disable Lock After Respring',
    key: 'SBDontLockAfterCrash',
    category: 'system',
    description: 'Prevents SpringBoard from forcing device re-lock after an intentional or crash respring.',
    badge: 'Convenience',
    defaultValue: false
  },
  {
    id: 'chargingDim',
    title: 'Disable Screen Dimming While Charging',
    key: 'SBDontDimOrLockOnAC',
    category: 'system',
    description: 'Keeps the display active and prevents sleep timeout while connected to external power.',
    defaultValue: false
  },
  {
    id: 'dynamicIslandSnapshots',
    title: 'Dynamic Island in Screenshots',
    key: 'SBAlwaysShowSystemApertureInSnapshots',
    category: 'appearance',
    description: 'Captures the Dynamic Island cutout and active Live Activities within system screenshots.',
    badge: 'System Aperture',
    defaultValue: false
  },
  {
    id: 'authenticationLine',
    title: 'Authentication Line',
    key: 'SBShowAuthenticationEngineeringUI',
    category: 'appearance',
    description: 'Displays Apple internal engineering biometric progress line below the status bar.',
    badge: 'Internal',
    defaultValue: false
  },
  {
    id: 'breadcrumb',
    title: 'Disable Breadcrumbs',
    key: 'SBNeverBreadcrumb',
    category: 'appearance',
    description: 'Hides top-left return arrow navigation when switching between apps.',
    defaultValue: false
  },
  {
    id: 'supervision',
    title: 'Show Supervision Text',
    key: 'SBShowSupervisionTextOnLockScreen',
    category: 'lockscreen',
    description: 'Forces lock screen to display corporate supervision notice header.',
    defaultValue: false
  },
  {
    id: 'hideDockBg',
    title: 'Hide Dock Background',
    key: 'SBHideDockBackground',
    category: 'appearance',
    description: 'Removes the frosted glass blur container behind bottom dock icons.',
    defaultValue: false
  },
  {
    id: 'hideHomeBar',
    title: 'Hide Home Bar Indicator',
    key: 'SBHideHomeAffordance',
    category: 'appearance',
    description: 'Removes the bottom swipe-up line affordance across the system.',
    badge: 'Clean UI',
    defaultValue: false
  }
];

export interface PairingRecord {
  hostName: string;
  hostModel: string;
  udid: string;
  systemGuid: string;
  altIRK: string;
  pairedAt: string;
  bonjourService: string;
  port: number;
}
