//
//  NotificationManager.swift
//  Grocery App
//
//  Created by Ikezaki  Kumataka on 2026/05/21.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    /// ユーザーにプッシュ通知の許可をリクエストする
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("🎉 通知許可が承認されました！")
            } else if let error = error {
                print("⚠️ 通知許可のリクエスト中にエラーが発生しました: \(error.localizedDescription)")
            }
        }
    }
    
    /// 新しい食材の通知をスケジュールする（3日前、1日前、当日）
    /// - Parameters:
    ///   - id: 食材のユニークID（通知のキャンセル等に必要）
    ///   - title: 食材の名前（例: "豚バラ肉"）
    ///   - expiryDate: 消費期限の日付
    /// 【テスト用】食材登録から15秒後に強制的に通知を鳴らす
    func scheduleExpiryNotifications(id: String, title: String, expiryDate: Date) {
            let center = UNUserNotificationCenter.current()
            let calendar = Calendar.current
            
            // --- 設定のデフォルト値（のちにステップ3の設定画面と連動させます） ---
            let daysBeforeOptions = [3, 1, 0] // 3日前、1日前、当日
            let eveningHour = 17              // 夕方の通知（17:30）
            let eveningMinute = 30
            let morningHour = 8               // 朝の通知（08:00）
            let morningMinute = 0
            // -------------------------------------------------------------
            
            for daysBefore in daysBeforeOptions {
                // 消費期限から「〇日前」の日付を計算
                guard let targetDate = calendar.date(byAdding: .day, value: -daysBefore, to: expiryDate) else { continue }
                
                // 通知を鳴らす時間を決定（当日は朝、それ以外は夕方）
                var components = calendar.dateComponents([.year, .month, .day], from: targetDate)
                if daysBefore == 0 {
                    components.hour = morningHour
                    components.minute = morningMinute
                } else {
                    components.hour = eveningHour
                    components.minute = eveningMinute
                }
                
                // 計算した通知日時が、すでに過去の場合はスケジュールしない
                guard let notificationDateTime = calendar.date(from: components), notificationDateTime > Date() else {
                    continue
                }
                
                // 通知のメッセージ（内容）を作る
                let content = UNMutableNotificationContent()
                content.title = "消費期限のお知らせ ⏰"
                content.sound = .default
                
                if daysBefore == 0 {
                    content.body = "【本日まで！】\(title)の消費期限は今日です！今日中に食べるか、冷凍保存してくださいね！"
                } else if daysBefore == 1 {
                    content.body = "【明日まで！】\(title)の期限は明日までです。今夜のうちにメニューをチェック！"
                } else {
                    content.body = "【あと3日】\(title)の期限が近づいています。そろそろ使う計画を立てませんか？"
                }
                
                // トリガー（引き金）を作成
                let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDateTime)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
                
                // 通知の個別識別マーク（ID）を作る（食材ID + 何日前）
                let requestIdentifier = "\(id)_\(daysBefore)daysBefore"
                let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
                
                // iOSに通知を予約する
                center.add(request) { error in
                    if let error = error {
                        print("⚠️ 通知の予約に失敗しました (\(title)): \(error.localizedDescription)")
                    } else {
                        print("🚀 通知を予約しました: \(title)（\(daysBefore)日前 -> 予定日時: \(components.hour!):\(components.minute!)）")
                    }
                }
            }
        }
    
    /// 食材が削除されたり食べ終わったりした時に、予約中の通知を消す
    func cancelNotifications(for id: String) {
        let center = UNUserNotificationCenter.current()
        let identifiers = ["\(id)_3daysBefore", "\(id)_1daysBefore", "\(id)_0daysBefore"]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ 食材ID: \(id) の予約中通知をキャンセルしました。")
    }
}
