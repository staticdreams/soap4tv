//
//  EpisodeCollectionViewCell.swift
//  Soap4TV
//
//  Created by Peter on 05/12/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class EpisodeCollectionViewCell: UICollectionViewCell, EpisodeDelegate {
    
	@IBOutlet weak var screenshot: UIImageView!
	@IBOutlet weak var episodeTitle: UILabel!
	@IBOutlet weak var overlay: UIView!

    internal func prepareWithEpisode(episode: Episode) {
        let prefix = String(episode.episode!)+". "
        let originalTitle = episode.title_en?.decodeEntity()
        self.episodeTitle.text = originalTitle!.hasPrefix(prefix) ? originalTitle! : prefix + originalTitle!
        self.overlay.hidden = episode.watched == true ? false : true
        self.screenshot.layer.borderColor = UIColor.whiteColor().CGColor
        self.screenshot.layer.borderWidth = episode.watched == true ? 0 : 3
        let screenshot = UIImage(named: "default-screenshot")
        if (episode.screenshotUrl?.absoluteString.count > 0) {
            self.screenshot.af_setImageWithURL(episode.screenshotUrl!)
        }
        else {
            self.screenshot.image = screenshot
        }
        episode.addDelegate(self)
    }

    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if (self == context.nextFocusedView) {
            UIView.animateWithDuration(0.4,
                    delay: 0,
                    usingSpringWithDamping: 0.4,
                    initialSpringVelocity: 3,
                    options: .CurveEaseIn,
                    animations: {
                           self.transform = CGAffineTransformMakeScale(1.2,1.2)
                    },
                    completion:nil)
        }
        else if (self == context.previouslyFocusedView) {
            UIView.animateWithDuration(0.1, animations: {
                self.transform = CGAffineTransformIdentity
            })
        }
    }

    func didUpdateImage(imageUrl: NSURL) {
        let screenshot = UIImage(named: "default-screenshot")
        self.screenshot.af_setImageWithURL(imageUrl, placeholderImage: screenshot, imageTransition: .CrossDissolve(0.2))
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        let screenshot = UIImage(named: "default-screenshot")
        self.screenshot.image = screenshot
    }
}
