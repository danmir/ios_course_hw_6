import UIKit

class CommonView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let nibName = NSStringFromClass(type(of: self)).components(separatedBy: ".").last else {
            return
        }
        
        guard let nibView = Bundle(for: type(of: self)).loadNibNamed(nibName, owner: self, options: nil)?.last as? UIView else {
            return
        }
        
        addSubview(nibView)
        nibView.frame = bounds
        nibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
