//
//  CollapsableHeaderViewController.swift
//  CollapsableTableViewHeader
//
//  Created by Rubens Pessoa on 27/02/18.
//  Copyright © 2018 Rubens Pessoa. All rights reserved.
//

import UIKit
import SnapKit

class CollapsableHeaderViewController: UIViewController {
  
  var headerView: UIView = UIView()
  var tableView: UITableView = UITableView()
  
  let minHeaderTopOffset: CGFloat = -44.0
  let maxHeaderTopOffset: CGFloat = 0.0
  var headerViewTopConstraintValue: CGFloat = 0.0
  var previousScrollOffset: CGFloat = 0.0
  
    override func viewDidLoad() {
      super.viewDidLoad()

      tableView.delegate = self
      tableView.dataSource = self
      headerView.backgroundColor = UIColor.red
      
      view.addSubview(headerView)
      
      headerView.snp.makeConstraints { (make) in
        make.top.equalTo(view.snp.top)
        make.left.equalTo(view.snp.left)
        make.right.equalTo(view.snp.right)
        make.height.equalTo(88)
      }
      
      view.addSubview(tableView)
      
      tableView.snp.makeConstraints { (make) in
        make.top.equalTo(headerView.snp.bottom)
        make.left.equalTo(view.snp.left)
        make.right.equalTo(view.snp.right)
        make.bottom.equalTo(view.snp.bottom)
      }
    }
}

extension CollapsableHeaderViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 40
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.textLabel!.text = "Cell \(indexPath.row)"
    return cell
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let absoluteTop: CGFloat = 0
    let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
    
    let scrollDiff = scrollView.contentOffset.y - previousScrollOffset
    
    let isScrollingUp = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
    let isScrollingDown = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
    
    let dy = headerViewTopConstraintValue - scrollDiff

    var newTopConstraint = headerViewTopConstraintValue

    if isScrollingDown {
      newTopConstraint = min(maxHeaderTopOffset, dy)
    } else if isScrollingUp {
      newTopConstraint = max(minHeaderTopOffset, dy)
    }

    if newTopConstraint != headerViewTopConstraintValue {
      headerView.snp.updateConstraints({ (make) in
        make.top.equalTo(newTopConstraint)
      })
      
      headerViewTopConstraintValue = newTopConstraint
      scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: previousScrollOffset), animated: false)
    }

    self.previousScrollOffset = scrollView.contentOffset.y
  }
  
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      scrollViewDidStopScrolling()
    }
  
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
      if !decelerate {
        scrollViewDidStopScrolling()
      }
    }
  
    private func collapseHeader() {
      headerView.snp.remakeConstraints({ (make) in
        make.top.equalTo(minHeaderTopOffset)
        make.left.equalTo(view.snp.left)
        make.right.equalTo(view.snp.right)
        make.height.equalTo(88)
      })
  
      UIView.animate(withDuration: 0.2, animations: {
        self.view.layoutIfNeeded()
      })
    }
  
    private func expandHeader() {
      headerView.snp.remakeConstraints({ (make) in
        make.top.equalTo(maxHeaderTopOffset)
        make.left.equalTo(view.snp.left)
        make.right.equalTo(view.snp.right)
        make.height.equalTo(88)
      })
  
      UIView.animate(withDuration: 0.2, animations: {
        self.view.layoutIfNeeded()
      })
    }
  
    private func scrollViewDidStopScrolling() {
      let range = abs(maxHeaderTopOffset - minHeaderTopOffset)
      let midPoint = minHeaderTopOffset + (range / 2)
  
      if headerViewTopConstraintValue > midPoint {
        expandHeader()
      } else {
        collapseHeader()
      }
    }
}
