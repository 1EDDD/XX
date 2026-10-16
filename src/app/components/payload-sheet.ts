import { Component, ChangeDetectionStrategy, inject, signal, output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { SpringBoardEngine } from '../services/tweak-engine';

@Component({
  selector: 'app-payload-sheet',
  imports: [CommonModule, MatIconModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
      <div class="w-full max-w-2xl bg-neutral-900 border border-neutral-800 rounded-2xl shadow-2xl flex flex-col max-h-[90vh] overflow-hidden">
        
        <!-- Header -->
        <div class="flex items-center justify-between p-4 border-b border-neutral-800">
          <div class="flex items-center gap-2.5">
            <div class="w-8 h-8 rounded-lg bg-neutral-800 flex items-center justify-center text-white">
              <mat-icon class="!w-5 !h-5 !text-[20px]">code</mat-icon>
            </div>
            <div>
              <h3 class="text-sm font-semibold text-white">com.apple.springboard.plist</h3>
              <p class="text-xs text-neutral-400 font-mono">{{ engine.destinationPath }}</p>
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

        <!-- Format Selector & Actions -->
        <div class="px-5 py-3 border-b border-neutral-800 flex items-center justify-between bg-neutral-950/40">
          <div class="flex items-center gap-2">
            <button
              type="button"
              (click)="viewMode.set('xml')"
              class="px-2.5 py-1 rounded text-xs font-medium transition-colors"
              [class.bg-neutral-800]="viewMode() === 'xml'"
              [class.text-white]="viewMode() === 'xml'"
              [class.text-neutral-400]="viewMode() !== 'xml'"
            >
              XML Property List
            </button>
            <button
              type="button"
              (click)="viewMode.set('binary')"
              class="px-2.5 py-1 rounded text-xs font-medium transition-colors"
              [class.bg-neutral-800]="viewMode() === 'binary'"
              [class.text-white]="viewMode() === 'binary'"
              [class.text-neutral-400]="viewMode() !== 'binary'"
            >
              Binary (bplist00)
            </button>
          </div>

          <div class="flex items-center gap-2">
            <button
              type="button"
              (click)="copyPayload()"
              class="px-2.5 py-1 rounded bg-neutral-800 hover:bg-neutral-700 text-neutral-300 text-xs font-medium transition-colors flex items-center gap-1.5"
            >
              <mat-icon class="!w-3.5 !h-3.5 !text-[15px]">content_copy</mat-icon>
              <span>{{ copied() ? 'Copied!' : 'Copy' }}</span>
            </button>
            <button
              type="button"
              (click)="downloadPlist()"
              class="px-2.5 py-1 rounded bg-white text-black hover:bg-neutral-200 text-xs font-semibold transition-colors flex items-center gap-1.5"
            >
              <mat-icon class="!w-3.5 !h-3.5 !text-[15px]">download</mat-icon>
              <span>Export .plist</span>
            </button>
          </div>
        </div>

        <!-- Code Content -->
        <div class="p-4 overflow-y-auto flex-1 bg-neutral-950 font-mono text-xs">
          @if (viewMode() === 'xml') {
            <pre class="text-neutral-300 whitespace-pre leading-relaxed select-all">{{ engine.generateXmlPlist() }}</pre>
          } @else {
            <pre class="text-emerald-400 whitespace-pre leading-relaxed select-all">{{ engine.generateBinaryHex() }}</pre>
          }
        </div>

        <!-- Footer -->
        <div class="p-4 border-t border-neutral-800 bg-neutral-950/60 flex items-center justify-between">
          <div class="flex items-center gap-2 text-xs text-neutral-400">
            <span>Presets:</span>
            <button
              type="button"
              (click)="engine.applyPreset('recommended')"
              class="px-2 py-0.5 bg-neutral-800 hover:bg-neutral-700 rounded text-neutral-300 hover:text-white"
            >
              Recommended
            </button>
            <button
              type="button"
              (click)="engine.applyPreset('minimal')"
              class="px-2 py-0.5 bg-neutral-800 hover:bg-neutral-700 rounded text-neutral-300 hover:text-white"
            >
              Minimal
            </button>
            <button
              type="button"
              (click)="engine.applyPreset('reset')"
              class="px-2 py-0.5 bg-neutral-800 hover:bg-neutral-700 rounded text-neutral-400 hover:text-red-400"
            >
              Reset
            </button>
          </div>

          <button
            type="button"
            (click)="close.emit()"
            class="px-4 py-1.5 bg-neutral-800 hover:bg-neutral-700 text-white rounded-lg text-xs font-medium transition-colors"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  `
})
export class PayloadSheet {
  readonly engine = inject(SpringBoardEngine);
  readonly close = output<void>();

  readonly viewMode = signal<'xml' | 'binary'>('xml');
  readonly copied = signal<boolean>(false);

  copyPayload(): void {
    const text = this.viewMode() === 'xml' ? this.engine.generateXmlPlist() : this.engine.generateBinaryHex();
    navigator.clipboard.writeText(text);
    this.copied.set(true);
    setTimeout(() => this.copied.set(false), 2000);
  }

  downloadPlist(): void {
    const text = this.engine.generateXmlPlist();
    const blob = new Blob([text], { type: 'application/x-plist' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'com.apple.springboard.plist';
    a.click();
    URL.revokeObjectURL(url);
  }
}
