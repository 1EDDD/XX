import { Component, ChangeDetectionStrategy, inject, signal, output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { SpringBoardEngine } from '../services/tweak-engine';
import { PairingManager } from '../services/pairing';
import { TweakDefinition } from '../models/tweak.model';

@Component({
  selector: 'app-tweak-list',
  imports: [CommonModule, MatIconModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="flex-1 flex flex-col h-full overflow-y-auto p-4 md:p-6 max-w-2xl mx-auto w-full space-y-6">
      
      <!-- Pairing Status Group Card (Directly mirroring original SwiftUI ContentView Section) -->
      <div class="bg-neutral-900 border border-neutral-800 rounded-2xl overflow-hidden shadow-sm">
        <div class="p-4 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-neutral-800 to-neutral-700 flex items-center justify-center text-white border border-white/5">
              <mat-icon class="!w-5 !h-5 !text-[20px]">stay_current_portrait</mat-icon>
            </div>
            <div>
              <div class="flex items-center gap-2">
                <h2 class="text-sm font-semibold text-white">X RPPairing Host</h2>
                @if (pairing.isPaired()) {
                  <span class="px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 text-[10px] font-medium">
                    Paired
                  </span>
                } @else {
                  <span class="px-2 py-0.5 rounded-full bg-neutral-800 text-neutral-400 border border-neutral-700 text-[10px] font-medium">
                    Not Paired
                  </span>
                }
              </div>
              <p class="text-xs text-neutral-400 font-mono mt-0.5">{{ pairing.status() }}</p>
            </div>
          </div>

          <div class="flex items-center gap-2">
            @if (pairing.running()) {
              <div class="flex items-center gap-2">
                <div class="w-4 h-4 border-2 border-neutral-600 border-t-white rounded-full animate-spin"></div>
                <button
                  type="button"
                  (click)="openPairing.emit()"
                  class="text-xs font-medium text-blue-400 hover:text-blue-300"
                >
                  View PIN
                </button>
              </div>
            } @else {
              <button
                type="button"
                (click)="openPairing.emit()"
                class="px-3.5 py-1.5 rounded-xl font-medium text-xs transition-colors shadow-sm flex items-center gap-1.5"
                [class.bg-white]="!pairing.isPaired()"
                [class.text-black]="!pairing.isPaired()"
                [class.hover:bg-neutral-200]="!pairing.isPaired()"
                [class.bg-neutral-800]="pairing.isPaired()"
                [class.text-neutral-300]="pairing.isPaired()"
                [class.hover:bg-neutral-700]="pairing.isPaired()"
              >
                <mat-icon class="!w-4 !h-4 !text-[16px]">
                  {{ pairing.isPaired() ? 'settings_ethernet' : 'link' }}
                </mat-icon>
                <span>{{ pairing.isPaired() ? 'Manage Pairing' : 'Pair Device' }}</span>
              </button>
            }
          </div>
        </div>

        @if (pairing.pin()) {
          <div class="px-4 py-3 bg-neutral-950/60 border-t border-neutral-800 flex items-center justify-between">
            <span class="text-xs text-neutral-400 font-medium">Device PIN</span>
            <span class="text-sm font-mono font-bold text-emerald-400 tracking-wider">{{ pairing.pin() }}</span>
          </div>
        }
      </div>

      <!-- SpringBoard Tweaks List (Directly mirroring original SwiftUI SpringBoardView) -->
      <div class="bg-neutral-900 border border-neutral-800 rounded-2xl overflow-hidden shadow-sm">
        <div class="px-4 py-3 border-b border-neutral-800/80 flex items-center justify-between bg-neutral-900/90">
          <div class="flex items-center gap-2">
            <mat-icon class="!w-4 !h-4 !text-[18px] text-neutral-400">tune</mat-icon>
            <h3 class="text-xs font-semibold text-neutral-300 uppercase tracking-wider">SpringBoard Tweaks</h3>
          </div>
          <div class="flex items-center gap-1">
            <button
              type="button"
              (click)="openPayload.emit()"
              class="px-2.5 py-1 rounded-lg text-neutral-300 hover:text-white hover:bg-neutral-800 text-xs font-medium transition-colors flex items-center gap-1 border border-neutral-700/60"
            >
              <mat-icon class="!w-3.5 !h-3.5 !text-[15px]">description</mat-icon>
              <span>Inspect .plist</span>
            </button>
          </div>
        </div>

        <div class="divide-y divide-neutral-800/60">
          @for (tweak of engine.tweaks(); track tweak.id) {
            <div class="p-3.5 hover:bg-neutral-850/40 transition-colors flex items-start justify-between gap-4">
              <div class="flex-1">
                <div class="flex items-center gap-2">
                  <span class="text-sm font-medium text-white">{{ tweak.title }}</span>
                  @if (tweak.badge) {
                    <span class="px-1.5 py-0.5 rounded text-[10px] bg-neutral-800 text-neutral-400 font-medium border border-neutral-700/60">
                      {{ tweak.badge }}
                    </span>
                  }
                </div>
                <p class="text-xs text-neutral-400 mt-0.5 leading-relaxed">{{ tweak.description }}</p>
                <code class="text-[10px] text-neutral-500 font-mono mt-1 inline-block">{{ tweak.key }}</code>
              </div>

              <!-- iOS Style Switch Toggle -->
              <button
                type="button"
                role="switch"
                [attr.aria-checked]="engine.isEnabled(tweak.id)"
                (click)="toggle(tweak)"
                class="relative inline-flex h-6 w-11 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-neutral-400 mt-1"
                [class.bg-emerald-500]="engine.isEnabled(tweak.id)"
                [class.bg-neutral-700]="!engine.isEnabled(tweak.id)"
              >
                <span
                  class="pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
                  [class.translate-x-5]="engine.isEnabled(tweak.id)"
                  [class.translate-x-0]="!engine.isEnabled(tweak.id)"
                ></span>
              </button>
            </div>
          }
        </div>
      </div>

      <!-- Action Buttons (Mirroring SwiftUI Buttons: Prepare Changes + Respring) -->
      <div class="bg-neutral-900 border border-neutral-800 rounded-2xl p-4 shadow-sm space-y-3">
        <h4 class="text-xs font-semibold text-neutral-400 uppercase tracking-wider">Deployment Actions</h4>
        
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <!-- Prepare Changes Button -->
          <button
            type="button"
            (click)="engine.applyPreparedChanges()"
            [disabled]="engine.applying()"
            class="w-full py-2.5 px-4 rounded-xl bg-white text-black hover:bg-neutral-200 disabled:opacity-50 text-xs font-semibold transition-colors flex items-center justify-center gap-2 shadow-sm"
          >
            @if (engine.applying()) {
              <div class="w-3.5 h-3.5 border-2 border-neutral-900 border-t-transparent rounded-full animate-spin"></div>
            } @else {
              <mat-icon class="!w-4 !h-4 !text-[18px]">save</mat-icon>
            }
            <span>Prepare Changes</span>
          </button>

          <!-- Respring Button -->
          <button
            type="button"
            (click)="engine.respring()"
            [disabled]="engine.applying() || engine.isRespringing()"
            class="w-full py-2.5 px-4 rounded-xl bg-neutral-800 hover:bg-neutral-700 text-white disabled:opacity-50 text-xs font-semibold transition-colors flex items-center justify-center gap-2 border border-neutral-700"
          >
            <mat-icon class="!w-4 !h-4 !text-[18px]">restart_alt</mat-icon>
            <span>Respring</span>
          </button>
        </div>

        @if (engine.message()) {
          <div class="p-3 bg-neutral-950 rounded-xl border border-neutral-800/80 text-xs text-neutral-300 flex items-start gap-2">
            <mat-icon class="!w-4 !h-4 !text-[16px] text-blue-400 shrink-0 mt-0.5">info</mat-icon>
            <div class="flex-1">
              <p class="leading-normal">{{ engine.message() }}</p>
              @if (engine.lastPreparedAt()) {
                <span class="text-[10px] text-neutral-500 font-mono mt-0.5 block">
                  Last serialized at {{ engine.lastPreparedAt() }}
                </span>
              }
            </div>
          </div>
        }
      </div>

      <!-- Quick Preset Actions -->
      <div class="flex items-center justify-between text-xs text-neutral-400 px-1 pb-4">
        <span>Quick Presets:</span>
        <div class="flex items-center gap-2">
          <button
            type="button"
            (click)="engine.applyPreset('recommended')"
            class="hover:text-white underline"
          >
            Recommended Tweaks
          </button>
          <span>•</span>
          <button
            type="button"
            (click)="engine.applyPreset('minimal')"
            class="hover:text-white underline"
          >
            Clean Lock Screen
          </button>
          <span>•</span>
          <button
            type="button"
            (click)="engine.applyPreset('reset')"
            class="hover:text-red-400 underline"
          >
            Clear All
          </button>
        </div>
      </div>
    </div>
  `
})
export class TweakList {
  readonly engine = inject(SpringBoardEngine);
  readonly pairing = inject(PairingManager);

  readonly openPairing = output<void>();
  readonly openPayload = output<void>();

  toggle(tweak: TweakDefinition): void {
    const current = this.engine.isEnabled(tweak.id);
    this.engine.setTweak(tweak.id, !current);
  }
}
