//
//  ViewController.swift
//  Work7_Music
//
//  Created by 彭有駿 on 2022/4/6.
//

import UIKit
import AVFoundation
import MediaPlayer
import SpriteKit

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var singer: UILabel!
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var musicImage: UIImageView!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var overTime: UILabel!
    @IBOutlet weak var musicTime: UISlider!
    @IBOutlet weak var backMusic: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var nextMusic: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var stochastic: UIButton!
    @IBOutlet weak var watchMV: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    
    //宣告musicList裡面的struct  s1
    var musics = music()
    //控制音樂的Track  s1
    var asset: AVAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        musicMessage()//s2
        playMusic()//s3
        songMusicMessage()//s5
        playNowTime()//s5
        musicEnd()//s6
        background()//s10
        
        // 打開模擬器剛開始的圖示 套用s9做好的func
        repeatButton.setImage(setbuttonImage(systemName: "repeat", pointSize: 15), for: .normal)
        stochastic.setImage(setbuttonImage(systemName: "shuffle.circle", pointSize: 20), for: .normal)
        pauseButton.setImage(setbuttonImage(systemName: "pause.fill", pointSize: 30), for: .normal)
        nextMusic.setImage(setbuttonImage(systemName: "forward.end.fill", pointSize: 30), for: .normal)
        backMusic.setImage(setbuttonImage(systemName: "backward.end.fill", pointSize: 30), for: .normal)
    }
    
 
    
    //上一首
    @IBAction func backMusicBtn(_ sender: UIButton) {
        playBackMusic()//s8
    }
    
    //播放音樂
    var playMusicIndex = 0
    @IBAction func playMusicBtn(_ sender: UIButton) {
        //點下去加一
        playMusicIndex += 1
        if playMusicIndex == 1{
            player.pause()
            pauseButton.setImage(setbuttonImage(systemName: "play.fill", pointSize: 30), for: .normal)
        }else{
        // 如果超過1就會歸0繼續播放按鈕換成暫停鍵
            playMusicIndex = 0
            player.play()
            pauseButton.setImage(setbuttonImage(systemName: "pause.fill", pointSize: 30), for: .normal)
        }
    }
    
    //下一首
    @IBAction func nextMusicBtn(_ sender: UIButton) {
        playNextMusic()//s7
    }
    
    //快轉歌曲
    @IBAction func timeChage(_ sender: UISlider) {
        //設定slider的value
        let changeTime = Int64(sender.value)
        //宣告一個CMTime來控制音樂到跑到哪
        let time:CMTime = CMTimeMake(value: changeTime , timescale: 1)
        //音樂會跟著slider拉到的地方播放
        player.seek(to: time)
        print("sender.value\(sender.value)")
        print("sender.maximumValue\(sender.maximumValue)")
    }
    
    //單曲重複播放
    var repeatIndex = 0
    @IBAction func repeatBtn(_ sender: UIButton) {
        repeatIndex += 1
        if repeatIndex == 1 {
            repeatButton.setImage(setbuttonImage(systemName: "repeat.1", pointSize: 15), for: .normal)
            repeatBool = true
        }else{
            repeatIndex = 0
            repeatButton.setImage(setbuttonImage(systemName: "repeat", pointSize: 15), for: .normal)
            repeatBool = false
        }
        //如果按下隨機播放就不能使用單曲循環
        if shuffleIndex == 1 {
            repeatIndex -= 1
            repeatButton.setImage(setbuttonImage(systemName: "repeat", pointSize: 15), for: .normal)
            repeatBool = false
        }
        
    }
    
    //隨機播放
    @IBAction func stochasticBtn(_ sender: UIButton) {
        shuffleIndex += 1
        if shuffleIndex == 1 {
            stochastic.setImage(setbuttonImage(systemName: "shuffle.circle.fill", pointSize: 20), for: .normal)
        }else{
            shuffleIndex = 0
            stochastic.setImage(setbuttonImage(systemName: "shuffle.circle", pointSize: 20), for: .normal)
        }
        //如果按下單曲循環就不能使用隨機播放
        if repeatIndex == 1{
            shuffleIndex -= 1
            stochastic.setImage(setbuttonImage(systemName: "shuffle.circle", pointSize: 20), for: .normal)
            repeatBool = true
        }
        
        
    }
    
    //音量調整
    @IBAction func volumeSlider(_ sender: UISlider) {
        player.volume = volumeSlider.value
    }
    
    //播放MV
    @IBAction func playMVBtn(_ sender: UIButton) {
    }
    
    
   
    
    
    
    
    //設置一個放置音樂的參數
    var musicIndex = 0
    //更改歌手跟歌名以及歌曲圖
    func musicMessage(){
        musicName.text = allMusicMessage[musicIndex].musicName
        singer.text = allMusicMessage[musicIndex].singer
        musicImage.image = UIImage(named: allMusicMessage[musicIndex].musicPic)
        
    }
    //播放音樂
    let player = AVPlayer()
    var playerItem: AVPlayerItem!
    
    func playMusic(){
        let fileMusicUrl = Bundle.main.url(forResource: allMusicMessage[musicIndex].music, withExtension: "mp4")!
        playerItem = AVPlayerItem(url: fileMusicUrl)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    //   顯示播放幾秒func
    func timeShow(time: Double) -> String {
    //轉換成秒數
        let time = Int(time).quotientAndRemainder(dividingBy: 60)
    //顯示分鐘與秒數
        let timeString = ("\(String(time.quotient)) : \(String(format:"%02d", time.remainder))")
    //回傳到顯示
        return timeString
        }
    
    // 更新歌曲時確認歌的時間讓Slider也跟著更新
    func songMusicMessage(){
        //宣告一個算歌曲秒數的timeduration
        guard let timeDuration = playerItem?.asset.duration else {return}
        // 在轉換型態成CMTimeGetSeconds
        let seconds = CMTimeGetSeconds(timeDuration)
        // 總秒數就會等於timeShow(time: seconds)func裡的秒數
        overTime.text = timeShow(time: seconds)
        //音樂最小值
        musicTime.minimumValue = 0
        //音樂最大值=目前播放的歌曲總秒數
        musicTime.maximumValue = Float(seconds)
        //slider持續隨音樂前進
        musicTime.isContinuous = true
    }
    
    //顯示目前播放到幾秒的func
    func playNowTime(){
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
            //如果音樂要播放
            if self.player.currentItem?.status == .readyToPlay{
                //得到播放時間
                let currentTime = CMTimeGetSeconds(self.player.currentTime())
                //Slider移動就會等於currenTime的時間
                self.musicTime.value = Float(currentTime)
                //顯示目前播放時間
                self.startTime.text = self.timeShow(time: currentTime)
            }
            
            
        })
    }
    
   
    // 控制是否重播
    var repeatBool = false
    //確認音樂結束
    func musicEnd(){
        //利用NotificationCenter.default.addObserver來確認音樂是否結束
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main){ (_) in
            // 如果結束有打開repeatBool 就會從頭播放
            if self.repeatBool{
                let musicEndTime: CMTime = CMTimeMake(value: 0, timescale: 1)
                self.player.seek(to: musicEndTime)
                self.player.play()
            }else{
                // 如果結束沒有打開repeatBool就會撥下一首歌
               self.playNextMusic()
            }
        }
    }
    
    
    
    //控制是否隨機播放圖示
        var shuffleIndex = 0
    //播放下一首
    func playNextMusic(){
        //如果隨機播放是打開的
        if shuffleIndex == 1{
            //就用亂數播歌
            musicIndex = Int.random(in: 0...allMusicMessage.count-1)
            musicMessage()
            playMusic()
            songMusicMessage()
        }else{//如果不是就是照列表播歌
            musicIndex += 1
            if musicIndex < allMusicMessage.count{
                musicMessage()
                playMusic()
                songMusicMessage()
            }else{
                musicIndex = 0
                musicMessage()
                playMusic()
                songMusicMessage()
            }
            
        }
        
    }
    
    //上一首
    func playBackMusic(){
        if shuffleIndex == 1{
            musicIndex = Int.random(in: 0...allMusicMessage.count - 1)
            musicMessage()
            playMusic()
            songMusicMessage()
        }else{
            musicIndex -= 1
            if musicIndex < 0{
                musicIndex = 0
                musicMessage()
                playMusic()
                songMusicMessage()
            }else{
                musicMessage()
                playMusic()
                songMusicMessage()
            }
        }
    }
    
    //    設定Button圖示大小跟圖案
        func setbuttonImage(systemName:String,pointSize: Int)-> UIImage?{
    //        設定一個圖示以及他的長寬
            let sfsymbol = UIImage.SymbolConfiguration(pointSize: CGFloat(pointSize), weight: .bold,scale: .large)
    //        設定圖片名字，跟他的出處
            let sfsymbolImage = UIImage(systemName: systemName, withConfiguration: sfsymbol)
    //        回傳
            return sfsymbolImage
        }
    
    
    
    func background(){
        let skView = SKView(frame: self.view.bounds)
        self.view.insertSubview(skView, at: 0)

        let scene = SKScene(size: skView.frame.size)
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.7)
        scene.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 128/255, alpha: 0)

        let emitterNode = SKEffectNode(fileNamed: "MyParticle")
        scene.addChild(emitterNode!)
        skView.presentScene(scene)

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds  //讓漸層的大小等於 controller view 的大小
        
        gradientLayer.colors = [CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0),
                                CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.5)]//背景顏色

        //疊加在skView上
        skView.layer.addSublayer(gradientLayer)
        
    }
    
    //播放當前在播放的東西
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       let MyAVPlayerVC = segue.destination as! MyAVPlayerViewController
        MyAVPlayerVC.player = player
    }
    
    
}

