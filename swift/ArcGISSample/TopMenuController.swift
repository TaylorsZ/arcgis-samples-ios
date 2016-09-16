//
//  TopMenuController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit

class TopMenuController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    
    let items = [
        "LayersViewController",
        "SwipeViewController",
        "PerspectiveViewController",
        "GpsViewController",
        "SensorViewController",
        "LegendViewController",
        "MagnifierViewController",
        "SketchViewController",
        "WmsViewController",
        "TimeViewController",
        "WebmapViewController",
        "CustomSymbolViewController",
        "RotationRendererViewController",
        "SearchViewController",
        "SpatialQueryViewController",
        "AttachmentManagerViewController",
        "LocatorViewController",
        "NetworkViewController",
        "ServiceAreaViewController",
        "CoordinateConversionViewController",
        "JsonViewController",
        "ExportTilesViewController"
    ]
    
    let itemNames = [
        "レイヤの表示・非表示",
        "スワイプ",
        "パース表示",
        "ナビゲーション",
        "地図の回転",
        "凡例",
        "拡大鏡",
        "スケッチレイヤー",
        "WMSレイヤー",
        "時間対応レイヤー",
        "Webマップの表示",
        "シンボルの表示",
        "レンダラー",
        "属性検索",
        "空間検索",
        "写真の添付",
        "リバース ジオコーディング",
        "ルート検索",
        "到達圏解析",
        "座標の表示形式",
        "フィーチャをJSON形式で保存",
        "タイルのエクスポート"
    ]
    
    
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = "メニュー"
        tableView = UITableView(frame: view.bounds)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        cell.textLabel!.text = "\(itemNames[indexPath.row])"
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let strTarget:String = "ArcGISSample."
        let strVC:String = items[indexPath.row] as String
        let className = strTarget + strVC
        
        if let theClass = NSClassFromString(className) as? UIViewController.Type {
            let controller = theClass.init(nibName: nil, bundle: nil)
            navigationController!.pushViewController(controller, animated: true)
        }


    }
        
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

