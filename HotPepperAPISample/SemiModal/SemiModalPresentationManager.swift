//
//  SemiModalPresentationManager.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/17.
//

import UIKit


protocol SemiModalPresentationManagerDelegate: AnyObject {
    //表示するViewController側にモーダルの高さを決めてもらう
    var semiModalContentHeight: CGFloat { get }
}

final class SemiModalPresentationManager: NSObject {
    
    private let dismissalInteractiveTransition = SemiModalDismissalInteractiveTrasition()
    
    //表示するViewController
    weak var viewController: UIViewController? {
        didSet {
            if let viewController = viewController {
                viewController.modalPresentationStyle = .custom
                viewController.transitioningDelegate = self
                dismissalInteractiveTransition.viewController = viewController
                dismissalInteractiveTransition.addPanGesture(to: [viewController.view, topBarView])
            }
        }
    }
    
    //表示するviewController上のオーバーレイ
    private lazy var overlayView: SemiModalOverlayView = {
        let overlayView = SemiModalOverlayView()
        let g = UITapGestureRecognizer(target: self, action: #selector(overlayViewTapped(_:)))
        overlayView.addGestureRecognizer(g)
        return overlayView
    }()
    
    //モーダルの上部に表示するバー
    private lazy var topBarView: SemiModalTopBarView = {
        let topBarView = SemiModalTopBarView()
        let g = UITapGestureRecognizer(target: self, action: #selector(topBarViewTapped(_:)))
        topBarView.addGestureRecognizer(g)
        return topBarView
    }()
}

//MARK: - gesture method
private extension SemiModalPresentationManager {
    
    ///overlayViewがタップされたとき
    @objc func overlayViewTapped(_ recognizer: UITapGestureRecognizer) {
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    ///topBarViewがタップされたとき
    @objc func topBarViewTapped(_ recognizer: UITapGestureRecognizer) {
        viewController?.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UIViewControllerTransitioningDelegate
extension SemiModalPresentationManager: UIViewControllerTransitioningDelegate {
    
    ///遷移アニメーションや表示するviewを管理する、カスタムなpresentationControllerを返してあげる
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SemiModalPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            overlayView: overlayView,
            topBarView: topBarView)
    }
    
    ///dismissのときに呼ばれ、アニメーションを指定する
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SemiModalDismissalTransitionAnimator()
    }
    
    ///インタラクティブなdismissを制御する
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?  {
        guard
            dismissalInteractiveTransition.isInteractiveDismissalTransition
        else { return nil }
        return dismissalInteractiveTransition
    }
    
    
}
