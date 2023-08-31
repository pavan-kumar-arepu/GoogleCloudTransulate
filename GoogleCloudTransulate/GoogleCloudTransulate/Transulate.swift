//
//  Transulate.swift
//  GoogleCloudTransulate
//
//  Created by Pavankumar Arepu on 22/08/23.
//

import Foundation

import SwiftUI

struct TransulateView: View {
    
    
    @State private var inputText = "How are you"
    @State private var selectedLanguage = "Hindi" // Default target language
    
    @State private var translatedText: String?
    let apiKey = "AIzaSyDtYovVn0-mrX9BwSu1_2b4-72tqlQLp0I"
    
    let indianLanguages: [String: String] = [
        "Assamese": "as",
        "Bengali": "bn",
        "Bodo": "brx",
        "Dogri": "doi",
        "Gujarati": "gu",
        "Hindi": "hi",
        "Kannada": "kn",
        "Kashmiri": "ks",
        "Konkani": "kok",
        "Maithili": "mai",
        "Malayalam": "ml",
        "Manipuri": "mni",
        "Marathi": "mr",
        "Nepali": "ne",
        "Odia": "or",
        "Punjabi": "pa",
        "Sanskrit": "sa",
        "Santali": "sat",
        "Sindhi": "sd",
        "Tamil": "ta",
        "Telugu": "te",
        "Urdu": "ur"
    ]
    
    var body: some View {
        
        VStack {
            
            Text("Transulation App").font(.title)
            Spacer()
            
            Text("India is an incredibly linguistically diverse country, and the number of languages spoken can vary depending on how languages and dialects are classified.")
                .foregroundColor(.blue)
            // Set text color to white
            
            let viewHeight = UIScreen.main.bounds.height * 0.2 /// Calculate 30% of the screen height
            Spacer()
            
            TextField("Enter text to translate", text: $inputText)
                .multilineTextAlignment(.center)
                .frame(height: viewHeight)
                .padding(7)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .shadow(radius: 4.0)
                .lineLimit(5)
            
            Text(translatedText ?? "Didn't try below languages yet?")
                .frame(height: viewHeight)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity) // Expand to full width
                .cornerRadius(10)
                .padding(.horizontal, 10)
                .foregroundColor(.gray)// Spacing on the left and right
            
            // Replace the Picker with a Grid of buttons
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.adaptive(minimum: 80))]) {
                    ForEach(indianLanguages.keys.sorted(), id: \.self) { language in
                        Button(action: {
                            selectedLanguage = language
                            translateText() // Automatically initiate translation
                            
                        }) {
                            Text(language)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    func translateText() {
        guard let targetLanguageCode = TranslationUtility.languageNameToCode(selectedLanguage, indianLanguages: indianLanguages) else {
            print("Target language code not found.")
            return
        }
        
        TranslationUtility.translateText(inputText: inputText, targetLanguage: targetLanguageCode, apiKey: apiKey) { translation in
            DispatchQueue.main.async {
                self.translatedText = translation
            }
        }
    }
}


struct TransulateView_Preview: PreviewProvider {
    static var previews: some View {
        TransulateView()
    }
}




class TranslationUtility {
    
    let indianLanguages: [String: String] = [
        "Assamese": "as",
        "Bengali": "bn",
        "Bodo": "brx",
        "Dogri": "doi",
        "Gujarati": "gu",
        "Hindi": "hi",
        "Kannada": "kn",
        "Kashmiri": "ks",
        "Konkani": "kok",
        "Maithili": "mai",
        "Malayalam": "ml",
        "Manipuri": "mni",
        "Marathi": "mr",
        "Nepali": "ne",
        "Odia": "or",
        "Punjabi": "pa",
        "Sanskrit": "sa",
        "Santali": "sat",
        "Sindhi": "sd",
        "Tamil": "ta",
        "Telugu": "te",
        "Urdu": "ur"
    ]
    
    static func translateText(inputText: String, targetLanguage: String, apiKey: String, completion: @escaping (String?) -> Void) {
        let baseURL = "https://translation.googleapis.com/language/translate/v2"
        let params: [String: String] = [
            "key": apiKey,
            "q": inputText,
            "target": targetLanguage
        ]
        
        guard let url = URL(string: baseURL)?.withQueries(params) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let translations = json["data"] as? [String: Any],
               let translatedTexts = translations["translations"] as? [[String: Any]],
               let firstTranslation = translatedTexts.first?["translatedText"] as? String {
                completion(firstTranslation)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    static func languageNameToCode(_ name: String, indianLanguages: [String: String]) -> String? {
        return indianLanguages[name]
    }
}


extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.map { URLQueryItem(name: $0.0, value: $0.1) }
        return components?.url
    }
}
