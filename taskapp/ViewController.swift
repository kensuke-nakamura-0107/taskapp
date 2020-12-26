//
//  ViewController.swift
//  taskapp
//
//  Created by 中村憲佑 on 2020/12/25.
//  Copyright © 2020 kensuke.nakamura. All rights reserved.
//


//①検索ボタンが押されたらSearchBar!に入れた値を取得する
//②SearchBar!に入れた値をRealmのfilterにセットして該当のものだけ表示する


import UIKit
import RealmSwift
import UserNotifications    // 追加

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
     //UI連携
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchCategory: UISearchBar!
    //イニシャライズ
    let realm = try! Realm()  // ←追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    //検索ボタン押下アクション（①⭐️検索ボタンが押されたらSearchBar!に入れた値を取得する）
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    //全体結果表示用
       var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    //絞り込み結果表示用
       var searchReslut = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true).filter("category = 'ランチ'")

    // データの数を返すメソッド（（②⭐️検索ボタンが押されていたかどうかで場合わけ）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskArray.count
        //searchCategoryがブランクの場合は全部返す、値が入ってる時はsearchResult.countを返す
//        if searchCategory.text == "" {
//            taskArray.count
//        } else {
//            searchResult.count
        }
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Cellに値を設定する.  --- ここから ---
        let task = searchReslut[indexPath.row]
        cell.textLabel?.text = task.title

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        // --- ここまで追加 --
        return cell
    }
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil) // ←追加する
    }
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        } // --- ここまで変更 ---
    }
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()

            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

