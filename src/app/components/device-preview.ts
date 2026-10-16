import { Component, ChangeDetectionStrategy, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { SpringBoardEngine } from '../services/tweak-engine';
import { PairingManager } from '../services/pairing';

@Component({
  selector: 'app-device-preview',
  imports: [CommonModule, MatIconModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="flex flex-col items-center justify-center p-4">
      <!-- Device Header / Mode switch -->
      <div class="flex items-center justify-between w-full max-w-[340px] mb-3 px-1 text-xs text-neutral-400">
        <div class="flex items-center gap-1.5 font-medium">
          <span class="inline-block w-2 h-2 rounded-full" [class.bg-emerald-500]="pairing.isPaired()" [class.bg-amber-500]="!pairing.isPaired()"></span>
          <span>{{ pairing.isPaired() ? 'iPhone 16 Pro (Paired)' : 'iPhone 16 Pro (Local)' }}</span>
        </div>
        <div class="flex items-center gap-1 bg-neutral-900 border border-neutral-800 rounded-lg p-0.5">
          <button
            type="button"
            (click)="screenMode.set('lock')"
            class="px-2.5 py-1 rounded text-[11px] font-medium transition-colors"
            [class.bg-neutral-800]="screenMode() === 'lock'"
            [class.text-white]="screenMode() === 'lock'"
            [class.text-neutral-400]="screenMode() !== 'lock'"
          >
            Lock Screen
          </button>
          <button
            type="button"
            (click)="screenMode.set('home')"
            class="px-2.5 py-1 rounded text-[11px] font-medium transition-colors"
            [class.bg-neutral-800]="screenMode() === 'home'"
            [class.text-white]="screenMode() === 'home'"
            [class.text-neutral-400]="screenMode() !== 'home'"
          >
            Home Screen
          </button>
        </div>
      </div>

      <!-- iPhone Chassis -->
      <div class="relative w-[320px] h-[650px] bg-black rounded-[52px] p-3 shadow-2xl border-[6px] border-neutral-800 ring-1 ring-white/10 select-none overflow-hidden flex flex-col">
        <!-- Physical button mockups on sides -->
        <div class="absolute -left-[9px] top-28 w-[3px] h-8 bg-neutral-700 rounded-l"></div>
        <div class="absolute -left-[9px] top-40 w-[3px] h-12 bg-neutral-700 rounded-l"></div>
        <div class="absolute -left-[9px] top-56 w-[3px] h-12 bg-neutral-700 rounded-l"></div>
        <div class="absolute -right-[9px] top-36 w-[3px] h-16 bg-neutral-700 rounded-r"></div>

        <!-- Screen Container with Wallpaper -->
        <div class="relative w-full h-full rounded-[42px] overflow-hidden bg-gradient-to-b from-indigo-950 via-slate-900 to-neutral-950 flex flex-col justify-between p-4 text-white">
          
          <!-- Top Area: Status Bar & Dynamic Island -->
          <div class="relative z-30 pt-1">
            <!-- Breadcrumb Navigation Simulation -->
            @if (!engine.isEnabled('breadcrumb')) {
              <div class="absolute left-0 top-1.5 flex items-center gap-0.5 text-[10px] text-blue-400 font-medium">
                <mat-icon class="!w-3 !h-3 !text-[12px] leading-none">chevron_left</mat-icon>
                <span>Settings</span>
              </div>
            }

            <!-- Dynamic Island Pill -->
            <div class="mx-auto w-24 h-7 bg-black rounded-full flex items-center justify-between px-2.5 shadow-md">
              <div class="w-2.5 h-2.5 rounded-full bg-neutral-900 ring-1 ring-neutral-800"></div>
              <div class="flex items-center gap-1">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                <span class="text-[9px] font-mono text-neutral-300">AirLift</span>
              </div>
            </div>

            <!-- Status bar items -->
            <div class="flex justify-between items-center text-[11px] font-semibold mt-1 px-3">
              <span class="tracking-tight">9:41</span>
              <div class="flex items-center gap-1.5 text-neutral-200">
                <mat-icon class="!w-3.5 !h-3.5 !text-[14px] leading-none">signal_cellular_alt</mat-icon>
                <span class="text-[10px] font-bold">5G</span>
                <mat-icon class="!w-3.5 !h-3.5 !text-[14px] leading-none">wifi</mat-icon>
                <div class="flex items-center gap-0.5 text-[10px]">
                  <span>88%</span>
                  <mat-icon class="!w-4 !h-4 !text-[14px] leading-none">battery_full</mat-icon>
                </div>
              </div>
            </div>

            <!-- Authentication Engineering Line -->
            @if (engine.isEnabled('authenticationLine')) {
              <div class="mt-2 mx-auto w-48 h-[2px] bg-emerald-400 shadow-[0_0_8px_rgba(52,211,153,0.8)] rounded-full animate-pulse"></div>
            }

            <!-- Supervision text -->
            @if (engine.isEnabled('supervision') && screenMode() === 'lock') {
              <div class="mt-3 text-center">
                <p class="text-[9px] text-neutral-300/80 font-medium tracking-tight bg-black/40 backdrop-blur-md py-0.5 px-2 rounded-full inline-block border border-white/10">
                  This iPhone is supervised and managed by X
                </p>
              </div>
            }
          </div>

          <!-- Main Screen Body -->
          <div class="relative z-20 flex-1 flex flex-col justify-center items-center my-2">
            @if (screenMode() === 'lock') {
              <!-- Lock Screen UI -->
              <div class="flex flex-col items-center text-center">
                <mat-icon class="!w-5 !h-5 !text-[20px] text-neutral-300 mb-1">lock</mat-icon>
                <span class="text-xs text-neutral-300 font-medium tracking-wide">Friday, October 16</span>
                <span class="text-6xl font-light tracking-tighter my-1 drop-shadow-md">09:41</span>
                
                <!-- AC Power Battery on Lockscreen -->
                @if (!engine.isEnabled('acPower')) {
                  <div class="mt-3 flex items-center gap-1.5 bg-black/40 backdrop-blur-md px-3 py-1.5 rounded-2xl border border-white/10 text-xs">
                    <mat-icon class="!w-4 !h-4 !text-[16px] text-emerald-400">bolt</mat-icon>
                    <span class="font-medium text-emerald-300">88% Charged</span>
                  </div>
                }

                <!-- Low Battery Alert Dialog Simulation (if not disabled) -->
                @if (showLowBatterySample() && !engine.isEnabled('lowBattery')) {
                  <div class="mt-4 bg-neutral-900/95 backdrop-blur-xl border border-white/15 rounded-2xl p-3 text-center shadow-2xl max-w-[220px]">
                    <h5 class="text-xs font-semibold text-white">Low Battery</h5>
                    <p class="text-[10px] text-neutral-300 mt-0.5">20% battery remaining</p>
                    <div class="mt-2.5 pt-2 border-t border-white/10 flex justify-center">
                      <button type="button" (click)="dismissLowBattery()" class="text-[11px] font-semibold text-blue-400 hover:text-blue-300">
                        Close
                      </button>
                    </div>
                  </div>
                }
              </div>
            } @else {
              <!-- Home Screen UI with App Grid -->
              <div class="w-full flex flex-col justify-between h-full pt-4">
                <div class="grid grid-cols-4 gap-3.5 px-1">
                  <!-- App Icons -->
                  <div class="flex flex-col items-center gap-1">
                    <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center shadow-lg">
                      <mat-icon class="text-white !w-6 !h-6 !text-[24px]">explore</mat-icon>
                    </div>
                    <span class="text-[10px] text-neutral-200 font-medium">Safari</span>
                  </div>
                  <div class="flex flex-col items-center gap-1">
                    <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-emerald-500 to-green-600 flex items-center justify-center shadow-lg">
                      <mat-icon class="text-white !w-6 !h-6 !text-[24px]">chat</mat-icon>
                    </div>
                    <span class="text-[10px] text-neutral-200 font-medium">Messages</span>
                  </div>
                  <div class="flex flex-col items-center gap-1">
                    <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-purple-500 to-pink-600 flex items-center justify-center shadow-lg">
                      <mat-icon class="text-white !w-6 !h-6 !text-[24px]">photo_library</mat-icon>
                    </div>
                    <span class="text-[10px] text-neutral-200 font-medium">Photos</span>
                  </div>
                  <div class="flex flex-col items-center gap-1">
                    <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-neutral-800 to-black ring-1 ring-white/20 flex items-center justify-center shadow-lg">
                      <span class="text-white font-bold text-sm tracking-widest">X</span>
                    </div>
                    <span class="text-[10px] text-neutral-200 font-medium">X Toolkit</span>
                  </div>
                  
                  <div class="flex flex-col items-center gap-1">
                    <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-amber-500 to-orange-600 flex items-center justify-center shadow-lg">
                      <mat-icon class="text-white !w-6 !h-6 !text-[24px]">music_note</mat-icon>
                    </div>
                    <span class="text-[10px] text-neutral-200 font-medium">Music</span>
                  </div>
                  <div class="flex flex-col items-center gap-1">
                    <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-slate-600 to-slate-800 flex items-center justify-center shadow-lg">
                      <mat-icon class="text-white !w-6 !h-6 !text-[24px]">settings</mat-icon>
                    </div>
                    <span class="text-[10px] text-neutral-200 font-medium">Settings</span>
                  </div>
                  <div class="flex flex-col items-center gap-1">
                    <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-rose-500 to-red-600 flex items-center justify-center shadow-lg">
                      <mat-icon class="text-white !w-6 !h-6 !text-[24px]">mail</mat-icon>
                    </div>
                    <span class="text-[10px] text-neutral-200 font-medium">Mail</span>
                  </div>
                  <div class="flex flex-col items-center gap-1">
                    <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-cyan-500 to-blue-600 flex items-center justify-center shadow-lg">
                      <mat-icon class="text-white !w-6 !h-6 !text-[24px]">cloud</mat-icon>
                    </div>
                    <span class="text-[10px] text-neutral-200 font-medium">Weather</span>
                  </div>
                </div>

                <!-- Dock Area -->
                <div 
                  class="w-full rounded-3xl p-2.5 flex justify-around items-center transition-all duration-300"
                  [class.bg-white/20]="!engine.isEnabled('hideDockBg')"
                  [class.backdrop-blur-xl]="!engine.isEnabled('hideDockBg')"
                  [class.bg-transparent]="engine.isEnabled('hideDockBg')"
                >
                  <div class="w-11 h-11 rounded-xl bg-gradient-to-br from-green-500 to-emerald-600 flex items-center justify-center shadow-md">
                    <mat-icon class="text-white !w-5 !h-5 !text-[20px]">call</mat-icon>
                  </div>
                  <div class="w-11 h-11 rounded-xl bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center shadow-md">
                    <mat-icon class="text-white !w-5 !h-5 !text-[20px]">public</mat-icon>
                  </div>
                  <div class="w-11 h-11 rounded-xl bg-gradient-to-br from-neutral-800 to-neutral-900 border border-white/20 flex items-center justify-center shadow-md">
                    <mat-icon class="text-white !w-5 !h-5 !text-[20px]">terminal</mat-icon>
                  </div>
                  <div class="w-11 h-11 rounded-xl bg-gradient-to-br from-purple-600 to-indigo-700 flex items-center justify-center shadow-md">
                    <mat-icon class="text-white !w-5 !h-5 !text-[20px]">tune</mat-icon>
                  </div>
                </div>
              </div>
            }
          </div>

          <!-- Bottom Area: Flashlight/Camera (Lock) & Home Bar -->
          <div class="relative z-20 pb-1">
            @if (screenMode() === 'lock') {
              <div class="flex justify-between items-center px-3 mb-2">
                <div class="w-10 h-10 rounded-full bg-black/40 backdrop-blur-md border border-white/10 flex items-center justify-center">
                  <mat-icon class="!w-5 !h-5 !text-[20px] text-neutral-200">flashlight_on</mat-icon>
                </div>
                <div class="w-10 h-10 rounded-full bg-black/40 backdrop-blur-md border border-white/10 flex items-center justify-center">
                  <mat-icon class="!w-5 !h-5 !text-[20px] text-neutral-200">photo_camera</mat-icon>
                </div>
              </div>
            }

            <!-- Home Bar Indicator -->
            @if (!engine.isEnabled('hideHomeBar')) {
              <div class="mx-auto w-32 h-1 bg-white/70 rounded-full"></div>
            }
          </div>

          <!-- Respring Animation Overlay -->
          @if (engine.isRespringing()) {
            <div class="absolute inset-0 z-50 bg-black flex flex-col items-center justify-center">
              <div class="w-10 h-10 border-2 border-neutral-700 border-t-white rounded-full animate-spin"></div>
              <span class="text-xs text-neutral-400 font-mono mt-4 tracking-wider">SpringBoard restarting...</span>
            </div>
          }
        </div>
      </div>

      <!-- Live Tweak Status Legend -->
      <div class="w-full max-w-[340px] mt-3 bg-neutral-900/60 border border-neutral-800/80 rounded-xl p-2.5 text-xs">
        <div class="flex items-center justify-between text-neutral-400 mb-1">
          <span class="font-medium text-neutral-300">Active Visual Tweaks:</span>
          <span class="font-mono text-emerald-400 font-semibold">{{ engine.enabledCount() }} applied</span>
        </div>
        <div class="flex flex-wrap gap-1 mt-1">
          @for (tweak of engine.tweaks(); track tweak.id) {
            @if (engine.isEnabled(tweak.id)) {
              <span class="inline-flex items-center gap-1 bg-neutral-800 border border-neutral-700 text-neutral-300 px-2 py-0.5 rounded text-[10px]">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                {{ tweak.title }}
              </span>
            }
          }
          @if (engine.enabledCount() === 0) {
            <span class="text-neutral-500 italic text-[11px]">Stock iOS SpringBoard preferences</span>
          }
        </div>
      </div>
    </div>
  `
})
export class DevicePreview {
  readonly engine = inject(SpringBoardEngine);
  readonly pairing = inject(PairingManager);

  readonly screenMode = signal<'lock' | 'home'>('lock');
  readonly showLowBatterySample = signal<boolean>(true);

  dismissLowBattery(): void {
    this.showLowBatterySample.set(false);
  }
}
