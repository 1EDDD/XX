import { Component, ChangeDetectionStrategy, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { TweakList } from './components/tweak-list';
import { DevicePreview } from './components/device-preview';
import { PairingSheet } from './components/pairing-sheet';
import { PayloadSheet } from './components/payload-sheet';
import { PairingManager } from './services/pairing';
import { SpringBoardEngine } from './services/tweak-engine';

@Component({
  selector: 'app-root',
  imports: [
    CommonModule,
    MatIconModule,
    TweakList,
    DevicePreview,
    PairingSheet,
    PayloadSheet
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="h-screen w-screen flex flex-col bg-neutral-950 text-neutral-100 overflow-hidden font-sans select-none">
      
      <!-- Top Navigation Bar -->
      <header class="h-14 border-b border-neutral-800/80 bg-neutral-900/60 backdrop-blur-md px-4 sm:px-6 flex items-center justify-between shrink-0 z-30">
        <div class="flex items-center gap-3">
          <div class="w-8 h-8 rounded-lg bg-white text-black flex items-center justify-center font-bold text-sm tracking-wider shadow-sm">
            X
          </div>
          <div>
            <div class="flex items-center gap-2">
              <h1 class="text-sm font-semibold text-white tracking-tight">X Toolkit</h1>
              <span class="text-[10px] font-mono bg-neutral-800 text-neutral-400 px-1.5 py-0.5 rounded border border-neutral-700/60">
                v0.1
              </span>
            </div>
            <p class="text-[11px] text-neutral-400 hidden sm:block">On-device iOS customization & SpringBoard tweak manager</p>
          </div>
        </div>

        <!-- Header Actions -->
        <div class="flex items-center gap-2">
          <!-- Pairing Status Pill / Action -->
          <button
            type="button"
            (click)="showPairing.set(true)"
            class="px-3 py-1.5 rounded-lg border text-xs font-medium transition-colors flex items-center gap-2 shadow-sm"
            [class.bg-neutral-800]="!pairing.isPaired()"
            [class.border-neutral-700]="!pairing.isPaired()"
            [class.text-neutral-300]="!pairing.isPaired()"
            [class.hover:bg-neutral-700]="!pairing.isPaired()"
            [class.bg-emerald-950/40]="pairing.isPaired()"
            [class.border-emerald-800/60]="pairing.isPaired()"
            [class.text-emerald-400]="pairing.isPaired()"
            [class.hover:bg-emerald-900/40]="pairing.isPaired()"
          >
            <span class="w-2 h-2 rounded-full" [class.bg-emerald-400]="pairing.isPaired()" [class.bg-neutral-500]="!pairing.isPaired()"></span>
            <span class="hidden sm:inline">{{ pairing.isPaired() ? 'RPPairing Active' : 'Not Paired' }}</span>
            <mat-icon class="!w-4 !h-4 !text-[16px]">qr_code_2</mat-icon>
          </button>

          <!-- Payload Inspector Button -->
          <button
            type="button"
            (click)="showPayload.set(true)"
            class="px-3 py-1.5 rounded-lg bg-neutral-800 hover:bg-neutral-700 border border-neutral-700 text-neutral-300 hover:text-white text-xs font-medium transition-colors flex items-center gap-1.5"
            title="Inspect com.apple.springboard.plist"
          >
            <mat-icon class="!w-4 !h-4 !text-[16px]">description</mat-icon>
            <span class="hidden md:inline">Inspect Plist</span>
          </button>

          <!-- Device Preview Toggle on mobile -->
          <button
            type="button"
            (click)="toggleMobilePreview()"
            class="lg:hidden px-3 py-1.5 rounded-lg bg-neutral-800 hover:bg-neutral-700 border border-neutral-700 text-neutral-300 hover:text-white text-xs font-medium transition-colors flex items-center gap-1.5"
          >
            <mat-icon class="!w-4 !h-4 !text-[16px]">smartphone</mat-icon>
            <span>{{ mobileView() === 'tweaks' ? 'Preview' : 'Tweaks' }}</span>
          </button>
        </div>
      </header>

      <!-- Main Layout -->
      <div class="flex-1 flex overflow-hidden">
        
        <!-- Left: Tweaks Configuration List -->
        <main 
          class="flex-1 flex flex-col h-full overflow-hidden transition-all duration-300"
          [class.hidden]="mobileView() === 'preview'"
          [class.flex]="mobileView() === 'tweaks'"
        >
          <app-tweak-list
            (openPairing)="showPairing.set(true)"
            (openPayload)="showPayload.set(true)"
          ></app-tweak-list>
        </main>

        <!-- Right: Interactive Device Simulator -->
        <aside 
          class="w-full lg:w-[420px] xl:w-[460px] border-l border-neutral-800/80 bg-neutral-950/80 backdrop-blur flex flex-col items-center justify-center overflow-y-auto shrink-0 transition-all duration-300"
          [class.hidden]="mobileView() === 'tweaks'"
          [class.flex]="mobileView() === 'preview'"
          class="lg:!flex"
        >
          <app-device-preview></app-device-preview>
        </aside>
      </div>

      <!-- Modals -->
      @if (showPairing()) {
        <app-pairing-sheet (close)="showPairing.set(false)"></app-pairing-sheet>
      }

      @if (showPayload()) {
        <app-payload-sheet (close)="showPayload.set(false)"></app-payload-sheet>
      }
    </div>
  `
})
export class App {
  readonly pairing = inject(PairingManager);
  readonly engine = inject(SpringBoardEngine);

  readonly showPairing = signal<boolean>(false);
  readonly showPayload = signal<boolean>(false);
  readonly mobileView = signal<'tweaks' | 'preview'>('tweaks');

  toggleMobilePreview(): void {
    this.mobileView.update(current => current === 'tweaks' ? 'preview' : 'tweaks');
  }
}
