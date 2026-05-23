//
//  FoodDetailView.swift
//  Grocery App
//
//  Created by Ikezaki Kumataka on 2026/05/23.
//

import SwiftUI

struct FoodDetailView: View {
    let item: FoodItem
    @Environment(\.presentationMode) var presentationMode
    
    // 🚀【追加】ViewModelを呼び出せるようにする
    @StateObject private var viewModel = FoodListViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("食材の詳細")
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
            }
            .padding(.horizontal)
            .padding(.top, 25)
            .padding(.bottom, 15)
            
            ScrollView {
                VStack(spacing: 20) {
                    // 🚀【修正エリア】ダミーのphotoアイコンを削除し、実際の写真を映し出す！
                    if let imagePath = item.imagePath,
                       let image = viewModel.loadImageFromDocuments(fileName: imagePath) {
                        // 写真が保存されている場合
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill() // 🚀 ここをFillにして正方形に綺麗に収めます
                            .frame(width: 180, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 20)) // 角丸にする
                            .clipped() // はみ出した部分をカット
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    } else {
                        // 写真がない場合のダミー表示（少しリッチにしました）
                        VStack {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray.opacity(0.5))
                            Text("写真はありません")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 5)
                        }
                        .frame(width: 180, height: 180)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                    }

                    VStack(spacing: 12) {
                        // 食材名
                        HStack {
                            Text("食材名")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(item.name)
                                .font(.title3)
                                .bold()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                        
                        // 消費期限
                        HStack {
                            Text("消費期限")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(item.expiryDate, style: .date)
                                .font(.title3)
                                .bold()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)

                        // ステータス（残り日数バッジ）
                        HStack {
                            Text("ステータス")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer()
                            if item.daysUntilExpiry < 1 {
                                Text("消費期限切れ")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .bold()
                                    .padding(8)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                            } else if item.daysUntilExpiry == 1 {
                                Text("あと 1 日")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .bold()
                                    .padding(8)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                            } else if item.daysUntilExpiry <= 3 {
                                Text("あと \(item.daysUntilExpiry) 日")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                            } else {
                                Text("あと \(item.daysUntilExpiry) 日")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        // 最初の高さを情報のサイズにぴったり自動フィット
        .presentationDetents([.fraction(0.6), .large])
        .presentationDragIndicator(.visible)
        // iOS標準の角丸(15px)を適用
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}
