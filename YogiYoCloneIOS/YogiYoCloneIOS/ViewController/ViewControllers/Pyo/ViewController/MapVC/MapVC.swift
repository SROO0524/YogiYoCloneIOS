//
//  MapVC.swift
//  YogiYoCloneIOS
//
//  Created by 표건욱 on 2020/09/16.
//  Copyright © 2020 김동현. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import GooglePlaces

class MapVC: UIViewController, CLLocationManagerDelegate {
    
    static let listString = "List"
    
    let topView: TopSearchView = {
        let view = TopSearchView()
        return view
    }()
    
    lazy var addressTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NearestCustomCell.self, forCellReuseIdentifier: NearestCustomCell.identifier)
        tableView.register(NearestListCustomCell.self, forCellReuseIdentifier: NearestListCustomCell.identifier)
        tableView.register(ExplainCustomCell.self, forCellReuseIdentifier: ExplainCustomCell.identifier)
        return tableView
    }()
    
    var addressData: RoadDocument?
    var addressList: [Address] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadList()
        
        setUI()
        setLayout()
    }
    
    private func setUI() {
        
        view.backgroundColor = ColorPiker.customGray
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(dismiss(_:)))
        navigationItem.leftBarButtonItem?.tintColor = .black
        title = "배달 주소 설정"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize:16, weight: .light)]
        
        topView.searchField.delegate = self
        topView.cancleButton.addTarget(self, action: #selector(cancleToggle(_:)), for: .touchUpInside)
        topView.nowButton.addTarget(self, action: #selector(nowButtonToggle(_:)), for: .touchUpInside)
        view.addSubview(topView)
        
        view.addSubview(addressTableView)
    }
    private func setLayout() {
        
        topView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(topView.snp.width).multipliedBy(0.32)
        }
        
        addressTableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(CollectionDesign.padding / 2)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    @objc private func dismiss(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @objc private func cancleToggle(_ sender: UIButton) {
        
        topView.searchField.text = nil
        topView.searchField.isSelected = false
        topView.searchField.resignFirstResponder()
        
        addressData = nil
        addressTableView.reloadData()
        
        UIView.animate(withDuration: 0.2) {
            self.topView.cancleButton.alpha = 0
            self.topView.constraint?
                .update(offset: -CollectionDesign.padding)
            self.topView.layoutIfNeeded()
        }
    }
    @objc private func nowButtonToggle(_ sender: UIButton) {
        let locationManager = CLLocationManager()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        let coor = locationManager.location?.coordinate
        let address = reverseGeocode(location: locationManager.location ?? CLLocation())
        
        pushGoogle(address: address, road: nil, lat: coor?.latitude, lon: coor?.longitude)
    }
    @objc func removeToggle(_ sender: UIButton) {
        
        addressList.remove(at: sender.tag)
        setList()
        
        addressTableView.reloadData()
    }
    func setList() {
        if let encoded = try? JSONEncoder().encode(addressList) {
            
            UserDefaults.standard.set(encoded, forKey: MapVC.listString)
        }
    }
    func loadList() {
        
        if let savedList = UserDefaults.standard.object(forKey: MapVC.listString) as? Data {
            if let loadedList = try? JSONDecoder().decode([Address].self, from: savedList) {
                
                addressList = loadedList
            }
        }
    }
    func reverseGeocode(location: CLLocation) -> String {
        let geocoder = CLGeocoder()
        var addName: String?
        
        geocoder.reverseGeocodeLocation(location) { placeMark, error in
            print("\n---------- [ 위경도 -> 주소 ] ----------")
            if error != nil {
                return print(error!.localizedDescription)
            }
            
            // 국가별 주소체계에 따라 어떤 속성 값을 가질지 다름
            guard let address = placeMark?.first,
                  let country = address.country,
                  let administrativeArea = address.administrativeArea,
                  let locality = address.locality,
                  let name = address.name
            else { return }
            
            addName = "\(country) \(administrativeArea) \(locality) \(name)"
        }
        return addName ?? ""
    }
    func pushGoogle(address: String, road: String?, lat: CLLocationDegrees?, lon: CLLocationDegrees?) {
        
        let googleVC = GoogleMapVC()
        
        googleVC.lat = lat
        googleVC.lon = lon
        googleVC.title = title
        
        googleVC.bottomView.addressLabel.text = address
        googleVC.bottomView.roadLabel.text = road
        
        navigationController?.pushViewController(googleVC, animated: true)
    }
}
