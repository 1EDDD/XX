import { Component, ChangeDetectionStrategy, inject, signal, output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { PairingManager } from '../services/pairing';

@Component({
  selector: 'app-pairing-sheet',
  imports: [CommonModule, MatIconModule, ReactiveFormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
      <div class="w-full max-w-lg bg-neutral-900 border border-neutral-800 rounded-2xl shadow-2xl flex flex-col max-h-[90vh] overflow-hidden">
        
        <!-- Header -->
        <div class="flex items-center justify-between p-4 border-b border-neutral-800">
          <div class="flex items-center gap-2.5">
            <div class="w-8 h-8 rounded-lg bg-neutral-800 flex items-center justify-center text-white">
              <mat-icon class="!w-5 !h-5 !text-[20px]">devices</mat-icon>
            </div>
            <div>
              <h3 class="text-sm font-semibold text-white">Developer Mode RPPairing</h3>
              <p class="text-xs text-neutral-400">On-device AirLift & AirTraffic pairing protocol</p>
            </div>
          </div>
          <button
            type="button"
            (click)="close.emit()"
            class="p-1.5 rounded-lg text-neutral-400 hover:text-white hover:bg-neutral-800 transition-colors"
          >
            <mat-icon class="!w-5 !h-5 !text-[20px]">close</mat-icon>
          </button>
        </div>

        <!-- Body -->
        <div class="p-5 overflow-y-auto space-y-5">
          <!-- Status Banner -->
          <div class="flex items-center justify-between bg-neutral-950/60 border border-neutral-800/80 rounded-xl p-3.5">
            <div class="flex items-center gap-3">
              <span class="relative flex h-3 w-3">
                <span 
                  class="animate-ping absolute inline-flex h-full w-full rounded-full opacity-75"
                  [class.bg-emerald-400]="pairing.isPaired()"
                  [class.bg-amber-400]="pairing.running()"
                  [class.bg-neutral-600]="!pairing.isPaired() && !pairing.running()"
                ></span>
                <span 
                  class="relative inline-flex rounded-full h-3 w-3"
                  [class.bg-emerald-500]="pairing.isPaired()"
                  [class.bg-amber-500]="pairing.running()"
                  [class.bg-neutral-500]="!pairing.isPaired() && !pairing.running()"
                ></span>
              </span>
              <div>
                <span class="text-xs font-semibold text-neutral-200">Pairing Status</span>
                <p class="text-xs text-neutral-400 font-mono">{{ pairing.status() }}</p>
              </div>
            </div>

            @if (pairing.isPaired()) {
              <button
                type="button"
                (click)="pairing.unpair()"
                class="px-3 py-1.5 rounded-lg bg-red-950/40 border border-red-800/60 text-red-400 hover:bg-red-900/50 text-xs font-medium transition-colors flex items-center gap-1.5"
              >
                <mat-icon class="!w-4 !h-4 !text-[16px]">link_off</mat-icon>
                <span>Unpair</span>
              </button>
            } @else if (!pairing.running()) {
              <button
                type="button"
                (click)="startPairing()"
                class="px-3.5 py-1.5 rounded-lg bg-white text-black hover:bg-neutral-200 text-xs font-semibold transition-colors flex items-center gap-1.5"
              >
                <mat-icon class="!w-4 !h-4 !text-[16px]">add_link</mat-icon>
                <span>Start Pairing</span>
              </button>
            } @else {
              <button
                type="button"
                (click)="pairing.cancelPairing()"
                class="px-3 py-1.5 rounded-lg bg-neutral-800 hover:bg-neutral-700 text-neutral-300 text-xs font-medium transition-colors flex items-center gap-1.5"
              >
                <mat-icon class="!w-4 !h-4 !text-[16px]">cancel</mat-icon>
                <span>Cancel</span>
              </button>
            }
          </div>

          <!-- Active Pairing In Progress (PIN Prompt) -->
          @if (pairing.running() && pairing.pin()) {
            <div class="bg-gradient-to-b from-neutral-950 to-neutral-900 border border-neutral-700/80 rounded-xl p-4 text-center space-y-3">
              <span class="text-xs font-medium text-neutral-400 uppercase tracking-wider">Device Verification PIN</span>
              <div class="text-3xl font-mono font-bold tracking-widest text-emerald-400 py-1 select-all">
                {{ pairing.pin() }}
              </div>
              <p class="text-[11px] text-neutral-400 max-w-xs mx-auto">
                Confirm this 6-digit passcode on your target iOS device to establish the mutual TLS-PSK pairing record.
              </p>

              <div class="pt-2 flex items-center justify-center gap-2">
                <input
                  type="text"
                  [formControl]="pinInput"
                  placeholder="Enter PIN to complete"
                  maxlength="7"
                  class="bg-neutral-950 border border-neutral-700 rounded-lg px-3 py-1.5 text-center font-mono text-xs text-white focus:outline-none focus:border-neutral-500 w-44"
                />
                <button
                  type="button"
                  (click)="confirmEnteredPin()"
                  class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-500 text-white rounded-lg text-xs font-semibold transition-colors flex items-center gap-1"
                >
                  <mat-icon class="!w-4 !h-4 !text-[16px]">check</mat-icon>
                  <span>Verify</span>
                </button>
              </div>
              <button
                type="button"
                (click)="autoAuthorize()"
                class="text-[11px] text-neutral-400 hover:text-white underline mt-1"
              >
                Auto-confirm matching PIN
              </button>
            </div>
          }

          <!-- Pairing Record Metadata Card -->
          @if (pairing.pairingRecord(); as record) {
            <div class="bg-neutral-950/80 border border-neutral-800 rounded-xl p-4 space-y-2.5">
              <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-neutral-300">Installed Pairing Identity</span>
                <span class="text-[10px] font-mono text-emerald-400 bg-emerald-950/40 border border-emerald-800/60 px-2 py-0.5 rounded">
                  airlift_pairing.plist
                </span>
              </div>
              <div class="grid grid-cols-2 gap-2 text-xs font-mono">
                <div class="bg-neutral-900 p-2 rounded-lg border border-neutral-800/80">
                  <span class="text-[10px] text-neutral-500 block uppercase">Host Name / Model</span>
                  <span class="text-neutral-300 font-medium">{{ record.hostName }} ({{ record.hostModel }})</span>
                </div>
                <div class="bg-neutral-900 p-2 rounded-lg border border-neutral-800/80">
                  <span class="text-[10px] text-neutral-500 block uppercase">Bonjour Port</span>
                  <span class="text-neutral-300 font-medium">{{ record.port }}</span>
                </div>
                <div class="bg-neutral-900 p-2 rounded-lg border border-neutral-800/80 col-span-2">
                  <span class="text-[10px] text-neutral-500 block uppercase">Device UDID</span>
                  <span class="text-neutral-300 truncate block">{{ record.udid }}</span>
                </div>
                <div class="bg-neutral-900 p-2 rounded-lg border border-neutral-800/80 col-span-2">
                  <span class="text-[10px] text-neutral-500 block uppercase">AltIRK Key (XPairingHostAltIRK)</span>
                  <span class="text-neutral-400 text-[11px] truncate block">{{ record.altIRK }}</span>
                </div>
              </div>
            </div>
          }

          <!-- Service Logs Console -->
          <div class="space-y-1.5">
            <span class="text-xs font-semibold text-neutral-400">RPPairing & AirTraffic Logs</span>
            <div class="bg-neutral-950 border border-neutral-800 rounded-xl p-3 h-36 overflow-y-auto font-mono text-[11px] space-y-1">
              @for (log of pairing.logs(); track log.time + log.msg) {
                <div class="flex items-start gap-2">
                  <span class="text-neutral-600 shrink-0">[{{ log.time }}]</span>
                  <span
                    [class.text-neutral-300]="log.type === 'info'"
                    [class.text-emerald-400]="log.type === 'success'"
                    [class.text-amber-400]="log.type === 'warn'"
                    [class.text-red-400]="log.type === 'error'"
                  >
                    {{ log.msg }}
                  </span>
                </div>
              }
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="p-4 border-t border-neutral-800 bg-neutral-950/40 flex justify-end">
          <button
            type="button"
            (click)="close.emit()"
            class="px-4 py-2 bg-neutral-800 hover:bg-neutral-700 text-white rounded-lg text-xs font-medium transition-colors"
          >
            Done
          </button>
        </div>
      </div>
    </div>
  `
})
export class PairingSheet {
  readonly pairing = inject(PairingManager);
  readonly close = output<void>();

  readonly pinInput = new FormControl<string>('');

  async startPairing(): Promise<void> {
    await this.pairing.startPairing();
    const pin = this.pairing.pin();
    if (pin) {
      this.pinInput.setValue(pin.replace(/\s/g, ''));
    }
  }

  async confirmEnteredPin(): Promise<void> {
    const code = this.pinInput.value || '';
    await this.pairing.completePairingWithCode(code);
  }

  async autoAuthorize(): Promise<void> {
    const currentPin = this.pairing.pin() || '';
    await this.pairing.completePairingWithCode(currentPin);
  }
}
