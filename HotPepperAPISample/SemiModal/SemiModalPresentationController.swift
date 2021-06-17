//
//  SemiModalPresentationController.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/17.
//

import UIKit

//遷移アニメーションと、表示するViewControllerの管理をするオブジェクト
final class SemiModalPresentationController: UIPresentationController {
    
    //表示するViewControllerの高さの親Viewに対するデフォルト比率
    private let presentedVCHeightRatio: CGFloat = 0.5
    
    //表示するもの
    //overlayView
    private let overlayView: SemiModalOverlayView
    //topBarView
    private let topBarView: SemiModalTopBarView
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, overlayView: SemiModalOverlayView, topBarView: SemiModalTopBarView) {
        self.overlayView = overlayView
        self.topBarView = topBarView
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    ///遷移アニメーション時に、表示されるViewControllerのframeを返す
    override var frameOfPresentedViewInContainerView: CGRect {
        //containerView全体のframe
        guard let containerBounds = containerView?.bounds else { return CGRect.zero }
        //表示されるViewControllerのframeを設定する
        var presentedViewFrame = CGRect.zero
        presentedViewFrame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.origin.x = containerBounds.size.width - presentedViewFrame.size.width
        presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height
        return presentedViewFrame
    }
    
    ///表示されるViewControllerのサイズを返す
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        //デリゲート先、つまり表示されるViewController側で高さが指定されていれば、それを優先して返す
        if let delegate = presentedViewController as? SemiModalPresentationManagerDelegate {
            return CGSize(width: parentSize.width, height: delegate.semiModalContentHeight)
        }
        //それ以外のときは高さの比率で返す
        return CGSize(width: parentSize.width, height: parentSize.height * presentedVCHeightRatio)
    }
    
    ///subViewをレイアウトする
    override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView else { return }
        
        //表示するViewのframeを指定
        presentedView?.frame = frameOfPresentedViewInContainerView
        
        //overlayのレイアウト。containerViewの一番上のレイヤーに挿入する
        overlayView.frame = containerView.bounds
        containerView.insertSubview(overlayView, at: 0)
        
        //topBarViewのレイアウト
        topBarView.frame = CGRect(x: 0, y: 0, width: 60, height: 8)
        presentedViewController.view.addSubview(topBarView)
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBarView.centerXAnchor.constraint(equalTo: presentedViewController.view.centerXAnchor),
            topBarView.topAnchor.constraint(equalTo: presentedViewController.view.topAnchor, constant: -16),
            topBarView.widthAnchor.constraint(equalToConstant: topBarView.frame.width),
            topBarView.heightAnchor.constraint(equalToConstant: topBarView.frame.height)
        ])
        
    }
    
    //Transitionに関するoverride method
    ///presentation transitionが開始するとき
    override func presentationTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.overlayView.isActive = true
        }, completion: nil)
    }
    
    ///presentation transitionが終了したとき
    override func presentationTransitionDidEnd(_ completed: Bool) {
        //完了していない場合、overlayViewを取り除く
        if !completed {
            overlayView.removeFromSuperview()
        }
    }
    
    ///dismiss transitionが開始するとき
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.overlayView.isActive = false
        }, completion: nil)
    }
    
    ///dismiss transitionが終了したとき
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        //完了したらoverlayViewを取り除く
        if completed {
            overlayView.removeFromSuperview()
        }
    }
    
}
