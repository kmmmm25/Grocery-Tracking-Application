//
//  AddFood.swift
//  Grocery App
//
//  Created by Ikezaki Kumataka on 2026/05/07.
//

import SwiftUI
import UIKit

struct AddFoodView: View {
    var onSave: (FoodItem) -> Void
    @Environment(\.presentationMode) var presentationMode
    var existingItem: FoodItem?

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
            .navigationTitle(existingItem == nil ? "新しく登録" : "食材を編集")
            .navigationBarItems(
                leading: Button("キャンセル") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    if var item = existingItem {
                        // 🚀【編集の場合】写真はそのまま引き継ぐ（今回は簡略化のため写真は編集不可とします）
                        item.name = name
                        item.expiryDate = expiryDate
                        onSave(item)
                    } else {
                        // 🚀【新規登録の場合】ここが本番！
                        let foodId = UUID().uuidString // IDを先に決める
                        var newItem = FoodItem(name: name, expiryDate: expiryDate, image: inputImage)
                        newItem.id = foodId
                        
                        // 🚀 もし写真があれば、iPhone内に保存してパスを記録する
                        if let image = inputImage {
                            if let savedPath = saveImageToDocuments(image: image, fileName: "\(foodId).jpg") {
                                newItem.imagePath = savedPath
                            }
                        }
                        
                        onSave(newItem)
                    }
                    
                    // 通知の予約
                    let foodId = existingItem?.id ?? UUID().uuidString
                    NotificationManager.shared.scheduleExpiryNotifications(
                        id: foodId,
                        title: name,
                        expiryDate: expiryDate
                    )
                    
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(name.isEmpty)
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .onAppear {
                if let item = existingItem {
                    name = item.name
                    expiryDate = item.expiryDate
                    // ※写真は現在、imagePathからの復元が必要なため、後ほど実装します
                }
            }
        }
    }
    
    // 🚀【新機能】UIImageをiPhone内のDocumentsフォルダにJPEGとして保存する関数
    private func saveImageToDocuments(image: UIImage, fileName: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            print("📸 写真を保存しました: \(fileURL.lastPathComponent)")
            return fileURL.lastPathComponent // 保存したファイル名だけを返す
        } catch {
            print("⚠️ 写真の保存に失敗しました: \(error.localizedDescription)")
            return nil
        }
    }
}
