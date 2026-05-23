//
//  ContentView.swift
//  Grocery App
//
//  Created by Ikezaki Kumataka on 2026/05/03.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FoodListViewModel()
    @State private var showingAddFoodView = false
    @State private var editingItem: FoodItem? = nil
    
    // 削除確認アラートを管理するための変数
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: FoodItem? = nil

    // 🚀【新機能】タップされた食材の詳細を表示するための状態管理
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
                    
                    // 残り日数に応じたカラーバッジ（あと1日も赤色）
                    if item.daysUntilExpiry < 1 {
                        Text("消費期限切れです")
                            .foregroundColor(.red)
                            .font(.caption)
                            .bold()
                            .padding(6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    } else if item.daysUntilExpiry == 1 {
                        Text("あと 1 日")
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
                            .padding(6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        Text("あと \(item.daysUntilExpiry) 日")
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(6)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .contentShape(Rectangle()) // 行のどこをタップしても反応するようにする魔法の1行
                // 🚀【新機能】タップした時の動作（詳細ハーフシートを開く）
                .onTapGesture {
                    selectedItemForDetail = item
                }
                // 長押しで出現するメニュー
                .contextMenu {
                    Button(action: {
                        editingItem = item
                    }) {
                        Label("編集する", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        // すぐ消さずに、消したい食材をキープしてアラートの旗（フラグ）をONにする
                        itemToDelete = item
                        showingDeleteAlert = true
                    }) {
                        Label("削除する", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("食材管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        editingItem = nil
                        showingAddFoodView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // ➕ボタン（新規登録）
            .sheet(isPresented: $showingAddFoodView) {
                AddFoodView(onSave: { newItem in
                    viewModel.add(item: newItem)
                }, existingItem: nil)
            }
            // 長押し編集
            .sheet(item: $editingItem) { itemToEdit in
                AddFoodView(onSave: { updatedItem in
                    viewModel.update(item: updatedItem)
                }, existingItem: itemToEdit)
            }
            // 🚀【新機能】普通にタップした時の「詳細ハーフシート」画面
            // itemBindable が入ってきたら自動的にシートを開きます
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
