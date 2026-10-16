import SwiftUI

@main
struct XApp: App {
    @StateObject private var environment = AppEnvironment.shared
    
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(environment)
                .preferredColorScheme(.dark)
        }
    }
}

struct MainAppView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: TabSelection = .dashboard
    
    enum TabSelection: Hashable {
        case dashboard
        case customization
        case pairing
        case plist
        case diagnostics
        case settings
    }
    
    var body: some View {
        if horizontalSizeClass == .regular {
            // Adaptive iPad Layout (Split view / Sidebar)
            NavigationSplitView {
                List(selection: $selectedTab) {
                    NavigationLink(value: TabSelection.dashboard) {
                        Label("Dashboard", systemImage: "square.grid.2x2")
                    }
                    NavigationLink(value: TabSelection.customization) {
                        Label("Customization", systemImage: "slider.horizontal.3")
                    }
                    NavigationLink(value: TabSelection.pairing) {
                        Label("Device Pairing", systemImage: "link")
                    }
                    NavigationLink(value: TabSelection.plist) {
                        Label("Plist Inspector", systemImage: "doc.text")
                    }
                    NavigationLink(value: TabSelection.diagnostics) {
                        Label("Diagnostics", systemImage: "waveform.path.ecg")
                    }
                    NavigationLink(value: TabSelection.settings) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                .navigationTitle("Project X")
            } detail: {
                detailView(for: selectedTab)
            }
        } else {
            // Adaptive iPhone Layout (TabView)
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "square.grid.2x2")
                    }
                    .tag(TabSelection.dashboard)
                
                NavigationStack {
                    CustomizationView()
                }
                .tabItem {
                    Label("Tweaks", systemImage: "slider.horizontal.3")
                }
                .tag(TabSelection.customization)
                
                NavigationStack {
                    DevicePairingView()
                }
                .tabItem {
                    Label("Pairing", systemImage: "link")
                }
                .tag(TabSelection.pairing)
                
                NavigationStack {
                    PlistInspectorView()
                }
                .tabItem {
                    Label("Plist", systemImage: "doc.text")
                }
                .tag(TabSelection.plist)
                
                NavigationStack {
                    DiagnosticsView()
                }
                .tabItem {
                    Label("Logs", systemImage: "waveform.path.ecg")
                }
                .tag(TabSelection.diagnostics)
            }
            .tint(.white)
        }
    }
    
    @ViewBuilder
    private func detailView(for tab: TabSelection) -> some View {
        switch tab {
        case .dashboard:
            DashboardView()
        case .customization:
            NavigationStack { CustomizationView() }
        case .pairing:
            NavigationStack { DevicePairingView() }
        case .plist:
            NavigationStack { PlistInspectorView() }
        case .diagnostics:
            NavigationStack { DiagnosticsView() }
        case .settings:
            SettingsView()
        }
    }
}
