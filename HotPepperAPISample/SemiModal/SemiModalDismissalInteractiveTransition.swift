//
//  SemiModalDismissalInteractiveTransition.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/17.
//

import UIKit



//インタラクティブ、つまりユーザーの操作にアニメーションを追従させる実装をするオブジェクト
final class SemiModalDismissalInteractiveTrasition: UIPercentDrivenInteractiveTransition {
    
    enum GestureDirection {
        case up
        case down
        
        init(recognizer: UIPanGestureRecognizer, view: UIView) {
            //panGestureの速度ベクトルで方向を判定
            let velocity = recognizer.velocity(in: view)
            self = velocity.y <= 0 ? .up : .down
        }
    }
    
    var viewController: UIViewController?
    
    //遷移中かどうかを判定する
    private(set) var isInteractiveDismissalTransition = false
    
    //アクションを完了する閾値
    private let percentCompleteThreshold: CGFloat = 0.3
    
    //panGestureの方向
    private var gestureDirection = GestureDirection.down
    
    override func cancel() {
        completionSpeed = 0.3
        super.cancel()
    }
    
    override func finish() {
        completionSpeed = 0.7
        super.finish()
    }
    
    ///pan gestureを追加するメソッド
    func addPanGesture(to views: [UIView]) {
        views.forEach {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dismissalPanGesture(_:)))
            panGesture.delegate = self
            $0.addGestureRecognizer(panGesture)
        }
    }
    
    @objc func dismissalPanGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let viewController = viewController else { return }
        //遷移が開始、または遷移中のとき、遷移しているとする
        isInteractiveDismissalTransition = recognizer.state == .began || recognizer.state == .changed
        
        switch recognizer.state {
        case .began:
            gestureDirection = GestureDirection(recognizer: recognizer, view: viewController.view)
            if gestureDirection == .down {
                viewController.dismiss(animated: true, completion: nil)
            }
        
        case .changed:
            //進行度合いに応じて処理を変える
            let transition = recognizer.translation(in: viewController.view)
            //viewの高さに対する移動量の進行度合いの絶対値
            let progress = abs(transition.y / viewController.view.bounds.size.height)
            //進行度合いに追従して角丸にしたいViewの角を変化させる
            viewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            viewController.view.layer.cornerRadius = SearchPanelViewController.contentViewCornerRadius * progress
            //進行度合いをupdate()メソッドに渡す
            update(progress)
            
        case .ended, .cancelled:
            viewController.view.layer.cornerRadius = 0
            //update()メソッドで渡されたprogressがpercentCompleteに渡される
            if percentComplete > percentCompleteThreshold {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
    
}

extension SemiModalDismissalInteractiveTrasition: UIGestureRecognizerDelegate {
    ///2つのジェスチャ認識エンジンが同時に認識できるようにするかどうかをデリゲートに尋ねるメソッド
    //scrollViewとpanGestureがコンフリクトしないようにしている
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer.view is UIScrollView {
            return true
        } else {
            return false
        }
    }
}
