//
//  DidSTableViewDataSource.swift
//  YogiYoCloneIOS
//
//  Created by Qussk_MAC on 2020/10/21.
//  Copyright © 2020 김동현. All rights reserved.
//

import UIKit


extension DidSearchVC : UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    searchList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "StoreListCell", for: indexPath) as! StoreListCell
    
    let search = searchList[indexPath.row].results
    let searchRetrun = searchMager.retunArray()
    let searchArr = search?[searchRetrun]
    
    _ = URL(string: searchArr?.image ?? "")
    
    cell.setValue(image: searchArr?.image, title: searchArr?.name, starPoint: searchArr?.star, review: searchArr?.reviewCount, discount: searchArr?.deliveryDiscount, explain: searchArr?.representativeMenus)
    cell.cescoMark.setImage(UIImage(named: "cesco"), for: .normal)
    cell.estimatedTime.text = searchArr?.deliveryTime ?? ""
    
    return cell
  }
}

