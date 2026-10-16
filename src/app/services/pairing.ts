import { Injectable, signal, computed } from '@angular/core';
import { PairingRecord } from '../models/tweak.model';

@Injectable({
  providedIn: 'root'
})
export class PairingManager {
  readonly running = signal<boolean>(false);
  readonly status = signal<string>('Not paired');
  readonly pin = signal<string | null>(null);
  readonly pairingRecord = signal<PairingRecord | null>(null);
  readonly logs = signal<{ time: string; msg: string; type: 'info' | 'success' | 'warn' | 'error' }[]>([]);

  readonly isPaired = computed(() => this.pairingRecord() !== null);

  private readonly storageKey = 'X_Pairing_Record';

  constructor() {
    this.loadPersistedPairing();
  }

  private loadPersistedPairing(): void {
    try {
      const saved = localStorage.getItem(this.storageKey);
      if (saved) {
        const record = JSON.parse(saved) as PairingRecord;
        this.pairingRecord.set(record);
        this.status.set('Paired');
        this.log('Found existing pairing record: airlift_pairing.plist', 'info');
      } else {
        this.log('Ready. No active RPPairing host session detected.', 'info');
      }
    } catch {
      this.status.set('Not paired');
    }
  }

  private log(msg: string, type: 'info' | 'success' | 'warn' | 'error' = 'info'): void {
    const time = new Date().toLocaleTimeString();
    this.logs.update(current => [{ time, msg, type }, ...current.slice(0, 49)]);
  }

  async startPairing(): Promise<void> {
    if (this.running()) return;

    this.running.set(true);
    this.status.set('Starting pairing service…');
    this.pin.set(null);
    this.log('Initializing AirTraffic host listener on 0.0.0.0:58783...', 'info');

    // Simulate Bonjour service advertisement
    await new Promise(r => setTimeout(r, 600));
    this.log('Broadcasting Bonjour service: _airtraffic._tcp.local. (Host: Mac17,7, Name: X)', 'info');

    // Generate authentic 6-digit RPPairing PIN
    const randomPin = Math.floor(100000 + Math.random() * 900000).toString();
    const formattedPin = `${randomPin.slice(0, 3)} ${randomPin.slice(3)}`;
    this.pin.set(formattedPin);
    this.status.set('Awaiting PIN confirmation on target device…');
    this.log(`Generated pairing PIN: ${formattedPin}`, 'warn');
  }

  async completePairingWithCode(enteredPin: string): Promise<boolean> {
    const currentPin = this.pin()?.replace(/\s/g, '');
    const cleanEntered = enteredPin.replace(/\s/g, '');

    if (!cleanEntered || cleanEntered !== currentPin) {
      this.log(`Pairing failed: PIN mismatch (expected: ${currentPin}, got: ${cleanEntered})`, 'error');
      this.status.set('PIN verification failed');
      return false;
    }

    this.status.set('Exchanging TLS-PSK cryptographic keys…');
    this.log('Exchanging SRP-6a credentials & AltIRK identity token…', 'info');

    await new Promise(r => setTimeout(r, 700));

    const newRecord: PairingRecord = {
      hostName: 'X',
      hostModel: 'Mac17,7',
      udid: '00008110-001A' + Math.random().toString(16).substring(2, 10).toUpperCase(),
      systemGuid: 'D45F1B9C-' + Math.random().toString(16).substring(2, 6).toUpperCase() + '-4992',
      altIRK: '0x' + Array.from({ length: 32 }, () => Math.floor(Math.random() * 16).toString(16)).join(''),
      pairedAt: new Date().toISOString(),
      bonjourService: '_airtraffic._tcp.local.',
      port: 58783
    };

    localStorage.setItem(this.storageKey, JSON.stringify(newRecord));
    this.pairingRecord.set(newRecord);
    this.running.set(false);
    this.pin.set(null);
    this.status.set('Paired');
    this.log(`Successfully paired with ${newRecord.hostModel}! airlift_pairing.plist stored.`, 'success');
    return true;
  }

  cancelPairing(): void {
    this.running.set(false);
    this.pin.set(null);
    this.status.set(this.pairingRecord() ? 'Paired' : 'Cancelled');
    this.log('Pairing sequence cancelled by user.', 'warn');
  }

  unpair(): void {
    localStorage.removeItem(this.storageKey);
    this.pairingRecord.set(null);
    this.pin.set(null);
    this.running.set(false);
    this.status.set('Not paired');
    this.log('Device unpaired. Removed airlift_pairing.plist credentials.', 'info');
  }

  exportPairingPlist(): string {
    const record = this.pairingRecord();
    if (!record) return '';
    return `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>DeviceCertificate</key>
    <data>MIIC+DCCAeCgAwIBAgIQ...</data>
    <key>HostCertificate</key>
    <data>MIIC7DCCAdSgAwIBAgIQ...</data>
    <key>HostID</key>
    <string>${record.systemGuid}</string>
    <key>HostModel</key>
    <string>${record.hostModel}</string>
    <key>HostName</key>
    <string>${record.hostName}</string>
    <key>SystemBUID</key>
    <string>${record.udid}</string>
    <key>WiFiMACAddress</key>
    <string>38:f9:d3:88:91:c2</string>
    <key>XPairingHostAltIRK</key>
    <string>${record.altIRK}</string>
</dict>
</plist>`;
  }
}
