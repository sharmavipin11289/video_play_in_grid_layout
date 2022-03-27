//
//  ImageCell.swift
//  autoPlay
//
//  Created by vipin mac on 21/03/22.
//

import UIKit
import AVKit


class ImageCell: UICollectionViewCell {

    @IBOutlet weak var videoView: UIView!
    
    public var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    var post : Posts! {
        didSet {
            self.configureCell()
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
    }
    
    //config cell
    private func configureCell(){
        
        if post.type.lowercased() == "video" {
            let url = URL(string: post.link)!
            
            if let layer = self.playerLayer {
                layer.removeFromSuperlayer()
                NotificationCenter.default.removeObserver(self,name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            }
            setupPlayer(url: url)
        }
    }
    
    //player setup
    private func setupPlayer(url:URL){
      
        //creating player item, player
        let playerItem = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: playerItem)
        
        //creating player layer
        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = self.bounds
        avPlayerLayer.videoGravity = .resizeAspectFill
        avPlayerLayer.backgroundColor = UIColor.clear.cgColor
        
        //add layer to video view
        self.videoView.layer.addSublayer(avPlayerLayer)
        
        //play video
        avPlayer.playImmediately(atRate: 1.0)
        avPlayer.isMuted = true
            //set player layer to local var
        self.playerLayer = avPlayerLayer
        self.player = avPlayer
        
        //set audio session category for audio
        try! AVAudioSession.sharedInstance().setCategory(.playback)
    
        //activity show when its start
        self.activityIndicator.startAnimating()
    
        //add time observer get status
        self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 600), queue: DispatchQueue.main) {
            [weak self] time in
            if self?.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                    self?.activityIndicator.stopAnimating()
            }
        }
    
        //observer if player reach ends play again
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { (_) in
            if (self.player?.currentItem) != nil {
                self.player?.seek(to: .zero)
                self.player?.play()
            }
        }
    }
}
