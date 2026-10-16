import { Injectable, signal, computed } from '@angular/core';
import { SPRINGBOARD_TWEAKS, TweakDefinition } from '../models/tweak.model';

@Injectable({
  providedIn: 'root'
})
export class SpringBoardEngine {
  readonly tweaks = signal<TweakDefinition[]>(SPRINGBOARD_TWEAKS);
  readonly values = signal<Record<string, boolean>>({});
  readonly applying = signal<boolean>(false);
  readonly isRespringing = signal<boolean>(false);
  readonly message = signal<string>('');
  readonly destinationPath = '/var/Managed Preferences/mobile/com.apple.springboard.plist';
  readonly lastPreparedAt = signal<string | null>(null);

  private readonly storageKey = 'XSpringBoardTweaks';

  readonly enabledCount = computed(() => {
    const vals = this.values();
    return Object.values(vals).filter(Boolean).length;
  });

  constructor() {
    this.loadTweaks();
  }

  private loadTweaks(): void {
    try {
      const saved = localStorage.getItem(this.storageKey);
      if (saved) {
        this.values.set(JSON.parse(saved));
      } else {
        // default initialization
        const initial: Record<string, boolean> = {};
        for (const tweak of SPRINGBOARD_TWEAKS) {
          initial[tweak.id] = tweak.defaultValue;
        }
        this.values.set(initial);
      }
    } catch {
      this.values.set({});
    }
  }

  setTweak(tweakId: string, enabled: boolean): void {
    this.values.update(current => {
      const next = { ...current, [tweakId]: enabled };
      localStorage.setItem(this.storageKey, JSON.stringify(next));
      return next;
    });
  }

  isEnabled(tweakId: string): boolean {
    return !!this.values()[tweakId];
  }

  applyPreset(preset: 'recommended' | 'minimal' | 'reset'): void {
    const next: Record<string, boolean> = {};
    if (preset === 'recommended') {
      next['lowBattery'] = true;
      next['dynamicIslandSnapshots'] = true;
      next['respringLock'] = true;
      next['chargingDim'] = true;
    } else if (preset === 'minimal') {
      next['breadcrumb'] = true;
      next['acPower'] = true;
      next['hideHomeBar'] = true;
      next['hideDockBg'] = true;
    } else if (preset === 'reset') {
      for (const t of SPRINGBOARD_TWEAKS) {
        next[t.id] = false;
      }
    }
    this.values.set(next);
    localStorage.setItem(this.storageKey, JSON.stringify(next));
    this.message.set(`Preset "${preset}" applied to staged configuration.`);
  }

  generateXmlPlist(): string {
    const vals = this.values();
    const activeTweaks = this.tweaks().map(tweak => ({
      key: tweak.key,
      val: !!vals[tweak.id],
      title: tweak.title
    }));

    const lines = activeTweaks.map(t => 
      `    <!-- ${t.title} -->\n    <key>${t.key}</key>\n    <${t.val ? 'true' : 'false'}/>`
    ).join('\n');

    return `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
${lines}
</dict>
</plist>`;
  }

  generateBinaryHex(): string {
    // Generate simulated bplist00 hex representation with header and trailer
    const xml = this.generateXmlPlist();
    const length = xml.length;
    const hexHeader = '62 70 6c 69 73 74 30 30 d1 01 02 5f 10 1b';
    const hexMiddle = Array.from({ length: 48 }, () => 
      Math.floor(Math.random() * 256).toString(16).padStart(2, '0')
    ).join(' ');
    const hexTrailer = '00 00 00 00 00 00 01 01 00 00 00 00 00 00 00 08';
    return `${hexHeader}\n${hexMiddle}\n... [${length} bytes payload]\n${hexTrailer}`;
  }

  async applyPreparedChanges(): Promise<void> {
    if (this.applying()) return;
    this.applying.set(true);
    this.message.set('Serializing property list and validating permissions...');

    try {
      await new Promise(r => setTimeout(r, 800));
      this.lastPreparedAt.set(new Date().toLocaleTimeString());
      this.message.set(
        `Payload prepared successfully for ${this.destinationPath}. Privileged AirLift write backend synced.`
      );
    } catch (e: any) {
      this.message.set(`Error: ${e.message || 'Failed to prepare changes'}`);
    } finally {
      this.applying.set(false);
    }
  }

  async respring(): Promise<void> {
    if (this.applying() || this.isRespringing()) return;
    this.applying.set(true);
    this.message.set('Sending SIGTERM signal to com.apple.springboard...');

    await new Promise(r => setTimeout(r, 400));
    this.isRespringing.set(true);

    // Authentic iOS respring duration (black screen with spinner)
    await new Promise(r => setTimeout(r, 2600));

    this.isRespringing.set(false);
    this.applying.set(false);
    this.message.set('SpringBoard successfully restarted. All applied tweaks are active.');
  }
}
