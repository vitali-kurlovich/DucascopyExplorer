//
//  AssetPickerViewController.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

import UIKit

final class AssetPickerViewController: UINavigationController {
    var selectAssetHandler: ((Asset, AssetPickerViewController) -> Void)?

    init() {
        let controller = AssetPickerCollectionViewController()

        super.init(rootViewController: controller)

        controller.selectAssetHandler = { [weak self] asset in
            self?.onSelect(asset: asset)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private
extension AssetPickerViewController {
    func onSelect(asset: Asset) {
        selectAssetHandler?(asset, self)
    }
}
