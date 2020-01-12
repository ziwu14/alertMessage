import UIKit

@IBDesignable
class switchView: UIView {
    
    let label1: UITextView = {
        let label = UITextView()
        
        let attributedText = NSMutableAttributedString(string: "Watch me",
                                                       attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 18)])
//        attributedText.append(NSAttributedString(string: "Let people nearby and your friends watch you",
//                                                 attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 13)]))
        label.attributedText = attributedText
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isEditable = false
        label.isScrollEnabled = false
        //label.frame.size.width = 200
        
        return label
    }()
    
    let label2: UITextView = {
        let label = UITextView()
        
        let attributedText = NSMutableAttributedString(string: "Help me",
                                                       attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 18)])
//        attributedText.append(NSAttributedString(string: "Let people nearby know you are in emergency and call police",
//                                                 attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 13)]))
        label.attributedText = attributedText
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isEditable = false
        label.isScrollEnabled = false
        //label.frame.size.width = 200

        
        return label
    }()

      //MARK: - Init
       
   //    programmatically created buttons
       override init(frame: CGRect) {
           super.init(frame: frame)
           sharedInit()
       }
       
   //    for Storyboard/.xib created buttons
       required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
           sharedInit()
       }
       
       
   //    called within the Storyboard editor itself for rendering @IBDesignable controls
       override func prepareForInterfaceBuilder() {
           sharedInit()
       }
    
    func sharedInit() {
        // all intialization functions go here
        setUpLabelAndSwitch()
    }
    
    func setUpLabelAndSwitch() {
        let watchSwitch1 = UISwitch()
        label1.widthAnchor.constraint(equalToConstant: 100).isActive = true
        let stackView1 = UIStackView(arrangedSubviews: [label1, watchSwitch1])
        stackView1.translatesAutoresizingMaskIntoConstraints = false
        stackView1.distribution = .fillEqually
        stackView1.axis = .horizontal
        
        let watchSwitch2 = UISwitch()
        label2.widthAnchor.constraint(equalToConstant: 100).isActive = true
        let stackView2 = UIStackView(arrangedSubviews: [label2, watchSwitch2])
        stackView2.translatesAutoresizingMaskIntoConstraints = false
        stackView2.distribution = .fillEqually
        stackView2.axis = .horizontal
        
        let stackView = UIStackView(arrangedSubviews: [stackView1, stackView2])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 20
        
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        
    }
}

