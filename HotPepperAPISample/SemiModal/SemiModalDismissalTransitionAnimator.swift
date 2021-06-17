//
//  SemiModalDismissalTransitionAnimator.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/17.
//

import UIKit

//dismissアニメーション遷移を実装するオブジェクト
final class SemiModalDismissalTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    ///アニメーションの時間
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    ///dismiss遷移アニメーションを実装する
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        //viewを下にスライドさせるアニメーション
                        guard let fromView = transitionContext.view(forKey: .from) else { return }
                        fromView.center.y = UIScreen.main.bounds.size.height + fromView.bounds.size.height / 2
                       },
                       completion: { _ in
                        //UIKitにアニメーションの終了を伝える必要がある
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                       })
    }
}
