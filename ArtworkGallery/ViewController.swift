//
//  ViewController.swift
//  ArtworkGallery
//
//  Created by HatanoKenta on 2017/08/31.
//  Copyright © 2017年 jp.nita. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var collectionView :UICollectionView?
    @IBOutlet var blurView: UIVisualEffectView?
    @IBOutlet var blurAlbumArtworkView: UIImageView?
    @IBOutlet var blurAlbumSongsView: UITableView?
    @IBOutlet var indicator: UIActivityIndicatorView?
    
    var albumArtworks:[[String:AnyObject]] = []
    var albumSongs:[String] = []
    var selectedAlbumIndex = 0
    
    let artworkCellIdentifier = "AlbumArtworkCell"
    let songsCellIdentifier = "AlbumSongsCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumArtworks = [[String:AnyObject]]()
        
        indicator?.isHidden = false
        indicator?.startAnimating()
        let albumsQuery = MPMediaQuery.albums()
        if let albums:[MPMediaItemCollection] = albumsQuery.collections {
            for album:MPMediaItemCollection in albums {
                if album.items.count > 0 {
                    let item = album.items[0] as MPMediaItem
                    let aTitle = item.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String
                    let anArtwork = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
                    
                    if let title = aTitle, let artwork = anArtwork {
                        let imageSize = artwork.bounds.size
                        let artworkImage = artwork.image(at: imageSize)! as UIImage
                        let newItem:[String:AnyObject] = [ "title": title as AnyObject, "artwork": artworkImage, "items": album.items as AnyObject ]
                        albumArtworks.append(newItem)
                    }
                }
            }
        }
        indicator?.stopAnimating()
        indicator?.isHidden = true
        
        collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
// MARK: UIGestureRecognizerDelegate
    
    @IBAction func handleGesture(sender: Any) {
//        UIView.animate(withDuration: 0.5, animations: {
//            self.blurView?.contentView.alpha = 0.0
//            self.blurView?.effect = nil
//        }, completion: { (_:Bool) in
//            self.blurView?.isHidden = true
//        })
        
        let srcArtworkRect = self.blurAlbumArtworkView?.frame
        var destArtworkRect = collectionView?.layoutAttributesForItem(at: NSIndexPath(row: selectedAlbumIndex, section: 0) as IndexPath)?.frame
        collectionView?.convert(destArtworkRect!, to: collectionView?.superview)
        destArtworkRect?.origin.x -= (collectionView?.contentOffset.x)!
        destArtworkRect?.origin.y -= (collectionView?.contentOffset.y)!
        
        let srcSongsRect = self.blurAlbumSongsView?.frame
        var destSongsRect = destArtworkRect
        destSongsRect?.size.width = 0
        
        self.blurAlbumArtworkView?.frame = srcArtworkRect!
        self.blurAlbumSongsView?.frame = srcSongsRect!
        self.blurView?.contentView.alpha = 1.0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.blurAlbumArtworkView?.frame = destArtworkRect!
            self.blurAlbumSongsView?.frame = destSongsRect!
            self.blurView?.effect = nil
        }, completion: { (_:Bool) in
            self.blurView?.isHidden = true
            self.blurAlbumArtworkView?.frame = srcArtworkRect!
            self.blurAlbumSongsView?.frame = srcSongsRect!
        })
        
    }
    
// MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return albumArtworks.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let returnSize = CGSize(width: self.view.bounds.height / 3.0, height: self.view.bounds.height / 3.0)
        
        return returnSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: artworkCellIdentifier, for: indexPath)
        
        for subview in cell.contentView.subviews{
            subview.removeFromSuperview()
        }
        
        var imageFrame = cell.frame
        imageFrame.origin.x = 0
        imageFrame.origin.y = 0
        
        let artwork = albumArtworks[indexPath.row]["artwork"] as! UIImage
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.frame = imageFrame
        imageView.image = artwork
        cell.contentView.addSubview(imageView)
        return cell
    }
    
// MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedAlbumIndex = indexPath.row
        
        let items = albumArtworks[indexPath.row]["items"] as! [MPMediaItem]
        let artwork = items[0].value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
        let imageSize = blurAlbumArtworkView?.bounds.size
        
        let artworkImage = artwork?.image(at: imageSize!)!
        
        var srcArtworkRect = collectionView.layoutAttributesForItem(at: indexPath)?.frame
        collectionView.convert(srcArtworkRect!, to: collectionView.superview)
        srcArtworkRect?.origin.x -= collectionView.contentOffset.x
        srcArtworkRect?.origin.y -= collectionView.contentOffset.y
        let destArtworkRect = self.blurAlbumArtworkView?.frame
        
        var srcSongsRect = srcArtworkRect
        srcSongsRect?.size.width = 0
        let destSongsRect = self.blurAlbumSongsView?.frame
        
        blurAlbumArtworkView?.image = artworkImage
        self.blurAlbumArtworkView?.frame = srcArtworkRect!
        self.blurAlbumSongsView?.frame = srcSongsRect!
        self.blurView?.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.blurView?.contentView.alpha = 1.0
            self.blurAlbumArtworkView?.frame = destArtworkRect!
            self.blurAlbumSongsView?.frame = destSongsRect!
            self.blurView?.effect = UIBlurEffect(style: .light)
        }
        
        self.blurAlbumSongsView?.reloadData()
    }
    
// MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let count = albumArtworks[selectedAlbumIndex]["items"]!.count
            return count!
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let items = albumArtworks[selectedAlbumIndex]["items"]! as! [MPMediaItem]
        let item = items[indexPath.row] as MPMediaItem
        
        let cell = tableView.dequeueReusableCell(withIdentifier: songsCellIdentifier, for: indexPath)
        
        let textField = cell.viewWithTag(1) as! UILabel
        textField.text = item.title
        
        return cell
    }
    
// MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath){
        let items = albumArtworks[selectedAlbumIndex]["items"]! as! [MPMediaItem]
        let item = items[indexPath.row] as MPMediaItem
        
        let albumsQuery = MPMediaQuery.init()
        albumsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: item.title,
                                                                forProperty: MPMediaItemPropertyTitle))
        albumsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: item.artist,
                                                                forProperty: MPMediaItemPropertyArtist))
        albumsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: item.albumTitle,
                                                                forProperty: MPMediaItemPropertyAlbumTitle))
        
        let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
        musicPlayer.setQueue(with: albumsQuery)
        musicPlayer.play()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

