import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("itemsPerPage") private var itemsPerPage = 10
    @AppStorage("selectedPokedex") private var selectedPokedex = 0
    @Environment(\.colorScheme) private var colorScheme
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(isOn: $isDarkMode) {
                        Label {
                            Text("Dark Mode")
                        } icon: {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.blue)
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                
                Section {
                    Picker(selection: $selectedPokedex) {
                        ForEach(Pokedex.all) { pokedex in
                            Text(pokedex.name).tag(pokedex.id)
                        }
                    } label: {
                        Label {
                            Text("Pokedex")
                        } icon: {
                            Image(systemName: "book.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Picker(selection: $itemsPerPage) {
                        Text("10 items").tag(10)
                        Text("20 items").tag(20)
                        Text("50 items").tag(50)
                    } label: {
                        Label {
                            Text("Items per Page")
                        } icon: {
                            Image(systemName: "list.number")
                                .foregroundColor(.blue)
                        }
                    }
                } header: {
                    Text("Pokedex")
                }
                
                Section {
                    HStack {
                        Label {
                            Text("Version")
                        } icon: {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundColor(.gray)
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label {
                            Text("Privacy Policy")
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label {
                            Text("Terms of Service")
                        } icon: {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
} 