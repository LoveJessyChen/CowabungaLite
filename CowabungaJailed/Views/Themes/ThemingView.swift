//
//  ThemingView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/24/23.
//

import SwiftUI

struct ThemingView: View {
    @State private var enableTweak = false
    @StateObject private var dataSingleton = DataSingleton.shared
    @StateObject private var themeManager = ThemingManager.shared
    @State private var easterEgg = false
    private var gridItemLayout = [GridItem(.adaptive(minimum: 160))]
    
    @State private var isAppClips: Bool = false
    @State private var hideAppLabels: Bool = false
    
    @State private var showPicker: Bool = false
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: easterEgg ? "doc.badge.gearshape.fill" : "paintbrush")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35).onTapGesture(perform: { easterEgg = !easterEgg })
                    VStack {
                        HStack {
                            Text(easterEgg ? "TrollTools" : "Icon Theming")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Toggle("Enable", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.themes, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.themes)
                            })
                            Spacer()
                        }
                    }
                    Spacer()
                    Button(action: {
                        showPicker.toggle()
                    }) {
                        Image(systemName: "square.and.arrow.down")
                        Text("Import")
                    }
                    .padding(.horizontal, 15)
                }
                Divider()
            }
            if dataSingleton.deviceAvailable {
                Group {
                    if (themeManager.themes.count == 0) {
                        Text("No themes found.\nDownload themes in the Explore tab or import them using the button in the top right corner.\nThemes have to contain icons in the format of <id>.png.")
                            .padding()
                            .background(Color.cowGray)
                            .multilineTextAlignment(.center)
                            .cornerRadius(16)
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    } else {
                        Group {
                            Toggle(isOn: $hideAppLabels) {
                                Text("Hide App Labels")
                            }.onChange(of: hideAppLabels, perform: { nv in
                                try? themeManager.setThemeSettings(hideDisplayNames: nv)
                            })
                            Toggle(isOn: $isAppClips) {
                                Text("As App Clips")
                            }.onChange(of: isAppClips, perform: { nv in
                                try? themeManager.setThemeSettings(appClips: nv)
                            })
                        }
                        Group {
                            LazyVGrid(columns: gridItemLayout, spacing: 10) {
                                ForEach(themeManager.themes, id: \.name) { theme in
                                    ThemeView(theme: theme)
                                }
                            }
                        }
                    }
                    Divider()
                    Text("Alternative Icons")
                }.disabled(!enableTweak)
            }
        }
        .disabled(!dataSingleton.deviceAvailable)
        .onAppear {
            themeManager.getThemes()
            hideAppLabels = themeManager.getThemeToggleSetting("HideDisplayNames")
            isAppClips = themeManager.getThemeToggleSetting("AsAppClips")
        }
        .fileImporter(isPresented: $showPicker, allowedContentTypes: [.folder], allowsMultipleSelection: false, onCompletion: { result in
            guard let url = try? result.get().first else { return }
            try? ThemingManager.shared.importTheme(from: url)
        })
    }
}

struct ThemingView_Previews: PreviewProvider {
    static var previews: some View {
        ThemingView()
    }
}
