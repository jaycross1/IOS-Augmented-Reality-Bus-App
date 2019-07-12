//
//  HomeVC.swift
//  ImageDetect
//


import UIKit
import AVKit
import AVFoundation
//this is the UI Kit, theme

class HomeVC: UIViewController {
//view controller where background code is written
    
    @IBOutlet weak var videoView: UIView!
    //imports UI view to display video
    var player: AVPlayer?
    //this displays video on phone
    override func viewDidLoad() {
        //this checks to see if it is loaded
        super.viewDidLoad()

        playBackgoundVideo()
    } //plays the video

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    } // navigation bar will hide if component is loading home page
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    } // navigation bar will show if component is loading home page
    
    // play a movie in movie player.
    private func playBackgoundVideo() {
        if let filePath = Bundle.main.path(forResource: "44-2", ofType:"mp4") {
            //defining the file path in the function, specific type to play
            let filePathUrl = NSURL.fileURL(withPath: filePath)
            //specifies the path of where the video is
            player = AVPlayer(url: filePathUrl)
            // creates an object that grabs this file and plays the file(video)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.videoView.bounds
            //specifies the frame and is proportional to the size of phone.
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            //allows the video not to get distorted and still fills the whole screen according to the size of phone you currently have
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: nil) { (_) in
                self.player?.seek(to: CMTime.zero)
                self.player?.play()
            }
            //this ensures the video repeats once it is finished
            self.videoView.layer.addSublayer(playerLayer)
            player?.play()
        }
    }

  
    
    
   
    

   
}
