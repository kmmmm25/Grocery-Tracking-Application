//
//  AddFood.swift
//  Grocery App
//
//  Created by Ikezaki Kumataka on 2026/05/07.
//

import SwiftUI
import UIKit

struct AddFoodView: View {
    // 追加：保存したデータをContentViewに渡すための仕組み
    var onSave: (FoodItem) -> Void
    // 追加：画面を閉じるための仕組み
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var expiryDate = Date()
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("食材名（例：卵、牛乳）", text: $name)
                    DatePicker("賞味期限", selection: $expiryDate, displayedComponents: .date)
                }

                Section(header: Text("写真")) {
                    if let image = inputImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text(inputImage == nil ? "写真を撮る" : "撮り直す")
                        }
                    }
                }
            }
            .navigationTitle("新しく登録")
            // 変更：保存ボタンなどをNavigation Bar（画面上部）に配置
            .navigationBarItems(
                leading: Button("キャンセル") {
                    presentationMode.wrappedValue.dismiss() // 画面を閉じる
                },
                trailing: Button("保存") {
                    // 入力された情報から新しい食材データを作成
                    let newItem = FoodItem(name: name, expiryDate: expiryDate, image: inputImage)
                    // ContentViewへデータを渡す
                    onSave(newItem)
                    // 画面を閉じる
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(name.isEmpty) // 名前が空の時は保存できないようにする
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
        }
    }
}
