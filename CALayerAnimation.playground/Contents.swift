
import UIKit
import PlaygroundSupport
import QuartzCore

final class ViewController: UIViewController
{
    var containerView: EmojiView?
    
    let maxContainerSize = CGSize(width: 300, height: 540)
    
    var currentContainerExpansion: Double = 0
    {
        didSet
        {
            containerView?.layer.timeOffset = currentContainerExpansion
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.frame = UIScreen.main.bounds
        
        let containerView = EmojiView(frame: .zero)
        view.addSubview(containerView)
        self.containerView = containerView
        
        setupAnimations()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(pan:)))
        view.addGestureRecognizer(pan)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let containerFrame = CGRect(x: view.bounds.midX - maxContainerSize.width * 0.5, y: view.bounds.midY - maxContainerSize.height * 0.5, width: maxContainerSize.width, height: maxContainerSize.height)
        self.containerView?.frame = containerFrame
    }
    
    @objc
    func handlePan(pan: UIPanGestureRecognizer)
    {
        let dragDistanceY = pan.translation(in: view).y
        let scaledDragAmount = Double(dragDistanceY / maxContainerSize.height)
        currentContainerExpansion = min(max(currentContainerExpansion + scaledDragAmount, 0), 1)
        pan.setTranslation(.zero, in: view)
    }
    
    func setupAnimations()
    {
        guard let containerLayer = containerView?.layer,
              let emojiLayers = containerView?.emojiLayers
            else { return }
        containerLayer.speed = 0
        
        let animation = CABasicAnimation(keyPath: "bounds.size.height")
        animation.fromValue = 80
        animation.toValue = maxContainerSize.height
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let widthAnimation = CABasicAnimation(keyPath: "bounds.size.width")
        widthAnimation.fromValue = 80.0
        widthAnimation.toValue = maxContainerSize.width
        widthAnimation.duration = 0.2
        widthAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        containerLayer.add(animation, forKey: nil)
        containerLayer.add(widthAnimation, forKey: nil)
        
        
        let baseStartTime = containerLayer.convertTime(CACurrentMediaTime(), from: nil)
        for i in emojiLayers.indices
        {
            let layer = emojiLayers[i]
            
            let animation = CABasicAnimation(keyPath: "transform.scale.xy")
            animation.fromValue = 0.01
            animation.toValue = 1
            animation.duration = 0.1
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.beginTime = baseStartTime + 0.028 * Double(i)
            animation.fillMode = kCAFillModeBackwards
            
            layer.add(animation, forKey: nil)
        }
    }
}

class EmojiView: UIView
{
    let emojiLayers: [CALayer]
    
    override init(frame: CGRect)
    {
        let emojiList = "😀😃😄😁😆😅😂🤣☺️😊😇🙂🙃😉😌😍😘😗😙😚😋😜😝😛🤑🤗🤓😎🤡🤠😏😒"
        let screenScale = UIScreen.main.scale
        let cornerInset = 45
        let layerSize = 70
        
        var index = 0
        var emojiLayers: [CALayer] = []
        for e in emojiList.characters
        {
            let layer = CATextLayer()
            layer.string = String(e)
            layer.fontSize = 50
            layer.contentsScale = screenScale
            layer.bounds = CGRect(x: 0, y: 0, width: layerSize, height: layerSize)
            layer.alignmentMode = kCAAlignmentCenter
            
            let column = index % 4
            let row = (index - column) / 4
            layer.position = CGPoint(x: cornerInset + layerSize * column, y: cornerInset + layerSize * row)
            emojiLayers.append(layer)
            index += 1
        }
        self.emojiLayers = emojiLayers
        super.init(frame: frame)
        self.backgroundColor = .white
        self.emojiLayers.forEach { self.layer.addSublayer($0) }
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 40.0
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("Don't use a coder; use init(frame:)")
    }
}

let viewController = ViewController()
PlaygroundPage.current.liveView = viewController

