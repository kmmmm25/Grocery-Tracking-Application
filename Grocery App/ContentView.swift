//
//  ContentView.swift
//  Grocery App
//
//  Created by Ikezaki Kumataka on 2026/05/03.
//

import SwiftUI

struct ContentView: View {
    // 🚀 AppApp.swift から環境変数経由でログイン中の家族IDを受け取る
    @Environment(\.currentFamilyID) var currentFamilyID
    
    // 🚀 ViewModelをログインしている家族IDに基づいて管理する
    @StateObject private var viewModel = FoodListViewModel()
    
    @State private var showingAddFoodView = false
    @State private var editingItem: FoodItem? = nil
    
    // 削除確認アラートを管理するための変数
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: FoodItem? = nil

    // タップされた食材の詳細を表示するための状態管理
    @State private var selectedItemForDetail: FoodItem? = nil

    var body: some View {
        NavigationView {
            List(viewModel.foodItems) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text("期限: \(item.expiryDate, style: .date)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // 残り日数に応じたカラーバッジ
                    if item.daysUntilExpiry < 1 {
                        Text("消費期限切れです")
                            .foregroundColor(.red)
                            .font(.caption)
                            .bold()
                            .padding(6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    } else if item.daysUntilExpiry <= 3 {
                        Text("あと \(item.daysUntilExpiry) 日")
                            .foregroundColor(.orange)
                            .font(.caption)
                            .bold()
                            .padding(6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        Text("あと \(item.daysUntilExpiry) 日")
                            .foregroundColor(.green)
                            .font(.caption)
                            .bold()
                            .padding(6)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .contentShape(Rectangle()) // 行の空白部分をタップしても反応するようにする設定
                .onTapGesture {
                    // タップしたら詳細シートを開く
                    selectedItemForDetail = item
                }
                // 左スワイプで「編集」「削除」のメニューを出す
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // 削除ボタン
                    Button(role: .destructive) {
                        itemToDelete = item
                        showingDeleteAlert = true
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                    
                    // 編集ボタン
                    Button {
                        editingItem = item
                    } label: {
                        Label("編集", systemImage: "pencil")
                    }
                    .tint(.orange)
                }
            }
            .navigationTitle("\(currentFamilyID)") // タイトルにログイン中の家族IDを表示
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddFoodView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                // 🚀 ログアウトボタン
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // 端末に保存されている家族IDを消去
                        UserDefaults.standard.removeObject(forKey: "savedFamilyID")
                        
                        // 画面を強制的にログイン画面に戻す（UIHostingControllerの引数を rootView: に修正）
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController = UIHostingController(
                                rootView: FamilyAuthView(currentFamilyID: .constant(nil))
                            )
                            window.makeKeyAndVisible()
                        }
                    }) {
                        Text("ログアウト")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
            }
            // ➕ボタン（新規登録）
            .sheet(isPresented: $showingAddFoodView) {
                AddFoodView(onSave: { newItem in
                    viewModel.add(item: newItem)
                }, existingItem: nil)
            }
            // 長押し（スワイプ）編集
            .sheet(item: $editingItem) { itemToEdit in
                AddFoodView(onSave: { updatedItem in
                    viewModel.update(item: updatedItem)
                }, existingItem: itemToEdit)
            }
            // タップした時の「詳細ハーフシート」画面
            .sheet(item: $selectedItemForDetail) { itemToShow in
                FoodDetailView(item: itemToShow)
            }
            // 「はい / いいえ」の削除確認アラート画面
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("食材の削除"),
                    message: Text("本当に「\((itemToDelete?.name) ?? "この食材")」を削除しますか？"),
                    primaryButton: .destructive(Text("はい")) {
                        if let item = itemToDelete {
                            viewModel.delete(item: item)
                        }
                    },
                    secondaryButton: .cancel(Text("いいえ")) {
                        itemToDelete = nil
                    }
                )
            }
        }
    }
}
