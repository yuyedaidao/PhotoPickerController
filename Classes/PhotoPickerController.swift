//
//  PhotoPickerController.swift
//  Photos
//
//  Created by 张晓鑫 on 2017/6/1.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit
import Photos

 class PDImageItem {
    var fetchResult:PHFetchResult<PHAsset>
    var title:String?
    
    init(title:String?, fetchResult: PHFetchResult<PHAsset>){
        self.title = title
        self.fetchResult = fetchResult
    }
    
}

public class PhotoPickerController: UIViewController {

//    @IBOutlet weak var tableView: UITableView!
    var tableView: UITableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    /// 完成回调
    public var completeHandler:((_ assets:[PHAsset])->())?
    /// 相册的PHFetchResult
    var items:[PDImageItem] = []
    /// 相册名称
    var sectionLocalizardTitles:[String] = []
    /// 最大选择数
    public var maxSelected = 9
    public var shouldDeleteAfterExport: Bool = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.register(PhotoLibarayCell.self, forCellReuseIdentifier: "PhotoLibarayCell")
        let smartOptions = PHFetchOptions()
        let smartAlumbs = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: smartOptions)
        self.convertCollection(smartAlumbs as! PHFetchResult<AnyObject>)
        
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        self.convertCollection(topLevelUserCollections as! PHFetchResult<AnyObject>)
        
        self.items.sort { (item1, item2) -> Bool in
            return item1.fetchResult.count > item2.fetchResult.count
        }
        PHPhotoLibrary.shared().register(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    fileprivate func convertCollection(_ collection:PHFetchResult<AnyObject>) {
        for i in 0 ..< collection.count {
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            guard let c = collection[i] as? PHAssetCollection else { return
            }
            let assetsFetchResult = PHAsset.fetchAssets(in: c , options: resultsOptions)
            if assetsFetchResult.count > 0 {
                items.append(PDImageItem.init(title: c.localizedTitle, fetchResult: assetsFetchResult))
            }
        }
    }
    
    var isFirstload = false
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "照片库"
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 55
        let rightBarItem = UIBarButtonItem(title: "取消", style:UIBarButtonItemStyle.plain, target: self, action:#selector(PhotoPickerController.cancel) )
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstload {
            return
        } else {
            isFirstload = true
        }
        guard let result = self.items.first?.fetchResult else {
            return
        }
        showGridController(with: result, animated: false)
    }
    
    func showGridController(with fetchResult: PHFetchResult<PHAsset>, animated: Bool = true) {
        let photoGridVC = PhotoGridController()
        photoGridVC.assetsFetchResults = fetchResult
        photoGridVC.completeHandler = completeHandler
        photoGridVC.maxSelected = maxSelected
        photoGridVC.shouldDeleteAfterExport = shouldDeleteAfterExport
        self.navigationController?.pushViewController(photoGridVC, animated: animated)
        
    }
    // MARK: - Navigation

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "ShowAllPhotos" {
            guard let photoGridController = segue.destination as? PhotoGridController, let cell = sender as? PhotoLibarayCell else {
                return
            }
            
            photoGridController.completeHandler = completeHandler
            photoGridController.title = cell.titleLabel.text
            photoGridController.maxSelected = maxSelected
            photoGridController.shouldDeleteAfterExport = shouldDeleteAfterExport
            guard let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            let fetchResult = items[indexPath.row].fetchResult
            guard fetchResult.firstObject != nil else {
                return
            }
            photoGridController.assetsFetchResults = fetchResult
           
        }
    }

}

//MARK: - PHPhotoLibraryChangeObserver
extension PhotoPickerController: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.global().async {
            var updateSectionFetchResults = self.items
            var reloadRequired = false
            for (index, item) in self.items.enumerated() {
                if let changeDetails = changeInstance.changeDetails(for: item.fetchResult as! PHFetchResult<PHObject>) {
                    updateSectionFetchResults[index].fetchResult = changeDetails.fetchResultAfterChanges as! PHFetchResult<PHAsset>
                    reloadRequired = true
                    
                }
            }
            if reloadRequired {
                DispatchQueue.main.async(execute: { 
                    self.items = updateSectionFetchResults
                    self.tableView.reloadData()
                })
            }
        }
    }
}

//MARK: - UITableViewDelegate && UItableVIewDataSource
extension PhotoPickerController:UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: "PhotoLibarayCell", for: indexPath) as! PhotoLibarayCell
        let item = self.items[indexPath.row]
//        cell.titleLabel.text = "\(item.title ?? " ")"
        cell.countLabel.text = "（\(item.fetchResult.count)）"
        let itemDic: Dictionary<String, String> = ["title" : item.title!,
                                                   "count" : "(\(item.fetchResult.count))"]
        cell.setupWithDictionary(itemDic)
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showGridController(with: self.items[indexPath.row].fetchResult)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

