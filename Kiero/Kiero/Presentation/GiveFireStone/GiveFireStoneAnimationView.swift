import UIKit
import SnapKit
import Then

final class GivingFireStoneView: BaseUIView {
    
    // 이벤트를 외부로 전달할 클로저
    var didTapGiveButton: (() -> Void)?
    
    // MARK: - UI Components
    
    private let headerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let backgroundView = UIImageView().then {
        $0.image = UIImage(resource: .imgBackground)
        $0.contentMode = .scaleAspectFill // 배경 꽉 차게
        $0.clipsToBounds = true
    }
    
    private let blackMarkupView = UIView().then {
        $0.backgroundColor = UIColor.kBlack
        $0.alpha = 0.35
    }
    
    private let giveSpeechBubble = SpeechBubble(speech: "불조각을 나에게 건네줘!")
    
    private let kkubiImageView = UIImageView(image: UIImage(resource: .imgGoblinKid)).then {
        $0.image = UIImage(resource: .imgGoblinKid)
        $0.contentMode = .scaleAspectFit
    }
    
    private let nameView = UIView().then {
        $0.backgroundColor = UIColor(resource: .gray900)
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
        $0.clipsToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.text = "꾸비"
        $0.textColor = .white
        $0.font = .body5_10_R
        $0.textAlignment = .center
    }
    
    // ⬇️ [복구] 버튼 및 내부 요소 정의
    private let giveFireButton = UIButton(type: .custom).then {
        $0.backgroundColor = UIColor(resource: .gray900)
        $0.layer.cornerRadius = 16
    }
    
    private let fireIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "flame.fill")?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .cyan
        $0.contentMode = .scaleAspectFit
    }
    
    private let fireCountLabel = UILabel().then {
        $0.text = "7개"
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 14)
    }
    
    private let fireActionLabel = UILabel().then {
        $0.text = "불 조각 건네주기"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16, weight: .bold)
    }
    
    // MARK: - Setup Methods
    
    override func setStyle() {
        super.setStyle()
    }
    
    override func setUI() {
        // giveFireButton 추가
        addSubviews(headerView, backgroundView, blackMarkupView, kkubiImageView, giveSpeechBubble, nameView, giveFireButton)
        
        nameView.addSubview(nameLabel)
        
        // 버튼 내부 UI 추가
        giveFireButton.addSubviews(fireIconImageView, fireCountLabel, fireActionLabel)
        
        // 버튼 액션 연결
        giveFireButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    override func setLayout() {
        headerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(32)
            $0.top.equalToSuperview().offset(54)
        }
        
        backgroundView.snp.makeConstraints{
            $0.horizontalEdges.equalToSuperview().inset(-54)
            $0.top.equalToSuperview().offset(102)
            $0.bottom.equalToSuperview()
        }
        
        blackMarkupView.snp.makeConstraints {
            $0.edges.equalTo(backgroundView)
        }
        
        giveSpeechBubble.snp.makeConstraints {
            $0.top.equalToSuperview().offset(227)
            $0.centerX.equalToSuperview()
        }
        
        kkubiImageView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(11)
            $0.top.equalToSuperview().offset(289)
        }
        
        nameView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(608)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(59)
            $0.height.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        // ⬇️ [복구] 버튼 레이아웃
        giveFireButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(81)
            $0.bottom.equalToSuperview().inset(50)
        }
        
        fireIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.centerX.equalToSuperview().offset(-15)
            $0.size.equalTo(18)
        }
        
        fireCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(fireIconImageView)
            $0.leading.equalTo(fireIconImageView.snp.trailing).offset(4)
        }
        
        fireActionLabel.snp.makeConstraints {
            $0.top.equalTo(fireIconImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
    }
    
    @objc
    private func buttonTapped() {
        didTapGiveButton?()
    }
}
