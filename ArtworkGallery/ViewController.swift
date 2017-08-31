//
//  ViewController.swift
//  ArtworkGallery
//
//  Created by HatanoKenta on 2017/08/31.
//  Copyright © 2017年 jp.nita. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView :UICollectionView?
    
    var albumArtworks:[[String:AnyObject]] = []
    
    let cellIdentifier = "AlbumArtworkCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumArtworks = [[String:AnyObject]]()
        
        let albumsQuery = MPMediaQuery.albums()
        if let albums:[MPMediaItemCollection] = albumsQuery.collections {
            for album:MPMediaItemCollection in albums {
                if album.items.count > 0 {
                    let item = album.items[0]
                    let aTitle = item.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String
                    let anArtwork = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
                    
                    if let title = aTitle, let artwork = anArtwork {
                        let imageSize = CGSize(width: self.view.bounds.height / 3.0, height: self.view.bounds.height / 3.0)
                        let artworkImage = artwork.image(at: imageSize)! as UIImage
                        let newItem:[String:AnyObject] = [ "title": title as AnyObject, "artwork": artworkImage, "item": item ]
                        albumArtworks.append(newItem)
                    }
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return albumArtworks.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        for subview in cell.contentView.subviews{
            subview.removeFromSuperview()
        }
        
        let artwork = albumArtworks[indexPath.row]["artwork"] as! UIImage
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0,y: 0,width: self.view.bounds.height / 3.0,height: self.view.bounds.height / 3.0)
        imageView.image = artwork
        cell.contentView.addSubview(imageView)
        return cell
    }

}

