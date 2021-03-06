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
    
    @IBOutlet var blurViewTapRecognizer :UIGestureRecognizer?
    @IBOutlet var artworkViewTapRecognizer :UIGestureRecognizer?
    
    @IBOutlet var collectionView :UICollectionView?
    @IBOutlet var blurView: UIVisualEffectView?
    @IBOutlet var blurAlbumArtworkView: UIImageView?
    @IBOutlet var blurAlbumSongsView: UITableView?
    @IBOutlet var indicator: UIActivityIndicatorView?
    @IBOutlet var progressLabel: UILabel?
    
    @IBOutlet var darkView: UIView?
    @IBOutlet var playPauseButton: UIButton?
    
    @IBOutlet var artistLabel: UILabel?
    @IBOutlet var albumLabel: UILabel?
    
    var albumArtworks:[[String:AnyObject]] = []
    var albumSongs:[String] = []
    var selectedAlbumIndex:Int?
    
    let artworkCellIdentifier = "AlbumArtworkCell"
    let songsCellIdentifier = "AlbumSongsCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumArtworks = [[String:AnyObject]]()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        albumArtworks = [[String:AnyObject]]()
        
        indicator?.isHidden = false
        indicator?.startAnimating()
        let albumsQuery = MPMediaQuery.albums()
        if let albums:[MPMediaItemCollection] = albumsQuery.collections {
            var albumIndex = 0
            progressLabel?.text = "0 / \(albums.count)"
            progressLabel?.isHidden = false
            
            var rect = blurAlbumArtworkView!.bounds
            rect.size.width /= 2.0
            rect.size.height /= 2.0
            
            for album:MPMediaItemCollection in albums {
                if album.items.count > 0 && albumArtworks.count < 10000 {
                    let item = album.items[0] as MPMediaItem
                    let aTitle = item.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String
                    let anArtwork = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
                    
                    if let title = aTitle, let artwork = anArtwork {
                        
                        UIGraphicsBeginImageContext(rect.size)
                        let context = UIGraphicsGetCurrentContext()
                        artwork.image(at: rect.size)?.draw(in: rect)
                        let artworkImage = UIGraphicsGetImageFromCurrentImageContext()
                        
                        UIGraphicsEndImageContext()
                        
                        // let artworkImage = artwork.image(at: imageSize)! as UIImage
                        let newItem:[String:AnyObject] = [ "title": title as AnyObject, "artwork": artworkImage!, "items": album.items as AnyObject ]
                        albumArtworks.append(newItem)
                    }
                    
                    albumIndex += 1
                    progressLabel!.text = aTitle ?? ""
                    progressLabel!.setNeedsDisplay()
                }
            }
        }
        
        albumArtworks.sort(by: { (a:[String:AnyObject], b:[String:AnyObject]) -> Bool in
            let itemsA = a["items"] as! [MPMediaItem]
            let itemsB = b["items"] as! [MPMediaItem]
            
            let itemA = itemsA[0]
            let itemB = itemsB[0]
            
            if itemA.albumArtist ?? itemA.artist! == itemB.albumArtist ?? itemB.artist! {
                return itemA.albumTitle! < itemB.albumTitle!
            } else {
                return itemA.albumArtist ?? itemA.artist! < itemB.albumArtist ?? itemB.artist!
            }
        } )
        
        indicator?.stopAnimating()
        indicator?.isHidden = true
        progressLabel?.isHidden = true
        
        collectionView?.reloadData()
        
        self.blurAlbumArtworkView?.removeGestureRecognizer(self.artworkViewTapRecognizer!)
        self.blurAlbumArtworkView?.isUserInteractionEnabled = true
        self.blurAlbumArtworkView?.addGestureRecognizer(self.artworkViewTapRecognizer!)
        
        updatePlayPauseButtonIcon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        let alertController = UIAlertController(title:"Warning", message:"Received memory warning.", preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
    }
    
    func updatePlayPauseButtonIcon() {
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
        if musicPlayer.playbackState == .playing {
            playPauseButton?.titleLabel?.text = "Pause"
        } else {
            playPauseButton?.titleLabel?.text = "Play"
        }
    }
    
    
    
// MARK: UIGestureRecognizerDelegate
    
    @IBAction func handleBlurViewTapGesture(sender: Any) {
//        UIView.animate(withDuration: 0.5, animations: {
//            self.blurView?.contentView.alpha = 0.0
//            self.blurView?.effect = nil
//        }, completion: { (_:Bool) in
//            self.blurView?.isHidden = true
//        })
        
        self.blurAlbumSongsView?.reloadData()
        self.darkView?.isHidden = true
        
        let srcArtworkRect = self.blurAlbumArtworkView?.frame
        var destArtworkRect = collectionView?.layoutAttributesForItem(at: NSIndexPath(row: selectedAlbumIndex ?? 0, section: 0) as IndexPath)?.frame
        collectionView?.convert(destArtworkRect!, to: collectionView?.superview)
        destArtworkRect?.origin.x -= (collectionView?.contentOffset.x)!
        destArtworkRect?.origin.y -= (collectionView?.contentOffset.y)!
        
        let srcSongsRect = self.blurAlbumSongsView?.frame
        var destSongsRect = destArtworkRect
        destSongsRect?.size.width = 0
        
//        self.blurAlbumArtworkView?.frame = srcArtworkRect!
//        self.blurAlbumSongsView?.frame = srcSongsRect!
        
        self.blurAlbumArtworkView?.alpha = 1.0
        self.blurAlbumSongsView?.alpha = 1.0
        UIView.animate(withDuration: 0.5, animations: {
            self.blurAlbumArtworkView?.alpha = 0.0
            self.blurAlbumSongsView?.alpha = 0.0
//            self.blurAlbumArtworkView?.frame = destArtworkRect!
//            self.blurAlbumSongsView?.frame = destSongsRect!
            self.blurView?.effect = nil
        }, completion: { (_:Bool) in
            self.blurAlbumArtworkView?.alpha = 1.0
            self.blurAlbumSongsView?.alpha = 1.0
            self.blurView?.isHidden = true
            self.blurAlbumArtworkView?.frame = srcArtworkRect!
            self.blurAlbumSongsView?.frame = srcSongsRect!
        })
        
    }
    
    @IBAction func handleArtworkViewTapGesture(sender: Any) {
        if (self.darkView?.isHidden)! {
            self.darkView?.alpha = 0.0
            self.darkView?.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.darkView?.alpha = 0.5
            }, completion: { (_:Bool) in
                
            })
        } else {
            self.darkView?.alpha = 0.5
            UIView.animate(withDuration: 0.5, animations: {
                self.darkView?.alpha = 0.0
            }, completion: { (_:Bool) in
                self.darkView?.isHidden = true
            })
        }
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
        
        self.artistLabel?.text = items[0].albumArtist
        self.albumLabel?.text = items[0].albumTitle
        
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
        self.blurView?.effect = nil
        self.blurView?.isHidden = false
        UIView.animate(withDuration: 0.5) {
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
            if albumArtworks.count > 0 && selectedAlbumIndex != nil {
                let count = albumArtworks[selectedAlbumIndex!]["items"]!.count
                return count!
            }
            return 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let items = albumArtworks[selectedAlbumIndex!]["items"]! as! [MPMediaItem]
        let item = items[indexPath.row] as MPMediaItem
        
        let cell = tableView.dequeueReusableCell(withIdentifier: songsCellIdentifier, for: indexPath)
        
        let textField = cell.viewWithTag(1) as! UILabel
        textField.text = item.title
        
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
        
        let playingView = cell.viewWithTag(2) as! UIImageView
        playingView.isHidden = musicPlayer.nowPlayingItem?.persistentID == items[indexPath.row].persistentID ? false : true
        
        return cell
    }
    
// MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath){
        let items = albumArtworks[selectedAlbumIndex!]["items"]! as! [MPMediaItem]
        let item = items[indexPath.row] as MPMediaItem
        
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
        if musicPlayer.nowPlayingItem?.persistentID == item.persistentID {
            if musicPlayer.playbackState == .playing {
                musicPlayer.pause()
            } else {
                musicPlayer.play()
            }
        } else {
            let albumsQuery = MPMediaQuery.init()
            albumsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: item.title,
                                                                    forProperty: MPMediaItemPropertyTitle))
            albumsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: item.artist,
                                                                    forProperty: MPMediaItemPropertyArtist))
            albumsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: item.albumTitle,
                                                                    forProperty: MPMediaItemPropertyAlbumTitle))
            
            let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
            musicPlayer.setQueue(with: albumsQuery)
            musicPlayer.play()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadData()
    }
    
// MARK: IBAction
    
    @IBAction func playPauseButtonTapped(sender:Any) {
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
        if musicPlayer.playbackState == .playing {
            musicPlayer.pause()
        } else {
            musicPlayer.play()
        }
        updatePlayPauseButtonIcon()
    }

}

