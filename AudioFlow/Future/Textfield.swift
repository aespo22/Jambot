//
//  textfield try.swift
//  MC3-Invisible
//
//  Created by Antonio Esposito on 23/02/23.
//

import SwiftUI

struct Textfield: View {
    @State private var text: String = ""
    
    private func tagViews() -> [TagView] {
        return text.split(separator: " ").map { TagView(tag: String($0)) }
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                ForEach(tagViews(), id: \.tag) { tagView in
                    tagView
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            HStack(spacing: 8) {
                TextField("Add tag", text: $text, onCommit: {
                    // Do something with the entered text
                })
                .textFieldStyle(RoundedBorderTextFieldStyle()) // apply the textFieldStyle to the instance of the TextField view
                Button(action: {
                    // Add the entered tag to the list of tags
                    text.append(" ")
                }, label: {
                    Image(systemName: "plus.circle.fill")
                           })
            }
            .padding(.horizontal)
        }
    }
}

struct TagView: View {
    let tag: String
    
    var body: some View {
        Text(tag)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue)
            .cornerRadius(16)
    }
}




struct Textfield_Previews: PreviewProvider {
    static var previews: some View {
        Textfield()
    }
}
