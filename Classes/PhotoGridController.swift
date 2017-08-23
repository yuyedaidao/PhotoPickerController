//
//  PhotoGridController.swift
//  Photos
//
//  Created by 张晓鑫 on 2017/6/1.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit
import Photos

let screenWidth:CGFloat = UIScreen.main.bounds.width
let screenHeigth:CGFloat = UIScreen.main.bounds.height

class PhotoGridController: UIViewController {

    var completeItem: UIBarButtonItem! = UIBarButtonItem()
    var collectionView: UICollectionView!
    
    ///后去到的结果 存放PHAsset
    var assetsFetchResults: PHFetchResult<PHAsset>!
    ///带缓存的图片管理对象
    var imageMannger: PHCachingImageManager!
    ///预览图大小
    open var assetGridThumbnailSize: CGSize!
    //原图大小
    var realImageSize: CGSize!
    ///与缓存Rect
    var previousPreheatRect: CGRect!
    ///最多可选择的个数
    var maxSelected = 9
    ///点击完成时的回调
    var completeHandler:((_ assets:[PHAsset]) ->())?
    var shouldDeleteAfterExport: Bool = false
    
    lazy var selectedLabel: ImageSelectedLabel = {
        let tempLabel = ImageSelectedLabel(toolBar:self.navigationController!.toolbar)
        return tempLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置流对象layout
        let collectionLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumLineSpacing = 1
        collectionLayout.minimumInteritemSpacing = 1
        collectionLayout.sectionInset = UIEdgeInsets.zero
        collectionLayout.itemSize = CGSize(width:screenWidth/4.0-1, height:screenWidth/4.0-1)
        collectionView = UICollectionView(frame:view.bounds, collectionViewLayout: collectionLayout)
        collectionView.register(PhotoGridCell.self, forCellWithReuseIdentifier: "PhotoGridCollectionCell")
        collectionView.backgroundColor = UIColor.white
        //并设置允许多选
        collectionView.allowsMultipleSelection = true
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.view.addSubview(collectionView)
        completeItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.plain, target: self, action: #selector(finishSelected))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        self.toolbarItems = [flexibleItem, completeItem]
        
        if assetsFetchResults == nil {
            //如果没有传入值 则获取所有资源
            let allPhotoOption = PHFetchOptions()
            allPhotoOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            assetsFetchResults = PHAsset.fetchAssets(with: allPhotoOption)
        }
        
        //初始化和重置缓存
        imageMannger = PHCachingImageManager()
        self.resetCachedAssets()
        
        let rightBarItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = rightBarItem
        completeItem.action = #selector(finishSelected)
        disableItems()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //计算出小图大小（为targetSize做准备）
        let scale = UIScreen.main.scale
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        realImageSize = CGSize(width: screenWidth * scale, height: screenHeigth * scale)
        self.navigationController!.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.isToolbarHidden = true
        selectedLabel.selectedNumber = 0
    }
    
    // 是否页面加载完毕 ， 加载完毕后再做缓存 否则数值可能有误
    var didLoad = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didLoad = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func enableItems() {
        completeItem.isEnabled = true
    }
    
    fileprivate func disableItems() {
        completeItem.isEnabled = false
    }
    
    
    /**
     重置缓存
    */
    func resetCachedAssets() {
        imageMannger.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }
    /**
     取消
    */
    func cancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /**
     获取已选择个数
    */
    func selectedCount() -> Int {
        return self.collectionView.indexPathsForSelectedItems?.count ?? 0
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PhotoGridController {
    /**
     点击完成调出图片资源
    */
    func finishSelected() {
        var assets:[PHAsset] = []
        //        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        option.resizeMode = .fast
        
        if let indexPaths = collectionView.indexPathsForSelectedItems {
            indexPaths.forEach({ (indexPath) in
                assets.append(assetsFetchResults[indexPath.row])
            })
            
        }
        self.dismiss(animated: true) {
            self.completeHandler?(assets)
        }
    }
    
    
    
    func assetToUIImage(asset: PHAsset, isThumbImage:Bool) -> UIImage? {
        var image: UIImage?
        
        // 新建一个默认类型的图像管理器imageManager
        let imageManager = PHImageManager.default()
        
        // 新建一个PHImageRequestOptions对象
        let imageRequestOption = PHImageRequestOptions()
        
        // PHImageRequestOptions是否有效
        imageRequestOption.isSynchronous = true
        
        // 缩略图的压缩模式设置为无
        imageRequestOption.resizeMode = .none
        
        // 缩略图的质量为高质量，不管加载时间花多少
        imageRequestOption.deliveryMode = .highQualityFormat
        
        // 按照PHImageRequestOptions指定的规则取出图片
        imageManager.requestImage(for: asset, targetSize: isThumbImage ? assetGridThumbnailSize : PHImageManagerMaximumSize, contentMode: .aspectFill, options: imageRequestOption, resultHandler: {
            (result, _ info) -> Void in
            image = result
        })
        return image
    }
    
}

// MARK: - UICollectionViewDelegate&&UICollectionViewDataSource
extension PhotoGridController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoGridCollectionCell", for: indexPath) as! PhotoGridCell
        let asset = self.assetsFetchResults[indexPath.row]
        imageMannger.requestImage(for: asset, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, info) in
            cell.imageView.image = image
            switch asset.mediaType {
            case .video:
                cell.duration = asset.duration
            default:
                break
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoGridCell {
            let selectedCount = self.selectedCount()
            selectedLabel.selectedNumber = selectedCount
            if selectedCount == 0 {
                self.disableItems()
            }
            cell.showAnim()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoGridCell {
            let selectedCount = self.selectedCount()
            if selectedCount > self.maxSelected {
                //选择个数大于选择数 设置为不选中状态
                collectionView.deselectItem(at: indexPath, animated: false)
                selectedLabel.animateMaxSelected()
            } else {
                selectedLabel.selectedNumber = selectedCount
                if selectedCount > 0 && !self.completeItem.isEnabled{
                    self.enableItems()
                }
                cell.showAnim()
            }
        }
        
    }
    
    /**
     滚动中更新缓存
    */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateChachedAssets()
    }
    
    func updateChachedAssets() {
        let isViewVisible = self.isViewLoaded && didLoad
        if !isViewVisible {
            return
        }
        var preheatRect = self.collectionView.bounds
        preheatRect = preheatRect.insetBy(dx: 0, dy: -0.5*preheatRect.height)
        let delta = abs(preheatRect.midY - self.previousPreheatRect.midY)
        if delta > collectionView.bounds.size.height / 3.0 {
            var addIndexPaths = [IndexPath]()
            var removedIndexPaths = [IndexPath]()
            self.computeDifferenceBetweenRect(self.previousPreheatRect, andRect: preheatRect, removedHandler: { (removedRect) in
                let indexPaths = self.collectionView.indexPathsForElementsInRect(removedRect)
                removedIndexPaths = removedIndexPaths.filter({ (indexPath) -> Bool in
                    return !indexPaths.contains(indexPath)
                })
            }, addedHandler: { (addedRect) in
                let indexPaths = self.collectionView.indexPathsForElementsInRect(addedRect)
                indexPaths.forEach({ (indexPath) in
                    addIndexPaths.append(indexPath)
                })
            })
            
            let assetsToStartCaching = self.assetsAtIndexPaths(addIndexPaths)
            let assetsStopCaching = self.assetsAtIndexPaths(removedIndexPaths)
            self.imageMannger.startCachingImages(for: assetsToStartCaching, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.aspectFill, options: nil)
            self.imageMannger.stopCachingImages(for: assetsStopCaching, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.aspectFill, options: nil)
            self.previousPreheatRect = preheatRect
        }
        
    }
    
    func computeDifferenceBetweenRect(_ oldRect:CGRect, andRect newRect:CGRect, removedHandler:((_ removedRect:CGRect)->())?, addedHandler:((_ addedRect:CGRect)->())?) {
        //判断两个矩形是否相交
        if newRect.intersects(oldRect) {
            let oldMaxY = oldRect.maxY
            let newMaxY = newRect.maxY
            let oldMinY = oldRect.minY
            let newMinY = oldRect.minY
            
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: newMaxY - oldMaxY)
                addedHandler?(rectToAdd)
            }
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: oldMinY - newMinY)
                addedHandler?(rectToAdd)
            }
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width:newRect.size.width, height: oldMaxY - newMaxY)
                removedHandler?(rectToRemove)
            }
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width:newRect.size.width, height: newMinY - oldMinY)
                removedHandler?(rectToRemove)
            }
        } else {
            addedHandler?(newRect)
            removedHandler?(oldRect)
        }
        
    }
    
    func assetsAtIndexPaths(_ indexPaths:[IndexPath]) -> [PHAsset] {
        var assets = [PHAsset]()
        indexPaths.forEach { (indexPath) in
            let asset = self.assetsFetchResults[indexPath.row]
            assets.append(asset)
        }
        return assets
    }
    
}

extension UICollectionView {
    func indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElements(in: rect)
        if let allLayoutAttributes = allLayoutAttributes ,  allLayoutAttributes.count == 0 {
            var indexPaths = [IndexPath]()
            allLayoutAttributes.forEach({ (attribute) in
                let indexPath = attribute.indexPath
                indexPaths.append(indexPath)
            })
            
            return indexPaths
        }else {
            return []
        }
    }
}
